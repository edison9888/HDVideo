//
//  VideoItem.m
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoItem.h"


@implementation VideoItem

@synthesize vid, collection, newItemCount, isNewItem, isCategory, rate, name, posterImage, posterUrl, videoUrl;

- (void)dealloc
{
    [vid release];
    [collection release];
    [name release];
    [posterImage release];
    [posterUrl release];
    [videoUrl release];
    
    [super dealloc];
}

@end