//
//  RegisterViewController.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-13.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@property (nonatomic, assign) CGRect adjustViewOriginalFrame;

@end

@implementation RegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setBackgroundImage:[UIImage imageNamed:@"Login_Background"]];
    
    [self addAdjustView];
    
    self.adjustView = [self.view viewWithTag:ADAPT_VIEW_TAG];
    self.adjustViewOriginalFrame = self.adjustView.frame;
    
    UIButton *dismissKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissKeyboardButton.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height );
    [dismissKeyboardButton addTarget:self action:@selector(dismissKeyboardButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.adjustView addSubview:dismissKeyboardButton];
    
    UIColor *placeholderColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:0.5];
    
    float screenRatio = [[UIScreen mainScreen] bounds].size.height / 568.0;
    
    // Background view for username text field
    UIImageView *usernameTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_TextField"]];
    usernameTextFieldBackground.frame = CGRectMake(32.0, 45.0 * screenRatio, 256.0, 50.0);
    usernameTextFieldBackground.userInteractionEnabled = YES;
    [self.adjustView addSubview:usernameTextFieldBackground];
    
    // Username text field
    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 13.0, 230.0, 24.0)];
    self.usernameTextField.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.7];
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入昵称" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    self.usernameTextField.delegate = self;
    [usernameTextFieldBackground addSubview:self.usernameTextField];
    
    // Background view for email text field
    UIImageView *emailTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_TextField"]];
    emailTextFieldBackground.frame = CGRectMake(32.0, 120.0 * screenRatio, 256.0, 50.0);
    emailTextFieldBackground.userInteractionEnabled = YES;
    [self.adjustView addSubview:emailTextFieldBackground];
    
    // Email text field
    self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 13.0, 230.0, 24.0)];
    self.emailTextField.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.7];
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入您的电子邮件地址" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    self.emailTextField.delegate = self;
    [emailTextFieldBackground addSubview:self.emailTextField];
    
    // Background view for password text field
    UIImageView *passwordTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_TextField"]];
    passwordTextFieldBackground.frame = CGRectMake(32.0, 195.0 * screenRatio, 256.0, 50.0);
    passwordTextFieldBackground.userInteractionEnabled = YES;
    [self.adjustView addSubview:passwordTextFieldBackground];
    
    // Password text field
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 13.0, 230.0, 24.0)];
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.7];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入密码" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    self.passwordTextField.delegate = self;
    [passwordTextFieldBackground addSubview:self.passwordTextField];
    
    // Background view for password confirm text field
    UIImageView *confirmTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_TextField"]];
    confirmTextFieldBackground.frame = CGRectMake(32.0, 270.0 * screenRatio, 256.0, 50.0);
    confirmTextFieldBackground.userInteractionEnabled = YES;
    [self.adjustView addSubview:confirmTextFieldBackground];
    
    // Password confirm text field
    self.confirmTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 13.0, 230.0, 24.0)];
    self.confirmTextField.secureTextEntry = YES;
    self.confirmTextField.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.7];
    self.confirmTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"再次输入密码以确认" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    self.confirmTextField.delegate = self;
    [confirmTextFieldBackground addSubview:self.confirmTextField];
    
    // Gender Switch
    UILabel *genderTip = [[UILabel alloc] initWithFrame:CGRectMake(32.0, 345.0 * screenRatio, 100.0, 30.0)];
    genderTip.text = @"性别";
    genderTip.textColor = [UIColor whiteColor];
    genderTip.backgroundColor = [UIColor clearColor];
    [self.adjustView addSubview:genderTip];
    
    self.genderSwitch = [[UISegmentedControl alloc] initWithItems:@[@"男", @"女"]];
    self.genderSwitch.frame = CGRectMake(188.0, 345.0 * screenRatio, 100.0, 30.0);
    self.genderSwitch.tintColor = [UIColor whiteColor];
    self.genderSwitch.selectedSegmentIndex = 0;
    [self.adjustView addSubview:self.genderSwitch];
    
    // Register button
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.registerButton.frame = CGRectMake(32.0, 410.0 * screenRatio, 256.0, 50.0);
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton"] forState:UIControlStateNormal];
    [self.registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [self.registerButton addTarget:self action:@selector(register) forControlEvents:UIControlEventTouchUpInside];
    [self.adjustView addSubview:self.registerButton];
    
    // Cancel button
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(32.0, 490.0 * screenRatio, 256.0, 50.0);
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"Login_TextField"] forState:UIControlStateNormal];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.adjustView addSubview:self.cancelButton];
    
    // Observe to events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegister:) name:MSG_DID_REGISTER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failRegister:) name:MSG_FAIL_REGISTER object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissKeyboardButtonClicked
{
    [self.usernameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmTextField resignFirstResponder];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.confirmTextField]) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.adjustView setFrame:CGRectMake(0.0, -50.0, 320.0, self.adjustView.frame.size.height)];
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            [self.adjustView setFrame:self.adjustViewOriginalFrame];
        }];
    }
    
    return YES;
}

#pragma mark -
- (void)register
{
    NSString *nickname = self.usernameTextField.text;
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *confirm = self.confirmTextField.text;
    BOOL isMan = self.genderSwitch.selectedSegmentIndex == 0 ? YES : NO;
    
    if (![password isEqualToString:confirm]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"填写错误" message:@"两次输入的密码不一致，请重新输入" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[NetworkClient sharedNetworkClient] registerWithNickname:nickname email:email password:password gender:isMan];
}

- (void)cancel
{
    [UIView animateWithDuration:0.25 animations:^{
        [self clearControls];
        [self.view setFrame:CGRectMake(0.0, self.view.frame.size.height, 320.0, self.view.frame.size.height)];
    }];
}

- (void)clearControls
{
    self.usernameTextField.text = @"";
    self.emailTextField.text = @"";
    self.passwordTextField.text = @"";
    self.confirmTextField.text = @"";
    self.genderSwitch.selectedSegmentIndex = 0;
}

#pragma mark - Event Handler
- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.adjustView setFrame:self.adjustViewOriginalFrame];
    }];
}

- (void)didRegister:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_LOGIN object:self];
}

- (void)failRegister:(NSNotification *)notification
{
    NSString *errMsg = [notification.userInfo objectForKey:@"ErrorMsg"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册错误" message:errMsg delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alert show];
}

@end
