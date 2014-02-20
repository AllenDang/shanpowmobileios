//
//  NetworkClient.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-2.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "NetworkClient.h"

@interface NetworkClient ()

@property (atomic, strong) NSMutableArray *pendingOperationQueue;

- (void)handleResponse:(id)responseObject success:(void(^)(NSDictionary *data))success failure:(void(^)(NSDictionary *ErrorMsg))failure;
- (void)handleError:(NSError *)error onRequest:(AFHTTPRequestOperation *)request;
- (void)handleFailureFromRequest:(AFHTTPRequestOperation *)operation;

@end

@implementation NetworkClient

@synthesize baseURL;

SINGLETON_GCD(NetworkClient);

- (id) init {
    if ( (self = [super init]) ) {
        self.baseURL = [NSURL URLWithString:BASE_URL];
        self.pendingOperationQueue = [NSMutableArray arrayWithCapacity:40];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    }
    return self;
}

#pragma mark - Handle response from server

- (void)handleResponse:(id)responseObject success:(void(^)(NSDictionary *data))success failure:(void(^)(NSDictionary *ErrorMsg))failure
{
    BOOL result = [[responseObject objectForKey:@"Result"] boolValue];
    
    if (result) {
        if (success) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[responseObject objectForKey:@"Data"] forKey:@"data"];
            success(userInfo);
        }
    } else {
        if (failure) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[responseObject objectForKey:@"ErrorMsg"] forKey:@"ErrorMsg"];
            failure(userInfo);
        }
    }
}

- (void)handleError:(NSError *)error onRequest:(AFHTTPRequestOperation *)request
{
    if (request.response.statusCode == 403) {
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request.request];
        [op setCompletionBlock:request.completionBlock];
        [self.pendingOperationQueue addObject:op];
        
        [self getCsrfToken];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetToken:) name:MSG_GOT_TOKEN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetToken:) name:MSG_FAIL_GET_TOKEN object:nil];
    }
    
    NSDictionary *errInfo = @{};
    switch (error.code) {
        case -1004:
            errInfo = @{@"ErrorMsg": ERR_CANT_CONNECT_TO_SERVER};
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MSG_ERROR object:self userInfo:errInfo];
}

- (void)handleFailureFromRequest:(AFHTTPRequestOperation *)operation
{
    if (!isLogin()) {
        [self.pendingOperationQueue addObject:operation];
        [self getCsrfToken];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloginToSendRequest:) name:MSG_GOT_TOKEN object:nil];
    }
}

#pragma mark - Boxed network interface method

- (void)sendRequestWithType:(NSString *)type
                        url:(NSString *)url
                 parameters:(NSDictionary *)param
                    success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *parameters = param ? [NSMutableDictionary dictionaryWithDictionary:param] : nil;
    if (self.csrfToken) {
        [parameters setObject:self.csrfToken forKey:@"csrf_token"];
    }
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:[type uppercaseString]
                                                                                 URLString:url
                                                                                parameters:parameters];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    AFHTTPRequestOperation *op = [manager HTTPRequestOperationWithRequest:request
                                                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                      success(operation, responseObject);
                                                                  }
                                                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                      failure(operation, error);
                                                                  }];
    
    [manager.operationQueue addOperation:op];
}

#pragma mark - Transform data with server

- (void)getCsrfToken
{
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:[[NSURL URLWithString:@"/token" relativeToURL:self.baseURL] absoluteString]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [me handleResponse:responseObject
                        success:^(NSDictionary *data){
                            NSString *token = [data objectForKey:@"data"];
                            [me setCsrfToken:token];
                            // Save token for later use
                            [[NSUserDefaults standardUserDefaults] setObject:token forKey:SETTINGS_CSRF_TOKEN];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:MSG_GOT_TOKEN object:me];
                        }
                        failure:^(NSDictionary *ErrorMsg){
                            [self handleFailureFromRequest:operation];
                            [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_TOKEN object:me];
                        }];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self handleError:error onRequest:operation];
         }];
}

- (void)loginWithLoginname:(NSString *)loginname password:(NSString *)password
{
    NSDictionary *parameters = @{@"email": loginname, @"password": password};
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                          url:[[NSURL URLWithString:@"/account/mobilelogin" relativeToURL:self.baseURL] absoluteString]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data){
                                         NSString *nickname = [[data objectForKey:@"data"] objectForKey:@"Nickname"];
                                         [[NSUserDefaults standardUserDefaults] setObject:nickname forKey:SETTINGS_CURRENT_USER];
                                         [[NSUserDefaults standardUserDefaults] setObject:[[password dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString] forKey:SETTINGS_CURRENT_PWD];
                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                         
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_LOGIN
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg){
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_LOGIN
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)loginWithQQOpenId:(NSString *)openId
{
    NSDictionary *parameters = @{@"openId": openId};
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                          url:[[NSURL URLWithString:@"/cooperate/mobileqqlogin" relativeToURL:self.baseURL] absoluteString]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject success:^(NSDictionary *data) {
                              [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_LOGIN object:self];
                          } failure:^(NSDictionary *ErrorMsg) {
                              NSString *errorMsg = [ErrorMsg objectForKey:@"ErrorMsg"];
                              if ([errorMsg isEqualToString:@"not found"]) {
                                  [[NSNotificationCenter defaultCenter] postNotificationName:MSG_QQ_LOGIN_NOT_FOUND object:me];
                              }
                          }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)relogin
{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CURRENT_USER];
    NSString *encodedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CURRENT_PWD];
    NSData *decodedData = [NSData dataFromBase64String:encodedPassword];
    NSString *password = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    [self loginWithLoginname:username password:password];
}

- (void)logout
{
    if (!isLogin()) {
        return;
    }
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                          url:[[NSURL URLWithString:@"/account/mobilelogout" relativeToURL:self.baseURL] absoluteString]
                   parameters:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_LOGOUT
                                                                              object:me
                                                                            userInfo:nil];
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getHotBooks
{
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                          url:[[NSURL URLWithString:@"/book/gethotcategories" relativeToURL:self.baseURL] absoluteString]
                   parameters:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data){
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_HOTBOOKS
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg){
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_HOTBOOKS
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)registerWithNickname:(NSString *)nickname email:(NSString *)email password:(NSString *)password gender:(BOOL)isMan
{
    NSDictionary *parameters = @{
                                 @"nickname": nickname,
                                 @"email": email,
                                 @"password": password,
                                 @"sex": isMan ? @YES : @NO
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                          url:[[NSURL URLWithString:@"/account/mobileregister" relativeToURL:self.baseURL] absoluteString]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data){
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_REGISTER
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg){
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_REGISTER
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)registerWithQQNickname:(NSString *)nickname email:(NSString *)email openId:(NSString *)openId accessToken:(NSString *)accessToken avatarUrl:(NSString *)avatarUrl sex:(BOOL)isMan
{
    NSDictionary *parameters = @{
                                 @"nickname": nickname,
                                 @"email": email,
                                 @"openId": openId,
                                 @"accessToken": accessToken,
                                 @"avatarUrl": avatarUrl,
                                 @"sex": isMan ? @YES : @NO
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                          url:[[NSURL URLWithString:@"/cooperate/mobileqqregister" relativeToURL:self.baseURL] absoluteString]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_REGISTER
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_REGISTER
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)searchWithKeyword:(NSString *)keyword
{
    NSDictionary *parameters = @{
                                 @"q": keyword
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                          url:[[NSURL URLWithString:@"/mobilesearch" relativeToURL:self.baseURL] absoluteString]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_SEARCH_RESULT
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_SEARCH_RESULT
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getBasicUserInfo:(NSString *)username
{
    NSDictionary *parameters = nil;
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                          url:[[NSURL URLWithString:[NSString stringWithFormat:@"/mpeople/%@", [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] relativeToURL:self.baseURL] absoluteString]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_BASIC_USER_INFO
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_BASIC_USER_INFO
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getBookDetail:(NSString *)bookId
{
    NSDictionary *parameters = nil;
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                          url:[[NSURL URLWithString:[NSString stringWithFormat:@"/mbook/%@", bookId] relativeToURL:self.baseURL] absoluteString]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         NSLog(@"%@", data);
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_BOOK_DETAIL
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_BOOK_DETAIL
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

#pragma mark - Event handler

- (void)didGetToken:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_GOT_TOKEN object:nil];
    
    [self logout];
    [self resendRequest:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:MSG_DID_LOGOUT object:nil];
}

- (void)failGetToken:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_TOKEN object:nil];
    [self getCsrfToken];
}

- (void)didLogout:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_LOGOUT object:nil];
    [self relogin];
}

- (void)reloginToSendRequest:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_GOT_TOKEN object:nil];
    
    [self relogin];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resendRequest:) name:MSG_DID_LOGIN object:nil];
}

- (void)resendRequest:(NSNotification *)notification
{
    for (AFHTTPRequestOperation *op in self.pendingOperationQueue) {
        [[AFHTTPRequestOperationManager manager].operationQueue addOperation:op];
    }
}

@end
