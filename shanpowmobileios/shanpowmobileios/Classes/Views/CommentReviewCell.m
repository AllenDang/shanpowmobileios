//
//  CommentReviewCell.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-6.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "CommentReviewCell.h"
#import "CommentReviewView.h"

@interface CommentReviewCell ()

@property (nonatomic, strong) CommentReviewView *commentReviewView;

@end

@implementation CommentReviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
		self.commentReviewView = [[CommentReviewView alloc] initWithFrame:self.bounds];
		[self addSubview:self.commentReviewView];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (void)layoutSubviews {
	self.frame = CGRectMake(self.frame.origin.x,
	                        self.frame.origin.y,
	                        self.frame.size.width,
	                        self.commentReviewView.calculatedHeight);
}

#pragma mark - Setter
- (void)setComment:(NSDictionary *)comment {
	if (![comment isEqualToDictionary:_comment]) {
		_comment = comment;

		self.commentReviewView.comment = comment;
		self.frame = CGRectMake(self.frame.origin.x,
		                        self.frame.origin.y,
		                        self.frame.size.width,
		                        self.commentReviewView.calculatedHeight);
	}

	[self setNeedsLayout];
}

- (void)setFrame:(CGRect)rect {
	self.center = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
	self.bounds = CGRectMake(0.0, 0.0, rect.size.width, rect.size.height);

	self.commentReviewView.frame = self.bounds;
}

- (void)setShowBookInfo:(BOOL)showBookInfo {
	if (showBookInfo != _showBookInfo) {
		_showBookInfo = showBookInfo;

		self.commentReviewView.showBookInfo = showBookInfo;
	}

	[self setNeedsLayout];
}

- (void)setShowMegaInfo:(BOOL)showMegaInfo {
	if (showMegaInfo != _showMegaInfo) {
		_showMegaInfo = showMegaInfo;

		self.commentReviewView.showMegaInfo = showMegaInfo;
	}

	[self setNeedsLayout];
}

@end
