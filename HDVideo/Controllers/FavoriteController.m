//
//  FavoriteController.m
//  HDVideo
//
//  Created by  on 11-12-18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FavoriteController.h"
#import "DataController.h"
#import "VideoItem.h"
#import "VideoPlayerController.h"
#import "VideoBrowserController.h"
#import "HDVideoAppDelegate.h"
#import "FeedBrowserController.h"


@implementation FavoriteController

@synthesize parentNavigationController = _parentNavigationController;
@synthesize popController = _popController;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
	[button setTitle:NSLocalizedString(@"ADD_FAVORITE_HINT", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    
    [view addSubview:button];
    [button release];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:view];
    [view release];
    
    self.navigationItem.leftBarButtonItem = item;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [[[DataController sharedDataController] favorites] count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSDictionary *dict = [[[DataController sharedDataController] favorites] objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = [dict objectForKey:@"name"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [[[DataController sharedDataController] favorites] objectAtIndex:indexPath.row];
    VideoItem *videoItem = [[VideoItem alloc] init];
    videoItem.name = [dict objectForKey:@"name"];
    videoItem.videoUrl = [dict objectForKey:@"videoUrl"];
    videoItem.vid = [dict objectForKey:@"videoId"];
    
    if (videoItem.videoUrl) {
        VideoPlayerController *player = [[VideoPlayerController alloc] init];
        player.videoItem = videoItem;
        player.navigationItem.title = videoItem.name;
        [videoItem release];
        
        [_parentNavigationController pushViewController:player animated:YES];
        [player release];
    }
    else if (videoItem.vid) {
        HDVideoAppDelegate *del = (HDVideoAppDelegate *)[UIApplication sharedApplication].delegate;
        
        FeedBrowserController *controller = [[FeedBrowserController alloc] init];
        controller.isEpisode = YES;
        controller.feedKey = videoItem.vid;
        controller.navigationItem.title = videoItem.name;
        [del.navigationController pushViewController:controller animated:YES];
        
        
        // stop UIScrollView from scrolling immediately
        [controller startDownloading];
        
        NSString *url = [NSString stringWithFormat:@"%@cate=serialitem&serialid=%@",
                         [[DataController sharedDataController] serverAddressBase],
                         videoItem.vid];
        controller.feedUrl = url;
        [controller startLoading:NO];
        [controller release];
    }
    
    [_popController dismissPopoverAnimated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableView beginUpdates];
        [[DataController sharedDataController] deleteFavoriteAtIndex:indexPath.row];
        NSArray *deleteIndexPaths = [NSArray arrayWithObjects:
                                     [NSIndexPath indexPathForRow:indexPath.row inSection:0],
                                     nil];
        [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

@end
