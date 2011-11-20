//
//  ParseOperation.h
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoItem.h"


@protocol ParseOperationDelegate;

@interface ParseOperation : NSOperation<NSXMLParserDelegate>
{
@private
    id <ParseOperationDelegate> delegate;
    
    NSData          *dataToParse;
    
    NSMutableArray  *workingArray;
    VideoItem       *workingEntry;
    NSMutableString *workingPropertyString;
    
    BOOL            storingCharacterData;
    NSString        *trackingCategoryName;
    NSString        *trackingReleaseDate;
}

- (id)initWithData:(NSData *)data delegate:(id <ParseOperationDelegate>)theDelegate;

@end

@protocol ParseOperationDelegate

- (void)didFinishParsing:(NSArray *)videoList;
- (void)parseErrorOccurred:(NSError *)error;

@end