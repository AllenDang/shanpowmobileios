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

- (void)registerNewAccount;
- (void)getToken;

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
  
  UIColor *placeholderColor = [UIColor colorWithWhite:1.0 alpha:0.4];
  UIColor *textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
  
  float screenRatio = [[UIScreen mainScreen] bounds].size.height / 568.0;
  
  // Background view for username text field
  UIImageView *usernameTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_EmailTextField"]];
  usernameTextFieldBackground.frame = CGRectMake(0.0, 83.0 * screenRatio, 320.0, 50.0);
  usernameTextFieldBackground.userInteractionEnabled = YES;
  [self.adjustView addSubview:usernameTextFieldBackground];
  
  // Username text field
  self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(50.0, 13.0, 230.0, 24.0)];
  self.usernameTextField.textColor = textColor;
  self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入昵称" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
  self.usernameTextField.delegate = self;
  self.usernameTextField.font = [UIFont systemFontOfSize:15.0];
  [usernameTextFieldBackground addSubview:self.usernameTextField];
  
  // Background view for email text field
  UIImageView *emailTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_MailTextField"]];
  emailTextFieldBackground.frame = CGRectMake(0.0, 134.0 * screenRatio, 320.0, 50.0);
  emailTextFieldBackground.userInteractionEnabled = YES;
  [self.adjustView addSubview:emailTextFieldBackground];
  
  // Email text field
  self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(50.0, 13.0, 230.0, 24.0)];
  self.emailTextField.textColor = textColor;
  self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入您的电子邮件地址" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
  self.emailTextField.delegate = self;
  self.emailTextField.font = [UIFont systemFontOfSize:15.0];
  [emailTextFieldBackground addSubview:self.emailTextField];
  
  // Background view for password text field
  UIImageView *passwordTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_PasswordTextField"]];
  passwordTextFieldBackground.frame = CGRectMake(0.0, 185.0 * screenRatio, 320.0, 50.0);
  passwordTextFieldBackground.userInteractionEnabled = YES;
  [self.adjustView addSubview:passwordTextFieldBackground];
  
  // Password text field
  self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(50.0, 13.0, 230.0, 24.0)];
  self.passwordTextField.secureTextEntry = YES;
  self.passwordTextField.textColor = textColor;
  self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入密码" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
  self.passwordTextField.delegate = self;
  self.passwordTextField.font = [UIFont systemFontOfSize:15.0];
  [passwordTextFieldBackground addSubview:self.passwordTextField];
  
  // Background view for password confirm text field
  UIImageView *confirmTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_PasswordTextField"]];
  confirmTextFieldBackground.frame = CGRectMake(0.0, 236.0 * screenRatio, 320.0, 50.0);
  confirmTextFieldBackground.userInteractionEnabled = YES;
  [self.adjustView addSubview:confirmTextFieldBackground];
  
  // Password confirm text field
  self.confirmTextField = [[UITextField alloc] initWithFrame:CGRectMake(50.0, 13.0, 230.0, 24.0)];
  self.confirmTextField.secureTextEntry = YES;
  self.confirmTextField.textColor = textColor;
  self.confirmTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"再次输入密码以确认" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
  self.confirmTextField.delegate = self;
  self.confirmTextField.font = [UIFont systemFontOfSize:15.0];
  [confirmTextFieldBackground addSubview:self.confirmTextField];
  
  // Gender Switch
  UILabel *genderTip = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 295.0 * screenRatio, 100.0, 30.0)];
  genderTip.text = @"性别";
  genderTip.textColor = [UIColor whiteColor];
  genderTip.backgroundColor = [UIColor clearColor];
  [self.adjustView addSubview:genderTip];
  
  self.genderSwitch = [[UISegmentedControl alloc] initWithItems:@[@"男", @"女"]];
  self.genderSwitch.frame = CGRectMake(200.0, 295.0 * screenRatio, 100.0, 30.0);
  self.genderSwitch.tintColor = [UIColor whiteColor];
  self.genderSwitch.selectedSegmentIndex = 0;
  [self.adjustView addSubview:self.genderSwitch];
  
  // Register button
  self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.registerButton.frame = CGRectMake(0.0, 410.0 * screenRatio, 320.0, 50.0);
  [self.registerButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton"] forState:UIControlStateNormal];
  [self.registerButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton_Highlight"] forState:UIControlStateHighlighted];
  [self.registerButton setTitle:@"注册" forState:UIControlStateNormal];
  [self.registerButton addTarget:self action:@selector(getToken) forControlEvents:UIControlEventTouchUpInside];
  [self.adjustView addSubview:self.registerButton];
  
  // Cancel button
  self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.cancelButton.frame = CGRectMake(0.0, 490.0 * screenRatio, 320.0, 50.0);
  [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton_Highlight"] forState:UIControlStateNormal];
  [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton"] forState:UIControlStateHighlighted];
  [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
  [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
  [self.adjustView addSubview:self.cancelButton];
  
  // Observe to events
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegister:) name:MSG_DID_REGISTER object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failRegister:) name:MSG_FAIL_REGISTER object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorHandler:) name:MSG_ERROR object:nil];
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

- (void)getToken
{
  [[NetworkClient sharedNetworkClient] getCsrfToken];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetToken:) name:MSG_GOT_TOKEN object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetToken:) name:MSG_FAIL_GET_TOKEN object:nil];
}

- (void)registerNewAccount
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

- (void)didGetToken:(NSNotification *)notification
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_GOT_TOKEN object:nil];
  [self registerNewAccount];
}

- (void)failGetToken:(NSNotification *)notification
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_TOKEN object:nil];
  [self getToken];
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

- (void)errorHandler:(NSNotification *)notification
{
  NSString *errMsg = [notification.userInfo objectForKey:@"ErrorMsg"];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出现问题" message:errMsg delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
  [alert show];
}

@end
