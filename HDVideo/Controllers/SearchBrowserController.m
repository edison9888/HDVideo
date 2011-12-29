//
//  SearchBrowserController.m
//  HDVideo
//
//  Created by  on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SearchBrowserController.h"
#import "NetworkController.h"
#import "Constants.h"

@implementation SearchBrowserController

- (void)initLoading
{
    [super initLoading];
    
    [[NetworkController sharedNetworkController] startLoadSearchResult:self.feedUrl];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // start listening for download completion
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadCompleted:)
                                                 name:SEARCH_RESULT_DOWNLOAD_COMPLETED_NOTIFICATION
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // no longer wanting to listen for download completion
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SEARCH_RESULT_DOWNLOAD_COMPLETED_NOTIFICATION
                                                  object:nil];
    
}

- (void)downloadCompleted:(NSNotification *)notification
{
    if (_isLoadingPrevious)
        [self stopLoading:YES withNotification:notification];
    else
        [self stopLoading:NO withNotification:notification];
}

@end