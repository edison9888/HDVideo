//
//  DataController.h
//  HDVideo
//
//  Created by Perry on 11-11-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//




@interface DataController : NSObject {
    
}

@property (nonatomic, readonly) NSString *latestFeedUrl;
@property (nonatomic, readonly) NSDictionary *categories;

+ (DataController *)sharedDataController;
- (NSDictionary *)getCategoryAtIndex:(NSUInteger)index;

@end