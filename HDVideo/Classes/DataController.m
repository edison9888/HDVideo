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

- (void)incrementAppLoadedTimes
{
    int times = [[self.categories objectForKey:@"AppLoadedTimes"] intValue];
    times += 1;
    if (times % 5 == 0) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"喜欢我们的应用吗？"
                                                         message:@"请为海量高清评分，您的褒奖和批评是我们持续改进的动力，谢谢！"
                                                        delegate:self
                                               cancelButtonTitle:@"不予置评"
                                               otherButtonTitles:@"我要评分！", nil] autorelease];
        [alert show];
    }
    [self.categories setValue:[NSNumber numberWithInt:times] forKey:@"AppLoadedTimes"];
    [DataUtil writeDictionary:self.categories toDataFile:@"Category"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *reviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=488730212";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
    }
}

@end
