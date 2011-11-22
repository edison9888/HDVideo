//
//  VideoBrowserView.m
//  HDVideo
//
//  Created by Perry on 11-11-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoBrowserView.h"
#import "VideoItemView.h"
#import "VideoItem.h"

#define LOCATION_X 50
#define LOCATION_Y 30
#define ITEM_BORDER 0
#define ITEM_SPACING_H 37
#define ITEM_SPACING_V 50
#define ITEM_WIDTH 155
#define ITEM_HEIGHT 228


@class PosterDownloader;

@interface VideoBrowserView ()
- (void)startPosterDownload:(VideoItem *)videoItem forIndex:(NSUInteger)index;
@end

@implementation VideoBrowserView

@synthesize controller = _controller;
@synthesize videoItems = _videoItems;
@synthesize posterDownloadsInProgress = _posterDownloadsInProgress;


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.posterDownloadsInProgress = [NSMutableDictionary dictionary]; 
    }
    return self;
}

- (void)setVideoItems:(NSArray *)videoItems
{
    if (_videoItems != videoItems)
    {
        if (self.posterDownloadsInProgress && [self.posterDownloadsInProgress count] > 0){
            // terminate all pending download connections
            NSArray *allDownloads = [self.posterDownloadsInProgress allValues];
            for (PosterDownloader *downloader in allDownloads) {
                [downloader performSelector:@selector(cancelDownload)];
            }
            
            [_posterDownloadsInProgress removeAllObjects];
        }
        
        [_videoItems release];
        _videoItems = [videoItems retain];
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    NSInteger i, j, item_count, old_view_count;
    VideoItem *itemSource;
    VideoItemView *view;
    NSMutableArray *old_views;
    CGFloat x, y;
    CGRect bounds, frame;
    
    item_count = [_videoItems count];
    old_views = _itemViews;
    _itemViews = [[NSMutableArray alloc] init];
    old_view_count = [old_views count];
    bounds = [self bounds];
    
    if (_lastWidth != bounds.size.width)
    {
        _lastWidth = bounds.size.width;
        _itemSize = CGSizeMake (ITEM_WIDTH, ITEM_HEIGHT);
    }
    
    x = LOCATION_X;
    y = LOCATION_Y;
    
    for (i = 0; i < item_count; i++)
    {
        frame = CGRectMake (x, y, _itemSize.width, _itemSize.height);
        itemSource = [_videoItems objectAtIndex:i];
        
        for (j = 0; j < old_view_count; j++)
        {
            view = [old_views objectAtIndex:j];
            if ([[view source] isEqual:itemSource])
            {
                [view setFrame:frame];
                [old_views removeObjectAtIndex:j];
                old_view_count--;
                goto got_view;
            }
        }
        
        view = [[VideoItemView alloc] initWithFrame:frame];
        view.source = itemSource;
        [self startPosterDownload:itemSource forIndex:i];
        view.opaque = YES;
        
        [self addSubview:view];
        [view release];
        
    got_view:
        [_itemViews addObject:view];
        
        x += _itemSize.width + ITEM_SPACING_H;
        if (x + _itemSize.width + ITEM_BORDER > bounds.size.width)
        {
            x = LOCATION_X;
            y += _itemSize.height + ITEM_SPACING_V;
        }
    }
    
    if (x > ITEM_BORDER)
        y += _itemSize.height + ITEM_BORDER;
    
    [self setContentSize:CGSizeMake (bounds.size.width, y)];
    
    for (view in old_views)
        [view removeFromSuperview];
    [old_views release];
}

- (void)dealloc
{
    [_itemViews release];
    [_videoItems release];
    [_posterDownloadsInProgress release];
    
    [super dealloc];
}

#pragma mark - cell image support

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
}

- (void)loadImagesForOnscreenRows
{
    if ([self.videoItems count] > 0)
    {
//        NSArray *visibleIndices = [NSArray arrayWithObjects:0, 1, 2, 3, 4, 5, 6, 7, 8, nil];
//        for (NSNumber *index in visibleIndices)
//        {
//            VideoItem *videoItem = [self.videoItems objectAtIndex:[index intValue]];
//            if (!videoItem.posterImage)
//            {
//                [self startPosterDownload:videoItem forIndex:[index intValue]];
//            }
//        }
    }
}

// called by our PosterDownloader when a poster is ready to be displayed
- (void)posterImageDidLoad:(NSUInteger)index;
{
    PosterDownloader *posterDownloader = [_posterDownloadsInProgress objectForKey:[NSNumber numberWithInt:index]];
    if (posterDownloader != nil)
    {
        VideoItemView *view = [_itemViews objectAtIndex:index];
        view.source = posterDownloader.videoItem;
    }
}

#pragma mark - Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

@end