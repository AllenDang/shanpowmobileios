//
//  ChatBubble.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-4.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "ChatBubble.h"
#import "UIImageView+AFNetworking.h"

@interface ChatBubble ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *bubbleBkgImageView;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIImage *bubbleDarkBkg;
@property (nonatomic, strong) UIImage *bubbleLightBkg;

@property (nonatomic, assign) float avatarSize;

@end

@implementation ChatBubble

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.avatarSize = 40.0;
        self.backgroundColor = [UIColor clearColor];
        self.avatarLocation = CB_AvatarLocationLeft;
        self.style = CBStyleDark;
        
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.bubbleBkgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        [self addSubview:self.avatarImageView];
        [self addSubview:self.bubbleBkgImageView];
        [self addSubview:self.contentLabel];
        
        self.bubbleDarkBkg = [[UIImage imageNamed:@"BubbleDark"] resizableImageWithCapInsets:UIEdgeInsetsMake(30.0, 15.0, 10.0, 10.0) resizingMode:UIImageResizingModeStretch];
        self.bubbleLightBkg = [[UIImage imageNamed:@"BubbleLight"] resizableImageWithCapInsets:UIEdgeInsetsMake(30.0, 15.0, 10.0, 10.0) resizingMode:UIImageResizingModeStretch];
        
        [self updateUILayout];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Setter
- (void)setUserAvatarUrl:(NSString *)userAvatarUrl
{
    if (![userAvatarUrl isEqualToString:_userAvatarUrl]) {
        _userAvatarUrl = userAvatarUrl;
        
        __block UIImageView *imageViewForBlock = self.avatarImageView;
        __block ChatBubble *me = self;
        [self.avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:userAvatarUrl]]
                               placeholderImage:[[[UIImage imageNamed:@"DefaultUser50"] scaledToSize:CGSizeMake(self.avatarSize * 2, self.avatarSize * 2)] imageByApplyingAlpha:0.3]
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            UIImage *scaledImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(me.avatarSize * 2, me.avatarSize * 2)];
                                            UIImage *avatarImage = [scaledImage makeRoundedImageWithRadius:me.avatarSize];
                                            imageViewForBlock.image = avatarImage;
                                        }
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                            
                                        }];
        [self updateUILayout];
    }
}

- (void)setContent:(NSString *)content
{
    if (![content isEqualToString:_content]) {
        _content = content;
        
        self.contentLabel.text = content;
        [self updateUILayout];
    }
}

- (void)setFont:(UIFont *)font
{
    if (![font isEqual:_font]) {
        _font = font;
        
        self.contentLabel.font = font;
        [self updateUILayout];
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    if (![textColor isEqual:_textColor]) {
        _textColor = textColor;
        
        self.contentLabel.textColor = textColor;
    }
}

- (void)setStyle:(CBStyle)style
{
    if (style != _style) {
        _style = style;
        
        switch (style) {
            case CBStyleDark:
            {
                self.bubbleBkgImageView.image = self.bubbleDarkBkg;
                self.contentLabel.textColor = UIC_ALMOSTWHITE(1.0);
                break;
            }
            case CBStyleLight:
            {
                self.bubbleBkgImageView.image = self.bubbleLightBkg;
                self.contentLabel.textColor = UIC_BRIGHT_GRAY(1.0);
            }
            default:
                break;
        }
    }
}

#pragma mark - UI
- (void)updateUILayout
{
    if (self.avatarLocation == CB_AvatarLocationLeft) {
        self.avatarImageView.frame = CGRectMake(0.0,
                                                0.0,
                                                self.avatarSize,
                                                self.avatarSize);
        self.bubbleBkgImageView.frame = CGRectMake(self.avatarSize + 5,
                                                   0.0,
                                                   self.bounds.size.width - self.avatarSize - 5,
                                                   self.bounds.size.height);
    } else if (self.avatarLocation == CB_AvatarLocationRight) {
        self.avatarImageView.frame = CGRectMake(self.bounds.size.width - self.avatarSize, 0.0, self.avatarSize, self.avatarSize);
    }
    self.bubbleBkgImageView.alpha = 0.3;
    
    if ([self.content length] > 0) {
        self.contentLabel.frame = CGRectMake(self.bubbleBkgImageView.frame.origin.x + 18.0,
                                             self.bubbleBkgImageView.frame.origin.y + 3.0,
                                             self.bubbleBkgImageView.frame.size.width - 18.0,
                                             self.bubbleBkgImageView.frame.size.height - 6.0);
        self.contentLabel.text = [NSString stringWithFormat:@"%@\n\n\n\n\n", self.content];
        self.contentLabel.numberOfLines = 5;
        self.contentLabel.font = self.font;
    }
}

@end
