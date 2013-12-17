//
//  QQRegisterViewController.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-17.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkClient.h"
#import "Common.h"

@interface QQRegisterViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UIView *adjustView;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UISegmentedControl *genderSwitch;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *cancelButton;

- (void)clearControls;

@end
