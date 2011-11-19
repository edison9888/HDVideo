//
//  VideoItem.m
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoItem.h"


@implementation VideoItem

@synthesize id, collection, newChildItemCount, isNewItem, rate, name, posterImage, posterUrl, videoUrl;

- (void)dealloc
{
    [collection release];
    [name release];
    [posterImage release];
    [posterUrl release];
    [videoUrl release];
    
    [super dealloc];
}

@end