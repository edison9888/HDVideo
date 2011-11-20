//
//  VideoPlayerController.h
//  HDVideo
//
//  Created by Perry on 11-11-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoItem.h"


@interface VideoPlayerController : UIViewController<UIWebViewDelegate> {
    UIWebView *_webView;
}

@property (nonatomic, retain) VideoItem *videoItem;

@end
