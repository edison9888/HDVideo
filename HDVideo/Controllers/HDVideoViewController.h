//
//  HDVideoViewController.h
//  HDVideo
//
//  Created by Perry on 11-11-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedBrowserController.h"
#import "SuggestionDisplayController.h"


@interface HDVideoViewController : UIViewController<UISearchBarDelegate, UIPopoverControllerDelegate> {
    UIPopoverController *_popoverHistoryController;
    UIPopoverController *_popoverFavoriteController;
}

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) SuggestionDisplayController *suggestionDisplayController;
@property (nonatomic, retain) FeedBrowserController *feedBrowserController;

@end