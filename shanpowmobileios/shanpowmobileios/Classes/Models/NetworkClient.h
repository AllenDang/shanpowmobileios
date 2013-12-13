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

@interface NetworkClient : NSObject

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *csrfToken;

+ (NetworkClient *)sharedNetworkClient;

- (void)getCsrfToken;
- (void)loginWithLoginname:(NSString *)loginname password:(NSString *)password;
- (void)logout;
- (void)getHotBooks;

@end
