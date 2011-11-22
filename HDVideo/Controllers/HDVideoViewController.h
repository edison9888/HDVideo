//
//  HDVideoViewController.h
//  HDVideo
//
//  Created by Perry on 11-11-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoBrowserController.h"
#import "VideoBrowserView.h"

@interface HDVideoViewController : UIViewController<UIPopoverControllerDelegate> {
    UIPopoverController *_popoverHistoryController;
}

@property (nonatomic, retain) VideoBrowserController *videoBrowserController;

@end