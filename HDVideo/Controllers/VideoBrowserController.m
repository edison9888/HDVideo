//
//  VideoBrowserController.m
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoBrowserController.h"
#import "ParseOperation.h"
#import "NetworkController.h"
#import "Constants.h"


#define LOCATION_X 50
#define LOCATION_Y 30
#define ITEM_BORDER 0
#define ITEM_SPACING_H 37
#define ITEM_SPACING_V 50
#define ITEM_WIDTH 155
#define ITEM_HEIGHT 228
#define ITEM_COUNT_PER_ROW 5


@implementation VideoBrowserController

@synthesize feedKey = _feedKey;
@synthesize videoItems = _videoItems;
@synthesize posterDownloadsInProgress = _posterDownloadsInProgress;


- (id)init
{
    if ((self = [super init]))
    {
        self.posterDownloadsInProgress = [NSMutableDictionary dictionary];
        _recycledVideos = [[NSMutableSet alloc] init];
        _visibleVideos = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_feedKey release];
    [_scrollView release];
    [_recycledVideos release];
    [_visibleVideos release];
    
    [_videoItems release];
    [_posterDownloadsInProgress release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    NSArray *allDownloads = [_posterDownloadsInProgress allValues];
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
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollView];
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *allDownloads = [self.posterDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self tileVideos];
}

#pragma mark - Deferred image loading (UIScrollViewDelegate)

- (void)downloadCompleted:(NSNotification *)notification
{
    NSString *currentKey = [[NetworkController sharedNetworkController] currentKey];
    if ([self.feedKey isEqualToString:currentKey])
    {
        self.videoItems = [notification object];
    }
}

- (void)startPosterDownload:(VideoItem *)videoItem forIndex:(NSUInteger)index
{
    PosterDownloader *posterDownloader = [_posterDownloadsInProgress objectForKey:[NSNumber numberWithInt:index]];
    if (posterDownloader == nil) 
    {
        posterDownloader = [[PosterDownloader alloc] init];
        posterDownloader.videoItem = videoItem;
        posterDownloader.indexInVideoBrowserView = index;
        posterDownloader.delegate = self;
        [_posterDownloadsInProgress setObject:posterDownloader forKey:[NSNumber numberWithInt:index]];
        [posterDownloader startDownload];
        [posterDownloader release];   
    }
    else{
        [posterDownloader startDownload];
    }
}

// called by our PosterDownloader when a poster is ready to be displayed
- (void)posterImageDidLoad:(NSUInteger)index;
{
    PosterDownloader *posterDownloader = [_posterDownloadsInProgress objectForKey:[NSNumber numberWithInt:index]];
    if (posterDownloader != nil)
    {
        for (VideoItemView *video in _visibleVideos) {
            if (video.index == index) {
                video.source = posterDownloader.videoItem;
            }
        }
    }
}

#pragma mark - self messages
- (UIScrollView *)scrollView
{
    return _scrollView;
}

- (void)setVideoItems:(NSArray *)videoItems
{
    if (_videoItems != videoItems)
    {
        [_videoItems release];
        _videoItems = [videoItems retain];
        
        // 
        [_recycledVideos removeAllObjects];
        [_visibleVideos removeAllObjects];
        [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        [_scrollView setContentOffset:CGPointMake(0, 0)];
        int rows = [_videoItems count] / ITEM_COUNT_PER_ROW;
        if (([_videoItems count] % ITEM_COUNT_PER_ROW) > 0)
            rows += 1;
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width,
                                             LOCATION_Y + (ITEM_HEIGHT + ITEM_SPACING_V)*rows);
        
        // cancel all posters downloading
        if (self.posterDownloadsInProgress && [self.posterDownloadsInProgress count] > 0){
            // terminate all pending download connections
            NSArray *allDownloads = [self.posterDownloadsInProgress allValues];
            [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
            [_posterDownloadsInProgress removeAllObjects];
        }
        
        [self tileVideos];
        _scrollView.delegate = self;
    }
}

- (void)configVideo:(VideoItemView *)video forIndex:(NSUInteger)index
{
    video.index = index;
    video.source = [_videoItems objectAtIndex:index];
    video.frame = [self frameForVideoAtIndex:index];
}

- (CGRect)frameForVideoAtIndex:(NSUInteger)index
{
    int rowIndex = index / ITEM_COUNT_PER_ROW;
    int colIndex = index % ITEM_COUNT_PER_ROW;
    CGRect rect = CGRectMake(LOCATION_X + colIndex * (ITEM_WIDTH+ITEM_SPACING_H),
                             LOCATION_Y + rowIndex * (ITEM_HEIGHT+ITEM_SPACING_V),
                             ITEM_WIDTH, ITEM_HEIGHT);
    return rect;
}

- (BOOL)isDisplayingVideoForIndex:(NSUInteger)index
{
    BOOL found = NO;
    for (VideoItemView *video in _visibleVideos) {
        if (video.index == index) {
            found = YES;
            break;
        }
    }
    return found;
}

- (VideoItemView *)dequeueRecycledVideo
{
    VideoItemView *video = [_recycledVideos anyObject];
    if (video) {
        [[video retain] autorelease];
        [_recycledVideos removeObject:video];
    }
    return video;
}

- (void)tileVideos
{
    // calculate which videos should now be visible
    CGRect visibleBounds    = _scrollView.bounds;
    int firstRowIndex       = floorf((CGRectGetMinY(visibleBounds)-LOCATION_Y) / (ITEM_HEIGHT+ITEM_SPACING_V));
    int lastRowIndex        = floorf((CGRectGetMaxY(visibleBounds)-LOCATION_Y-1) / (ITEM_HEIGHT+ITEM_SPACING_V));
    int firstVideoIndex     = MAX(firstRowIndex, 0) * ITEM_COUNT_PER_ROW;
    int lastVideoIndex      = MIN((lastRowIndex+1) * ITEM_COUNT_PER_ROW, [self.videoItems count]-1);
    
    // recycle no longer needed videos
    for (VideoItemView *video in _visibleVideos) {
        if (video.index < firstVideoIndex || video.index > lastRowIndex) {
            [_recycledVideos addObject:video];
            [video removeFromSuperview];
        }
    }
    [_visibleVideos minusSet:_recycledVideos];
    
    // add missing videos
    for (int index=firstVideoIndex; index<=lastVideoIndex; index++) {
        if (![self isDisplayingVideoForIndex:index]) {
            VideoItemView *video = [self dequeueRecycledVideo];
            if (video == nil) {
                video = [[[VideoItemView alloc] init] autorelease];
            }
            [self startPosterDownload:[_videoItems objectAtIndex:index] forIndex:index];
            [self configVideo:video forIndex:index];
            [_scrollView addSubview:video];
            [_visibleVideos addObject:video];
        }
    }
}

@end