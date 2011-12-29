//
//  SearchResultController.m
//  HDVideo
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SuggestionDisplayController.h"
#import "Constants.h"


@implementation SuggestionDisplayController

@synthesize suggestions = _suggestions;


- (void)setSuggestions:(NSArray *)suggestions
{
    if (_suggestions != suggestions) {
        [_suggestions release];
        _suggestions = [suggestions retain];
        [self.tableView reloadData];
    }
}

- (void)dealloc
{
    [super dealloc];
    [_suggestions release];
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
    return [_suggestions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    // add a placeholder cell while waiting on table data
    int nodeCount = [self.suggestions count];
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
		cell.detailTextLabel.text = NSLocalizedString(@"LOADING_RESULT", nil);
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
    cell.textLabel.text = [_suggestions objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *query = [self.suggestions objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:START_SEARCHING_NOTIFICATION object:query];
}

@end
