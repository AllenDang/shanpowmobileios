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

@interface BookGridViewController : UITableViewController

@property (nonatomic, strong) NSArray *books;
@property (nonatomic, assign) BOOL needShowExtraInfo;

@end
