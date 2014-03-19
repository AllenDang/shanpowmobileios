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

@end

@implementation CachedDownloadManager

SINGLETON_GCD(CachedDownloadManager);

- (void)forceExpiredForNextRequest
{
    self.forceExpired = YES;
}

- (BOOL)saveCache:(id<NSCoding>)data forKey:(NSString *)key
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    cachesDirectory = [cachesDirectory stringByAppendingPathComponent:@"ShanpowCache"];
    
    NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[key md5]];
    
    if ([[NSFileManager defaultManager] createDirectoryAtPath:cachesDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
        return [NSKeyedArchiver archiveRootObject:data toFile:cachePath];
    }
    
    return NO;
}

- (id)loadCache:(NSString *)key
{
    if (self.forceExpired) {
        self.forceExpired = NO;
        return nil;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    cachesDirectory = [cachesDirectory stringByAppendingPathComponent:@"ShanpowCache"];
    
    NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:[key md5]];
    
    NSTimeInterval stalenessLevel = [[[[NSFileManager defaultManager] attributesOfItemAtPath:cachePath error:nil] fileModificationDate] timeIntervalSinceNow];
    
    if (ABS(stalenessLevel) > CACHE_EXPIRE_DURATION) {
        return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
}

@end
