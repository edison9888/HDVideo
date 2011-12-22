//
//  HDVideoViewController.h
//  HDVideo
//
//  Created by Perry on 11-11-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoBrowserController.h"
#import "SearchResultController.h"


@interface HDVideoViewController : UIViewController<UISearchBarDelegate, UIPopoverControllerDelegate> {
    UIPopoverController *_popoverHistoryController;
    UIPopoverController *_popoverFavoriteController;
}

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) SearchResultController *searchResultController;
@property (nonatomic, retain) VideoBrowserController *videoBrowserController;

@end