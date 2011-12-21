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
#import "DataController.h"
#import "VideoPlayerController.h"
#import "HDVideoAppDelegate.h"


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
@synthesize footerView, footerLabel, footerArrow, footerSpinner;
@synthesize textPullHeader, textPullFooter, textLoading, textRelease, textReachFirstPage, textReachLastPage;


- (id)init
{
    if ((self = [super init]))
    {
        self.posterDownloadsInProgress = [NSMutableDictionary dictionary];
        _recycledVideos = [[NSMutableSet alloc] init];
        _visibleVideos = [[NSMutableSet alloc] init];
        
        self.textPullHeader = @"下拉可以翻页";
        self.textPullFooter = @"上拉可以翻页";
        self.textRelease = @"松开即可翻页";
        self.textLoading = @"正在载入...";
        self.textReachFirstPage = @"已到第一页";
        self.textReachLastPage = @"已到最后一页";
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
    
    [footerArrow release];
    [footerLabel release];
    [footerSpinner release];
    [footerView release];
    
    [textPullHeader release];
    [textPullFooter release];
    [textLoading release];
    [textRelease release];
    [textReachFirstPage release];
    [textReachLastPage release];
    
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
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_scrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIViewController *topController = [self.navigationController.viewControllers objectAtIndex:0];
    self.navigationItem.rightBarButtonItem = topController.navigationItem.rightBarButtonItem;
    
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
    if (_isLoadingNext || _isLoadingPrevious)
        return;
    _isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isLoadingPrevious || _isLoadingNext) {
        if (_isLoadingPrevious) {
            if (scrollView.contentOffset.y > 0)
                self.scrollView.contentInset = UIEdgeInsetsZero;
            else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
                self.scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        }
        else {
            if (scrollView.contentSize.height - scrollView.contentOffset.y > self.view.frame.size.height)
                self.scrollView.contentInset = UIEdgeInsetsZero;
            else if (scrollView.contentSize.height + REFRESH_HEADER_HEIGHT - scrollView.contentOffset.y <= self.view.frame.size.height)
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_HEADER_HEIGHT, 0);
        }
    }
    else if (_isDragging) {
        if (scrollView.contentOffset.y < 0) {
            // Update the arrow direction and label
            [UIView beginAnimations:nil context:NULL];
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                headerLabel.text = (self.currentPageIndex==1 ? self.textReachFirstPage : self.textRelease);
                [headerArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            }
            else { // User is scrolling somewhere within the header
                headerLabel.text = (self.currentPageIndex==1 ? self.textReachFirstPage : self.textPullHeader);
                [headerArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
            [UIView commitAnimations];
        }
        else if (scrollView.contentSize.height - scrollView.contentOffset.y < self.view.frame.size.height) {
            // Update the arrow direction and label
            [UIView beginAnimations:nil context:NULL];
            if (scrollView.contentSize.height + REFRESH_HEADER_HEIGHT - scrollView.contentOffset.y < self.view.frame.size.height) {
                footerLabel.text = (self.currentPageIndex==self.totalPageCount ? self.textReachLastPage : self.textRelease);
                [footerArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            }
            else {
                footerLabel.text = (self.currentPageIndex==self.totalPageCount ? self.textReachLastPage : self.textPullFooter);
                [footerArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
            [UIView commitAnimations];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_isLoadingNext || _isLoadingPrevious)
        return;
    _isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        if (self.currentPageIndex > 1) {
            [self setupPageUrl:self.currentPageIndex - 1];
            [self startLoading:YES];
        }
        else {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            self.scrollView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
            [UIView commitAnimations];
                        
            [self stopLoading:YES withNotification:nil];
        }
    }
    else if (scrollView.contentOffset.y > scrollView.contentSize.height+REFRESH_HEADER_HEIGHT-self.view.frame.size.height) {
        if (self.currentPageIndex < self.totalPageCount) {
            [self setupPageUrl:self.currentPageIndex + 1];
            [self startLoading:NO];
        }
        else {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_HEADER_HEIGHT, 0);
            [UIView commitAnimations];
            
            [self stopLoading:NO withNotification:nil];
        }
    }
}

#pragma mark - Deferred image loading (UIScrollViewDelegate)

- (void)downloadCompleted:(NSNotification *)notification
{
    NSString *currentKey = [[NetworkController sharedNetworkController] currentKey];
    if ([self.feedKey isEqualToString:currentKey])
    {
        if (_isLoadingPrevious)
            [self stopLoading:YES withNotification:notification];
        else
            [self stopLoading:NO withNotification:notification];
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
        [posterDownloader startDownload:!_isEpisode];
        [posterDownloader release];
        posterDownloader = nil;
    }
    else{
        [posterDownloader startDownload:!_isEpisode];
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
            
            float height = LOCATION_Y + (self.itemHeight + ITEM_SPACING_V)*rows;
            // frame height + 1 to enable scrolling
            height = MAX(height, CGRectGetHeight(self.scrollView.frame)+1);
            _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, height);
            footerView.frame = CGRectMake(0, _scrollView.contentSize.height, 1024, REFRESH_HEADER_HEIGHT);
            
            [self tileVideos];
        }
    }
}

- (NSMutableArray *)subContentViews
{
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in _scrollView.subviews) {
        if ([view isKindOfClass:[VideoItemView class]])
            [array addObject:view];
    }
    return array;
}

- (void)configVideo:(VideoItemView *)video forIndex:(NSUInteger)index
{
    video.delegate = self;
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
//    int lastVideoIndex      = MIN((lastRowIndex+1) * ITEM_COUNT_PER_ROW, [self.videoItems count])-1;
    int lastVideoIndex      = [self.videoItems count] - 1;
    
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
    // header
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, -REFRESH_HEADER_HEIGHT, 1024, REFRESH_HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.2];
    
    headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:15.0];
    headerLabel.textColor = [UIColor darkGrayColor];
    headerLabel.textAlignment = UITextAlignmentCenter;
    
    headerArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-down"]];
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
    
    // footer
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), 1024, REFRESH_HEADER_HEIGHT)];
    footerView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.2];
    
    footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1024, REFRESH_HEADER_HEIGHT)];
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.font = [UIFont boldSystemFontOfSize:15.0];
    footerLabel.textColor = [UIColor darkGrayColor];
    footerLabel.textAlignment = UITextAlignmentCenter;
    
    footerArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-up"]];
    footerArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                   (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                   27, 44);
    
    footerSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    footerSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    footerSpinner.hidesWhenStopped = YES;
    
    [footerView addSubview:footerLabel];
    [footerView addSubview:footerArrow];
    [footerView addSubview:footerSpinner];
    [self.scrollView addSubview:footerView];
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

- (void)startLoading:(BOOL)isHeader
{
    if (headerView == nil)
        [self setupPullToRefresh];

    [self startDownloading];
    if (isHeader) {
        _isLoadingPrevious = YES;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.scrollView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        headerLabel.text = self.textLoading;
        headerArrow.hidden = YES;
        [headerSpinner startAnimating];
        [UIView commitAnimations];
    }
    else {
        _isLoadingNext = YES;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_HEADER_HEIGHT, 0);
        footerLabel.text = self.textLoading;
        footerArrow.hidden = YES;
        [footerSpinner startAnimating];
        [UIView commitAnimations];
    }
    
    [[NetworkController sharedNetworkController] startLoadFeed:self.feedUrl forKey:self.feedKey];
}

- (void)initLoading
{
    if (headerView == nil)
        [self setupPullToRefresh];
    
    [self startDownloading];
    _isLoadingNext = YES;
    footerView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)-REFRESH_HEADER_HEIGHT, 1024, REFRESH_HEADER_HEIGHT);
    footerLabel.text = self.textLoading;
    footerArrow.hidden = YES;
    [footerSpinner startAnimating];
    [UIView commitAnimations];
    
    [[NetworkController sharedNetworkController] startLoadFeed:self.feedUrl forKey:self.feedKey];
}

- (void)stopLoading:(BOOL)isHeader withNotification:(NSNotification *)notification
{
    [_scrollView setContentOffset:CGPointMake(0, 0)];
    
    [UIView animateWithDuration:.2
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.scrollView.contentInset = UIEdgeInsetsZero;
                         if (_isLoadingPrevious)
                             [headerArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
                         else
                             [footerArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
                     }
                     completion:^(BOOL finished){
                         if (_isLoadingPrevious) {
                             _isLoadingPrevious = NO;
                             
                             headerLabel.text = self.textPullHeader;
                             headerArrow.hidden = NO;
                             [headerSpinner stopAnimating];
                         }
                         else {
                             _isLoadingNext = NO;
                             
                             footerLabel.text = self.textPullFooter;
                             footerArrow.hidden = NO;
                             [footerSpinner stopAnimating];
                         }
                         
                         if (notification != nil) {
                             self.videoItems = [[notification object] objectAtIndex:0];
                             self.currentPageIndex = [[[notification object] objectAtIndex:1] intValue];
                             self.totalPageCount = [[[notification object] objectAtIndex:2] intValue];
                         }
                     }];
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


#pragma mark - VideoBrowserDelegate
- (void)videoBrowserDidTapwithSource:(VideoItem *)videoItem
{
    HDVideoAppDelegate *del = (HDVideoAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (videoItem.isCategory)
    {
        VideoBrowserController *controller = [[VideoBrowserController alloc] init];
        controller.isEpisode = YES;
        controller.feedKey = videoItem.vid;
        controller.navigationItem.title = videoItem.name;
        [del.navigationController pushViewController:controller animated:YES];
        
        
        // stop UIScrollView from scrolling immediately
        [self.scrollView setContentOffset:self.scrollView.contentOffset animated:NO];
        [controller startDownloading];
        
        NSString *url = [NSString stringWithFormat:@"%@cate=serialitem&serialid=%@",
                         [[DataController sharedDataController] serverAddressBase],
                         videoItem.vid];
        controller.feedUrl = url;
        [controller startLoading:NO];
        [controller release];
    }
    else
    {
        VideoPlayerController *player = [[VideoPlayerController alloc] init];
        player.videoItem = videoItem;
        if (self.isEpisode)
            player.navigationItem.title = [NSString stringWithFormat:@"%@ (%@)", self.navigationItem.title, videoItem.name];
        else
            player.navigationItem.title = videoItem.name;
        [del.navigationController pushViewController:player animated:YES];
        [player release];
    }
}

- (void)videoBrowserAddToFavorite:(VideoItem *)videoItem withPoster:(UIImageView *)poster
{
    if (_isEpisode)
        return;
    
    // add to favorites
    NSLog(@"vid=%@", videoItem.vid);
    [[DataController sharedDataController] addFavorite:videoItem.name videoUrl:videoItem.videoUrl videoId:videoItem.vid];
    
    // animation
    HDVideoAppDelegate *del = (HDVideoAppDelegate *)[UIApplication sharedApplication].delegate;
    UIImageView *posterCopy = [[UIImageView alloc] initWithImage:videoItem.posterImage];
    posterCopy.tag = 1099;
    posterCopy.frame = [del.navigationController.view convertRect:poster.frame fromView:poster.superview];
    [del.navigationController.view addSubview:posterCopy];
    [posterCopy release];
    
    
    CGPoint point = CGPointMake(880, 35);
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:posterCopy.center];
    [movePath addQuadCurveToPoint:point
                     controlPoint:CGPointMake(point.x, posterCopy.center.y)];
    
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = movePath.CGPath;
    moveAnim.removedOnCompletion = YES;
    
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)];
    scaleAnim.removedOnCompletion = YES;
    
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"alpha"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnim.toValue = [NSNumber numberWithFloat:0.1];
    opacityAnim.removedOnCompletion = YES;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:moveAnim, scaleAnim, opacityAnim, nil];
    animGroup.duration = 0.5;
    animGroup.delegate = self;
    [posterCopy.layer addAnimation:animGroup forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    HDVideoAppDelegate *del = (HDVideoAppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *view = [del.navigationController.view viewWithTag:1099];
    [view removeFromSuperview];
}

@end