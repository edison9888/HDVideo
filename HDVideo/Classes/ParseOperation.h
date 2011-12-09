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
    VideoItem       *workingSerialEntry;
    NSMutableString *workingPropertyString;
    
    BOOL            storingCharacterData;
    NSString        *trackingCategoryName;
    NSString        *trackingReleaseDate;
    
    NSUInteger      _currentPageIndex;
    NSUInteger      _totalPageCount;
    NSString        *_category;
}

- (id)initWithData:(NSData *)data delegate:(id <ParseOperationDelegate>)theDelegate;

@end

@protocol ParseOperationDelegate

- (void)didFinishParsing:(NSArray *)videoList forPageIndex:(NSUInteger)pageIndex fromAll:(NSUInteger)totalPageCount;
- (void)parseErrorOccurred:(NSError *)error;

@end
