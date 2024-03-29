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
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *bookTitle;
@property (nonatomic, strong) NSString *bookCategory;
@property (nonatomic, assign) NSInteger thumbUpSum;
@property (nonatomic, assign) NSInteger thumbDownSum;
@property (nonatomic, assign) NSInteger chatSum;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *timeStampLabel;
@property (nonatomic, strong) AMRatingControl *ratingStar;

@property (nonatomic, strong) UIView *bookInfoBkgView;
@property (nonatomic, strong) UILabel *bookInfoBookTitleLabel;
@property (nonatomic, strong) UILabel *bookInfoBookCategoryLabel;

@property (nonatomic, strong) UIImageView *thumbUpImage;
@property (nonatomic, strong) UILabel *thumbUpLabel;
@property (nonatomic, strong) UIImageView *thumbDownImage;
@property (nonatomic, strong) UILabel *thumbDownLabel;
@property (nonatomic, strong) UIImageView *chatImage;
@property (nonatomic, strong) UILabel *chatLabel;

@property (nonatomic, assign) float generalMargin;
@property (nonatomic, assign) float avatarSize;

@property (nonatomic, assign) BOOL isReview;

@property (nonatomic, assign) CGFloat calculatedHeight;

@end

@implementation CommentReviewView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		self.titleLabel = [[UILabel alloc] init];
		self.avatar = [[UIImageView alloc] init];
		self.nicknameLabel = [[UILabel alloc] init];
		self.contentLabel = [[UILabel alloc] init];
		self.timeStampLabel = [[UILabel alloc] init];
		self.ratingStar = [[AMRatingControl alloc] initWithLocation:CGPointZero emptyImage:[UIImage imageNamed:@"Star_Gray_Small"] solidImage:[UIImage imageNamed:@"Star_Red_Small"] andMaxRating:5];
		self.bookInfoBkgView = [[UIView alloc] init];
		self.bookInfoBookTitleLabel = [[UILabel alloc] init];
		self.bookInfoBookCategoryLabel = [[UILabel alloc] init];
		self.thumbUpImage = [[UIImageView alloc] init];
		self.thumbUpLabel = [[UILabel alloc] init];
		self.thumbDownImage = [[UIImageView alloc] init];
		self.thumbDownLabel = [[UILabel alloc] init];
		self.chatImage = [[UIImageView alloc] init];
		self.chatLabel = [[UILabel alloc] init];

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
		[self addSubview:self.bookInfoBkgView];
		[self.bookInfoBkgView addSubview:self.bookInfoBookTitleLabel];
		[self.bookInfoBkgView addSubview:self.bookInfoBookCategoryLabel];
		[self addSubview:self.thumbUpImage];
		[self addSubview:self.thumbUpLabel];
		[self addSubview:self.thumbDownImage];
		[self addSubview:self.thumbDownLabel];
		[self addSubview:self.chatImage];
		[self addSubview:self.chatLabel];

		self.backgroundColor = [UIColor clearColor];

		self.nicknameLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nicknameLabelTapped:)];
		[self.nicknameLabel addGestureRecognizer:tapRecognizer];
	}
	return self;
}

#pragma mark -
- (void)setComment:(NSDictionary *)comment {
	if (![comment isEqualToDictionary:_comment]) {
		_comment = comment;

		if ([comment objectForKey:@"Title"] != nil && [[comment objectForKey:@"Title"] length] >= 1) {
			self.isReview = YES;
		}
		else {
			self.isReview = NO;
		}

		self.reviewTitle = [self.comment objectForKey:@"Title"];
		self.avatarUrl = [[self.comment objectForKey:@"Author"] objectForKey:@"AvatarUrl"];
		self.nickname = [[self.comment objectForKey:@"Author"] objectForKey:@"Nickname"];
		self.timeStamp = [self.comment objectForKey:@"CreationTime"];
		self.score = [[self.comment objectForKey:@"Score"] floatValue];

		self.content = [self.comment objectForKey:@"Content"];
		if (!self.isDetailMode) {
			if ([[self.comment objectForKey:@"Content"] length] > 80) {
				self.content = [[[self.comment objectForKey:@"Content"] substringToIndex:80] stringByAppendingString:@"..."];
			}
		}

		self.likeSum = [[self.comment objectForKey:@"LikeSum"] integerValue];
		self.disLikeSum = [[self.comment objectForKey:@"DislikeSum"] integerValue];
		self.responseSum = [[self.comment objectForKey:@"ResponseSum"] integerValue];
		self.userId = [[self.comment objectForKey:@"Author"] objectForKey:@"Id"];

		self.bookTitle = [self.comment objectForKey:@"BookTitle"];
		self.bookCategory = [self.comment objectForKey:@"BookCategory"];

		self.thumbUpSum = [[self.comment objectForKey:@"LikeSum"] integerValue];
		self.thumbDownSum = [[self.comment objectForKey:@"DislikeSum"] integerValue];
		self.chatSum = [[self.comment objectForKey:@"ResponseSum"] integerValue];
	}

	[self setNeedsLayout];
}

- (void)setShowBookInfo:(BOOL)showBookInfo {
	if (showBookInfo != _showBookInfo) {
		_showBookInfo = showBookInfo;
	}

	[self setNeedsLayout];
}

- (void)setShowMegaInfo:(BOOL)showMegaInfo {
	if (showMegaInfo != _showMegaInfo) {
		_showMegaInfo = showMegaInfo;
	}

	[self setNeedsLayout];
}

#pragma mark -
- (CGFloat)calculatedHeight {
	[self updateUIData];
	[self updateUILayout];

	CGFloat height = 0;

	height = self.titleLabel.frame.size.height + self.avatarSize + self.contentLabel.frame.size.height + self.bookInfoBkgView.frame.size.height + (TextHeightWithFont(MEDIUM_FONT)) + self.generalMargin * 5;

	if (self.likeSum == 0 && self.disLikeSum == 0 && self.responseSum == 0) {
		height = height - TextHeightWithFont(MEDIUM_FONT) - self.generalMargin * 2;
	}

	if (!self.isReview) {
		height = height - self.generalMargin;
	}

	return height;
}

#pragma mark -
- (void)setAvatarUrl:(NSString *)avatarUrl {
	if (![avatarUrl isEqualToString:_avatarUrl]) {
		_avatarUrl = avatarUrl;

		__block UIImageView *imageViewForBlock = self.avatar;
		__block CommentReviewView *me = self;
		[self.avatar setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.avatarUrl]]
		                   placeholderImage:[[[UIImage imageNamed:@"DefaultUser50"] scaledToSize:CGSizeMake(self.avatarSize * 2, self.avatarSize * 2)] imageByApplyingAlpha:0.3]
		                            success: ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		    UIImage *scaledImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(me.avatarSize * 2, me.avatarSize * 2)];
		    UIImage *avatarImage = [scaledImage makeRoundedImageWithRadius:me.avatarSize];
		    imageViewForBlock.image = avatarImage;
		}

		                            failure: ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		}];
	}
}

#pragma mark - UI
- (void)layoutSubviews {
	[self updateUIData];
	[self updateUILayout];
}

- (void)updateUILayout {
	// Section 1
	self.titleLabel.frame = self.isReview ? CGRectMake(self.generalMargin,
	                                                   self.generalMargin,
	                                                   self.frame.size.width - self.generalMargin * 2,
	                                                   TextHeightWithFont(MEDIUM_BOLD_FONT)) : CGRectMake(self.generalMargin,
	                                                                                                      self.generalMargin,
	                                                                                                      0,
	                                                                                                      0);
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
	self.nicknameLabel.textColor = UIC_CERULEAN(1.0);

	self.ratingStar.frame = CGRectMake(self.nicknameLabel.frame.size.width + self.nicknameLabel.frame.origin.x,
	                                   self.nicknameLabel.frame.origin.y + (self.nicknameLabel.frame.size.height - StarSize(@"Star_Red_Small")) / 2,
	                                   StarSize(@"Star_Red_Small"),
	                                   StarSize(@"Star_Red_Small"));
	self.ratingStar.starSpacing = -5;
	self.ratingStar.userInteractionEnabled = NO;

	self.timeStampLabel.frame = CGRectMake(self.frame.size.width - 110,
	                                       self.avatar.frame.origin.y,
	                                       100,
	                                       self.avatarSize);
	self.timeStampLabel.textAlignment = NSTextAlignmentRight;
	self.timeStampLabel.backgroundColor = [UIColor clearColor];
	self.timeStampLabel.textColor = UIC_BRIGHT_GRAY(0.5);
	self.timeStampLabel.font = MEDIUM_FONT;

	// Section 3
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width - self.generalMargin * 2, GENERAL_CELL_HEIGHT * 1.5)];
	label.font = MEDIUM_FONT;
	label.text = self.content;
	label.numberOfLines = 0;
	[label sizeToFit];
	self.contentLabel.frame = CGRectMake(self.generalMargin,
	                                     self.avatar.frame.origin.y + self.avatarSize + self.generalMargin / 2,
	                                     self.frame.size.width - self.generalMargin * 2,
	                                     MIN(label.frame.size.height, (self.isDetailMode ? label.frame.size.height : TextHeightWithFont((self.isDetailMode ? MEDIUM_FONT : SMALL_FONT)) * 4)));
	self.contentLabel.numberOfLines = self.isReview ? (self.isDetailMode ? INFINITY : 4) : 7;
	self.contentLabel.backgroundColor = [UIColor clearColor];
	self.contentLabel.font = self.isDetailMode ? MEDIUM_FONT : SMALL_FONT;

	// Section 4
	self.bookInfoBkgView.frame = self.showBookInfo ? CGRectMake(0.0,
	                                                            self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height + self.generalMargin,
	                                                            self.bounds.size.width,
	                                                            55) : CGRectMake(0.0,
	                                                                             self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height + self.generalMargin,
	                                                                             0,
	                                                                             0);
	self.bookInfoBkgView.backgroundColor = UIC_WHISPER(1.0);

	self.bookInfoBookTitleLabel.frame = self.showBookInfo ? CGRectMake(self.generalMargin,
	                                                                   5.0,
	                                                                   self.bookInfoBkgView.bounds.size.width - self.generalMargin * 2,
	                                                                   20) : CGRectMake(self.generalMargin, 5.0, 0, 0);
	self.bookInfoBookTitleLabel.font = MEDIUM_BOLD_FONT;
	self.bookInfoBookTitleLabel.textColor = UIC_BRIGHT_GRAY(0.8);
	self.bookInfoBookTitleLabel.backgroundColor = [UIColor clearColor];

	self.bookInfoBookCategoryLabel.frame = self.showBookInfo ? CGRectMake(self.generalMargin,
	                                                                      self.bookInfoBkgView.bounds.size.height - TextHeightWithFont(SMALL_FONT) - 12.0,
	                                                                      self.bounds.size.width - self.generalMargin * 2,
	                                                                      20) : CGRectMake(self.generalMargin,
	                                                                                       self.bookInfoBkgView.frame.origin.y + self.bookInfoBkgView.frame.size.height - 8.0 - TextHeightWithFont(SMALL_FONT),
	                                                                                       0,
	                                                                                       0);
	self.bookInfoBookCategoryLabel.font = SMALL_FONT;
	self.bookInfoBookCategoryLabel.textColor = UIC_BRIGHT_GRAY(0.5);
	self.bookInfoBookCategoryLabel.backgroundColor = [UIColor clearColor];

	// Section 5
	if (self.chatSum == 0) {
		self.chatLabel.frame = CGRectZero;
		self.chatImage.frame = CGRectZero;
	}
	else {
		self.chatLabel.frame = self.showMegaInfo ? CGRectMake(self.bounds.size.width - self.generalMargin - 30,
		                                                      self.bookInfoBkgView.frame.origin.y + self.bookInfoBkgView.frame.size.height + self.generalMargin,
		                                                      30,
		                                                      TextHeightWithFont(MEDIUM_FONT)) : CGRectZero;
		self.chatLabel.font = MEDIUM_FONT;
		self.chatLabel.alpha = 0.5;

		self.chatImage.frame = self.showMegaInfo ? CGRectMake(self.chatLabel.frame.origin.x - self.generalMargin / 2 - 16,
		                                                      self.chatLabel.frame.origin.y + (TextHeightWithFont(MEDIUM_FONT) - 13) / 2,
		                                                      16,
		                                                      13) : CGRectZero;
		self.chatImage.image = [UIImage imageNamed:@"Chat"];
		self.chatImage.alpha = 0.5;
	}

	if (self.thumbDownSum == 0) {
		self.thumbDownLabel.frame = CGRectZero;
		self.thumbDownImage.frame = CGRectZero;
	}
	else {
		self.thumbDownLabel.frame = self.showMegaInfo ? CGRectMake(self.chatImage.frame.origin.x - self.generalMargin - 30,
		                                                           self.chatLabel.frame.origin.y,
		                                                           30,
		                                                           TextHeightWithFont(MEDIUM_FONT)) : CGRectZero;
		self.thumbDownLabel.font = MEDIUM_FONT;
		self.thumbDownLabel.alpha = 0.5;

		self.thumbDownImage.frame = self.showMegaInfo ? CGRectMake(self.thumbDownLabel.frame.origin.x - self.generalMargin / 2 - 16,
		                                                           self.chatLabel.frame.origin.y + (TextHeightWithFont(MEDIUM_FONT) - 13) / 2,
		                                                           16,
		                                                           13) : CGRectZero;
		self.thumbDownImage.image = [UIImage imageNamed:@"ThumbDown"];
		self.thumbDownImage.alpha = 0.5;
	}

	if (self.thumbUpSum == 0) {
		self.thumbUpLabel.frame = CGRectZero;
		self.thumbUpImage.frame = CGRectZero;
	}
	else {
		self.thumbUpLabel.frame = self.showMegaInfo ? CGRectMake(self.thumbDownImage.frame.origin.x - self.generalMargin - 30,
		                                                         self.chatLabel.frame.origin.y,
		                                                         30,
		                                                         TextHeightWithFont(MEDIUM_FONT)) : CGRectZero;
		self.thumbUpLabel.font = MEDIUM_FONT;
		self.thumbUpLabel.alpha = 0.5;

		self.thumbUpImage.frame = self.showMegaInfo ? CGRectMake(self.thumbUpLabel.frame.origin.x - self.generalMargin / 2 - 16,
		                                                         self.chatLabel.frame.origin.y + (TextHeightWithFont(MEDIUM_FONT) - 13) / 2,
		                                                         16,
		                                                         13) : CGRectZero;
		self.thumbUpImage.image = [UIImage imageNamed:@"ThumbUp"];
		self.thumbUpImage.alpha = 0.5;
	}
}

- (void)updateUIData {
	self.titleLabel.text = self.reviewTitle;

	self.avatarUrl = self.avatarUrl;

	self.nicknameLabel.text = self.nickname;

	[self.ratingStar setRating:self.score];

	self.timeStampLabel.text = [self.timeStamp stringByAppendingString:@"前"];

	self.contentLabel.text = self.content;

	self.bookInfoBookTitleLabel.text = self.bookTitle;

	self.bookInfoBookCategoryLabel.text = self.bookCategory;

	self.thumbUpLabel.text = [NSString stringWithFormat:@"%ld", (long)self.thumbUpSum];

	self.thumbDownLabel.text = [NSString stringWithFormat:@"%ld", (long)self.thumbDownSum];

	self.chatLabel.text = [NSString stringWithFormat:@"%ld", (long)self.chatSum];
}

#pragma mark - Event handler
- (void)nicknameLabelTapped:(UIGestureRecognizer *)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:MSG_TAPPED_NICKNAME object:self userInfo:@{ @"Nickname": self.nickname,
	                                                                                                       @"Id": self.userId }];
}

@end
