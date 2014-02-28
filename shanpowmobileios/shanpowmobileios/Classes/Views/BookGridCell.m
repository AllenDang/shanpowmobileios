//
//  BookGridCell.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-28.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "BookGridCell.h"

@implementation BookGridCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.bookController = [[BookGridViewController alloc] initWithStyle:UITableViewStylePlain];
        self.bookController.view.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
        [self addSubview:self.bookController.view];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
