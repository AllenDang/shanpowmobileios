//
//  SearchResultViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-18.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "BookGridViewController.h"
#import "BooklistGridViewController.h"
#import "UserListViewController.h"

@interface SearchResultViewController : UIViewController

@property (nonatomic, strong) NSDictionary *searchResult;

- (id)initWithSearchResult:(NSDictionary *)searchResult;

@end
