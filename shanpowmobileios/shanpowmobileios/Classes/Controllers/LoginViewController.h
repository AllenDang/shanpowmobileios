//
//  LoginViewController.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-3.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkClient.h"
#import "Common.h"
#import "RegisterViewController.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *loginWithOtherServicesButton;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIView *adjustView;
@property (nonatomic, strong) RegisterViewController *registerViewController;

@end
