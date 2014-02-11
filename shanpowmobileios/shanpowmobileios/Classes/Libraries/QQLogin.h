//
//  QQLogin.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-17.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "Common.h"

@interface QQLogin : NSObject <TencentLoginDelegate, TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth *tencent;
@property (nonatomic, strong) NSArray *permissions;

+ (QQLogin *)sharedQQLogin;

- (void)loginWithQQ;
- (void)getUserInfo;

@end
