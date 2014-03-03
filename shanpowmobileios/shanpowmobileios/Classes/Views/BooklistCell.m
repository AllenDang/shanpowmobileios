//
//  BooklistCell.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-3.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "BooklistCell.h"

@interface BooklistCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@end

@implementation BooklistCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, self.frame.size.width - 40, TextHeightWithFont(LARGE_FONT))];
        self.titleLabel.text = self.title;
        self.titleLabel.font = LARGE_FONT;
        [self addSubview:self.titleLabel];
        
        self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 35.0, self.frame.size.width - 40, self.frame.size.height / 2)];
        self.subTitleLabel.text = self.subTitle;
        self.subTitleLabel.numberOfLines = 2;
        self.subTitleLabel.font = SMALL_FONT;
        self.subTitleLabel.textColor = UIC_BRIGHT_GRAY(0.5);
        [self addSubview:self.subTitleLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTitle:(NSString *)title
{
    if (![_title isEqualToString:title]) {
        _title = title;
        
        self.titleLabel.text = title;
    }
}

- (void)setSubTitle:(NSString *)subTitle
{
    if (![_subTitle isEqualToString:subTitle]) {
        _subTitle = subTitle;
        
        self.subTitleLabel.text = subTitle;
    }
}

- (void)setShowDescription:(BOOL)showDescription
{
    if (_showDescription != showDescription) {
        _showDescription = showDescription;
        
        [self updateUILayout];
    }
}

#pragma mark - UI
- (void)updateUILayout
{
    if (self.showDescription) {
        self.titleLabel.frame = CGRectMake(10.0, 10.0, self.frame.size.width - 40, TextHeightWithFont(LARGE_FONT));
        
        self.subTitleLabel.frame = CGRectMake(10.0, 35.0, self.frame.size.width - 40, self.frame.size.height / 2);
    } else {
        self.titleLabel.frame = CGRectMake(10.0, 10.0, self.frame.size.width - 40, self.frame.size.height);
        self.subTitleLabel.frame = CGRectZero;
    }
}

@end
