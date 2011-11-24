//
//  ParseOperation.m
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ParseOperation.h"


// string contants found in the RSS feed
static NSString *kEntryStr  = @"Item"; // marker for each app entry

@interface ParseOperation ()
@property (nonatomic, assign) id <ParseOperationDelegate> delegate;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) VideoItem *workingEntry;
@property (nonatomic, retain) NSMutableString *workingPropertyString;
@property (nonatomic, retain) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;
@property (nonatomic, assign) NSString *trackingCategoryName;
@property (nonatomic, assign) NSString *trackingReleaseDate;
@end

@implementation ParseOperation

@synthesize delegate, dataToParse, workingArray, workingEntry, workingPropertyString, elementsToParse,
storingCharacterData, trackingCategoryName, trackingReleaseDate;

- (id)initWithData:(NSData *)data delegate:(id <ParseOperationDelegate>)theDelegate
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
    [workingPropertyString release];
    [workingArray release];
    [trackingCategoryName release];
    [trackingReleaseDate release];
    
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
        [self.delegate didFinishParsing:self.workingArray forPageIndex:_currentPageIndex fromAll:_totalPageCount];
    }
    
    self.workingArray = nil;
    self.workingPropertyString = nil;
    self.dataToParse = nil;
    self.trackingCategoryName = nil;
    self.trackingReleaseDate = nil;
    
    [parser release];
    
	[pool release];
}


#pragma mark -
#pragma mark RSS processing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"Items"])
    {
        _currentPageIndex               = [[attributeDict objectForKey:@"index"] intValue];
        _totalPageCount                 = [[attributeDict objectForKey:@"total"] intValue];
    }
    else if ([elementName isEqualToString:kEntryStr])
	{
        self.workingEntry               = [[[VideoItem alloc] init] autorelease];
        self.workingEntry.vid           = [attributeDict objectForKey:@"id"];
        self.workingEntry.isNewItem     = [[attributeDict objectForKey:@"isNew"] boolValue];
        self.workingEntry.newItemCount  = [[attributeDict objectForKey:@"newItemCount"] intValue];
        self.workingEntry.rate          = [[attributeDict objectForKey:@"rate"] floatValue];
        self.workingEntry.name          = [attributeDict objectForKey:@"name"];
        self.workingEntry.posterUrl     = [attributeDict objectForKey:@"posterUrl"];
        self.workingEntry.videoUrl      = [attributeDict objectForKey:@"videoUrl"];
        self.workingEntry.isCategory    = [[attributeDict objectForKey:@"isSerial"] boolValue];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (self.workingEntry)
	{
        if ([elementName isEqualToString:kEntryStr])
        {
            // we are at the end of an entry
            [self.workingArray addObject:self.workingEntry];
            self.workingEntry = nil;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (storingCharacterData)
    {
        [workingPropertyString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [delegate parseErrorOccurred:parseError];
}

@end