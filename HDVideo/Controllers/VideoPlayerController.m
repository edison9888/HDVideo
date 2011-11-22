//
//  VideoPlayerController.m
//  HDVideo
//
//  Created by Perry on 11-11-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoPlayerController.h"
#import "DataController.h"

@implementation VideoPlayerController

@synthesize videoItem = _videoItem;

- (void)dealloc
{
    [_videoItem release];
    [_webView release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.view = view;
    [view release];
    
    _webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:_webView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (_videoItem)
    {
        self.navigationItem.title = _videoItem.name;
        
        [_webView stopLoading];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_videoItem.videoUrl]]];
        
        // set history
        [[DataController sharedDataController] addHistory:_videoItem.name videoUrl:_videoItem.videoUrl];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _webView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_webView stopLoading];
    _webView.delegate = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
//    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.style.zoom=%f;", 5.5]];
//    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0, %i)", 470]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end