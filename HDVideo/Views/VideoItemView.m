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

#define IMAGE_WIDTH 128
#define STAR_WIDTH 15
#define STAR_GAP 4.5

@implementation VideoItemView

@synthesize source = _source;
@synthesize index, isEpisode, delegate;

- (CGPathRef)renderRect:(UIView*)imgView {
	UIBezierPath *path = [UIBezierPath bezierPathWithRect:imgView.bounds];
	return path.CGPath;
}

- (CGPathRef)renderPaperCurl:(UIView*)imgView {
	CGSize size = imgView.bounds.size;
	CGFloat curlFactor = 8.0f;
	CGFloat shadowDepth = 1.0f;
    
	UIBezierPath *path = [UIBezierPath bezierPath];
    float origin_x = imgView.bounds.origin.x;
    float origin_y = imgView.bounds.origin.y;
	[path moveToPoint:CGPointMake(origin_x, origin_y)];
	[path addLineToPoint:CGPointMake(origin_x + size.width, origin_y)];
	[path addLineToPoint:CGPointMake(origin_x + size.width, origin_y + size.height + shadowDepth + 3)];
	[path addCurveToPoint:CGPointMake(origin_x, origin_y + size.height + shadowDepth + 3)
			controlPoint1:CGPointMake(origin_x + size.width - curlFactor, origin_y + size.height + shadowDepth - curlFactor + 3)
			controlPoint2:CGPointMake(origin_x + curlFactor, origin_y + size.height + shadowDepth - curlFactor + 3)];
    
	return path.CGPath;
}

- (void)posterTapped:(UIGestureRecognizer *)gestureRecognizer
{
    [self.delegate videoBrowserDidTapwithSource:self.source];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(CGRectGetWidth(frame)/2.0-IMAGE_WIDTH/2.0, 0, IMAGE_WIDTH, CGRectGetHeight(frame)-50);
        _poster = [[UIImageView alloc] initWithFrame:rect];
        _poster.layer.shadowColor = [UIColor blackColor].CGColor;
        _poster.layer.shadowOpacity = 0.7f;
        _poster.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
        _poster.layer.shadowRadius = 2.0f;
        _poster.layer.masksToBounds = NO;
        [self addSubview:_poster];
        
        UIView *star = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/2-93.0/2,
                                                                CGRectGetHeight(frame)-40,
                                                                93, 15)];
        star.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        star.backgroundColor = [UIColor clearColor];
        [self addSubview:star];
        
        UIImageView *starBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star-back"]];
        starBackground.frame = star.bounds;
        [star addSubview:starBackground];
        [starBackground release];
        
        _star = [[UIView alloc] initWithFrame:star.bounds];
        _star.backgroundColor = [UIColor clearColor];
        _star.clipsToBounds = YES;
        [star addSubview:_star];
        
        UIImageView *starForeground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star-fore"]];
        starForeground.frame = _star.frame;
        [_star addSubview:starForeground];
        [starForeground release];
        
        [star release];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame)-20, CGRectGetWidth(frame), 20)];
        _name.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _name.backgroundColor = [UIColor clearColor];
        _name.font = [UIFont boldSystemFontOfSize:15];
        _name.textAlignment = UITextAlignmentCenter;
        _name.adjustsFontSizeToFitWidth = YES;
        _name.shadowColor = [UIColor whiteColor];
        _name.shadowOffset = CGSizeMake(0, 0.4);
        [self addSubview:_name];
        
        rect = CGRectMake(CGRectGetWidth(frame)/2.0+IMAGE_WIDTH/2.0-47, 0, 47, 47);
        _newRibbon = [[UIImageView alloc] initWithFrame:rect];
        _newRibbon.hidden = YES;
        _newRibbon.image = [UIImage imageNamed:@"new-ribbon"];
        [self addSubview:_newRibbon];
        
        rect = CGRectMake(CGRectGetWidth(frame)/2.0-IMAGE_WIDTH/2.0-21, -5, 60, 38);
        _countRibbon = [[UIImageView alloc] initWithFrame:rect];
        _countRibbon.hidden = YES;
        _countRibbon.image = [UIImage imageNamed:@"count-ribbon"];
        [self addSubview:_countRibbon];
        
        rect = _countRibbon.bounds;
        rect = CGRectMake(CGRectGetMinX(rect)+24, CGRectGetMinY(rect)+4, 17, 17);
        _count = [[UILabel alloc] initWithFrame:rect];
        _count.hidden = YES;
        _count.backgroundColor = [UIColor clearColor];
        _count.font = [UIFont boldSystemFontOfSize:23];
        _count.textAlignment = UITextAlignmentCenter;
        _count.textColor = [UIColor whiteColor];
        _count.shadowColor = [UIColor blackColor];
        _count.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:_count];
        
        rect = CGRectMake(23, 137, 20, 20);
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.frame = rect;
        _spinner.hidesWhenStopped = YES;
        [self addSubview:_spinner];
        [_spinner startAnimating];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGRect rect = CGRectMake(CGRectGetWidth(frame)/2.0-IMAGE_WIDTH/2.0, 0, IMAGE_WIDTH, CGRectGetHeight(frame)-50);
    _poster.frame = rect;
    
    rect = CGRectMake(CGRectGetWidth(frame)/2.0+IMAGE_WIDTH/2.0-47, 0, 47, 47);
    _newRibbon.frame = rect;
    
    rect = CGRectMake(CGRectGetWidth(frame)/2.0-IMAGE_WIDTH/2.0-21, -5, 60, 38);
    _countRibbon.frame = rect;
}

- (void)setSource:(VideoItem *)source
{
    if (source != _source)
    {
        [_source release];
        _source = [source retain];
    }
    [self setNeedsLayout];
    
    // update controls
    _name.text = _source.name;
    _newRibbon.hidden = (!_source.isNewItem);
    
    // new item count
    if (_source.newItemCount > 0)
    {
        _count.text = [NSString stringWithFormat:@"%d", _source.newItemCount];
        _count.hidden = NO;
        _countRibbon.hidden = NO;
    }
    else
    {
        _count.hidden = YES;
        _countRibbon.hidden = YES;
    }
    
    // poster image
    if (_source.posterImage)
    {
        _poster.image = _source.posterImage;
        if (_source.isCategory)
            _poster.layer.shadowPath = [self renderRect:_poster];
        else
            _poster.layer.shadowPath = [self renderPaperCurl:_poster];
        
        [_spinner stopAnimating];
    }
    else
    {
        if (!self.isEpisode)
            _poster.image = [UIImage imageNamed:@"placeholder"];
        else
            _poster.image = [UIImage imageNamed:@"placeholder2"];
    }
    
    // star rating
    CGRect rect = [_star superview].bounds;
    int numOfStar = floor(_source.rate);
    float tail = _source.rate - numOfStar;
    if (tail > 0.06)
        tail -= 0.06;    // adjustment
    float w = numOfStar * (STAR_WIDTH + STAR_GAP) + tail * STAR_WIDTH;
    _star.frame = CGRectMake(0, 0, w, CGRectGetHeight(rect));
}

- (void)dealloc
{
    [_star release];
    [_poster release];
    [_newRibbon release];
    [_name release];
    [_count release];
    [_countRibbon release];
    [_source release];
    [_spinner release];
    
    [super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_poster];
    if (CGRectContainsPoint(_poster.bounds, point)) {
        if (touch.tapCount == 2) {
            if (self.source.posterImage) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(posterTapped:) object:nil];
                [self.delegate videoBrowserAddToFavorite:self.source withPoster:_poster];
            }
        }
        else if (touch.tapCount == 1) {
            [self performSelector:@selector(posterTapped:) withObject:nil afterDelay:0.5];
        }
    }
}

@end