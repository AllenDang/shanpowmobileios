//
//  BookGridViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-12.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "BookInfoCell.h"
#import "BookDetailViewController.h"

@interface BookGridViewController : UITableViewController

@property (nonatomic, strong) NSArray *books;
@property (nonatomic, assign) BOOL needShowExtraInfo;
@property (nonatomic, assign) BOOL isPlain;
@property (nonatomic, assign) BOOL needLoadMore;

@property (nonatomic, readonly) float headerHeight;
@property (nonatomic, readonly) float bookCellHeight;

@end
