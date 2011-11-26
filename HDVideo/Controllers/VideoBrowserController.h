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
    
    BOOL _isDragging;
    BOOL _isLoadingNext;
    BOOL _isLoadingPrevious;
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

@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, retain) UILabel *footerLabel;
@property (nonatomic, retain) UIImageView *footerArrow;
@property (nonatomic, retain) UIActivityIndicatorView *footerSpinner;

@property (nonatomic, copy) NSString *textPullHeader;
@property (nonatomic, copy) NSString *textPullFooter;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;
@property (nonatomic, copy) NSString *textReachFirstPage;
@property (nonatomic, copy) NSString *textReachLastPage;


- (void)tileVideos;
- (VideoItemView *)dequeueRecycledVideo;
- (void)configVideo:(VideoItemView *)video forIndex:(NSUInteger)index;
- (BOOL)isDisplayingVideoForIndex:(NSUInteger)index;
- (CGRect)frameForVideoAtIndex:(NSUInteger)index;

- (void)startDownloading;
- (void)cancelDownloading;

- (void)startLoading:(BOOL)isHeader;
- (void)stopLoading:(BOOL)isHeader withNotification:(NSNotification *)notification;

- (void)initLoading;

- (void)setupPageUrl:(NSUInteger)pageIndex;

@end