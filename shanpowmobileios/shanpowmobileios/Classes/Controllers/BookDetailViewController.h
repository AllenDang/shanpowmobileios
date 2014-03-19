//
//  BookDetailViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-20.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "NetworkClient.h"
#import "CommentReviewView.h"
#import "AwesomeMenu.h"
#import "WriteCommentReviewViewController.h"
#import "AddToBooklistViewController.h"


@interface BookDetailViewController : UITableViewController <AwesomeMenuDelegate>

@property (nonatomic, strong) NSString *bookId;

@end
