//
//  CreateBookListViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-13.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "CreateBookListViewController.h"
#import "NetworkClient.h"

@interface CreateBookListViewController ()

@property (nonatomic, strong) UITextField *booklistTitleTextView;
@property (nonatomic, strong) SPTextView *booklistDescriptionTextView;
@property (nonatomic, strong) UIBarButtonItem *done;

@end

@implementation CreateBookListViewController

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
	self.title = @"创建书单";
	self.view.backgroundColor = UIC_ALMOSTWHITE(1.0);

	if (IsSysVerGTE(7.0)) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}

	self.done = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doneCreateBookList:)];
	[self.navigationItem setRightBarButtonItem:self.done];

	self.booklistTitleTextView = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 0.0, self.view.bounds.size.width - 20, 40.0)];
	self.booklistTitleTextView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"书单名（必填）"
	                                                                                   attributes:@{ NSForegroundColorAttributeName: UIC_BRIGHT_GRAY(0.3) }];
	self.booklistTitleTextView.font = MEDIUM_FONT;
	[self.view addSubview:self.booklistTitleTextView];

	UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.booklistTitleTextView.bounds.size.height, self.view.bounds.size.width, 1.0)];
	divider.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Dot"]];
	divider.alpha = 0.2;
	[self.view addSubview:divider];

	self.booklistDescriptionTextView = [[SPTextView alloc] initWithFrame:CGRectMake(5.0,
	                                                                                self.booklistTitleTextView.frame.size.height + 5.0,
	                                                                                self.view.bounds.size.width - 10,
	                                                                                self.view.bounds.size.height - self.booklistTitleTextView.frame.size.height - self.tabBarController.tabBar.frame.size.height - UINAVIGATIONBAR_HEIGHT - UISTATUSBAR_HEIGHT - 10)];
	self.booklistDescriptionTextView.placeholder = @"书单描述（可选）";
	self.booklistDescriptionTextView.placeholderColor = UIC_BRIGHT_GRAY(0.3);
	self.booklistDescriptionTextView.font = MEDIUM_FONT;
	self.booklistDescriptionTextView.backgroundColor = [UIColor clearColor];
	self.booklistDescriptionTextView.delegate = self;
	[self.view addSubview:self.booklistDescriptionTextView];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateBooklist:) name:MSG_DID_CREATE_BOOKLIST object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failCreateBooklist:) name:MSG_FAIL_CREATE_BOOKLIST object:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)doneCreateBookList:(UIBarButtonItem *)sender {
	NSString *title = self.booklistTitleTextView.text;
	NSString *desc = self.booklistDescriptionTextView.text;

	[[NetworkClient sharedNetworkClient] createBooklistWithTitle:title description:desc];
}

#pragma mark - Event handler
- (void)handleKeyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

	[UIView animateWithDuration:0.25 animations: ^{
	    self.booklistDescriptionTextView.frame = CGRectMake(self.booklistDescriptionTextView.frame.origin.x,
	                                                        self.booklistDescriptionTextView.frame.origin.y,
	                                                        self.booklistDescriptionTextView.frame.size.width,
	                                                        self.booklistDescriptionTextView.frame.size.height - keyboardBounds.size.height + self.tabBarController.tabBar.frame.size.height);
	} completion: ^(BOOL finished) {
	    [self.booklistDescriptionTextView scrollRangeToVisible:NSMakeRange((self.booklistDescriptionTextView.text.length > 0 ? self.booklistDescriptionTextView.text.length : 0), 0)];
	}];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

	[UIView animateWithDuration:0.25 animations: ^{
	    self.booklistDescriptionTextView.frame = CGRectMake(self.booklistDescriptionTextView.frame.origin.x,
	                                                        self.booklistDescriptionTextView.frame.origin.y,
	                                                        self.booklistDescriptionTextView.frame.size.width,
	                                                        self.booklistDescriptionTextView.frame.size.height + keyboardBounds.size.height - self.tabBarController.tabBar.frame.size.height);
	} completion: ^(BOOL finished) {
	}];
}

- (void)didCreateBooklist:(NSNotification *)notification {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"书单已经创建成功" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
	alert.tag = 1000;
	[alert show];
}

- (void)failCreateBooklist:(NSNotification *)notification {
	NSString *err = [[notification userInfo] objectForKey:@"ErrorMsg"];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错啦" message:err delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
	alert.tag = 1001;
	[alert show];
}

#pragma mark - UITextView delegate
- (BOOL)textView:(UITextView *)tView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	CGRect textRect = [tView.layoutManager usedRectForTextContainer:tView.textContainer];
	CGFloat sizeAdjustment = tView.font.lineHeight * [UIScreen mainScreen].scale;

	if (textRect.size.height >= tView.frame.size.height - sizeAdjustment) {
		if ([text isEqualToString:@"\n"]) {
			[UIView animateWithDuration:0.2 animations: ^{
			    [tView setContentOffset:CGPointMake(tView.contentOffset.x, tView.contentOffset.y + sizeAdjustment)];
			}];
		}
	}

	return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
	[textView scrollRangeToVisible:textView.selectedRange];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 1000) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

@end
