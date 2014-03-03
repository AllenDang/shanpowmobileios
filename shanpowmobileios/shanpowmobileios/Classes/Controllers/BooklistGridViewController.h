//
//  BooklistGridViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-18.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

typedef enum {
    BGM_DisplayMode = 0,
    BGM_SelectionMode = 1
} BooklistGridMode;

@interface BooklistGridViewController : UITableViewController

@property (nonatomic, strong) NSArray *booklists;
@property (nonatomic, assign) BOOL showDescription;
@property (nonatomic, assign) BooklistGridMode mode;

@end
