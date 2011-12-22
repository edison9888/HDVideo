//
//  ParseOperation.h
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoItem.h"


@protocol ParseFeedDelegate;

@interface ParseFeedOperation : NSOperation<NSXMLParserDelegate>
{
@private
    id <ParseFeedDelegate> delegate;
    
    NSData          *dataToParse;
    
    NSMutableArray  *workingArray;
    VideoItem       *workingEntry;
    VideoItem       *workingSerialEntry;
    NSMutableString *workingPropertyString;
    
    NSUInteger      _currentPageIndex;
    NSUInteger      _totalPageCount;
    NSString        *_category;
}

- (id)initWithData:(NSData *)data delegate:(id <ParseFeedDelegate>)theDelegate;

@end

@protocol ParseFeedDelegate

- (void)didFinishParsing:(NSArray *)videoList forPageIndex:(NSUInteger)pageIndex fromAll:(NSUInteger)totalPageCount;
- (void)parseErrorOccurred:(NSError *)error;

@end