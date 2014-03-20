//
//  BookInfoCell.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-23.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "BookInfoCell.h"

@interface BookInfoCell ()

@end

@implementation BookInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
		self.bookInfoView = [[BookInfoView alloc] initWithStyle:BookInfoViewStyleMinimal frame:self.bounds];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (void)layoutSubviews {
	self.bookInfoView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);

	[super layoutSubviews];
}

@end
