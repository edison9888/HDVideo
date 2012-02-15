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
#import "Reachability.h"


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

- (NSArray *)favorites
{
    NSArray *array = [self.categories objectForKey:@"Favorites"];
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

- (void)addFavorite:(NSString *)name videoUrl:(NSString *)url videoId:(NSString *)vid
{
    if ([name isEqualToString:@""] || ([url isEqualToString:@""] && [vid isEqualToString:@""]))
        return;
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.favorites];
    for (NSDictionary *dict in array) {
        if ([[dict objectForKey:@"name"] isEqualToString:name])
        {
            [array removeObject:dict];
            break;
        }
    }
    
    NSDictionary *dict;
    if (url) {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                name, @"name",
                url, @"videoUrl",
                nil];
    }
    else {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                name, @"name",
                vid, @"videoId",
                nil];
    }
    [array insertObject:dict atIndex:0];
    
    // most count is 50
    if ([array count] > 50)
    {
        [array removeObjectAtIndex:50];
    }
    
    [self.categories setValue:array forKey:@"Favorites"];
    [DataUtil writeDictionary:self.categories toDataFile:@"Category"];
}

- (void)deleteFavoriteAtIndex:(NSUInteger)index
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.favorites];
    [array removeObjectAtIndex:index];
    
    [self.categories setValue:array forKey:@"Favorites"];
    [DataUtil writeDictionary:self.categories toDataFile:@"Category"];
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

- (BOOL)checkNetwork
{
    // check network
    Reachability* wifiReach = [Reachability reachabilityForLocalWiFi];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    if (netStatus == ReachableViaWiFi) {
        return YES;
    }
    else if (netStatus == ReachableViaWWAN) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WWAN_TITLE", nil)
                                                        message:NSLocalizedString(@"WWAN_BODY", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"WWAN_CANCEL", nil)
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else {      // NotReachable
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NO_REACH_TITLE", nil)
                                                            message:NSLocalizedString(@"NO_REACH_BODY", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    return NO;
}

@end
