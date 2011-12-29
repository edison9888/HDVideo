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
    NSMutableString *workingPropertyString;
    
    NSUInteger      _currentPageIndex;
    NSUInteger      _totalPageCount;
    NSString        *_category;
}

- (id)initWithData:(NSData *)data delegate:(id <ParseSearchDelegate>)theDelegate;

@end


@protocol ParseSearchDelegate

- (void)didFinishParsingSearchResults:(NSArray *)searchResults forPageIndex:(NSUInteger)pageIndex fromAll:(NSUInteger)totalPageCount;
- (void)parseErrorOccurred:(NSError *)error;

@end