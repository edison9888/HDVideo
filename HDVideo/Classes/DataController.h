//
//  DataController.h
//  HDVideo
//
//  Created by Perry on 11-11-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//




@interface DataController : NSObject<UIAlertViewDelegate> {
    
}

@property (nonatomic, readonly) NSDictionary *categories;
@property (nonatomic, readonly) NSArray *histories;
@property (nonatomic, readonly) NSArray *favorites;

+ (DataController *)sharedDataController;

- (NSString *)serverAddressBase;
- (NSDictionary *)getCategoryAtIndex:(NSUInteger)index;

- (void)addHistory:(NSString *)name videoUrl:(NSString *)url;
- (void)cleanHistory;

- (void)incrementAppLoadedTimes;

@end