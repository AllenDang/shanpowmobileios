//
//  ResponseCell.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-10.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "ResponseCell.h"

@interface ResponseCell ()

@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *authorPlusLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *replayButton;

@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) NSString *content;

@end

@implementation ResponseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
		self.authorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.authorPlusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.replayButton = [UIButton buttonWithType:UIButtonTypeCustom];

		[self addSubview:self.authorLabel];
		[self addSubview:self.authorPlusLabel];
		[self addSubview:self.contentLabel];
		[self addSubview:self.replayButton];

		UITapGestureRecognizer *nicknameTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nicknameTapped:)];
		[self.authorLabel addGestureRecognizer:nicknameTapRecognizer];

		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (void)setResponse:(NSDictionary *)response {
	if (![response isEqualToDictionary:_response]) {
		_response = response;

		self.authorName = [[response objectForKey:@"Author"] objectForKey:@"Nickname"];
		self.content = [response objectForKey:@"Content"];

		[self updateUILayout];
		[self updateUIData];
	}
}

- (void)updateUILayout {
	self.authorLabel.frame = CGRectMake(10.0,
	                                    5.0,
	                                    MIN(self.frame.size.width - 50, [self.authorName sizeWithFont:MEDIUM_FONT].width),
	                                    TextHeightWithFont(MEDIUM_FONT));
	self.authorLabel.font = MEDIUM_FONT;
	self.authorLabel.textColor = UIC_CYAN(1.0);
	self.authorLabel.backgroundColor = [UIColor clearColor];
	self.authorLabel.userInteractionEnabled = YES;

	self.authorPlusLabel.frame = CGRectMake(self.authorLabel.frame.size.width + 15.0,
	                                        self.authorLabel.frame.origin.y,
	                                        50.0,
	                                        TextHeightWithFont(MEDIUM_FONT));
	self.authorPlusLabel.font = MEDIUM_FONT;
	self.authorPlusLabel.backgroundColor = [UIColor clearColor];

	self.contentLabel.frame = CGRectMake(10.0,
	                                     self.authorLabel.frame.size.height + 10,
	                                     self.frame.size.width - 20.0,
	                                     heightForMultilineTextWithFont(self.content, SMALL_FONT, self.frame.size.width - 20));
	self.contentLabel.numberOfLines = INFINITY;
	self.contentLabel.font = SMALL_FONT;
	self.contentLabel.lineBreakMode = NSLineBreakByClipping;
	self.contentLabel.backgroundColor = [UIColor clearColor];

	self.frame = CGRectMake(self.frame.origin.x,
	                        self.frame.origin.y,
	                        self.frame.size.width,
	                        self.authorLabel.frame.size.height + self.contentLabel.frame.size.height + 15.0);
}

- (void)updateUIData {
	self.authorLabel.text = self.authorName;
	self.authorPlusLabel.text = @"说：";
	self.contentLabel.text = self.content;
}

#pragma mark - Event handler
- (void)nicknameTapped:(UITapGestureRecognizer *)tapRecognizer {
	UILabel *label = (UILabel *)tapRecognizer.view;
	[[NSNotificationCenter defaultCenter] postNotificationName:MSG_TAPPED_NICKNAME object:self userInfo:@{
	     @"Nickname": label.text
	 }];
}

@end
