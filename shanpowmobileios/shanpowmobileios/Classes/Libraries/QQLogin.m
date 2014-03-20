//
//  QQLogin.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-17.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "QQLogin.h"

@interface QQLogin ()

@end

@implementation QQLogin

SINGLETON_GCD(QQLogin);

- (id)init {
	if ((self = [super init])) {
		self.tencent = [[TencentOAuth alloc] initWithAppId:@"100511288" andDelegate:self];
		self.permissions = [NSArray arrayWithObjects:@"get_user_info", @"add_t", nil];
	}
	return self;
}

- (void)loginWithQQ {
	[self.tencent authorize:self.permissions];
}

- (void)getUserInfo {
	[self.tencent getUserInfo];
}

#pragma mark - TencentLoginDelegate

- (void)tencentDidLogin {
	if (self.tencent.accessToken && 0 != [self.tencent.accessToken length]) {
		// 记录登录用户的OpenID、Token以及过期时间
		NSString *accessToken = self.tencent.accessToken;
		NSString *openId = self.tencent.openId;
		[[NSUserDefaults standardUserDefaults] setObject:openId forKey:SETTINGS_CURRENT_QQ_OPENID];
		[[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:SETTINGS_CURRENT_QQ_ACCESSTOKEN];
		[[NSUserDefaults standardUserDefaults] synchronize];

		[[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_QQ_LOGIN object:self userInfo:@{
		     @"accessToken": accessToken,
		     @"openId": openId
		 }];
	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_QQ_LOGIN object:self];
	}
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
	if (cancelled) {
		[[NSNotificationCenter defaultCenter] postNotificationName:MSG_CANCEL_QQ_LOGIN object:self];
	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_QQ_LOGIN object:self];
	}
}

- (void)tencentDidNotNetWork {
	[[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_QQ_LOGIN object:self];
}

#pragma mark - TencentSessionDelegate

- (void)getUserInfoResponse:(APIResponse *)response {
	[[NSUserDefaults standardUserDefaults] setObject:response.jsonResponse forKey:SETTINGS_CURRENT_QQ_USER_INFO];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_QQ_USER_INFO object:self];
}

@end
