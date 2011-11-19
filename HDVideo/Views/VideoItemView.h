//
//  VideoItemView.h
//  HDVideo
//
//  Created by Perry on 11-11-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoItem.h"

@interface VideoItemView : UIView {
    UIImageView *_poster;
    UILabel *_name;
}

@property (nonatomic, retain) VideoItem *source;

@end
