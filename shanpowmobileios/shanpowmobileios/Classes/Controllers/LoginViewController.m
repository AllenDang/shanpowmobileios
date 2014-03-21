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

@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *loginWithOtherServicesButton;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIView *adjustView;
@property (nonatomic, strong) RegisterViewController *registerViewController;
@property (nonatomic, strong) QQRegisterViewController *qqRegisterViewController;

- (void)login;
- (void)qqLogin;
- (void)weiboLogin;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	[self setBackgroundImage:[UIImage imageWithColor:UIC_ALMOSTWHITE(1.0)]];

	[self addAdjustView];

	self.adjustView = [self.view viewWithTag:ADAPT_VIEW_TAG];

	UIButton *dismissKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
	dismissKeyboardButton.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	[dismissKeyboardButton addTarget:self action:@selector(dismissKeyboardButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self.adjustView addSubview:dismissKeyboardButton];

	UIColor *placeholderColor = UIC_BRIGHT_GRAY(0.25);

	// Background view for username text field
	UIImageView *usernameTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_EmailTextField"]];
	usernameTextFieldBackground.frame = CGRectMake(0.0, 50.0 * SCREEN_RATIO, 320.0, 50.0);
	usernameTextFieldBackground.userInteractionEnabled = YES;
	[self.adjustView addSubview:usernameTextFieldBackground];

	// Username text field
	self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(50.0, 13, 230.0, 24.0)];
	self.usernameTextField.textColor = UIC_BRIGHT_GRAY(1.0);
	self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入电子邮件地址或者昵称"
	                                                                               attributes:@{ NSForegroundColorAttributeName: placeholderColor }];
	self.usernameTextField.delegate = self;
	self.usernameTextField.font = MEDIUM_FONT;
	[usernameTextFieldBackground addSubview:self.usernameTextField];

	// Background view for password text field
	UIImageView *passwordTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_PasswordTextField"]];
	passwordTextFieldBackground.frame = CGRectMake(0.0,
	                                               usernameTextFieldBackground.frame.origin.y + usernameTextFieldBackground.frame.size.height + 1,
	                                               320.0,
	                                               50.0);
	passwordTextFieldBackground.userInteractionEnabled = YES;
	[self.adjustView addSubview:passwordTextFieldBackground];

	// Password text field
	self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(50.0, 13, 230.0, 24.0)];
	self.passwordTextField.secureTextEntry = YES;
	self.passwordTextField.textColor = UIC_BRIGHT_GRAY(1.0);
	self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入密码"
	                                                                               attributes:@{ NSForegroundColorAttributeName: placeholderColor }];
	self.passwordTextField.delegate = self;
	self.passwordTextField.font = MEDIUM_FONT;
	[passwordTextFieldBackground addSubview:self.passwordTextField];

	// Login button
	self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.loginButton.frame = CGRectMake(0.0,
	                                    passwordTextFieldBackground.frame.origin.y + passwordTextFieldBackground.frame.size.height + 50 * SCREEN_RATIO,
	                                    320.0,
	                                    50.0);
	[self.loginButton setBackgroundImage:[UIImage imageWithColor:UIC_CYAN(1.0)] forState:UIControlStateNormal];
	[self.loginButton setBackgroundImage:[UIImage imageWithColor:UIC_CERULEAN(1.0)] forState:UIControlStateHighlighted];
	[self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
	[self.loginButton addTarget:self action:@selector(getToken) forControlEvents:UIControlEventTouchUpInside];
	[self.adjustView addSubview:self.loginButton];

	// Cancel button
	self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.cancelButton.frame = CGRectMake(0.0,
	                                     self.loginButton.frame.origin.y + self.loginButton.frame.size.height + 15 * SCREEN_RATIO,
	                                     320.0,
	                                     50.0);
	[self.cancelButton setBackgroundImage:[UIImage imageWithColor:UIC_BRIGHT_GRAY(0.3)] forState:UIControlStateNormal];
	[self.cancelButton setBackgroundImage:[UIImage imageWithColor:UIC_BRIGHT_GRAY(0.5)] forState:UIControlStateHighlighted];
	[self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
	[self.cancelButton addTarget:self action:@selector(cancelLogin) forControlEvents:UIControlEventTouchUpInside];
	[self.adjustView addSubview:self.cancelButton];

	// Lines
	UIView *lineLeft = [[UIView alloc] init];
	lineLeft.backgroundColor = UIC_BRIGHT_GRAY(0.5);
	lineLeft.frame = CGRectMake(84.0,
	                            self.cancelButton.frame.origin.y + self.cancelButton.frame.size.height + 40 * SCREEN_RATIO + TextHeightWithFont(MEDIUM_FONT) / 2,
	                            48.0,
	                            1.0);
	[self.adjustView addSubview:lineLeft];

	UIView *lineRight = [[UIView alloc] init];
	lineRight.backgroundColor = UIC_BRIGHT_GRAY(0.5);
	lineRight.frame = CGRectMake(188.0,
	                             lineLeft.frame.origin.y,
	                             48.0,
	                             1.0);
	[self.adjustView addSubview:lineRight];

	// "Or" label
	UILabel *orLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
	                                                             self.cancelButton.frame.origin.y + self.cancelButton.frame.size.height + 40 * SCREEN_RATIO,
	                                                             320.0,
	                                                             TextHeightWithFont(MEDIUM_FONT))];
	orLabel.text = @"或者";
	orLabel.textAlignment = NSTextAlignmentCenter;
	orLabel.textColor = UIC_BRIGHT_GRAY(0.5);
	orLabel.font = MEDIUM_FONT;
	orLabel.backgroundColor = [UIColor clearColor];
	[self.adjustView addSubview:orLabel];

	// Other services login button
	self.loginWithOtherServicesButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.loginWithOtherServicesButton.frame = CGRectMake(0.0,
	                                                     orLabel.frame.origin.y + orLabel.frame.size.height + 30 * SCREEN_RATIO,
	                                                     320.0,
	                                                     50.0);
	self.loginWithOtherServicesButton.titleLabel.font = MEDIUM_FONT;
	[self.loginWithOtherServicesButton setTitle:@"使用合作网站帐号登录" forState:UIControlStateNormal];
	[self.loginWithOtherServicesButton setTitleColor:UIC_BRIGHT_GRAY(0.5) forState:UIControlStateNormal];
	[self.loginWithOtherServicesButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton_Highlight"] forState:UIControlStateHighlighted];
	[self.loginWithOtherServicesButton addTarget:self action:@selector(serviceLogin) forControlEvents:UIControlEventTouchUpInside];
	[self.adjustView addSubview:self.loginWithOtherServicesButton];

	// Register button
	self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.registerButton.frame = CGRectMake(0.0,
	                                       self.loginWithOtherServicesButton.frame.origin.y + self.loginWithOtherServicesButton.frame.size.height + 10 * SCREEN_RATIO,
	                                       320.0,
	                                       50.0);
	self.registerButton.titleLabel.font = MEDIUM_FONT;
	[self.registerButton setTitle:@"立即注册" forState:UIControlStateNormal];
	[self.registerButton setTitleColor:UIC_BRIGHT_GRAY(0.5) forState:UIControlStateNormal];
	[self.registerButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton_Highlight"] forState:UIControlStateHighlighted];
	[self.registerButton addTarget:self action:@selector(showRegisterView) forControlEvents:UIControlEventTouchUpInside];
	[self.adjustView addSubview:self.registerButton];

	self.loginType = LoginType_Normal;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:MSG_ERROR object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated {
	[UIView animateWithDuration:0.25 animations: ^{
	    [self.registerViewController clearControls];
	    [self.registerViewController.view setFrame:CGRectMake(0.0, self.view.frame.size.height, 320.0, self.view.frame.size.height)];
	}];

	[MobClick endLogPageView:NSStringFromClass([self class])];

	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)getToken {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetToken:) name:MSG_GOT_TOKEN object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetToken:) name:MSG_FAIL_GET_TOKEN object:nil];

	self.loginType = LoginType_Normal;

	[[NetworkClient sharedNetworkClient] getCsrfToken];
}

- (void)cancelLogin {
	[self dismissViewControllerAnimated:YES completion: ^{
	    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_ERROR object:nil];
	}];
}

- (void)login {
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
	}
	else if (password.length <= 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"填写错误" message:@"请填写密码并重试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
		[alert show];
	}
	else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedLogin:) name:MSG_FAIL_LOGIN object:nil];

		[[NetworkClient sharedNetworkClient] loginWithLoginname:username password:password];
	}
}

- (void)failedLogin:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_LOGIN object:nil];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"请核对您的登录信息并重试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
	[alert show];
}

- (void)serviceLogin {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"使用合作网站帐号登录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"QQ登录", nil];
	[actionSheet showInView:self.view];
}

- (void)qqLogin {
	QQLogin *qq = [QQLogin sharedQQLogin];
	[qq loginWithQQ];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didQQLogin:) name:MSG_DID_QQ_LOGIN object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failQQLogin:) name:MSG_FAIL_QQ_LOGIN object:nil];
}

- (void)weiboLogin {
	WeiboLogin *weibo = [WeiboLogin sharedWeiboLogin];
	[weibo loginWithWeibo];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didWeiboLogin:) name:MSG_WEIBO_LOGIN object:nil];
}

- (void)dismissKeyboardButtonClicked {
	[self.usernameTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];
}

- (void)showRegisterView {
	self.registerViewController = [[RegisterViewController alloc] init];
	self.registerViewController.view.frame = CGRectMake(0.0, [[UIScreen mainScreen] bounds].size.height, 320.0, [[UIScreen mainScreen] bounds].size.height);
	[self.view addSubview:self.registerViewController.view];

	[UIView animateWithDuration:0.3 animations: ^{
	    [self.registerViewController.view setFrame:CGRectMake(0.0, 0.0, 320.0, [[UIScreen mainScreen] bounds].size.height)];
	}];
}

- (void)showQQRegisterView {
	[[QQLogin sharedQQLogin] getUserInfo];

	self.qqRegisterViewController = [[QQRegisterViewController alloc] init];
	self.qqRegisterViewController.view.frame = CGRectMake(0.0, [[UIScreen mainScreen] bounds].size.height, 320.0, [[UIScreen mainScreen] bounds].size.height);
	[self.view addSubview:self.qqRegisterViewController.view];

	[UIView animateWithDuration:0.3 animations: ^{
	    [self.qqRegisterViewController.view setFrame:CGRectMake(0.0, 0.0, 320.0, [[UIScreen mainScreen] bounds].size.height)];
	}];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];

	if (textField == self.passwordTextField) {
		[self getToken];
	}

	return YES;
}

#pragma mark - ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex < actionSheet.numberOfButtons - 1) {
		[self getToken];
		self.loginType = buttonIndex;
	}
}

#pragma mark - Event handler

- (void)handleError:(NSNotification *)notification {
	NSString *errorMsg = [[notification userInfo] objectForKey:@"ErrorMsg"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络问题" message:errorMsg delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
	[alert show];
}

- (void)didGetToken:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_GOT_TOKEN object:nil];
	switch (self.loginType) {
		case LoginType_QQ:
			[self qqLogin];
			break;

		case LoginType_WeiBo:
			[self weiboLogin];
			break;

		default:
			[self login];
			break;
	}
}

- (void)failGetToken:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_TOKEN object:nil];
	[self getToken];
}

- (void)didQQLogin:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_QQ_LOGIN object:nil];

	NSDictionary *userInfo = [notification userInfo];
	NSString *openId = [userInfo objectForKey:@"openId"];

	[[NetworkClient sharedNetworkClient] loginWithQQOpenId:openId];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showQQRegisterView) name:MSG_QQ_LOGIN_NOT_FOUND object:nil];
}

- (void)failQQLogin:(NSNotification *)notification {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"请重新尝试用QQ登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
	[alert show];
}

- (void)didWeiboLogin:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSInteger statusCode = [[userInfo objectForKey:@"statusCode"] integerValue];

	if (statusCode == WeiboSDKResponseStatusCodeSuccess) {
		NSString *userId = [[userInfo objectForKey:@"extraInfo"] objectForKey:@"userId"];
		NSString *accessToken = [[userInfo objectForKey:@"extraInfo"] objectForKey:@"accessToken"];

		[[WeiboLogin sharedWeiboLogin] getUserInfoWithUserId:userId accessToken:accessToken];
	}
}

@end
