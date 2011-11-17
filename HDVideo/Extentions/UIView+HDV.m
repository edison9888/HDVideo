//
//  UIView+HDV.m
//  HDVideo
//
//  Created by Perry on 11-11-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIView+HDV.h"


@implementation UIView (HDV)

- (void)changeUISegmentFont:(CGFloat)fontSize
{
    NSString *typeName = NSStringFromClass([self class]);
    if ([typeName compare:@"UISegmentLabel" options:NSLiteralSearch] == NSOrderedSame){
		UILabel *label = (UILabel *)self;
        CGPoint center = CGPointMake(CGRectGetMinX(label.frame)+CGRectGetWidth(label.frame)/2.0,
                                     CGRectGetMinY(label.frame)+CGRectGetHeight(label.frame)/2.0);
		label.font = [UIFont boldSystemFontOfSize:fontSize];
        label.shadowColor = [UIColor grayColor];
        label.shadowOffset = CGSizeMake(.5, 1);
        CGSize size = [label.text sizeWithFont:label.font];
        label.frame = CGRectMake(center.x-size.width/2,
                                 center.y-size.height/2,
                                 size.width,
                                 size.height);
	}
    else if ([typeName compare:@"UISegment" options:NSLiteralSearch] == NSOrderedSame){
        UIView *view = (UIView *)self;
        view.alpha = .75;
    }
	NSArray *subs = [self subviews];
	NSEnumerator *iter = [subs objectEnumerator];
	UIView *subView;
	while ((subView = [iter nextObject])) {
        [subView changeUISegmentFont:fontSize];
	}
}

@end