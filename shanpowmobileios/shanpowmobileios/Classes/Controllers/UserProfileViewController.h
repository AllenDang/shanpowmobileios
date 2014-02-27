//
//  UserProfileViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-13.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "UIImage+ImageEffects.h"
#import "SPLabel.h"
#import "NetworkClient.h"

@interface UserProfileViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *userId;

- (id)initWithUsername:(NSString *)username;

@end
