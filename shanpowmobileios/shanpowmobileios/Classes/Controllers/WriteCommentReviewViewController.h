//
//  WriteCommentReviewViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-14.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "SPTextView.h"
#import "AMRatingControl.h"
#import "NetworkClient.h"

@interface WriteCommentReviewViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSString *bookId;

@property (nonatomic, strong) NSString *bookTitle;
@property (nonatomic, strong) NSString *bookImageUrl;
@property (nonatomic, strong) NSString *bookCategory;

@end
