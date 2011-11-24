//
//  VideoBrowserController.h
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoItemView.h"
#import "VideoItem.h"
#import "PosterDownloader.h"

@class VideoItemView;

@interface VideoBrowserController : UIViewController<UIScrollViewDelegate, PosterDownloaderDelegate> {
    UIScrollView *_scrollView;
    NSMutableSet *_recycledVideos;
    NSMutableSet *_visibleVideos;
    UIActivityIndicatorView *_spinner;
}

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, retain) NSString *feedKey;
@property (nonatomic, retain) NSArray *videoItems;
@property (nonatomic, retain) NSMutableDictionary *posterDownloadsInProgress;
@property (nonatomic) BOOL isEpisode;

// paging
@property (nonatomic) NSUInteger currentPageIndex;
@property (nonatomic) NSUInteger totalPageCount;


- (void)tileVideos;
- (VideoItemView *)dequeueRecycledVideo;
- (void)configVideo:(VideoItemView *)video forIndex:(NSUInteger)index;
- (BOOL)isDisplayingVideoForIndex:(NSUInteger)index;
- (CGRect)frameForVideoAtIndex:(NSUInteger)index;

- (void)startDownloading;
- (void)cancelDownloading;

@end