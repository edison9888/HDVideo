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

- (NSArray *)histories
{
    NSArray *array = [self.categories objectForKey:@"Histories"];
    return array;
}

- (NSString *)serverAddressBase
{
    NSString *url = [self.categories objectForKey:@"ServerAddressBase"];
    return url;
}

- (NSDictionary *)getCategoryAtIndex:(NSUInteger)index
{
    NSArray *array = [self.categories objectForKey:@"Categories"];
    NSDictionary *dict = [array objectAtIndex:index];
    return dict;
}

- (void)addHistory:(NSString *)name videoUrl:(NSString *)url
{
    if ([name isEqualToString:@""] || [url isEqualToString:@""])
        return;
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.histories];
    for (NSDictionary *dict in array) {
        if ([[dict objectForKey:@"name"] isEqualToString:name])
        {
            [array removeObject:dict];
            break;
        }
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          name, @"name",
                          url, @"videoUrl",
                          nil];
    [array insertObject:dict atIndex:0];
    
    // most count is 50
    if ([array count] > 50)
    {
        [array removeObjectAtIndex:50];
    }
    
    [self.categories setValue:array forKey:@"Histories"];
    [DataUtil writeDictionary:self.categories toDataFile:@"Category"];
}

- (void)cleanHistory
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.histories];
    [array removeAllObjects];
    [self.categories setValue:array forKey:@"Histories"];
    [DataUtil writeDictionary:self.categories toDataFile:@"Category"];
}

@end
