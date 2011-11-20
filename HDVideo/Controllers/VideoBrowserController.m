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

@synthesize feedKey = _feedKey;
@synthesize browserView = _browserView;

- (void)dealloc
{
    [_feedKey release];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    UIView *background = [[UIView alloc] initWithFrame:rect];
    background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpg"]];
    self.view = background;
    [background release];
    
    _browserView = [[VideoBrowserView alloc] initWithFrame:self.view.bounds];
    _browserView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _browserView.controller = self;
    _browserView.backgroundColor = [UIColor clearColor];
    _browserView.posterDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.view addSubview:_browserView];
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
    NSString *currentKey = [[NetworkController sharedNetworkController] currentKey];
    if ([self.feedKey isEqualToString:currentKey])
    {
        _browserView.videoItems = [notification object];
    }
}

@end