//
//  CategoriesCell.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-28.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "CategoriesCell.h"

@interface CategoriesCell ()

@property (nonatomic, assign) float cellHeight;

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) UIButton *lastSelectedButton;
@property (nonatomic, strong) NSString *selectedCategory;

@end

@implementation CategoriesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellHeight:(float)cellHeight width:(float)width
{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = UIC_ALMOSTWHITE(1.0);
        self.cellHeight = cellHeight;
        self.categories = @[@"玄幻", @"奇幻", @"架空", @"仙侠", @"武侠", @"历史", @"穿越", @"都市", @"青春", @"竞技", @"悬疑", @"恐怖", @"官场", @"科幻", @"军事", @"言情", @"耽美", @"穿越", @"种田", @"豪门"];
        
        for (int i = 0; i < 20; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0.0 + (width / 4) * (i % 4),
                                   0.0 + self.cellHeight * (int)(i / 4),
                                   width / 4 - 0.5,
                                   self.cellHeight - 0.5);
            btn.backgroundColor = UIC_BRIGHT_GRAY(1.0);
            [btn setTitle:[self.categories objectAtIndex:i] forState:UIControlStateNormal];
            [btn setTitleColor:UIC_ALMOSTWHITE(1.0) forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(categorySelected:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = MEDIUM_FONT;
            
            [self addSubview:btn];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)clearSelection
{
    if (self.lastSelectedButton) {
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.lastSelectedButton.backgroundColor = UIC_BRIGHT_GRAY(1.0);
                         }];
    }
}

- (void)categorySelected:(UIButton *)sender
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(shouldSelectCategory:)]) {
            if (![self.delegate shouldSelectCategory:sender.titleLabel.text]) {
                return;
            }
        }
    }
    
    self.selectedCategory = sender.titleLabel.text;
    
    if (self.lastSelectedButton) {
        self.lastSelectedButton.backgroundColor = UIC_BRIGHT_GRAY(1.0);
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.lastSelectedButton.backgroundColor = UIC_BRIGHT_GRAY(1.0);
                         }];
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         sender.backgroundColor = UIC_BRIGHT_GRAY(0.5);
                     }
                     completion:^(BOOL finished) {
                         self.lastSelectedButton = sender;
                         if (self.delegate) {
                             [self.delegate categorySelected:sender.titleLabel.text];
                         }
                     }];
}

@end
