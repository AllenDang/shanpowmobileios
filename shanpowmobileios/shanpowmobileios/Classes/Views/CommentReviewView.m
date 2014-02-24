//
//  CommentReviewView.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-24.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "CommentReviewView.h"

@interface CommentReviewView ()

@property (nonatomic, strong) NSString *reviewTitle;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *timeStamp;
@property (nonatomic, assign) float score;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, assign) NSInteger likeSum;
@property (nonatomic, assign) NSInteger disLikeSum;
@property (nonatomic, assign) NSInteger responseSum;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *timeStampLabel;
@property (nonatomic, strong) AMRatingControl *ratingStar;

@property (nonatomic, assign) float generalMargin;
@property (nonatomic, assign) float avatarSize;

@property (nonatomic, assign) BOOL isReview;

@end

@implementation CommentReviewView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleLabel = [[UILabel alloc] init];
        self.avatar = [[UIImageView alloc] init];
        self.nicknameLabel = [[UILabel alloc] init];
        self.contentLabel = [[UILabel alloc] init];
        self.timeStampLabel = [[UILabel alloc] init];
        self.ratingStar = [[AMRatingControl alloc] initWithLocation:CGPointZero emptyImage:[UIImage imageNamed:@"Star_Gray_Small"] solidImage:[UIImage imageNamed:@"Star_Red_Small"] andMaxRating:5];
        
        self.likeSum = 0;
        self.disLikeSum = 0;
        self.responseSum = 0;
        
        self.generalMargin = 10.0;
        self.avatarSize = 30.0;
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.avatar];
        [self addSubview:self.nicknameLabel];
        [self addSubview:self.contentLabel];
        [self addSubview:self.timeStampLabel];
        [self addSubview:self.ratingStar];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    [self updateUILayout];
    [self updateUIData];
}

#pragma mark -
-(void)setComment:(NSDictionary *)comment
{
    if (![comment isEqualToDictionary:_comment]) {
        _comment = comment;
        
        if ([comment objectForKey:@"Title"] != nil) {
            self.isReview = YES;
        } else {
            self.isReview = NO;
        }
        
        self.reviewTitle = [self.comment objectForKey:@"Title"];
        self.avatarUrl = [[self.comment objectForKey:@"Author"] objectForKey:@"AvatarUrl"];
        self.nickname = [[self.comment objectForKey:@"Author"] objectForKey:@"Nickname"];
        self.content = [self.comment objectForKey:@"Content"];
        self.timeStamp = [self.comment objectForKey:@"CreationTime"];
        self.score = [[self.comment objectForKey:@"Score"] floatValue];
        
        self.likeSum = [[self.comment objectForKey:@"LikeSum"] integerValue];
        self.disLikeSum = [[self.comment objectForKey:@"DislikeSum"] integerValue];
        self.responseSum = [[self.comment objectForKey:@"ResponseSum"] integerValue];
        
        [self updateUILayout];
        [self updateUIData];
    };
}

#pragma mark -
- (void)setAvatarUrl:(NSString *)avatarUrl
{
    if (![avatarUrl isEqualToString:_avatarUrl]) {
        _avatarUrl = avatarUrl;
        
        __block UIImageView *imageViewForBlock = self.avatar;
        __block CommentReviewView *me = self;
        [self.avatar setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.avatarUrl]]
                           placeholderImage:[[[UIImage imageNamed:@"DefaultUser50"] scaledToSize:CGSizeMake(self.avatarSize * 2, self.avatarSize * 2)] imageByApplyingAlpha:0.3]
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        UIImage *scaledImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(me.avatarSize * 2, me.avatarSize * 2)];
                                        UIImage *avatarImage = [scaledImage makeRoundedImageWithRadius:me.avatarSize];
                                        imageViewForBlock.image = avatarImage;
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        
                                    }];
    }
}

#pragma mark - UI
- (void)updateUILayout
{
    // Section 1
    self.titleLabel.frame = self.isReview ? CGRectMake(self.generalMargin, self.generalMargin, self.frame.size.width - self.generalMargin * 2, TextHeightWithFont(MEDIUM_BOLD_FONT)) : CGRectZero;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = LARGE_BOLD_FONT;
    self.titleLabel.textColor = UIC_BRIGHT_GRAY(1.0);
    
    float titleHeight = self.isReview ? TextHeightWithFont(MEDIUM_FONT) + self.generalMargin : 0;
    
    // Section 2
    self.avatar.frame = CGRectMake(self.generalMargin,
                                   self.generalMargin + titleHeight,
                                   self.avatarSize,
                                   self.avatarSize);
    
    self.nicknameLabel.frame = CGRectMake(self.generalMargin * 2 + self.avatarSize,
                                          self.avatar.frame.origin.y,
                                          MIN([self.nickname sizeWithFont:MEDIUM_FONT].width + self.generalMargin, 90),
                                          self.avatarSize);
    
    self.ratingStar.frame = CGRectMake(self.nicknameLabel.frame.size.width + self.nicknameLabel.frame.origin.x,
                                       self.nicknameLabel.frame.origin.y + (self.nicknameLabel.frame.size.height - StarSize(@"Star_Red_Small")) / 2,
                                       StarSize(@"Star_Red_Small"),
                                       StarSize(@"Star_Red_Small"));
    self.ratingStar.starSpacing = -5;
    
    self.timeStampLabel.frame = CGRectMake(self.frame.size.width - 110,
                                           self.avatar.frame.origin.y,
                                           100,
                                           self.avatarSize);
    self.timeStampLabel.textAlignment = NSTextAlignmentRight;
    self.timeStampLabel.backgroundColor = [UIColor clearColor];
    self.timeStampLabel.textColor = UIC_BRIGHT_GRAY(0.5);
    self.timeStampLabel.font = MEDIUM_FONT;
    
    // Section 3
    self.contentLabel.frame = CGRectMake(self.generalMargin,
                                         self.avatar.frame.origin.y + self.avatarSize + self.generalMargin / 2,
                                         self.frame.size.width - self.generalMargin * 2,
                                         self.frame.size.height - self.avatar.frame.origin.y - self.avatarSize - self.generalMargin);
    self.contentLabel.numberOfLines = 4;
    self.contentLabel.backgroundColor = [UIColor clearColor];
    self.contentLabel.font = SMALL_FONT;
}

- (void)updateUIData
{
    self.titleLabel.text = self.reviewTitle;
    
    self.avatarUrl = self.avatarUrl;
    
    self.nicknameLabel.text = self.nickname;
    
    [self.ratingStar setRating:self.score];
    
    self.timeStampLabel.text = self.timeStamp;
    
    self.contentLabel.text = [NSString stringWithFormat:@"%@\n\n\n\n", self.content];
}

@end
