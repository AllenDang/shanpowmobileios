//
//  BooklistDetailInfoCell.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-27.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "BooklistDetailInfoCell.h"
#import "Common.h"
#import "UIImageView+AFNetworking.h"

@interface BooklistDetailInfoCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *timeStampLabel;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) UILabel *descriptionLabel;

@property (nonatomic, assign) float generalMargin;
@property (nonatomic, assign) float avatarSize;

@end

@implementation BooklistDetailInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.titleLabel = [[UILabel alloc] init];
        self.avatarImageView = [[UIImageView alloc] init];
        self.nicknameLabel = [[UILabel alloc] init];
        self.timeStampLabel = [[UILabel alloc] init];
        self.dividerView = [[UIView alloc] init];
        self.descriptionLabel = [[UILabel alloc] init];
        
        self.generalMargin = 10.0;
        self.avatarSize = 30.0;

        [self addSubview:self.titleLabel];
        [self addSubview:self.avatarImageView];
        [self addSubview:self.nicknameLabel];
        [self addSubview:self.timeStampLabel];
        [self addSubview:self.dividerView];
        [self addSubview:self.descriptionLabel];
        
        [self updateUILayout];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nicknameLabelTapped:)];
        [self.nicknameLabel addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUILayout
{
    // Section 1
    self.titleLabel.frame = CGRectMake(self.generalMargin, self.generalMargin, 320.0 - self.generalMargin * 2, ([self.title length] > 10 ? 60.0 : 30.0));
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.font = LARGE_BOLD_FONT;
    self.titleLabel.textColor = UIC_BRIGHT_GRAY(1.0);
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    // Section 2
    self.avatarImageView.frame = CGRectMake(self.generalMargin, self.titleLabel.frame.size.height + self.titleLabel.frame.origin.y + self.generalMargin,
                                            self.avatarSize, self.avatarSize);
    
    self.nicknameLabel.frame = CGRectMake(self.generalMargin * 2 + self.avatarSize,
                                          self.avatarImageView.frame.origin.y,
                                          [self.nickname sizeWithFont:MEDIUM_FONT].width,
                                          self.avatarSize);
    self.nicknameLabel.font = MEDIUM_FONT;
    self.nicknameLabel.textColor = UIC_CERULEAN(1.0);
    self.nicknameLabel.backgroundColor = [UIColor clearColor];
    self.nicknameLabel.userInteractionEnabled = YES;
    
    self.timeStampLabel.frame = CGRectMake(self.frame.size.width - [self.timeStamp sizeWithFont:MEDIUM_FONT].width - self.generalMargin * 2,
                                           self.avatarImageView.frame.origin.y,
                                           [self.timeStamp sizeWithFont:MEDIUM_FONT].width + self.generalMargin,
                                           self.avatarSize);
    self.timeStampLabel.textAlignment = NSTextAlignmentRight;
    self.timeStampLabel.textColor = UIC_BRIGHT_GRAY(0.5);
    self.timeStampLabel.backgroundColor = [UIColor clearColor];
    
    // Divider
    self.dividerView.frame = CGRectMake(0.0, self.avatarImageView.frame.origin.y + self.avatarSize + self.generalMargin, 320.0, 1.0);
    self.dividerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Dot"]];
    self.dividerView.alpha = DOTTED_LINE_ALPHA;
    
    // Section 3
    self.descriptionLabel.frame = CGRectMake(self.generalMargin,
                                             self.dividerView.frame.origin.y + self.generalMargin,
                                             self.frame.size.width - self.generalMargin * 2,
                                             TextHeightWithFont(SMALL_FONT) * 5);
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    self.descriptionLabel.font = SMALL_FONT;
    self.descriptionLabel.numberOfLines = 5;
}

#pragma mark -
- (void)setTitle:(NSString *)title
{
    if (![title isEqualToString:_title]) {
        _title = title;
        
        self.titleLabel.text = title;
    }

    [self updateUILayout];
}

- (void)setAvatarUrl:(NSString *)avatarUrl
{
    if (![avatarUrl isEqualToString:_avatarUrl]) {
        _avatarUrl = avatarUrl;
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:avatarUrl]];
        [request addValue:@"http://www.shanpow.com" forHTTPHeaderField:@"Referer"];
        
        __block UIImageView *imageViewForBlock = self.avatarImageView;
        __block BooklistDetailInfoCell *me = self;
        [self.avatarImageView setImageWithURLRequest:request
                                    placeholderImage:[[UIImage imageNamed:@"DefaultUser50"] scaledToSize:CGSizeMake(self.avatarSize * 2, self.avatarSize * 2)]
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                 UIImage *scaledImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(me.avatarSize * 2, me.avatarSize * 2)];
                                                 UIImage *avatarImage = [scaledImage makeRoundedImageWithRadius:me.avatarSize];
                                                 imageViewForBlock.image = avatarImage;
                                             }
                                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 
                                             }];
    }

    [self updateUILayout];
}

- (void)setNickname:(NSString *)nickname
{
    if (![nickname isEqualToString:_nickname]) {
        _nickname = nickname;
        
        self.nicknameLabel.text = nickname;
    }

    [self updateUILayout];
}

- (void)setTimeStamp:(NSString *)timeStamp
{
    if (![timeStamp isEqualToString:_timeStamp]) {
        _timeStamp = timeStamp;
        
        self.timeStampLabel.text = timeStamp;
    }

    [self updateUILayout];
}

- (void)setDescription:(NSString *)description
{
    if (![description isEqualToString:_description]) {
        _description = description;
        
        self.descriptionLabel.text = [NSString stringWithFormat:@"%@\n\n\n\n\n\n", description];
    }

    [self updateUILayout];
}

#pragma mark - Event handler
- (void)nicknameLabelTapped:(UITapGestureRecognizer *)recognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MSG_TAPPED_NICKNAME object:self userInfo:@{@"nickname": self.nickname}];
}

@end
