//
//  VideoItem.h
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VideoItem : NSObject {
    
}

@property (nonatomic, retain) NSString *vid;
@property (nonatomic, retain) NSMutableArray *collection;
@property (nonatomic) NSUInteger newItemCount;
@property (nonatomic) BOOL isCategory;
@property (nonatomic) BOOL isNewItem;
@property (nonatomic) CGFloat rate;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UIImage *posterImage;
@property (nonatomic, retain) NSString *posterUrl;
@property (nonatomic, retain) NSString *videoUrl;

@end