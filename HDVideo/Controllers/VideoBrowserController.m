//
//  VideoBrowserController.m
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
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
#define ITEM_COUNT_PER_ROW 5

#define REFRESH_HEADER_HEIGHT 52.0f



@interface VideoBrowserController ()
@property (nonatomic) NSUInteger itemHeight;
@property (nonatomic, readonly) NSMutableArray *subContentViews;

- (void)setupPullToRefresh;
@end

@implementation VideoBrowserController

@synthesize feedKey = _feedKey;
@synthesize feedUrl = _feedUrl;
@synthesize videoItems = _videoItems;
@synthesize posterDownloadsInProgress = _posterDownloadsInProgress;
@synthesize isEpisode = _isEpisode;
@synthesize itemHeight = _itemHeight;

@synthesize currentPageIndex, totalPageCount;
@synthesize headerView, headerLabel, headerArrow, headerSpinner;
@synthesize textPull, textLoading, textRelease;


- (id)init
{
    if ((self = [super init]))
    {
        self.posterDownloadsInProgress = [NSMutableDictionary dictionary];
        _recycledVideos = [[NSMutableSet alloc] init];
        _visibleVideos = [[NSMutableSet alloc] init];
        
        self.textPull = @"下拉可以翻页";
        self.textRelease = @"松开即可翻页";
        self.textLoading = @"正在载入...";
    }
    return self;
}

- (void)dealloc
{
    [self cancelDownloading];
    
    [_feedKey release];
    [_feedUrl release];
    [_scrollView release];
    [_recycledVideos release];
    [_visibleVideos release];
    
    [_videoItems release];
    [_posterDownloadsInProgress release];
    
    [headerArrow release];
    [headerLabel release];
    [headerSpinner release];
    [headerView release];
    
    [textPull release];
    [textLoading release];
    [textRelease release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self cancelDownloading];
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
    
    [self setupPullToRefresh];
    
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
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_isLoading)
        return;
    _isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.scrollView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (_isDragging && scrollView.contentOffset.y < 0) {
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
            headerLabel.text = self.textRelease;
            [headerArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        }
        else {
            headerLabel.text = self.textPull;
            [headerArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
    else if (scrollView.contentOffset.y > 0) {
        NSArray *allDownloads = [self.posterDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
        [self tileVideos];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_isLoading)
        return;
    _isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        [self setupPageUrl:self.currentPageIndex + 1];
        [self startLoading];
    }
}

#pragma mark - Deferred image loading (UIScrollViewDelegate)

- (void)downloadCompleted:(NSNotification *)notification
{
    NSString *currentKey = [[NetworkController sharedNetworkController] currentKey];
    if ([self.feedKey isEqualToString:currentKey])
    {
        self.videoItems = [[notification object] objectAtIndex:0];
        self.currentPageIndex = [[[notification object] objectAtIndex:1] intValue];
        self.totalPageCount = [[[notification object] objectAtIndex:2] intValue];
    }
    
    [self stopLoading];
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
        posterDownloader = nil;
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

- (NSUInteger)itemHeight
{
    if (_isEpisode)
        return 138;
    else
        return 228;
}

- (void)setVideoItems:(NSArray *)videoItems
{
    if (_videoItems != videoItems)
    {
        [_videoItems release];
        _videoItems = [videoItems retain];
        
        if ([videoItems count] > 0) {
            int rows = [_videoItems count] / ITEM_COUNT_PER_ROW;
            if (([_videoItems count] % ITEM_COUNT_PER_ROW) > 0)
                rows += 1;
            _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width,
                                                 LOCATION_Y + (self.itemHeight + ITEM_SPACING_V)*rows);
            
            [self tileVideos];
        }
    }
}

- (NSMutableArray *)subContentViews
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:_scrollView.subviews];
    [array removeObject:self.headerView];
    return array;
}

- (void)startDownloading
{
    self.videoItems = nil;
    
    // 
    [_recycledVideos removeAllObjects];
    [_visibleVideos removeAllObjects];
    [self.subContentViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [_scrollView setContentOffset:CGPointMake(0, 0)];
    
    [self cancelDownloading];
    self.posterDownloadsInProgress = [NSMutableDictionary dictionary];
    
    _scrollView.delegate = self;
}

- (void)cancelDownloading
{
    // cancel all posters downloading
    if (self.posterDownloadsInProgress && [self.posterDownloadsInProgress count] > 0){
        // terminate all pending download connections
        NSArray *allDownloads = [self.posterDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    }
}

- (void)configVideo:(VideoItemView *)video forIndex:(NSUInteger)index
{
    video.index = index;
    video.isEpisode = self.isEpisode;
    video.source = [_videoItems objectAtIndex:index];
    video.frame = [self frameForVideoAtIndex:index];
}

- (CGRect)frameForVideoAtIndex:(NSUInteger)index
{
    int rowIndex = index / ITEM_COUNT_PER_ROW;
    int colIndex = index % ITEM_COUNT_PER_ROW;
    CGRect rect = CGRectMake(LOCATION_X + colIndex * (ITEM_WIDTH+ITEM_SPACING_H),
                             LOCATION_Y + rowIndex * (self.itemHeight+ITEM_SPACING_V),
                             ITEM_WIDTH, self.itemHeight);
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
    int firstRowIndex       = floorf((CGRectGetMinY(visibleBounds)-LOCATION_Y) / (self.itemHeight+ITEM_SPACING_V));
    int lastRowIndex        = floorf((CGRectGetMaxY(visibleBounds)-LOCATION_Y-1) / (self.itemHeight+ITEM_SPACING_V));
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

- (void)setupPullToRefresh
{
    // setup pull to refresh
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 1024, REFRESH_HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1024, REFRESH_HEADER_HEIGHT)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:15.0];
    headerLabel.textColor = [UIColor darkGrayColor];
    headerLabel.textAlignment = UITextAlignmentCenter;
    
    headerArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-up"]];
    headerArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                   (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                   27, 44);
    
    headerSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    headerSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    headerSpinner.hidesWhenStopped = YES;
    
    [headerView addSubview:headerLabel];
    [headerView addSubview:headerArrow];
    [headerView addSubview:headerSpinner];
    [self.scrollView addSubview:headerView];
}

- (void)startLoading
{
    [self startDownloading];
    _isLoading = YES;
    
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.scrollView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    headerLabel.text = self.textLoading;
    headerArrow.hidden = YES;
    [headerSpinner startAnimating];
    [UIView commitAnimations];
    
    [[NetworkController sharedNetworkController] startLoadFeed:self.feedUrl forKey:self.feedKey];
}

- (void)stopLoading
{
    _isLoading = NO;
    
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.scrollView.contentInset = UIEdgeInsetsZero;
    [headerArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    [UIView commitAnimations];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    headerLabel.text = self.textPull;
    headerArrow.hidden = NO;
    [headerSpinner stopAnimating];
}

- (void)setupPageUrl:(NSUInteger)pageIndex;
{
    NSRange range = [self.feedUrl rangeOfString:@"page="];
    if (range.length > 0) {
        NSString *prefix = [self.feedUrl substringToIndex:range.location-1];
        NSString *sufix = [self.feedUrl substringFromIndex:range.location+5];
        range = [sufix rangeOfString:@"&"];
        if (range.length > 0)
            sufix = [sufix substringFromIndex:range.location];
        else
            sufix = @"";
        
        self.feedUrl = [NSString stringWithFormat:@"%@&page=%i%@", prefix, pageIndex, sufix];
    }
    else {
        self.feedUrl = [NSString stringWithFormat:@"%@&page=%i", self.feedUrl, pageIndex];
    }
}

@end