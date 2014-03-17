//
//  RankingDetailCell.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-12.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "RankingDetailCell.h"
#import "ChatBubble.h"

@interface RankingDetailCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;

@property (nonatomic, strong) ChatBubble *reasonBubble;

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
        
        self.reasonBubble = [[ChatBubble alloc] initWithFrame:CGRectZero];
        [self addSubview:self.reasonBubble];
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
    self.reasonBubble.content = [self.book objectForKey:@"Comment"];
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
    
    self.reasonBubble.frame = CGRectMake(10.0,
                                         GENERAL_CELL_HEIGHT * 1.5 + 5,
                                         self.bounds.size.width - 20,
                                         self.reasonBubble.calculatedHeight);
    self.reasonBubble.style = CBStyleLight;
    self.reasonBubble.font = MEDIUM_FONT;
    self.reasonBubble.avatarLocation = CB_AvatarLocationNone;
}

@end
