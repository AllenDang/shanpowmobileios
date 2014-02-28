//
//  BooklistDetailViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-27.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "MMDrawerController.h"
#import "FilterViewController.h"

@interface BooklistDetailInfoViewController : UITableViewController <FilterDataSource>

@property (nonatomic, readonly) NSDictionary *booklist;
@property (nonatomic, strong) NSString *booklistId;

@end
