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
        if ([[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CSRF_TOKEN]) {
            self.csrfToken = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CSRF_TOKEN];
        }
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
                       path:(NSString *)urlPath
                 parameters:(NSDictionary *)param
                    success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *parameters = param ? [NSMutableDictionary dictionaryWithDictionary:param] : nil;
    if (self.csrfToken) {
        [parameters setObject:self.csrfToken forKey:@"csrf_token"];
    }
    
    NSString *url = [[NSURL URLWithString:[urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] relativeToURL:self.baseURL] absoluteString];
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
    
    [self sendRequestWithType:@"GET"
                         path:@"/token"
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
                         path:@"/account/mobilelogin"
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data){
                                         NSString *nickname = [[data objectForKey:@"data"] objectForKey:@"Nickname"];
                                         NSString *userId = [[data objectForKey:@"data"] objectForKey:@"Id"];
                                         [[NSUserDefaults standardUserDefaults] setObject:nickname forKey:SETTINGS_CURRENT_USER];
                                         [[NSUserDefaults standardUserDefaults] setObject:[[password dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString] forKey:SETTINGS_CURRENT_PWD];
                                         [[NSUserDefaults standardUserDefaults] setObject:userId forKey:SETTINGS_CURRENT_USER_ID];
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
                         path:@"/cooperate/mobileqqlogin"
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
                         path:@"/account/mobilelogout"
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
                         path:@"/book/gethotcategories"
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
                         path:@"/account/mobileregister"
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
                         path:@"/cooperate/mobileqqregister"
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
                         path:@"/mobilesearch"
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
                         path:[NSString stringWithFormat:@"/mpeople/%@", username]
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
                         path:[NSString stringWithFormat:@"/mbook/%@", bookId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
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

- (void)markBookWithBookId:(NSString *)bookId markType:(NSString *)markType score:(NSInteger)score content:(NSString *)content isShareToQQ:(BOOL)shareToQQ isShareToWeibo:(BOOL)shareToWeibo
{
    NSDictionary *parameters = @{
                                 @"markType": markType,
                                 @"score": [NSNumber numberWithInteger:score],
                                 @"content": content,
                                 @"isShareToQQ": [NSNumber numberWithBool:shareToQQ],
                                 @"isShareToWeibo": [NSNumber numberWithBool:shareToWeibo]
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                         path:[NSString stringWithFormat:@"/book/%@/mark", bookId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_MARK_BOOK
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_MARK_BOOK
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)postReviewWithBookId:(NSString *)bookId params:(NSDictionary *)options
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:options];
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                         path:[NSString stringWithFormat:@"/book/%@/addreview", bookId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_POST_REVIEW
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_POST_REVIEW
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getBooklistsByAuthorId:(NSString *)authorId
{
    NSDictionary *parameters = nil;
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:[NSString stringWithFormat:@"/booklist/getsimplebooklists/%@", authorId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_BOOKLISTS
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_BOOKLISTS
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getBooklistsBySubscriberId:(NSString *)subscriberId
{
    NSDictionary *parameters = nil;
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:[NSString stringWithFormat:@"/booklist/getsimplebooklistsbysubscriberid/%@", subscriberId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_BOOKLISTS
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_BOOKLISTS
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getBooklistsByBookId:(NSString *)bookId
{
    NSDictionary *parameters = nil;
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:[NSString stringWithFormat:@"/booklist/getallbooklistscontainsbookid/%@", bookId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_BOOKLISTS
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_BOOKLISTS
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getBooklistDetailById:(NSString *)booklistId
{
    NSDictionary *parameters = nil;
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:[NSString stringWithFormat:@"/mbooklist/%@", booklistId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_BOOKLIST_DETAIL
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_BOOKLIST_DETAIL
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)addBook:(NSString *)bookId toBooklist:(NSString *)booklistId
{
    NSDictionary *parameters = @{
                                 @"bookId": bookId
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"PUT"
                         path:[NSString stringWithFormat:@"/booklist/%@/addbook", booklistId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_ADD_BOOK_TO_BOOKLIST
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_ADD_BOOK_TO_BOOKLIST
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)createBooklistWithTitle:(NSString *)title description:(NSString *)description
{
    NSDictionary *parameters = @{
                                 @"bookId": @"",
                                 @"title": title,
                                 @"description": description
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                         path:@"/booklist/create"
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_CREATE_BOOKLIST
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_CREATE_BOOKLIST
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getReadRecordsByUserName:(NSString *)username markType:(NSInteger)markType range:(NSRange)range
{
    NSDictionary *parameters = @{
                                 @"pageNum": @(range.location),
                                 @"numPerPage": @(range.length),
                                 @"markType": @(markType)
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];

    [self sendRequestWithType:@"GET"
                         path:[NSString stringWithFormat:@"/people/%@/getmorebooks", username]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_READ_RECORD
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_READ_RECORD
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getBooksByCategory:(NSString *)category range:(NSRange)range
{
    NSDictionary *parameters = @{
                                 @"pageNum": @(range.location),
                                 @"numPerPage": @(range.length)
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:[NSString stringWithFormat:@"/mcategory/%@", category]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_BOOKS
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_BOOKS
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getReivewsByCategory:(NSString *)category channel:(FilterChannel)channel score:(NSInteger)score range:(NSRange)range
{
    NSDictionary *parameters = @{
                                 @"pageNum": @(range.location),
                                 @"numPerPage": @(range.length),
                                 @"category": category,
                                 @"score": @(score),
                                 @"reviewType": @(channel)
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:@"/mreview/all"
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_REVIEWS
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_REVIEWS
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getReviewDetailById:(NSString *)reviewId
{
    NSDictionary *parameters = nil;
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:[NSString stringWithFormat:@"/mreview/%@", reviewId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_REVIEW_DETAIL
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_REVIEW_DETAIL
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getCommentDetailByBookId:(NSString *)bookId authorId:(NSString *)authorId
{
    NSDictionary *parameters = nil;
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:[NSString stringWithFormat:@"/mbook/%@/getcomment/%@", bookId, authorId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_COMMENT_DETAIL
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_COMMENT_DETAIL
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)likeCommentByBookId:(NSString *)bookId authorId:(NSString *)authorId
{
    NSDictionary *parameters = @{
                                 @"authorId": authorId
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                         path:[NSString stringWithFormat:@"/book/%@/likecomment", bookId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_LIKE_COMMENT
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_LIKE_COMMENT
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)dislikeCommentByBookId:(NSString *)bookId authorId:(NSString *)authorId
{
    NSDictionary *parameters = @{
                                 @"authorId": authorId
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                         path:[NSString stringWithFormat:@"/book/%@/dislikecomment", bookId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_DISLIKE_COMMENT
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_DISLIKE_COMMENT
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)likeReviewByBookId:(NSString *)bookId reviewId:(NSString *)reviewId
{
    NSDictionary *parameters = @{
                                 @"bookId": bookId
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                         path:[NSString stringWithFormat:@"/review/%@/like", reviewId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_LIKE_REVIEW
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_LIKE_REVIEW
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)dislikeReviewByBookId:(NSString *)bookId reviewId:(NSString *)reviewId
{
    NSDictionary *parameters = @{
                                 @"bookId": bookId
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                         path:[NSString stringWithFormat:@"/review/%@/dislike", reviewId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_DISLIKE_REVIEW
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_DISLIKE_REVIEW
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)responseToComment:(NSString *)content bookId:(NSString *)bookId commentAuthorId:(NSString *)authorId
{
    NSDictionary *parameters = @{
                                 @"content": content
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                         path:[NSString stringWithFormat:@"/book/%@/%@/response", bookId, authorId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_RESPONSE_TO_COMMENT
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_RESPONSE_TO_COMMENT
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)responseToReview:(NSString *)content bookId:(NSString *)bookId reviewId:(NSString *)reviewId
{
    NSDictionary *parameters = @{
                                 @"content": content,
                                 @"bookId": bookId
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"POST"
                         path:[NSString stringWithFormat:@"/review/%@/response", reviewId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_RESPONSE_TO_REVIEW
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_RESPONSE_TO_REVIEW
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getWizardResult
{
    NSDictionary *parameters = nil;
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:@"/book/recommendations"
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_WIZARD_RESULT
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_WIZARD_RESULT
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getSimilarBooksById:(NSString *)bookId
{
    NSDictionary *parameters = nil;
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:[NSString stringWithFormat:@"/book/getsimilarbooksbyid/%@", bookId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_BOOKS
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_BOOKS
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getBooksBySameAuthor:(NSString *)author
{
    NSDictionary *parameters = nil;
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:[NSString stringWithFormat:@"/book/getbooksbyauthor/%@", author]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_BOOKS
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_BOOKS
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getTitlesOfAllRankingListForMan:(BOOL)forMan
{
    NSDictionary *parameters = @{
                                 @"isForMan": [NSNumber numberWithBool:forMan]
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:@"/editor/gettitlesofbookbillboard"
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_RANKINGLIST_TITLES
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_RANKINGLIST_TITLES
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getRankingDetailById:(NSString *)rankingId
{
    NSDictionary *parameters = nil;
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:[NSString stringWithFormat:@"/editor/getbookbillboardbyid/%@", rankingId]
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_RANKINGLIST_DETAIL
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_RANKINGLIST_DETAIL
                                                                                             object:me
                                                                                           userInfo:ErrorMsg];
                                     }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [self handleError:error onRequest:operation];
                      }];
}

- (void)getRankingDetailByTitle:(NSString *)title version:(NSString *)ver
{
    NSDictionary *parameters = @{
                                 @"title": title,
                                 @"version": ver
                                 };
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [self sendRequestWithType:@"GET"
                         path:@"/editor/getbookbillboardbytitleandversion"
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [me handleResponse:responseObject
                                     success:^(NSDictionary *data) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_RANKINGLIST_DETAIL
                                                                                             object:me
                                                                                           userInfo:data];
                                     }
                                     failure:^(NSDictionary *ErrorMsg) {
                                         [self handleFailureFromRequest:operation];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_RANKINGLIST_DETAIL
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
