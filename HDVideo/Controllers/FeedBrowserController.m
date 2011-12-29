//
//  FeedBrowserController.m
//  HDVideo
//
//  Created by  on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FeedBrowserController.h"
#import "NetworkController.h"
#import "Constants.h"

@implementation FeedBrowserController

- (void)initLoading
{
    [super initLoading];
    
    [[NetworkController sharedNetworkController] startLoadFeed:self.feedUrl forKey:self.feedKey];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // start listening for download completion
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadCompleted:)
                                                 name:VIDEO_FEED_DOWNLOAD_COMPLETED_NOTIFICATION
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // no longer wanting to listen for download completion
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:VIDEO_FEED_DOWNLOAD_COMPLETED_NOTIFICATION
                                                  object:nil];

}

- (void)downloadCompleted:(NSNotification *)notification
{
    NSString *currentKey = [[NetworkController sharedNetworkController] currentKey];
    if ([self.feedKey isEqualToString:currentKey])
    {
        if (_isLoadingPrevious)
            [self stopLoading:YES withNotification:notification];
        else
            [self stopLoading:NO withNotification:notification];
    }
}

@end
