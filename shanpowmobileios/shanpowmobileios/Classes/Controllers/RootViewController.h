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
#import "MainMenuViewController.h"
#import "LoginViewController.h"

@interface RootViewController : UIViewController

@property (strong, nonatomic) UITableView *mainTable;
@property (strong, nonatomic) NSArray *tableData;

@end
