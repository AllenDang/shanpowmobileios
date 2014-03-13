//
//  RankingDetailViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-12.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface RankingDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *rankingTitle;
@property (nonatomic, strong) NSString *version;

@property (nonatomic, readonly) BOOL isActive;

@end
