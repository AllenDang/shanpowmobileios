//
//  HotBooksViewController.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-5.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkClient.h"
#import "UIKit+AFNetworking.h"
#import "Common.h"
#import "BookGridViewController.h"

@interface HotBooksViewController : UIViewController

@property (strong, nonatomic) NSArray *categories;

@end
