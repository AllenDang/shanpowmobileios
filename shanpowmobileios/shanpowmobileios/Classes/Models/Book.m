//
//  Book.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-23.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "Book.h"

@implementation Book

+ (id)bookFromDictionary:(NSDictionary *)dict
{
    NSString *bookTitle = [dict objectForKey:@"Title"];
    NSString *category = [dict objectForKey:@"Category"];
    NSString *author = [dict objectForKey:@"Author"];
    NSString *status = [dict objectForKey:@"Status"];
    NSString *Id = [dict objectForKey:@"Id"];
    NSString *description = [dict objectForKey:@"Summary"];
    NSDictionary *simpleComment = [dict objectForKey:@"Comment"];
    float score = [[dict objectForKey:@"Score"] length] > 0 ? [[dict objectForKey:@"Score"] floatValue] : [[dict objectForKey:@"UserScore"] floatValue];
    long ratingSum = [[dict objectForKey:@"RatingSum"] longValue];
    
    Book *book = [[Book alloc] init];
    if (book) {
        book.title = bookTitle;
        book.category = category;
        book.author = author;
        book.status = status;
        book.Id = Id;
        book.score = score;
        book.ratingSum = ratingSum;
        book.summary = description;
        if ([[simpleComment objectForKey:@"Author"] length] <= 0 || [[simpleComment objectForKey:@"Content"] length] <= 0) {
            book.simpleComment = nil;
        } else {
            book.simpleComment = simpleComment;
        }
    }
    
    return book;
}

@end
