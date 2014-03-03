//
//  RightSubtitleCell.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-27.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "RightSubtitleCell.h"
#import "Common.h"

@interface RightSubtitleCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation RightSubtitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.bounds.size.width, self.bounds.size.height)];
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width - 40, self.bounds.size.height)];
        
        self.titleLabel.textColor = UIC_BRIGHT_GRAY(1.0);
        self.titleLabel.font = MEDIUM_FONT;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.text = self.title;
        
        self.subtitleLabel.textColor = UIC_BLACK(0.3);
        self.subtitleLabel.textAlignment = NSTextAlignmentRight;
        self.subtitleLabel.font = SMALL_FONT;
        self.subtitleLabel.text = self.rightTitle;
        self.subtitleLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.subtitleLabel];
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
    if (![title isEqualToString:_title]) {
        _title = title;
        
        self.titleLabel.text = title;
    }
}

- (void)setRightTitle:(NSString *)rightTitle
{
    if (![rightTitle isEqualToString:_rightTitle]) {
        _rightTitle = rightTitle;
        
        self.subtitleLabel.text = rightTitle;
    }
}

@end
