//
//  WeiboLogin.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-17.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "WeiboLogin.h"

@interface WeiboLogin ()

@end

@implementation WeiboLogin

SINGLETON_GCD(WeiboLogin);

- (void)loginWithWeibo
{
    [[[[UIApplication sharedApplication] delegate] window] makeKeyWindow];
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = weiboRedirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

- (void)getUserInfoWithUserId:(NSString *)userId accessToken:(NSString *)accessToken
{
    [WBHttpRequest requestWithAccessToken:accessToken
                                      url:@"https://api.weibo.com/2/users/show.json"
                               httpMethod:@"GET"
                                   params:@{@"uid": userId}
                                 delegate:self
                                  withTag:@""];
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        WBAuthorizeResponse *authResponse = (WBAuthorizeResponse *)response;
        
        NSDictionary *extraInfo = @{};
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            extraInfo = @{
                          @"userId": authResponse.userID,
                          @"accessToken": authResponse.accessToken
                          };
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MSG_WEIBO_LOGIN 
                                                            object:self 
                                                          userInfo:@{
                                                                     @"statusCode": [NSNumber numberWithInt:response.statusCode],
                                                                     @"extraInfo": extraInfo
                                                                     }];
    }
}

#pragma mark - WBHttpRequestDelegate

-(void)request:(WBHttpRequest*)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@", response);
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data
{
    
}

@end
