//
//  QQRegisterViewController.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-17.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "QQRegisterViewController.h"

@interface QQRegisterViewController ()

@property (nonatomic, assign) CGRect adjustViewOriginalFrame;

- (void)registerNewAccount;

@end

@implementation QQRegisterViewController

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
	[self setBackgroundImage:[UIImage imageWithColor:UIC_WHISPER(1.0)]];

	[self addAdjustView];

	self.adjustView = [self.view viewWithTag:ADAPT_VIEW_TAG];
	self.adjustViewOriginalFrame = self.adjustView.frame;

	UIButton *dismissKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
	dismissKeyboardButton.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	[dismissKeyboardButton addTarget:self action:@selector(dismissKeyboardButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self.adjustView addSubview:dismissKeyboardButton];

	UIColor *placeholderColor = UIC_ALMOSTWHITE(0.65);

	// Background view for username text field
	UILabel *qqRegisterTip = [[UILabel alloc] initWithFrame:CGRectMake(32.0, 80.0 * SCREEN_RATIO, 256.0, 50.0)];
	qqRegisterTip.backgroundColor = [UIColor clearColor];
	qqRegisterTip.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
	qqRegisterTip.text = @"由于您是第一次登录，需要补填一些信息才能正常使用";
	qqRegisterTip.textAlignment = NSTextAlignmentCenter;
	qqRegisterTip.numberOfLines = 3;
	[self.adjustView addSubview:qqRegisterTip];

	// Background view for email text field
	UIImageView *emailTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_TextField"]];
	emailTextFieldBackground.frame = CGRectMake(32.0, 175.0 * SCREEN_RATIO, 256.0, 50.0);
	emailTextFieldBackground.userInteractionEnabled = YES;
	[self.adjustView addSubview:emailTextFieldBackground];

	// Email text field
	self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 13.0, 230.0, 24.0)];
	self.emailTextField.textColor = UIC_ALMOSTWHITE(1.0);
	self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入您的电子邮件地址" attributes:@{ NSForegroundColorAttributeName: placeholderColor }];
	self.emailTextField.delegate = self;
	[emailTextFieldBackground addSubview:self.emailTextField];

	// Gender Switch
	UILabel *genderTip = [[UILabel alloc] initWithFrame:CGRectMake(32.0, 280.0 * SCREEN_RATIO, 100.0, 30.0)];
	genderTip.text = @"性别";
	genderTip.textColor = [UIColor whiteColor];
	genderTip.backgroundColor = [UIColor clearColor];
	[self.adjustView addSubview:genderTip];

	self.genderSwitch = [[UISegmentedControl alloc] initWithItems:@[@"男", @"女"]];
	self.genderSwitch.frame = CGRectMake(188.0, 280.0 * SCREEN_RATIO, 100.0, 30.0);
	self.genderSwitch.tintColor = UIC_CYAN(1.0);
	self.genderSwitch.selectedSegmentIndex = 0;
	[self.adjustView addSubview:self.genderSwitch];

	// Register button
	self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.registerButton.frame = CGRectMake(32.0, 410.0 * SCREEN_RATIO, 256.0, 50.0);
	[self.registerButton setBackgroundImage:[UIImage imageWithColor:UIC_CYAN(1.0)] forState:UIControlStateNormal];
	[self.registerButton setBackgroundImage:[UIImage imageWithColor:UIC_CERULEAN(1.0)] forState:UIControlStateHighlighted];
	[self.registerButton setTitle:@"注册" forState:UIControlStateNormal];
	[self.registerButton addTarget:self action:@selector(registerNewAccount) forControlEvents:UIControlEventTouchUpInside];
	[self.adjustView addSubview:self.registerButton];

	// Cancel button
	self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.cancelButton.frame = CGRectMake(32.0, 490.0 * SCREEN_RATIO, 256.0, 50.0);
	[self.cancelButton setBackgroundImage:[UIImage imageWithColor:UIC_BRIGHT_GRAY(0.2)] forState:UIControlStateNormal];
	[self.cancelButton setBackgroundImage:[UIImage imageWithColor:UIC_BRIGHT_GRAY(0.5)] forState:UIControlStateHighlighted];
	[self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
	[self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
	[self.adjustView addSubview:self.cancelButton];

	// Observe to events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegister:) name:MSG_DID_REGISTER object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failRegister:) name:MSG_FAIL_REGISTER object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorHandler:) name:MSG_ERROR object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[MobClick endLogPageView:NSStringFromClass([self class])];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)dismissKeyboardButtonClicked {
	[self.emailTextField resignFirstResponder];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -

- (void)registerNewAccount {
	NSString *email = self.emailTextField.text;
	BOOL isMan = self.genderSwitch.selectedSegmentIndex == 0 ? YES : NO;

	NSDictionary *qqUserInfo = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CURRENT_QQ_USER_INFO];
	NSString *nickname = [qqUserInfo objectForKey:@"nickname"];
	NSString *avatarUrl = [qqUserInfo objectForKey:@"figureurl_qq_1"];

	NSString *openId = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CURRENT_QQ_OPENID];
	NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CURRENT_QQ_ACCESSTOKEN];

	[[NetworkClient sharedNetworkClient] registerWithQQNickname:nickname email:email openId:openId accessToken:accessToken avatarUrl:avatarUrl sex:isMan];
}

- (void)cancel {
	[UIView animateWithDuration:0.25 animations: ^{
	    [self clearControls];
	    [self.view setFrame:CGRectMake(0.0, self.view.frame.size.height, 320.0, self.view.frame.size.height)];
	}];
}

- (void)clearControls {
	self.emailTextField.text = @"";
	self.genderSwitch.selectedSegmentIndex = 0;
}

#pragma mark - Event Handler
- (void)didRegister:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_LOGIN object:self];
}

- (void)failRegister:(NSNotification *)notification {
	NSString *errMsg = [notification.userInfo objectForKey:@"ErrorMsg"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册错误" message:errMsg delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
	[alert show];
}

- (void)errorHandler:(NSNotification *)notification {
	NSString *errMsg = [notification.userInfo objectForKey:@"ErrorMsg"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出现问题" message:errMsg delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
	[alert show];
}

@end
