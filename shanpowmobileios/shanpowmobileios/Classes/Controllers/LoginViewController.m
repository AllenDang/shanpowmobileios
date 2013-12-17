//
//  LoginViewController.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-3.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (nonatomic, assign) LoginServiceType loginType;

- (void)login;

@end

@implementation LoginViewController

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
    
    UIButton *dismissKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissKeyboardButton.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height );
    [dismissKeyboardButton addTarget:self action:@selector(dismissKeyboardButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.adjustView addSubview:dismissKeyboardButton];
    
    UIColor *placeholderColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:0.5];
    
    float screenRatio = self.view.bounds.size.height / 568.0;
    
    // Background view for username text field
    UIImageView *usernameTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_TextField"]];
    usernameTextFieldBackground.frame = CGRectMake(32.0, 57.0 * screenRatio, 256.0, 50.0);
    usernameTextFieldBackground.userInteractionEnabled = YES;
    [self.adjustView addSubview:usernameTextFieldBackground];
    
    // Username text field
    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 13, 230.0, 24.0)];
    self.usernameTextField.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.7];
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入电子邮件地址或者昵称" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    self.usernameTextField.delegate = self;
    [usernameTextFieldBackground addSubview:self.usernameTextField];
    
    // Background view for password text field
    UIImageView *passwordTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_TextField"]];
    passwordTextFieldBackground.frame = CGRectMake(32.0, 135.0 * screenRatio, 256.0, 50.0);
    passwordTextFieldBackground.userInteractionEnabled = YES;
    [self.adjustView addSubview:passwordTextFieldBackground];
    
    // Password text field
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 13, 230.0, 24.0)];
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.7];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入密码" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    self.passwordTextField.delegate = self;
    [passwordTextFieldBackground addSubview:self.passwordTextField];
    
    // Login button
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginButton.frame = CGRectMake(32.0, 240.0 * screenRatio, 256.0, 50.0);
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton"] forState:UIControlStateNormal];
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(getToken) forControlEvents:UIControlEventTouchUpInside];
    [self.adjustView addSubview:self.loginButton];
    
    // Lines
    UIView *lineLeft = [[UIView alloc] init];
    lineLeft.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    lineLeft.frame = CGRectMake(84.0, 368.0 * screenRatio, 48.0, 1.0);
    [self.adjustView addSubview:lineLeft];
    
    UIView *lineRight = [[UIView alloc] init];
    lineRight.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    lineRight.frame = CGRectMake(188.0, 368.0 * screenRatio, 48.0, 1.0);
    [self.adjustView addSubview:lineRight];
    
    // "Or" label
    UILabel *orLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 360.0 * screenRatio, 320.0, 16.0)];
    orLabel.text = @"或者";
    orLabel.textAlignment = NSTextAlignmentCenter;
    orLabel.textColor = [UIColor whiteColor];
    orLabel.font = [UIFont systemFontOfSize:15.0];
    orLabel.backgroundColor = [UIColor clearColor];
    [self.adjustView addSubview:orLabel];
    
    // Other services login button
    self.loginWithOtherServicesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginWithOtherServicesButton.frame = CGRectMake(32.0, 425.0 * screenRatio, 256.0, 50.0);
    self.loginWithOtherServicesButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.loginWithOtherServicesButton setTitle:@"使用合作网站帐号登录" forState:UIControlStateNormal];
    [self.loginWithOtherServicesButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton"] forState:UIControlStateHighlighted];
    [self.loginWithOtherServicesButton addTarget:self action:@selector(serviceLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.adjustView addSubview:self.loginWithOtherServicesButton];
    
    // Register button
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.registerButton.frame = CGRectMake(32.0, 490.0 * screenRatio, 256.0, 50.0);
    self.registerButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.registerButton setTitle:@"立即注册" forState:UIControlStateNormal];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton"] forState:UIControlStateHighlighted];
    [self.registerButton addTarget:self action:@selector(showRegisterView) forControlEvents:UIControlEventTouchUpInside];
    [self.adjustView addSubview:self.registerButton];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.registerViewController clearControls];
        [self.registerViewController.view setFrame:CGRectMake(0.0, self.view.frame.size.height, 320.0, self.view.frame.size.height)];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getToken
{
    [[NetworkClient sharedNetworkClient] getCsrfToken];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetToken:) name:MSG_GOT_TOKEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetToken:) name:MSG_FAIL_GET_TOKEN object:nil];
}

- (void)login
{
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if (!username) {
        username = @"";
    }
    
    if (!password) {
        password = @"";
    }
    
    if (username.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"填写错误" message:@"请填写电子邮件地址或者昵称并重试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
    } else if (password.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"填写错误" message:@"请填写密码并重试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedLogin:) name:MSG_FAIL_LOGIN object:nil];
        
        [[NetworkClient sharedNetworkClient] loginWithLoginname:username password:password];
    }
}

- (void)failedLogin:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_LOGIN object:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"请核对您的登录信息并重试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alert show];
}

- (void)serviceLogin
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"使用合作网站帐号登录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"QQ登录", @"微信登录", @"微博登录", nil];
    [actionSheet showInView:self.view];
}

- (void)qqLogin
{
    QQLogin *qq = [QQLogin sharedQQLogin];
    [qq loginWithQQ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didQQLogin:) name:MSG_DID_QQ_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failQQLogin:) name:MSG_FAIL_QQ_LOGIN object:nil];
}

- (void)dismissKeyboardButtonClicked
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)showRegisterView
{
    self.registerViewController = [[RegisterViewController alloc] init];
    self.registerViewController.view.frame = CGRectMake(0.0, [[UIScreen mainScreen] bounds].size.height, 320.0, [[UIScreen mainScreen] bounds].size.height);
    [self.view addSubview:self.registerViewController.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.registerViewController.view setFrame:CGRectMake(0.0, 0.0, 320.0, [[UIScreen mainScreen] bounds].size.height)];
    }];
}

- (void)showQQRegisterView
{
    self.qqRegisterViewController = [[QQRegisterViewController alloc] init];
    self.qqRegisterViewController.view.frame = CGRectMake(0.0, [[UIScreen mainScreen] bounds].size.height, 320.0, [[UIScreen mainScreen] bounds].size.height);
    [self.view addSubview:self.qqRegisterViewController.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.qqRegisterViewController.view setFrame:CGRectMake(0.0, 0.0, 320.0, [[UIScreen mainScreen] bounds].size.height)];
    }];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.loginType = buttonIndex;
    if (buttonIndex < actionSheet.numberOfButtons - 1) {
        [self getToken];
    }
}

#pragma mark - Event handler

- (void)didGetToken:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_GOT_TOKEN object:nil];
    switch (self.loginType) {
        case LoginType_QQ:
            [self qqLogin];
            break;
        case LoginType_WeiXin:
            break;
        case LoginType_WeiBo:
            break;
        default:
            [self login];
            break;
    }
}

- (void)failGetToken:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_TOKEN object:nil];
    [self getToken];
}

-(void)didQQLogin:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_QQ_LOGIN object:nil];
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *openId = [userInfo objectForKey:@"openId"];
    
    [[QQLogin sharedQQLogin] getUserInfo];
    
    [[NetworkClient sharedNetworkClient] loginWithQQOpenId:openId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showQQRegisterView) name:MSG_QQ_LOGIN_NOT_FOUND object:nil];
}

-(void)failQQLogin:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"请重新尝试用QQ登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alert show];
}

@end
