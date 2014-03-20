//
//  CachedDownloadManager.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-19.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "CachedDownloadManager.h"

#define CACHE_DIRECTORY [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"ShanpowCache"]

@interface CachedDownloadManager ()

@property (nonatomic, assign) BOOL forceExpired;

@end

@implementation CachedDownloadManager

SINGLETON_GCD(CachedDownloadManager);

+ (BOOL)clearAllCache {
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:CACHE_DIRECTORY];

	NSString *file;
	while (file = [dirEnum nextObject]) {
		if (![[NSFileManager defaultManager] removeItemAtPath:file error:nil]) {
			return NO;
		}
	}

	return YES;
}

- (void)forceExpiredForNextRequest {
	self.forceExpired = YES;
}

- (BOOL)saveCache:(id <NSCoding> )data forKey:(NSString *)key {
	NSString *cachePath = [CACHE_DIRECTORY stringByAppendingPathComponent:[key md5]];

	if ([[NSFileManager defaultManager] createDirectoryAtPath:CACHE_DIRECTORY withIntermediateDirectories:YES attributes:nil error:nil]) {
		return [NSKeyedArchiver archiveRootObject:data toFile:cachePath];
	}

	return NO;
}

- (id)loadCacheForKey:(NSString *)key {
	if (self.forceExpired) {
		self.forceExpired = NO;
		return nil;
	}

	NSString *cachePath = [CACHE_DIRECTORY stringByAppendingPathComponent:[key md5]];

/*
 *  check expire time interval
 */
//    NSTimeInterval stalenessLevel = [[[[NSFileManager defaultManager] attributesOfItemAtPath:cachePath error:nil] fileModificationDate] timeIntervalSinceNow];
//
//    if (ABS(stalenessLevel) > CACHE_EXPIRE_DURATION) {
//        return nil;
//    }

	return [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
}

- (BOOL)clearCacheForKey:(NSString *)key {
	NSString *cachePath = [CACHE_DIRECTORY stringByAppendingPathComponent:[key md5]];

	return [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
}

@end
