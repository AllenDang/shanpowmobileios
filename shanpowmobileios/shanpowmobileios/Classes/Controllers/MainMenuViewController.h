//
//  MainMenuViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-10.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "RankingListViewController.h"
#import "CategoriesViewController.h"
#import "SearchViewController.h"
#import "WriteCommentReviewViewController.h"
#import "ReviewListRootViewController.h"
#import "WizardResultViewController.h"

@interface MainMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL shouldRemainBottomBarOnDisappear;

@end
