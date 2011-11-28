//
//  HDVideoViewController.m
//  HDVideo
//
//  Created by Perry on 11-11-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HDVideoViewController.h"
#import "VideoPlayerController.h"
#import "DataController.h"
#import "NetworkController.h"
#import "HistoryController.h"
#import "UIView+HDV.h"
#import "UIColor+HDV.h"
#import "Constants.h"

#define SEGMENT_CONTROL_TAG 1

@interface HDVideoViewController ()
- (IBAction)popupHistory:(UIBarButtonItem *)barButtonItem;
@end

@implementation HDVideoViewController

@synthesize videoBrowserController = _videoBrowserController;

- (void)setupNavigationBar
{
    // custom right bar buttons
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
	[button setTitle:@"播放记录" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:self action:@selector(popupHistory:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button];
    [button release];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:view];
    [view release];
    
    self.navigationItem.rightBarButtonItem = item;
    [item release];
}

- (void)dealloc
{
    [_popoverHistoryController release];
    [_videoBrowserController release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView
{
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    UIView *background = [[UIView alloc] initWithFrame:rect];
    background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpg"]];
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
    NSDictionary *dict = [[DataController sharedDataController] categories];
    NSArray *cats = [dict objectForKey:@"Categories"];
    NSMutableArray *channels = [NSMutableArray arrayWithCapacity:[cats count]];
    for (NSDictionary *cat in cats) {
        [channels addObject:[cat objectForKey:@"name"]];
    }
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithArray:channels]];
    segment.tag = SEGMENT_CONTROL_TAG;
    segment.frame = CGRectMake(290, 666, 1024-580, 34);
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    segment.tintColor = [UIColor colorForWoodTint];
    [segment changeUISegmentFont:16];
    [segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segment];
    [segment release];
    
    // video controller
    _videoBrowserController = [[VideoBrowserController alloc] init];
    _videoBrowserController.view.frame = CGRectMake(0, 0, 1024, 660);
    [self.view addSubview:_videoBrowserController.view];
    
    HistoryController *historyController = [[HistoryController alloc] init];
    historyController.contentSizeForViewInPopover = CGSizeMake(300, 560);
    historyController.parentNavigationController = self.navigationController;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:historyController];
    
    _popoverHistoryController = [[UIPopoverController alloc] initWithContentViewController:navController];
    _popoverHistoryController.delegate = self;
    historyController.popController = _popoverHistoryController;
    [historyController release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationBar];
    
    UISegmentedControl *segment = (UISegmentedControl *)[self.view viewWithTag:SEGMENT_CONTROL_TAG];
    [segment setSelectedSegmentIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UISegmentedControl *segment = (UISegmentedControl *)[self.view viewWithTag:SEGMENT_CONTROL_TAG];
    self.title = [segment titleForSegmentAtIndex:segment.selectedSegmentIndex];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - private handlers

- (void)segmentAction:(id)sender
{
    // stop UIScrollView from scrolling immediately
    [_videoBrowserController.scrollView setContentOffset:_videoBrowserController.scrollView.contentOffset animated:NO];
    
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    [segment changeUISegmentFont:16];
    
    NSDictionary *category = [[DataController sharedDataController] getCategoryAtIndex:segment.selectedSegmentIndex];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",
                     [[DataController sharedDataController] serverAddressBase],
                     [category objectForKey:@"feedUrl"]];
    NSString *key = [NSString stringWithFormat:@"Segment-%d", segment.selectedSegmentIndex];
    _videoBrowserController.feedUrl = url;
    _videoBrowserController.feedKey = key;
    [_videoBrowserController initLoading];
}

- (IBAction)popupHistory:(UIBarButtonItem *)barButtonItem
{
    [_popoverHistoryController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem
                                      permittedArrowDirections:UIPopoverArrowDirectionUp
                                                      animated:YES];
}

@end