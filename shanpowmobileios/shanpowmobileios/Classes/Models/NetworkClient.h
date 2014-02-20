//
//  NetworkClient.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-2.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "Common.h"
#import "NSData+Base64.h"

@interface NetworkClient : NSObject

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *csrfToken;

+ (NetworkClient *)sharedNetworkClient;

- (void)sendRequestWithType:(NSString *)type
                        url:(NSString *)url
                 parameters:(NSDictionary *)param
                    success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getCsrfToken;

- (void)loginWithLoginname:(NSString *)loginname password:(NSString *)password;
- (void)loginWithQQOpenId:(NSString *)openId;
- (void)relogin;
- (void)logout;
- (void)registerWithNickname:(NSString *)nickname email:(NSString *)email password:(NSString *)password gender:(BOOL)isMan;
- (void)registerWithQQNickname:(NSString *)nickname email:(NSString *)email openId:(NSString *)openId accessToken:(NSString *)accessToken avatarUrl:(NSString *)avatarUrl sex:(BOOL)isMan;

- (void)getHotBooks;

- (void)searchWithKeyword:(NSString *)keyword;

- (void)getBasicUserInfo:(NSString *)username;

- (void)getBookDetail:(NSString *)bookId;

@end
