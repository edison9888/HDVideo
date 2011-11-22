//
//  VideoItemView.h
//  HDVideo
//
//  Created by Perry on 11-11-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoItem.h"
#import "VideoBrowserController.h"

@interface VideoItemView : UIView {
    UIImageView *_poster;
    UIImageView *_newRibbon;
    UIImageView *_countRibbon;
    UIView *_star;
    
    UILabel *_name;
    UILabel *_count;
    UIActivityIndicatorView *_spinner;
}

@property (nonatomic, retain) VideoItem *source;
@property (nonatomic) NSUInteger index;

@end
