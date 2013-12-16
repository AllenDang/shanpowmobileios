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
#define MSG_GOT_TOKEN               @"SMNC_GotCsrfToken"
#define MSG_DID_LOGIN               @"SMNC_DidLogin"
#define MSG_FAIL_LOGIN              @"SMNC_FailedLogin"
#define MSG_DID_LOGOUT              @"SMNC_DidLogout"
#define MSG_FAIL_LOGOUT             @"SMNC_FailedLogout"
#define MSG_DID_GET_HOTBOOKS        @"SMNC_GotHotBooks"
#define MSG_FAIL_GET_HOTBOOKS       @"SMNC_FailedGetHotBooks"
#define MSG_DID_REGISTER            @"SMNC_DidRegister"
#define MSG_FAIL_REGISTER           @"SMNC_FailRegister"

#pragma mark - Setting to save
#define SETTINGS_CSRF_TOKEN         @"csrfToken"
#define SETTINGS_DID_LOGIN          @"didLogin"

#pragma mark - Global Functions

extern BOOL isLogin();

#pragma mark - UIViewController category

@interface UIViewController (ScreenAdapter)

- (void)addAdjustView;
- (void)setBackgroundImage:(UIImage *)image;

@end

#pragma mark -
