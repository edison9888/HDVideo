//
//  UINavigationBar+HDV.h
//  HDVideo
//
//  Created by Perry on 11-11-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UINavigationBar (HDV)

- (void)hdvInsertSubview:(UIView *)view atIndex:(NSInteger)index;
- (void)hdvSendSubviewToBack:(UIView *)view;

@end
