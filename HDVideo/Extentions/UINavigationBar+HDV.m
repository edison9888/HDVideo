//
//  UINavigationBar+HDV.m
//  HDVideo
//
//  Created by Perry on 11-11-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar+HDV.h"
#import "Constants.h"


@implementation UINavigationBar (HDV)

- (void)hdvInsertSubview:(UIView *)view atIndex:(NSInteger)index
{
    [self hdvInsertSubview:view atIndex:index];
    
    UIView *backgroundImageView = [self viewWithTag:kNavigationBarBackgroundImageTag];
    if (backgroundImageView != nil)
    {
        [self hdvSendSubviewToBack:backgroundImageView];
    }
}

- (void)hdvSendSubviewToBack:(UIView *)view
{
    [self hdvSendSubviewToBack:view];
    
    UIView *backgroundImageView = [self viewWithTag:kNavigationBarBackgroundImageTag];
    if (backgroundImageView != nil)
    {
        [self hdvSendSubviewToBack:backgroundImageView];
    }
}

@end