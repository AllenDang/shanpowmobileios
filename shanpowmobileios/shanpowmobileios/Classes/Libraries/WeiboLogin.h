//
//  WeiboLogin.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-17.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "Common.h"

@interface WeiboLogin : NSObject <WeiboSDKDelegate, WBHttpRequestDelegate>

+ (WeiboLogin *)sharedWeiboLogin;
- (void)loginWithWeibo;
- (void)getUserInfoWithUserId:(NSString *)userId accessToken:(NSString *)accessToken;

@end
