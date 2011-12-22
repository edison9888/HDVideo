//
//  SearchResultController.m
//  HDVideo
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SearchResultController.h"


@implementation SearchResultController

@synthesize searchResults = _searchResults;


- (void)setSearchResults:(NSArray *)searchResults
{
    if (_searchResults != searchResults) {
        [_searchResults release];
        _searchResults = [searchResults retain];
        [self.tableView reloadData];
    }
}

- (void)dealloc
{
    [super dealloc];
    [_searchResults release];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    // add a placeholder cell while waiting on table data
    int nodeCount = [self.searchResults count];
	if (nodeCount == 0 && indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
		{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										   reuseIdentifier:PlaceholderCellIdentifier] autorelease];
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
		cell.detailTextLabel.text = @"正在载入搜索结果...";
        cell.textLabel.font = [UIFont systemFontOfSize:15];
		return cell;
    }

    // cell for search results
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = [_searchResults objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
