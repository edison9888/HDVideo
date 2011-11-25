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
    
    BOOL _isDragging;
    BOOL _isLoading;
}

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, retain) NSString *feedKey;
@property (nonatomic, retain) NSString *feedUrl;
@property (nonatomic, retain) NSArray *videoItems;
@property (nonatomic, retain) NSMutableDictionary *posterDownloadsInProgress;
@property (nonatomic) BOOL isEpisode;

// paging
@property (nonatomic) NSUInteger currentPageIndex;
@property (nonatomic) NSUInteger totalPageCount;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UILabel *headerLabel;
@property (nonatomic, retain) UIImageView *headerArrow;
@property (nonatomic, retain) UIActivityIndicatorView *headerSpinner;

@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;


- (void)tileVideos;
- (VideoItemView *)dequeueRecycledVideo;
- (void)configVideo:(VideoItemView *)video forIndex:(NSUInteger)index;
- (BOOL)isDisplayingVideoForIndex:(NSUInteger)index;
- (CGRect)frameForVideoAtIndex:(NSUInteger)index;

- (void)startDownloading;
- (void)cancelDownloading;

- (void)startLoading;
- (void)stopLoading;

@end