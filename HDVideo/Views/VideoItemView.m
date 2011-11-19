//
//  VideoItemView.m
//  HDVideo
//
//  Created by Perry on 11-11-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoItemView.h"


@implementation VideoItemView

@synthesize source = _source;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)-40);
        _poster = [[UIImageView alloc] initWithFrame:rect];
        [self addSubview:_poster];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame)-20, CGRectGetWidth(frame), 20)];
        [self addSubview:_name];
        
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
        _poster.image = _source.posterImage;
    else
        _poster.image = [UIImage imageNamed:@"placeholder"];
}

- (void)dealloc
{
    [_poster release];
    [_name release];
    [_source release];
    
    [super dealloc];
}

@end
