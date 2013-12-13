//
//  RootViewController.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-3.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "NetworkClient.h"
#import "LoginViewController.h"
#import "HotBooksViewController.h"

@interface RootViewController : UITableViewController

@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) HotBooksViewController *hotBooksViewController;
@property (strong, nonatomic) UITableView *mainTable;
@property (strong, nonatomic) NSArray *tableData;

@end
