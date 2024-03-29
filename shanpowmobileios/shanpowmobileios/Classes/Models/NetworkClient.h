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
#import "SPLoadingView.h"

@interface NetworkClient : NSObject

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *csrfToken;

+ (NetworkClient *)sharedNetworkClient;

- (void)sendRequestWithType:(NSString *)type
                       path:(NSString *)urlPath
                 parameters:(NSDictionary *)param
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

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
- (void)getFavBooksByUser:(NSString *)username;
- (void)getFollowersByUser:(NSString *)username;
- (void)getFollowingsByUser:(NSString *)username;
- (void)followUser:(NSString *)username;
- (void)unfollowUser:(NSString *)username;

- (void)getBookDetail:(NSString *)bookId;

- (void)getBooksByCategory:(NSString *)category range:(NSRange)range;
- (void)getSimilarBooksById:(NSString *)bookId;
- (void)getBooksBySameAuthor:(NSString *)author;

- (void)markBookWithBookId:(NSString *)bookId markType:(NSString *)markType score:(NSInteger)score content:(NSString *)content isShareToQQ:(BOOL)shareToQQ isShareToWeibo:(BOOL)shareToWeibo;
- (void)postReviewWithBookId:(NSString *)bookId params:(NSDictionary *)options;

- (void)getBooklistsByAuthorId:(NSString *)authorId;
- (void)getBooklistsBySubscriberId:(NSString *)subscriberId;
- (void)getBooklistsByBookId:(NSString *)bookId;
- (void)getBooklistDetailById:(NSString *)booklistId;

- (void)addBook:(NSString *)bookId toBooklist:(NSString *)booklistId;

- (void)createBooklistWithTitle:(NSString *)title description:(NSString *)description;

- (void)getReadRecordsByUserName:(NSString *)username markType:(NSInteger)markType range:(NSRange)range;

- (void)getReviewsByCategory:(NSString *)category channel:(FilterChannel)channel score:(NSInteger)score range:(NSRange)range;
- (void)getReviewDetailById:(NSString *)reviewId;
- (void)getCommentDetailByBookId:(NSString *)bookId authorId:(NSString *)authorId;
- (void)getMoreCommentsByBookId:(NSString *)bookId range:(NSRange)range;
- (void)getMoreReviewsByBookId:(NSString *)bookId range:(NSRange)range;

- (void)likeCommentByBookId:(NSString *)bookId authorId:(NSString *)authorId;
- (void)dislikeCommentByBookId:(NSString *)bookId authorId:(NSString *)authorId;
- (void)likeReviewByBookId:(NSString *)bookId reviewId:(NSString *)reviewId;
- (void)dislikeReviewByBookId:(NSString *)bookId reviewId:(NSString *)reviewId;

- (void)responseToComment:(NSString *)content bookId:(NSString *)bookId commentAuthorId:(NSString *)authorId;
- (void)responseToReview:(NSString *)content bookId:(NSString *)bookId reviewId:(NSString *)reviewId;

- (void)getWizardResult;

- (void)getTitlesOfAllRankingListForMan:(BOOL)forMan;
- (void)getRankingDetailById:(NSString *)rankingId;
- (void)getRankingDetailByTitle:(NSString *)title version:(NSString *)ver;

@end
