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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: self.viewController];
    
    CGRect tr = navigationController.navigationBar.frame;
    tr = CGRectMake(0, 0, CGRectGetWidth(tr), CGRectGetHeight(tr));
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:tr];
    imageView.contentMode = UIViewContentModeTopLeft;
    imageView.tag = kNavigationBarBackgroundImageTag;
    imageView.image = [UIImage imageNamed:@"top-bar"];
    [navigationController.navigationBar insertSubview:imageView atIndex:0];
    [navigationController.navigationBar setTintColor:[UIColor colorForWoodTint]];
    [imageView release];
    
    self.window.rootViewController = navigationController;
    [navigationController release];
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
