//
//  BookInfoCell.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-23.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookInfoView.h"

@interface BookInfoCell : UITableViewCell

@property (nonatomic, strong) BookInfoView *bookInfoView;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
