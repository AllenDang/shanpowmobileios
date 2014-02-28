//
//  FilterViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-27.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoriesCell.h"

@class FilterViewController;

@protocol FilterDataSource <NSObject>

- (void)filterDataWithReadStatus:(BOOL)showAll categoryToShow:(NSString *)category scoreToShow:(NSInteger)score;

@end

@interface FilterViewController : UITableViewController <CategoriesCellDelegate>

@property (nonatomic, strong) id<FilterDataSource> dataSource;

@property (nonatomic, readonly) BOOL showAll;
@property (nonatomic, readonly) NSString *categoryToShow;
@property (nonatomic, readonly) NSInteger scoreToShow;

@end
