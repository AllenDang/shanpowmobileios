//
//  ReadRecordRootViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-4.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "MMDrawerController.h"
#import "Common.h"
#import "ReadRecordViewController.h"
#import "FilterViewController.h"

@interface ReadRecordRootViewController : MMDrawerController

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *avatarUrl;

- (id)initWithUserName:(NSString *)username;

@end
