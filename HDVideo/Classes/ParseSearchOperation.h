//
//  ParseSearchOperation.h
//  HDVideo
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoItem.h"

@protocol ParseSearchDelegate;

@interface ParseSearchOperation : NSOperation<NSXMLParserDelegate>
{
@private
    id <ParseSearchDelegate> delegate;
    
    NSData          *dataToParse;
    
    NSMutableArray  *workingArray;
    VideoItem       *workingEntry;
    VideoItem       *workingSerialEntry;
    NSMutableString *workingPropertyString;
    
    BOOL            storingCharacterData;
    NSString        *trackingCategoryName;
    NSString        *trackingReleaseDate;
}

- (id)initWithData:(NSData *)data delegate:(id <ParseSearchDelegate>)theDelegate;

@end


@protocol ParseSearchDelegate

- (void)didFinishParsing:(NSArray *)resultList;
- (void)parseErrorOccurred:(NSError *)error;

@end