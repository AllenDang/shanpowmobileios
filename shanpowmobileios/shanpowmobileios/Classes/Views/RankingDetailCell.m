//
//  RankingDetailCell.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-12.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "RankingDetailCell.h"

@interface RankingDetailCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UIButton *reasonButton;

@end

@implementation RankingDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, self.bounds.size.width - 100, TextHeightWithFont(MEDIUM_BOLD_FONT))];
        self.titleLabel.font = MEDIUM_BOLD_FONT;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        
        self.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                     self.frame.size.height - TextHeightWithFont(MEDIUM_FONT) - 10,
                                                                     self.bounds.size.width - 100,
                                                                     TextHeightWithFont(MEDIUM_FONT))];
        self.authorLabel.font = MEDIUM_FONT;
        self.authorLabel.textColor = UIC_BRIGHT_GRAY(0.5);
        self.authorLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.authorLabel];
        
        self.reasonButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.reasonButton.layer.cornerRadius = 4;
        self.reasonButton.layer.borderWidth = 1;
        self.reasonButton.layer.borderColor = UIC_CYAN(1.0).CGColor;
        self.reasonButton.titleLabel.font = SMALL_FONT;
        [self.reasonButton setTitleColor:UIC_CYAN(1.0) forState:UIControlStateNormal];
        [self.reasonButton setTitle:@"上榜理由" forState:UIControlStateNormal];
        [self.reasonButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.reasonButton];
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

- (void)setBook:(NSDictionary *)book
{
    if (![book isEqualToDictionary:_book]) {
        _book = book;
        
        [self updateUIData];
    }
}

- (void)updateUIData
{
    self.titleLabel.text = [self.book objectForKey:@"Title"];
    self.authorLabel.text = [self.book objectForKey:@"Author"];
}

- (void)layoutSubviews
{
    self.titleLabel.frame = CGRectMake(10.0,
                                       15.0,
                                       self.bounds.size.width - 100,
                                       TextHeightWithFont(MEDIUM_BOLD_FONT));
    
    self.authorLabel.frame = CGRectMake(10.0,
                                        self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 15,
                                        self.bounds.size.width - 100,
                                        TextHeightWithFont(MEDIUM_FONT));
    
    self.reasonButton.frame = CGRectMake(self.bounds.size.width - 80,
                                         (self.frame.size.height - 25) / 2,
                                         70,
                                         25);
}

- (void)buttonTapped:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MSG_TAPPED_REASON object:self userInfo:@{
                                                                                                        @"Sender": sender,
                                                                                                        @"BookId":[self.book objectForKey:@"Id"]
                                                                                                        }];
}

@end
