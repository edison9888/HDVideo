//
//  NetworkController.m
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NetworkController.h"
#import "DataController.h"
#import "SynthesizeSingleton.h"
#import "Constants.h"

@implementation NetworkController

SYNTHESIZE_SINGLETON_FOR_CLASS(NetworkController);

@synthesize videoItems, queue, videoFeedData, videoFeedConnection;
@synthesize currentKey = _currentKey;

- (void)dealloc
{
    [videoItems release];
    [queue release];
    [videoFeedConnection release];
    [videoFeedData release];

    [_currentKey release];    

    [super dealloc];
}

- (void)startLoadFeed:(NSString *)feedUrl forKey:(NSString *)key
{
    [self.videoFeedConnection cancel];

    _currentKey = [key copy];
    
    // Initialize the array of app records and pass a reference to that list to our root view controller
    self.videoItems = [NSMutableArray array];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedUrl]];
    self.videoFeedConnection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development
    // If the URL is more dynamic, then you should implement a more flexible validation technique, and
    // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
    //
    NSAssert(self.videoFeedConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


#pragma mark - NSURLConnection
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法获取视频信息"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.videoFeedData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [videoFeedData appendData:data];  // append incoming data
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
															 forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
        [self handleError:noConnectionError];
    }
	else
	{
        // otherwise handle the error generically
        [self handleError:error];
    }
    
    self.videoFeedConnection = nil;   // release our connection
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.videoFeedConnection = nil;   // release our connection
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    // create the queue to run our ParseOperation
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    
    // create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
    // "ownership of appListData has been transferred to the parse operation and should no longer be
    // referenced in this thread.
    //
    ParseOperation *parser = [[ParseOperation alloc] initWithData:videoFeedData delegate:self];
    
    [queue addOperation:parser]; // this will start the "ParseOperation"
    
    [parser release];
    
    // ownership of appListData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    self.videoFeedData = nil;
}

#pragma mark - ParseOperationDelegate
- (void)handleLoadedVideos:(NSArray *)loadedVideos
{
    [self.videoItems addObjectsFromArray:loadedVideos];
    
    // tell our interested view controller reload its data, now that parsing has completed
    [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_FEED_DOWNLOAD_COMPLETED_NOTIFICATION object:loadedVideos];
}

// -------------------------------------------------------------------------------
//	didFinishParsing:appList
// -------------------------------------------------------------------------------
- (void)didFinishParsing:(NSArray *)videoList forPageIndex:(NSUInteger)pageIndex fromAll:(NSUInteger)totalPageCount;
{
    NSArray *array = [NSArray arrayWithObjects:videoList,
                      [NSNumber numberWithInt:pageIndex],
                      [NSNumber numberWithInt:totalPageCount],
                      nil];
    [self performSelectorOnMainThread:@selector(handleLoadedVideos:) withObject:array waitUntilDone:NO];
    
    self.queue = nil;   // we are finished with the queue and our ParseOperation
}

- (void)parseErrorOccurred:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(handleError:) withObject:error waitUntilDone:NO];
}

@end