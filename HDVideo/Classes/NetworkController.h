//
//  NetworkController.h
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ParseOperation.h"


@interface NetworkController : NSObject<ParseOperationDelegate> {
    
}

@property (nonatomic, retain) NSMutableArray *videoItems;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSURLConnection *videoFeedConnection;
@property (nonatomic, retain) NSMutableData *videoFeedData;

- (void)startLoadFeed;

@end