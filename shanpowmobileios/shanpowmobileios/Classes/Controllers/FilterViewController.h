//
//  FilterViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-27.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoriesCell.h"
#import "Common.h"

@class FilterViewController;

@protocol FilterDataSource <NSObject>

- (void)filterDataWithReadStatus:(BOOL)showAll channel:(FilterChannel)channel categoryToShow:(NSString *)category scoreToShow:(NSInteger)score;

@end

@interface FilterViewController : UITableViewController <CategoriesCellDelegate>

@property (nonatomic, strong) id<FilterDataSource> dataSource;

@property (nonatomic, assign) BOOL showReadStatus;
@property (nonatomic, assign) BOOL showChannel;

@property (nonatomic, assign) BOOL showAll;
@property (nonatomic, strong) NSString *categoryToShow;
@property (nonatomic, assign) NSInteger scoreToShow;
@property (nonatomic, assign) FilterChannel channel;

@end
