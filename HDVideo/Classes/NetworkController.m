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

@synthesize feedItems, feedQueue, feedData, feedConnection;
@synthesize currentKey = _currentKey;

@synthesize suggestionItems, suggestionQueue, suggestionData, suggestionConnection;
@synthesize searchItems, searchQueue, searchData, searchConnection;

- (void)dealloc
{
    [feedItems release];
    [feedQueue release];
    [feedConnection release];
    [feedData release];
    [_currentKey release];
    
    [suggestionItems release];
    [suggestionQueue release];
    [suggestionConnection release];
    [suggestionData release];

    [super dealloc];
}

- (void)startLoadFeed:(NSString *)url forKey:(NSString *)key
{
    [self.feedConnection cancel];

    if (_currentKey != key) {
        [_currentKey release];
        _currentKey = [key copy];
    }
    
    // Initialize the array of app records and pass a reference to that list to our root view controller
    self.feedItems = [NSMutableArray array];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    self.feedConnection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development
    // If the URL is more dynamic, then you should implement a more flexible validation technique, and
    // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
    //
    NSAssert(self.feedConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)startLoadSuggestion:(NSString *)url
{
    [self.suggestionConnection cancel];
    
    // Initialize the array of app records and pass a reference to that list to our root view controller
    self.suggestionItems = [NSMutableArray array];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    self.suggestionConnection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)startLoadSearchResult:(NSString *)url
{
    [self.searchConnection cancel];
    
    // Initialize the array of app records and pass a reference to that list to our root view controller
    self.searchItems = [NSMutableArray array];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    self.searchConnection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - NSURLConnection
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONNECTION_ERROR", nil)
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
    if (connection == feedConnection) {
        self.feedData = [NSMutableData data];
    }
    else if (connection == suggestionConnection) {
        self.suggestionData = [NSMutableData data];
    }
    else if (connection == searchConnection) {
        self.searchData = [NSMutableData data];
    }
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == feedConnection) {
        [feedData appendData:data];
    }
    else if (connection == suggestionConnection) {
        [suggestionData appendData:data];
    }
    else if (connection == searchConnection) {
        [searchData appendData:data];
    }
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
    
    if (connection == feedConnection) {
        self.feedConnection = nil;
    }
    else if (connection == suggestionConnection) {
        self.suggestionConnection = nil;
    }
    else if (connection == searchConnection) {
        self.searchConnection = nil;
    }
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if (connection == feedConnection) {
        self.feedConnection = nil;
        self.feedQueue = [[[NSOperationQueue alloc] init] autorelease];

        ParseFeedOperation *parser = [[ParseFeedOperation alloc] initWithData:feedData delegate:self];
        [feedQueue addOperation:parser]; // this will start the "ParseOperation"
        [parser release];

        self.feedData = nil;
    }
    else if (connection == suggestionConnection) {
        self.suggestionConnection = nil;
        self.suggestionQueue = [[[NSOperationQueue alloc] init] autorelease];
        
        ParseSuggestionOperation *parser = [[ParseSuggestionOperation alloc] initWithData:suggestionData delegate:self];
        [suggestionQueue addOperation:parser]; // this will start the "ParseOperation"
        [parser release];
        
        self.suggestionData = nil;
    }
    else if (connection == searchConnection) {
        self.searchConnection = nil;
        self.searchQueue = [[[NSOperationQueue alloc] init] autorelease];
        
        ParseSearchOperation *parser = [[ParseSearchOperation alloc] initWithData:searchData delegate:self];
        [searchQueue addOperation:parser]; // this will start the "ParseOperation"
        [parser release];
        
        self.searchData = nil;
    }
}

#pragma mark - ParseFeedDelegate, ParseSuggestionDelegate
- (void)handleLoadedVideos:(NSArray *)loadedVideos
{
    [self.feedItems addObjectsFromArray:loadedVideos];
    [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_FEED_DOWNLOAD_COMPLETED_NOTIFICATION object:loadedVideos];
}

- (void)handleLoadedSuggestions:(NSArray *)loadedSuggestions
{
    [self.suggestionItems addObjectsFromArray:loadedSuggestions];
    [[NSNotificationCenter defaultCenter] postNotificationName:SUGGESTION_COMPLETED_NOTIFICATION object:loadedSuggestions];
}

- (void)handleLoadedSearchResults:(NSArray *)loadedSearchResults
{
    [self.searchItems addObjectsFromArray:loadedSearchResults];
    [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_RESULT_DOWNLOAD_COMPLETED_NOTIFICATION object:loadedSearchResults];
}

- (void)didFinishParsing:(NSArray *)videoList forPageIndex:(NSUInteger)pageIndex fromAll:(NSUInteger)totalPageCount
{
    NSArray *array = [NSArray arrayWithObjects:videoList,
                      [NSNumber numberWithInt:pageIndex],
                      [NSNumber numberWithInt:totalPageCount],
                      nil];
    [self performSelectorOnMainThread:@selector(handleLoadedVideos:) withObject:array waitUntilDone:NO];
    self.feedQueue = nil;   // we are finished with the queue and our ParseOperation
}

- (void)didFinishParsingSuggestion:(NSArray *)suggestions
{
    [self performSelectorOnMainThread:@selector(handleLoadedSuggestions:) withObject:suggestions waitUntilDone:NO];
    self.suggestionQueue = nil;
}

- (void)didFinishParsingSearchResults:(NSArray *)searchResults forPageIndex:(NSUInteger)pageIndex fromAll:(NSUInteger)totalPageCount
{
    NSArray *array = [NSArray arrayWithObjects:searchResults,
                      [NSNumber numberWithInt:pageIndex],
                      [NSNumber numberWithInt:totalPageCount],
                      nil];
    [self performSelectorOnMainThread:@selector(handleLoadedSearchResults:) withObject:array waitUntilDone:NO];
    self.searchQueue = nil;
}

- (void)parseErrorOccurred:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(handleError:) withObject:error waitUntilDone:NO];
}

@end