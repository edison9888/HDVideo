//
//  ParseOperation.m
//  HDVideo
//
//  Created by Perry on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ParseOperation.h"


// string contants found in the RSS feed
static NSString *kEntryStr  = @"Data"; // marker for each app entry

@interface ParseOperation ()
@property (nonatomic, assign) id <ParseOperationDelegate> delegate;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) VideoItem *workingEntry;
@property (nonatomic, retain) VideoItem *workingSerialEntry;
@property (nonatomic, retain) NSMutableString *workingPropertyString;
@property (nonatomic, retain) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;
@property (nonatomic, assign) NSString *trackingCategoryName;
@property (nonatomic, assign) NSString *trackingReleaseDate;
@end

@implementation ParseOperation

@synthesize delegate, dataToParse, workingArray, workingEntry, workingSerialEntry, workingPropertyString, elementsToParse,
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
    [workingSerialEntry release];
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
    if ([elementName isEqualToString:@"Result"])
    {
        _currentPageIndex               = [[attributeDict objectForKey:@"Page"] intValue];
        _totalPageCount                 = [[attributeDict objectForKey:@"Total"] intValue];
        _category                       = [attributeDict objectForKey:@"Cate"];
    }
    else if ([elementName isEqualToString:kEntryStr] || [elementName isEqualToString:@"FeedSerialItem"])
	{
        if ([_category isEqualToString:@"SerialItem"] && [elementName isEqualToString:kEntryStr]) {
            self.workingSerialEntry             = [[[VideoItem alloc] init] autorelease];
            self.workingSerialEntry.vid         = [attributeDict objectForKey:@"Id"];
            self.workingSerialEntry.isNewItem   = [[attributeDict objectForKey:@"isNew"] boolValue];
            self.workingSerialEntry.newItemCount= [[attributeDict objectForKey:@"newItemCount"] intValue];
            self.workingSerialEntry.rate        = [[attributeDict objectForKey:@"Rank"] floatValue] / 2.0f;
            self.workingSerialEntry.name        = [attributeDict objectForKey:@"Title"];
            self.workingSerialEntry.posterUrl   = [attributeDict objectForKey:@"PosterUrl"];
            self.workingSerialEntry.videoUrl    = [attributeDict objectForKey:@"PlayUrl"];
            self.workingSerialEntry.isCategory  = [_category isEqualToString:@"Serial"];
            
            if ([_category isEqualToString:@"SerialItem"]) {
                _totalPageCount                 = ceil([[attributeDict objectForKey:@"ItemAmt"] intValue]*1.0f / 20);
            }
        }
        else {
            self.workingEntry               = [[[VideoItem alloc] init] autorelease];
            self.workingEntry.vid           = [attributeDict objectForKey:@"Id"];
            self.workingEntry.isNewItem     = [[attributeDict objectForKey:@"isNew"] boolValue];
            self.workingEntry.newItemCount  = [[attributeDict objectForKey:@"newItemCount"] intValue];
            self.workingEntry.name          = [attributeDict objectForKey:@"Title"];
            self.workingEntry.posterUrl     = [attributeDict objectForKey:@"PosterUrl"];
            self.workingEntry.videoUrl      = [attributeDict objectForKey:@"PlayUrl"];
            self.workingEntry.isCategory    = [_category isEqualToString:@"Serial"];
            
            if ([_category isEqualToString:@"SerialItem"]) {
                self.workingEntry.rate      = self.workingSerialEntry.rate;
            }
            else {
                self.workingEntry.rate      = [[attributeDict objectForKey:@"Rank"] floatValue] / 2.0f;
            }
        }
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