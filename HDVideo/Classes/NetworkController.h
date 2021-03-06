//
//  NetworkController.h
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ParseFeedOperation.h"
#import "ParseSuggestionOperation.h"
#import "ParseSearchOperation.h"


@interface NetworkController : NSObject<ParseFeedDelegate, ParseSuggestionDelegate, ParseSearchDelegate> {
}

+ (NetworkController *)sharedNetworkController;


// feed
@property (nonatomic, readonly) NSString        *currentKey;
@property (nonatomic, retain) NSMutableArray    *feedItems;
@property (nonatomic, retain) NSOperationQueue  *feedQueue;
@property (nonatomic, retain) NSURLConnection   *feedConnection;
@property (nonatomic, retain) NSMutableData     *feedData;

- (void)startLoadFeed:(NSString *)url forKey:(NSString *)key;


// suggestion
@property (nonatomic, retain) NSMutableArray    *suggestionItems;
@property (nonatomic, retain) NSOperationQueue  *suggestionQueue;
@property (nonatomic, retain) NSURLConnection   *suggestionConnection;
@property (nonatomic, retain) NSMutableData     *suggestionData;

- (void)startLoadSuggestion:(NSString *)url;

// search result
@property (nonatomic, retain) NSMutableArray    *searchItems;
@property (nonatomic, retain) NSOperationQueue  *searchQueue;
@property (nonatomic, retain) NSURLConnection   *searchConnection;
@property (nonatomic, retain) NSMutableData     *searchData;

- (void)startLoadSearchResult:(NSString *)url;

@end