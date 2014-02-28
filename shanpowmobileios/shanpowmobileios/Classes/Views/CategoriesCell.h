//
//  CategoriesCell.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-28.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@class CategoriesCell;

@protocol CategoriesCellDelegate <NSObject>

- (void)categorySelected:(NSString *)category;

@optional
- (BOOL)shouldSelectCategory:(NSString *)category;

@end

@interface CategoriesCell : UITableViewCell

@property (nonatomic, weak) id<CategoriesCellDelegate> delegate;
@property (nonatomic, readonly) NSString *selectedCategory;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellHeight:(float)cellHeight width:(float)width;
- (void)clearSelection;

@end