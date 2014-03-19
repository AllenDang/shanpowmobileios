//
//  CachedDownloadManager.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-19.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#import "NSData+Base64.h"
#import "NSStringCategory.h"

#define CACHE_EXPIRE_DURATION       600   // in seconds

@interface CachedDownloadManager : NSObject

+ (CachedDownloadManager *)sharedCachedDownloadManager;

- (BOOL)saveCache:(id<NSCoding>)data forKey:(NSString *)key;
- (id)loadCache:(NSString *)key;
- (void)forceExpiredForNextRequest;

@end
