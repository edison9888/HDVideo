//
//  UIImage+BitRice.h
//  HDVideo
//
//  Created by  on 11-12-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (BitRice)

+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;

@end