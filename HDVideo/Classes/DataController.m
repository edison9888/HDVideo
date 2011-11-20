//
//  DataController.m
//  HDVideo
//
//  Created by Perry on 11-11-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DataController.h"
#import "DataUtil.h"
#import "SynthesizeSingleton.h"


@implementation DataController

SYNTHESIZE_SINGLETON_FOR_CLASS(DataController);


static NSDictionary *alldict = nil;

- (NSDictionary *)categories
{
    if (alldict == nil){
        alldict = [[DataUtil readDictionaryFromFile:@"Category"] retain];
    }
    return alldict;
}

- (NSString *)latestFeedUrl
{
    NSString *url = [self.categories objectForKey:@"latestFeedUrl"];
    return url;
}

- (NSDictionary *)getCategoryAtIndex:(NSUInteger)index
{
    NSArray *array = [self.categories objectForKey:@"Categories"];
    NSDictionary *dict = [array objectAtIndex:index];
    return dict;
}

@end
