//
//  VideoBrowserController.m
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoBrowserController.h"
#import "VideoBrowserView.h"
#import "VideoItem.h"
#import "ParseOperation.h"
#import "NetworkController.h"
#import "Constants.h"


@implementation VideoBrowserController

@synthesize browserView = _browserView;

- (void)dealloc
{
    [_browserView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.browserView.posterDownloadsInProgress allValues];
    for (PosterDownloader *downloader in allDownloads) {
        [downloader performSelector:@selector(cancelDownload)];
    }
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    _browserView = [[VideoBrowserView alloc] init];
    _browserView.controller = self;
    _browserView.backgroundColor = [UIColor clearColor];
    _browserView.posterDownloadsInProgress = [NSMutableDictionary dictionary];
    self.view = _browserView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // start listening for download completion
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadCompleted:)
                                                 name:VIDEO_FEED_DOWNLOAD_COMPLETED_NOTIFICATION
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // no longer wanting to listen for download completion
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VIDEO_FEED_DOWNLOAD_COMPLETED_NOTIFICATION
                                                  object:nil];
}

#pragma mark - Deferred image loading (UIScrollViewDelegate)

- (void)downloadCompleted:(NSNotification *)notification
{
    _browserView.videoItems = [notification object];   // incoming object is an NSArray of AppRecords
}

@end