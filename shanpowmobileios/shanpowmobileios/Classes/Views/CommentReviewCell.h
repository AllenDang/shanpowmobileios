//
//  CommentReviewCell.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-6.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface CommentReviewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *comment;
@property (nonatomic, assign) BOOL showBookInfo;
@property (nonatomic, assign) BOOL showMegaInfo;

@end
