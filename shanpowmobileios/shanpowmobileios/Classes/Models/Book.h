//
//  Book.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-23.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

@property (strong, nonatomic) NSString *Id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *bookCoverUrl;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSDictionary *simpleComment;
@property (assign, nonatomic) float score;
@property (assign, nonatomic) long ratingSum;

+ (id)bookFromDictionary:(NSDictionary *)dict;

@end
