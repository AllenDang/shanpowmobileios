//
//  AccessoryTypeDotTableViewCell.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-11.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "AccessoryTypeDotTableViewCell.h"

@interface AccessoryTypeDotTableViewCell ()

@property (nonatomic, strong) UIImageView *dotView;
@property (nonatomic, assign) CGFloat dotSize;

@end

@implementation AccessoryTypeDotTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.dotColor = UIC_CYAN(1.0);
        
        self.dotSize = 8.0;
        
        self.dotView = [[UIImageView alloc] init];
        self.dotView.image = [[[UIImage imageWithColor:self.dotColor] scaledToSize:CGSizeMake(self.dotSize * 2, self.dotSize * 2) ] makeRoundedImageWithRadius:self.dotSize];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setter

- (void)setShowDot:(BOOL)showDot
{
    if (showDot != _showDot) {
        _showDot = showDot;
    }
    
    if (showDot) {
        self.dotView.frame = CGRectMake(self.bounds.size.width - 20,
                                        self.textLabel.frame.origin.y,
                                        self.dotSize,
                                        self.dotSize);
        self.dotView.center = CGPointMake(self.dotView.frame.origin.x, GENERAL_CELL_HEIGHT / 2);
        [self addSubview:self.dotView];
        self.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [self.dotView removeFromSuperview];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void)setDotColor:(UIColor *)dotColor
{
    if (![dotColor isEqual:_dotColor]) {
        _dotColor = dotColor;
        
        self.dotView.image = [[UIImage imageWithColor:self.dotColor] makeRoundedImageWithRadius:self.dotSize];
    }
}

@end
