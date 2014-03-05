//
//  ReadRecordViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-4.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "FilterViewController.h"

@interface ReadRecordViewController : UITableViewController <FilterDataSource>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *avatarUrl;

@end
