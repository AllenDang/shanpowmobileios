//
//  ReviewListViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-6.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "FilterViewController.h"

@interface ReviewListViewController : UITableViewController <FilterDataSource>

@property (nonatomic, strong) NSString *bookId;
@property (nonatomic, assign) BOOL isComment;
@property (nonatomic, assign) NSInteger itemSum;

@end
