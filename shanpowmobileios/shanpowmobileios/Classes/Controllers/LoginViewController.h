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
#import "QQLogin.h"
#import "QQRegisterViewController.h"
#import "WeiboLogin.h"

typedef enum
{
    LoginType_Normal = -1,
    LoginType_QQ = 0,
    LoginType_WeiBo = 1
} LoginServiceType;

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate>

@end
