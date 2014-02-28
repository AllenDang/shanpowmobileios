//
//  Common.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-2.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#pragma mark - Singleton GCD Macro
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
#   define BASE_URL                             @"http://www.shanpow.com"
#else
#   define BASE_URL                             @"http://www.shanpow.com"
#endif

#pragma mark - Notifications

#define MSG_ERROR                               @"SMNC_0"
#define MSG_GOT_TOKEN                           @"SMNC_1"
#define MSG_FAIL_GET_TOKEN                      @"SMNC_2"
#define MSG_DID_LOGIN                           @"SMNC_3"
#define MSG_FAIL_LOGIN                          @"SMNC_4"
#define MSG_DID_LOGOUT                          @"SMNC_5"
#define MSG_FAIL_LOGOUT                         @"SMNC_6"
#define MSG_DID_GET_HOTBOOKS                    @"SMNC_7"
#define MSG_FAIL_GET_HOTBOOKS                   @"SMNC_8"
#define MSG_DID_REGISTER                        @"SMNC_9"
#define MSG_FAIL_REGISTER                       @"SMNC_10"
#define MSG_DID_QQ_LOGIN                        @"SMNC_11"
#define MSG_FAIL_QQ_LOGIN                       @"SMNC_12"
#define MSG_CANCEL_QQ_LOGIN                     @"SMNC_13"
#define MSG_DID_GET_QQ_USER_INFO                @"SMNC_14"
#define MSG_QQ_LOGIN_NOT_FOUND                  @"SMNC_15"
#define MSG_WEIBO_LOGIN                         @"SMNC_16"
#define MSG_DID_GET_SEARCH_RESULT               @"SMNC_17"
#define MSG_FAIL_GET_SEARCH_RESULT              @"SMNC_18"
#define MSG_DID_GET_BASIC_USER_INFO             @"SMNC_19"
#define MSG_FAIL_GET_BASIC_USER_INFO            @"SMNC_20"
#define MSG_DID_GET_BOOK_DETAIL                 @"SMNC_21"
#define MSG_FAIL_GET_BOOK_DETAIL                @"SMNC_22"
#define MSG_DID_MARK_BOOK                       @"SMNC_23"
#define MSG_FAIL_MARK_BOOK                      @"SMNC_24"
#define MSG_DID_POST_REVIEW                     @"SMNC_25"
#define MSG_FAIL_POST_REVIEW                    @"SMNC_26"
#define MSG_DID_GET_BOOKLISTS                   @"SMNC_27"
#define MSG_FAIL_GET_BOOKLISTS                  @"SMNC_28"
#define MSG_DID_GET_BOOKLIST_DETAIL             @"SMNC_27"
#define MSG_FAIL_GET_BOOKLIST_DETAIL            @"SMNC_28"

#define MSG_DID_SELECT_BOOK                     @"SMNC_1000"
#define MSG_DID_SELECT_BOOKLIST                 @"SMNC_1001"

#define MSG_INT_BOOKINFOVIEW_TAPPED             @"SMNC_2000"
#define MSG_TAPPED_NICKNAME                     @"SMNC_2001"

#pragma mark - Errors

#define ERR_TITLE                               @"错误"
#define ERR_CANT_CONNECT_TO_SERVER              @"无法连接到服务器"
#define ERR_FAIL_GET_DATA                       @"无法获取数据"

#pragma mark - Settings to save

#define SETTINGS_CSRF_TOKEN                     @"csrfToken"
#define SETTINGS_CURRENT_USER                   @"currentUser"
#define SETTINGS_CURRENT_USER_ID                @"currentUserID"
#define SETTINGS_CURRENT_PWD                    @"currentPassword"
#define SETTINGS_CURRENT_QQ_OPENID              @"currentQQOpenId"
#define SETTINGS_CURRENT_QQ_ACCESSTOKEN         @"currentQQAccessToken"
#define SETTINGS_CURRENT_QQ_USER_INFO           @"currentQQUserInfo"

#pragma mark - Constants

#define weiboAppKey                             @"1250697727"
#define weiboRedirectURI                        @"https://api.weibo.com/oauth2/default.html"

#pragma mark - UI Related
#pragma mark — Colors
#define UIC_BLACK(x)                            [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:(x)]
#define UIC_BRIGHT_GRAY(x)                      [UIColor colorWithRed:0.192 green:0.224 blue:0.267 alpha:(x)]
#define UIC_CERULEAN(x)                         [UIColor colorWithRed:0.000 green:0.671 blue:0.839 alpha:(x)]
#define UIC_CYAN(x)                             [UIColor colorWithRed:0.004 green:0.792 blue:1.000 alpha:(x)]
#define UIC_WHISPER(x)                          [UIColor colorWithRed:0.953 green:0.945 blue:0.965 alpha:(x)]
#define UIC_ALMOSTWHITE(x)                      [UIColor colorWithRed:0.996 green:0.996 blue:0.996 alpha:(x)]
#define UIC_WHITE(x)                            [UIColor colorWithWhite:1.0 alpha:(x)]

#pragma mark — Apperance
#define ADAPT_VIEW_TAG                          529
#define SCREEN_RATIO                            (self.view.bounds.size.height / 568.0)
#define MAIN_NAVIGATION_CONTROLLER              (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController
    
#define UINAVIGATIONBAR_HEIGHT                  44.0
#define UISTATUSBAR_HEIGHT                      20.0
    
#pragma mark — UIFont   
#define SMALL_FONT                              [UIFont systemFontOfSize:14.0]
#define SMALL_BOLD_FONT                         [UIFont boldSystemFontOfSize:14.0]
#define MEDIUM_FONT                             [UIFont systemFontOfSize:16.0]
#define MEDIUM_BOLD_FONT                        [UIFont boldSystemFontOfSize:16.0]
#define LARGE_FONT                              [UIFont systemFontOfSize:18.0]
#define LARGE_BOLD_FONT                         [UIFont boldSystemFontOfSize:18.0]
#define XLARGE_FONT                             [UIFont systemFontOfSize:24.0]
#define XLARGE_BOLD_FONT                        [UIFont boldSystemFontOfSize:24.0]
#define XXLARGE_FONT                            [UIFont systemFontOfSize:36.0]
#define XXLARGE_BOLD_FONT                       [UIFont boldSystemFontOfSize:36.0]
#define FONT_WITH_SIZE(x)                       [UIFont systemFontOfSize:(x)]
#define BOLD_FONT_WITH_SIZE(x)                  [UIFont boldSystemFontOfSize:(x)]

#define DOTTED_LINE_ALPHA                       0.2
#define GENERAL_CELL_HEIGHT                     55.0
#define GENERAL_HEADER_HEIGHT                   40.0
    
#pragma mark - Global Functions 
    
#define IsSysVerGTE(ver)                        ([[[UIDevice currentDevice] systemVersion] floatValue] >= (ver))
#define StarSize(x)                             MAX([UIImage imageNamed:(x)].size.width, [UIImage imageNamed:(x)].size.height)
#define TextHeightWithFont(x)                   ([@"我" sizeWithFont:(x)].height)

extern BOOL isLogin();

#pragma mark - UIViewController category

@interface UIViewController (ScreenAdapter)

- (void)addAdjustView;
- (void)setBackgroundImage:(UIImage *)image;
- (void)pushViewController:(UIViewController *)controller;

@end

@interface UIImage (extended)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
- (UIImage *)makeRoundedImageWithRadius:(float)radius;
- (UIImage *)scaledToSize:(CGSize)newSize;
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;

@end

@interface UILabel (Clipboard)

- (BOOL) canBecomeFirstResponder;

@end

#pragma mark -
