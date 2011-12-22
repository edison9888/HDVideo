//
//  ParseOperation.m
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ParseSearchOperation.h"


// string contants found in the RSS feed
static NSString *kEntryStr  = @"Data"; // marker for each app entry

@interface ParseSearchOperation ()

@property (nonatomic, assign) id <ParseSearchDelegate> delegate;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) VideoItem *workingEntry;
@property (nonatomic, retain) VideoItem *workingSerialEntry;
@property (nonatomic, retain) NSMutableString *workingPropertyString;
@property (nonatomic, retain) NSArray *elementsToParse;

@end

@implementation ParseSearchOperation

@synthesize delegate, dataToParse, workingArray, workingEntry, workingSerialEntry, workingPropertyString, elementsToParse;

- (id)initWithData:(NSData *)data delegate:(id <ParseSearchDelegate>)theDelegate
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = data;
        self.delegate = theDelegate;
    }
    return self;
}

// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{
    [dataToParse release];
    [workingEntry release];
    [workingSerialEntry release];
    [workingPropertyString release];
    [workingArray release];
    
    [super dealloc];
}

// -------------------------------------------------------------------------------
//	main:
//  Given data to parse, use NSXMLParser and process all the top paid apps.
// -------------------------------------------------------------------------------
- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.workingArray = [NSMutableArray array];
    self.workingPropertyString = [NSMutableString string];
    
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not
	// desirable because it gives less control over the network, particularly in responding to
	// connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataToParse];
	[parser setDelegate:self];
    [parser parse];
	
	if (![self isCancelled])
    {
        // notify our AppDelegate that the parsing is complete
        [self.delegate didFinishParsing:self.workingArray];
    }
    
    self.workingArray = nil;
    self.workingPropertyString = nil;
    self.dataToParse = nil;
    
    [parser release];    
	[pool release];
}


#pragma mark - xml parsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"Result"])
    {
    }
    else if ([elementName isEqualToString:kEntryStr])
	{
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (self.workingEntry)
	{
        if ([elementName isEqualToString:kEntryStr] || [elementName isEqualToString:@"FeedSerialItem"])
        {
            // we are at the end of an entry
            [self.workingArray addObject:self.workingEntry];
            self.workingEntry = nil;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [workingPropertyString appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [delegate parseErrorOccurred:parseError];
}

@end