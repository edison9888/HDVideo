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
#import "UIView+HDV.h"
#import "Constants.h"

#define SEGMENT_CONTROL_TAG 1

@implementation HDVideoViewController

@synthesize videoBrowserView = _videoBrowserView;

- (void)dealloc
{
    [_videoBrowserView release];
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
    segment.tintColor = [UIColor colorWithRed:202.0/255 green:174.0/255 blue:124.0/255 alpha:1.0];
    [segment changeUISegmentFont:16];
    [segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segment];
    [segment release];
    
    // video browser
    _videoBrowserView = [[VideoBrowserView alloc] init];
    _videoBrowserView.frame = CGRectMake(0, 0, 1024, 660);
    _videoBrowserView.posterDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.view addSubview:_videoBrowserView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadCompleted:)
                                                 name:VIDEO_FEED_DOWNLOAD_COMPLETED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPosterTapped:)
                                                 name:VIDEO_POSTER_TAPPED_NOTIFICATION
                                               object:nil];
    
    UISegmentedControl *segment = (UISegmentedControl *)[self.view viewWithTag:SEGMENT_CONTROL_TAG];
    [segment setSelectedSegmentIndex:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VIDEO_FEED_DOWNLOAD_COMPLETED_NOTIFICATION
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VIDEO_POSTER_TAPPED_NOTIFICATION
                                                  object:nil];
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
    
    NSDictionary *category = [[DataController sharedDataController] getCategoryAtIndex:segment.selectedSegmentIndex];
    [[NetworkController sharedNetworkController] startLoadFeed:[category objectForKey:@"feedUrl"]
                                                        forKey:[NSString stringWithFormat:@"Segment-%d", segment.selectedSegmentIndex]];
}

- (void)downloadCompleted:(NSNotification *)notification
{
    NSString *currentKey = [[NetworkController sharedNetworkController] currentKey];
    NSRange range = [currentKey rangeOfString:@"Segment-"];
    if (range.location == 0)
    {
        _videoBrowserView.videoItems = [notification object];
    }
}

- (void)videoPosterTapped:(NSNotification *)notification
{
    VideoItem *videoItem = [notification object];
    if (videoItem.isCategory)
    {
        VideoBrowserController *controller = [[VideoBrowserController alloc] init];
        controller.feedKey = [NSString stringWithFormat:@"%d", videoItem.id];
        controller.navigationItem.title = videoItem.name;
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
        [[NetworkController sharedNetworkController] startLoadFeed:videoItem.subFeedUrl
                                                            forKey:[NSString stringWithFormat:@"%d", videoItem.id]];
    }
    else
    {
        VideoPlayerController *player = [[VideoPlayerController alloc] init];
        player.videoItem = [notification object];
        [self.navigationController pushViewController:player animated:YES];
        [player release];
    }
}

@end