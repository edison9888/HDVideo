//
//  HDVideoAppDelegate.m
//  HDVideo
//
//  Created by Perry on 11-11-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HDVideoAppDelegate.h"
#import "HDVideoViewController.h"
#import "Constants.h"
#import "UIColor+HDV.h"

@implementation HDVideoAppDelegate


@synthesize window=_window;
@synthesize viewController=_viewController;
@synthesize navigationController=_navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _navigationController = [[UINavigationController alloc] initWithRootViewController: self.viewController];
    
    // customize navigation controller bar
    CGRect tr = _navigationController.navigationBar.frame;
    tr = CGRectMake(0, 0, CGRectGetWidth(tr), CGRectGetHeight(tr));
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:tr];
    imageView.contentMode = UIViewContentModeTopLeft;
    imageView.tag = kNavigationBarBackgroundImageTag;
    imageView.image = [UIImage imageNamed:@"top-bar"];
    [_navigationController.navigationBar insertSubview:imageView atIndex:0];
    [_navigationController.navigationBar setTintColor:[UIColor colorForWoodTint]];
    [imageView release];
    
    self.window.rootViewController = _navigationController;
    [_navigationController release];
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [_viewController release];
    [super dealloc];
}

@end
