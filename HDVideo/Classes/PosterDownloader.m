//
//  PosterDownloader.m
//  HDVideo
//
//  Created by Perry on 11-11-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PosterDownloader.h"
#import "UIImage+BitRice.h"

@implementation PosterDownloader

@synthesize videoItem;
@synthesize indexInVideoBrowserView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;

#pragma mark

- (void)dealloc
{
    [videoItem release];
    
    [activeDownload release];
    [imageConnection cancel];
    [imageConnection release];
    
    [super dealloc];
}

- (void)startDownload:(BOOL)isPosterPortrait
{
    _isPortrait = isPosterPortrait;
    
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:videoItem.posterUrl]] delegate:self];
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    UIImage *image = [[[UIImage alloc] initWithData:self.activeDownload] autorelease];
    float w = image.size.width;
    float h = image.size.height;
    if (_isPortrait && w > h) {
        float delta = w - h*0.75f;
        CGRect rect = CGRectMake(delta/2.0, 0, w-delta, h);
        image = [UIImage imageByCropping:image toRect:rect];
    }
    
    self.videoItem.posterImage = image;
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    // call our delegate and tell it that our icon is ready for display
    if (delegate)
        [delegate posterImageDidLoad:self.indexInVideoBrowserView];
}

@end
