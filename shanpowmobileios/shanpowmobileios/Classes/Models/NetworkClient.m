//
//  NetworkClient.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-2.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "NetworkClient.h"

@interface NetworkClient ()

- (void)handleResponse:(id)responseObject success:(void(^)(NSDictionary *data))success failure:(void(^)(NSDictionary *ErrorMsg))failure;

@end

@implementation NetworkClient

@synthesize baseURL;

SINGLETON_GCD(NetworkClient);

- (id) init {
    if ( (self = [super init]) ) {
        self.baseURL = [NSURL URLWithString:BASE_URL];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    }
    return self;
}

#pragma mark -
#pragma mark Handle response from server
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

#pragma mark -
#pragma mark Transform data with server
- (void)getCsrfToken
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];

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
                            NSLog(@"Error: %@", ErrorMsg);
                        }];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"ErrorOnGetToken: %@", error);
         }];
}

- (void)loginWithLoginname:(NSString *)loginname password:(NSString *)password
{
    if (self.csrfToken == nil) {
        [self getCsrfToken];
        return;
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"email": loginname, @"password": password, @"csrf_token": self.csrfToken};

    __block NetworkClient *me = [NetworkClient sharedNetworkClient];

    [manager POST:[[NSURL URLWithString:@"/account/mobilelogin" relativeToURL:self.baseURL] absoluteString]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [me handleResponse:responseObject 
                         success:^(NSDictionary *data){
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
              NSLog(@"ErrorOnLogin: %@", error);
          }];
}

- (void)logout
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"csrf_token": self.csrfToken};
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [manager POST:[[NSURL URLWithString:@"/account/mobilelogout" relativeToURL:self.baseURL] absoluteString]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [me handleResponse:responseObject 
                         success:^(NSDictionary *data){
                             [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_LOGOUT 
                                                                                 object:me 
                                                                               userInfo:data];
                         } 
                         failure:^(NSDictionary *ErrorMsg){
                             [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_LOGOUT 
                                                                                 object:me 
                                                                               userInfo:ErrorMsg];
                         }];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"ErrorOnLogout: %@", error);
          }];
}

- (void)getHotBooks
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"csrf_token": self.csrfToken};
    
    __block NetworkClient *me = [NetworkClient sharedNetworkClient];
    
    [manager POST:[[NSURL URLWithString:@"/book/gethotcategories" relativeToURL:self.baseURL] absoluteString]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [me handleResponse:responseObject 
                         success:^(NSDictionary *data){
                             [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_GET_HOTBOOKS 
                                                                                 object:me 
                                                                               userInfo:data];
                         } 
                         failure:^(NSDictionary *ErrorMsg){
                             [[NSNotificationCenter defaultCenter] postNotificationName:MSG_FAIL_GET_HOTBOOKS 
                                                                                 object:me 
                                                                               userInfo:ErrorMsg];
                         }];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"ErrorOnLogout: %@", error);
          }];
}

@end
