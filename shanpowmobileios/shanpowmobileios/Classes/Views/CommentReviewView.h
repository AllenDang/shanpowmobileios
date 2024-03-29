//
//  CommentReviewView.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-24.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMRatingControl.h"
#import "Common.h"
#import "UIImageView+AFNetworking.h"

@interface CommentReviewView : UIView

@property (nonatomic, strong) NSDictionary *comment;
@property (nonatomic, assign) BOOL showBookInfo;
@property (nonatomic, assign) BOOL showMegaInfo;
@property (nonatomic, assign) BOOL isDetailMode;

@property (nonatomic, readonly) CGFloat calculatedHeight;

@end
