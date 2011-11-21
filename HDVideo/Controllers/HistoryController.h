//
//  HistoryController.h
//  HDVideo
//
//  Created by Perry on 11-11-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HistoryController : UITableViewController<UIAlertViewDelegate> {
    
}

@property (nonatomic, assign) UINavigationController *parentNavigationController;
@property (nonatomic, assign) UIPopoverController *popController;

@end