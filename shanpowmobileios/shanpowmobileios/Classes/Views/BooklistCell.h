//
//  BooklistCell.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-3.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface BooklistCell : UITableViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;

@property (nonatomic, assign) BOOL showDescription;

@end
