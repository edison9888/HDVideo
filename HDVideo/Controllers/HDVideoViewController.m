//
//  HDVideoViewController.m
//  HDVideo
//
//  Created by Perry on 11-11-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HDVideoViewController.h"
#import "UIView+HDV.h"

@implementation HDVideoViewController

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView
{
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    UIView *background = [[UIView alloc] initWithFrame:rect];
    background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.view = background;
    [background release];
    
    // bottom bar
    UIImage *imageBottomBar = [UIImage imageNamed:@"bottom-bar"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 768-119, 1024, 55)];
    imageView.contentMode = UIViewContentModeBottomLeft;
    imageView.image = imageBottomBar;
    [self.view addSubview:imageView];
    [imageView release];
    
    // segment control
    NSArray *channels = [NSArray arrayWithObjects:@"美剧", @"电影", @"电视剧", @"综艺", nil];
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:channels];
    segment.frame = CGRectMake(290, 666, 1024-580, 34);
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    segment.tintColor = [UIColor colorWithRed:202.0/255 green:174.0/255 blue:124.0/255 alpha:1.0];
    [segment changeUISegmentFont:16];
    [segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segment];
    [segment release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

#pragma mark - private handlers
- (void)segmentAction:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    [segment changeUISegmentFont:16];
}

@end
