//
//  RankingViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-13.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface RankingViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) NSString *currentRankingTitle;
@property (nonatomic, strong) NSString *currentRankingVersion;

@end
