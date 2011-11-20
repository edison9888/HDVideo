//
//  VideoItemView.m
//  HDVideo
//
//  Created by Perry on 11-11-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoItemView.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@implementation VideoItemView

@synthesize source = _source;

- (CGPathRef)renderRect:(UIView*)imgView {
	UIBezierPath *path = [UIBezierPath bezierPathWithRect:imgView.bounds];
	return path.CGPath;
}

- (CGPathRef)renderPaperCurl:(UIView*)imgView {
	CGSize size = imgView.bounds.size;
	CGFloat curlFactor = 8.0f;
	CGFloat shadowDepth = 1.0f;
    
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0.0f, 0.0f)];
	[path addLineToPoint:CGPointMake(size.width, 0.0f)];
	[path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
	[path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
			controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
			controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    
	return path.CGPath;
}

- (void)posterTapped:(UIGestureRecognizer *)gestureRecognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_POSTER_TAPPED_NOTIFICATION object:self.source];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)-50);
        _poster = [[UIImageView alloc] initWithFrame:rect];
        _poster.layer.shadowColor = [UIColor blackColor].CGColor;
        _poster.layer.shadowOpacity = 0.7f;
        _poster.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
        _poster.layer.shadowRadius = 2.0f;
        _poster.layer.masksToBounds = NO;
        [self addSubview:_poster];
        _poster.layer.shadowPath = [self renderPaperCurl:_poster];
        
        UIView *star = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/2-93.0/2,
                                                                CGRectGetHeight(frame)-40,
                                                                93, 15)];
        star.backgroundColor = [UIColor clearColor];
        [self addSubview:star];
        
        UIImageView *starBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star-back"]];
        starBackground.frame = star.bounds;
        [star addSubview:starBackground];
        [starBackground release];
        
        [star release];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame)-20, CGRectGetWidth(frame), 20)];
        _name.backgroundColor = [UIColor clearColor];
        _name.font = [UIFont boldSystemFontOfSize:15];
        _name.textAlignment = UITextAlignmentCenter;
        _name.shadowColor = [UIColor whiteColor];
        _name.shadowOffset = CGSizeMake(0, 0.4);
        [self addSubview:_name];
        
        // tap gesture
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(posterTapped:)];
        [self addGestureRecognizer:gesture];
        [gesture release];
    }
    return self;
}

- (void)setSource:(VideoItem *)source
{
    if (source != _source)
    {
        [_source release];
        _source = [source retain];
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews{
    _name.text = _source.name;
    if (_source.posterImage)
    {
        _poster.image = _source.posterImage;
        if (_source.isCategory)
            _poster.layer.shadowPath = [self renderRect:_poster];
        else
            _poster.layer.shadowPath = [self renderPaperCurl:_poster];
    }
    else
    {
        _poster.image = [UIImage imageNamed:@"placeholder"];
    }
}

- (void)dealloc
{
    [_poster release];
    [_name release];
    [_source release];
    
    [super dealloc];
}

@end
