//
//  UIImage+BitRice.m
//  HDVideo
//
//  Created by  on 11-12-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIImage+BitRice.h"

@implementation UIImage (BitRice)

+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    //create a context to do our clipping in
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    //create a rect with the size we want to crop the image to
    //the X and Y here are zero so we start at the beginning of our
    //newly created context
    CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CGContextClipToRect(currentContext, clippedRect);
    
    //create a rect equivalent to the full size of the image
    //offset the rect by the X and Y we want to start the crop
    //from in order to cut off anything before them
    CGRect drawRect = CGRectMake(rect.origin.x * -1,
                                 rect.origin.y * -1,
                                 imageToCrop.size.width,
                                 imageToCrop.size.height);
    
    CGContextTranslateCTM(currentContext, 0.0, drawRect.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    //draw the image to our clipped context using our offset rect
    CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
    
    //pull the image from our cropped context
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    //Note: this is autoreleased
    return cropped;
}

@end