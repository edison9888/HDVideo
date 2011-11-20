//
//  HistoryController.m
//  HDVideo
//
//  Created by Perry on 11-11-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HistoryController.h"
#import "DataController.h"
#import "VideoPlayerController.h"


@implementation HistoryController

@synthesize parentNavigationController = _parentNavigationController;
@synthesize popController = _popController;


- (void)cleanHistory
{
    
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"清空"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(cleanHistory)];
    self.navigationItem.rightBarButtonItem = item;
    [item release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    self.title = [NSString stringWithFormat:@"共%d条", [[[DataController sharedDataController] histories] count]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - table view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [[[DataController sharedDataController] histories] objectAtIndex:indexPath.row];
    VideoItem *videoItem = [[VideoItem alloc] init];
    videoItem.name = [dict objectForKey:@"name"];
    videoItem.videoUrl = [dict objectForKey:@"videoUrl"];
    
    VideoPlayerController *player = [[VideoPlayerController alloc] init];
    player.videoItem = videoItem;
    [videoItem release];
    
    [_parentNavigationController pushViewController:player animated:YES];
    [player release];
    
    [_popController dismissPopoverAnimated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int count = [[[DataController sharedDataController] histories] count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    NSDictionary *dict = [[[DataController sharedDataController] histories] objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"name"];

    return cell;
}

@end
