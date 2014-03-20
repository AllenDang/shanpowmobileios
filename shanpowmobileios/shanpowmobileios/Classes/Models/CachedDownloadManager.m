//
//  CachedDownloadManager.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-19.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "CachedDownloadManager.h"

@interface CachedDownloadManager ()

@property (nonatomic, assign) BOOL forceExpired;
@property (nonatomic, strong) NSString *cacheDirectory;

@end

@implementation CachedDownloadManager

SINGLETON_GCD(CachedDownloadManager);

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        NSString *cachesDirectory = [paths objectAtIndex:0];
        
        self.cacheDirectory = [cachesDirectory stringByAppendingPathComponent:@"ShanpowCache"];
    }
    return self;
}

+ (void)clearAllCache
{
    
}

- (void)forceExpiredForNextRequest
{
    self.forceExpired = YES;
}

- (BOOL)saveCache:(id<NSCoding>)data forKey:(NSString *)key
{
    NSString *cachePath = [self.cacheDirectory stringByAppendingPathComponent:[key md5]];
    
    if ([[NSFileManager defaultManager] createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
        return [NSKeyedArchiver archiveRootObject:data toFile:cachePath];
    }
    
    return NO;
}

- (id)loadCacheForKey:(NSString *)key
{
    if (self.forceExpired) {
        self.forceExpired = NO;
        return nil;
    }
    
    NSString *cachePath = [self.cacheDirectory stringByAppendingPathComponent:[key md5]];

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

- (BOOL)clearCacheForKey:(NSString *)key
{
    NSString *cachePath = [self.cacheDirectory stringByAppendingPathComponent:[key md5]];
    
    return [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
}

@end
