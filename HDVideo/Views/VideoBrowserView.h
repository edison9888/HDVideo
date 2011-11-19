//
//  VideoBrowserView.h
//  HDVideo
//
//  Created by Perry on 11-11-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoBrowserController.h"
#import "PosterDownloader.h"


@interface VideoBrowserView : UIScrollView<PosterDownloaderDelegate> {
    NSMutableArray *_itemViews;
    CGFloat _lastWidth;
    CGSize _itemSize;
}

@property (nonatomic, assign) VideoBrowserController *controller;
@property (nonatomic, retain) NSArray *videoItems;
@property (nonatomic, retain) NSMutableDictionary *posterDownloadsInProgress;

@end