//
//  UserListViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-18.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "UIImageView+AFNetworking.h"

@interface UserListViewController : UITableViewController

@property (nonatomic, assign) BOOL isSimple;
@property (nonatomic, strong) NSArray *users;

@end
