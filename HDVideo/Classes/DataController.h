//
//  DataController.h
//  HDVideo
//
//  Created by Perry on 11-11-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//




@interface DataController : NSObject {
    
}

@property (nonatomic, readonly) NSDictionary *categories;
@property (nonatomic, readonly) NSArray *histories;

+ (DataController *)sharedDataController;

- (NSString *)serverAddressBase;
- (NSDictionary *)getCategoryAtIndex:(NSUInteger)index;

- (void)addHistory:(NSString *)name videoUrl:(NSString *)url;
- (void)cleanHistory;

@end