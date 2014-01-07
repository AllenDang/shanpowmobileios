//
//  Common.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-2.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Singleton GCD Macro
#ifndef SINGLETON_GCD
#define SINGLETON_GCD(classname)                        \
\
+ (classname *)shared##classname {                      \
\
static dispatch_once_t pred;                            \
__strong static classname * shared##classname = nil;    \
dispatch_once( &pred, ^{                                \
shared##classname = [[self alloc] init]; });            \
return shared##classname;                               \
}
#endif

#pragma mark - Disable NSLog on release
#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else 
#   define NSLog(...)
#endif

#pragma mark - Basic settings
#ifdef DEBUG
#   define BASE_URL                 @"http://127.0.0.1"
#else
#   define BASE_URL                 @"http://www.shanpow.com"
#endif

#define ADAPT_VIEW_TAG              529

#pragma mark - Notifications

#define MSG_ERROR                           @"SMNC_Error"
#define MSG_GOT_TOKEN                       @"SMNC_GotCsrfToken"
#define MSG_FAIL_GET_TOKEN                  @"SMNC_FailGetCsrfToken"
#define MSG_DID_LOGIN                       @"SMNC_DidLogin"
#define MSG_FAIL_LOGIN                      @"SMNC_FailedLogin"
#define MSG_DID_LOGOUT                      @"SMNC_DidLogout"
#define MSG_FAIL_LOGOUT                     @"SMNC_FailedLogout"
#define MSG_DID_GET_HOTBOOKS                @"SMNC_GotHotBooks"
#define MSG_FAIL_GET_HOTBOOKS               @"SMNC_FailedGetHotBooks"
#define MSG_DID_REGISTER                    @"SMNC_DidRegister"
#define MSG_FAIL_REGISTER                   @"SMNC_FailRegister"
#define MSG_DID_QQ_LOGIN                    @"SMNC_DidQQLogin"
#define MSG_FAIL_QQ_LOGIN                   @"SMNC_FailQQLogin"
#define MSG_CANCEL_QQ_LOGIN                 @"SMNC_CancelQQLogin"
#define MSG_DID_GET_QQ_USER_INFO            @"SMNC_DidGetQQUserInfo"
#define MSG_QQ_LOGIN_NOT_FOUND              @"SMNC_QQLoginNotFound"
#define MSG_WEIBO_LOGIN                     @"SMNC_WeiboLogin"

#define MSG_HC_BOOK_SELECTED                @"SMNC_HotCategories_Book_Selected"

#pragma mark - Errors

#define ERR_CANT_CONNECT_TO_SERVER          @"无法连接到服务器"

#pragma mark - Settings to save

#define SETTINGS_CSRF_TOKEN                 @"csrfToken"
#define SETTINGS_CURRENT_USER               @"currentUser"
#define SETTINGS_CURRENT_PWD                @"currentPassword"
#define SETTINGS_CURRENT_QQ_OPENID          @"currentQQOpenId"
#define SETTINGS_CURRENT_QQ_ACCESSTOKEN     @"currentQQAccessToken"
#define SETTINGS_CURRENT_QQ_USER_INFO       @"currentQQUserInfo"

#pragma mark - Constants

#define weiboAppKey                         @"1250697727"
#define weiboRedirectURI                    @"https://api.weibo.com/oauth2/default.html"

#pragma mark - Global Functions

extern BOOL isLogin();

#pragma mark - UIViewController category

@interface UIViewController (ScreenAdapter)

- (void)addAdjustView;
- (void)setBackgroundImage:(UIImage *)image;

@end

@interface UIImage (extended)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end

#pragma mark -
