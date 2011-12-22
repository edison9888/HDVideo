//
//  ParseSearchOperation.h
//  HDVideo
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ParseSuggestionDelegate;

@interface ParseSuggestionOperation : NSOperation<NSXMLParserDelegate>
{
@private
    id <ParseSuggestionDelegate> delegate;
    
    NSData          *dataToParse;
    
    NSMutableArray  *workingArray;
    NSMutableString *workingEntry;
}

- (id)initWithData:(NSData *)data delegate:(id <ParseSuggestionDelegate>)theDelegate;

@end


@protocol ParseSuggestionDelegate

- (void)didFinishParsingSuggestion:(NSArray *)suggestions;
- (void)parseErrorOccurred:(NSError *)error;

@end