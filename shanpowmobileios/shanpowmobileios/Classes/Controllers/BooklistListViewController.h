//
//  BooklistListViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-26.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BLDS_CreateAuthor = 0,
    BLDS_FavedBy = 1
} BooklistDataSource;

@interface BooklistListViewController : UIViewController

@property (nonatomic, assign) BooklistDataSource dataSource;

@property (nonatomic, strong) NSString *authorId;

@end
