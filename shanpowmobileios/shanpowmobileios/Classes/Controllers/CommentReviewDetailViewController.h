//
//  CommentReviewDetailViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-6.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface CommentReviewDetailViewController : UITableViewController

@property (nonatomic, strong) NSString *reviewId;
@property (nonatomic, strong) NSString *bookId;
@property (nonatomic, strong) NSString *authorId;

@property (nonatomic, strong) NSString *bookTitle;
@property (nonatomic, strong) NSString *bookCategory;

- (id)initWithStyle:(UITableViewStyle)style isReview:(BOOL)isReview;

@end
