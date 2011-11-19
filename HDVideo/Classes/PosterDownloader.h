//
//  PosterDownloader.h
//  HDVideo
//
//  Created by Perry on 11-11-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoItem.h"


@protocol PosterDownloaderDelegate 

- (void)posterImageDidLoad:(NSUInteger)index;

@end

@interface PosterDownloader : NSObject {
    
}

@property (nonatomic, retain) VideoItem *videoItem;
@property (nonatomic) NSUInteger indexInVideoBrowserView;
@property (nonatomic, assign) id <PosterDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end