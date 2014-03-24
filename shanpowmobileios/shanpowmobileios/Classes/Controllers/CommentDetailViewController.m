//
//  CommentDetailViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-7.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "CommentDetailViewController.h"

#import "NetworkClient.h"
#import "CommentReviewView.h"
#import "BookDetailViewController.h"
#import "ResponseCell.h"
#import "UserProfileViewController.h"

@interface CommentDetailViewController ()

@property (nonatomic, strong) UIScrollView *container;

@property (nonatomic, strong) CommentReviewView *crView;
@property (nonatomic, strong) UITableView *mainTable;
@property (nonatomic, strong) SPTextView *responseTextField;
@property (nonatomic, strong) UIButton *replyButton;
@property (nonatomic, strong) UIButton *overlayButton;
@property (nonatomic, strong) UIButton *thumbUpButton;
@property (nonatomic, strong) UIButton *thumbDownButton;
@property (nonatomic, strong) UIButton *chatButton;

@property (nonatomic, assign) BOOL isReview;
@property (nonatomic, assign) BOOL shouldScrollToLastResponse;

@property (nonatomic, strong) NSDictionary *reviewDetail;

@property (nonatomic, assign) CGFloat textViewY;
@property (nonatomic, assign) CGSize oriSize;

@end

@implementation CommentDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (id)initWithIsReview:(BOOL)isReview {
	self = [super init];
	if (self) {
		// Custom initialization
		self.isReview = isReview;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.title = @"书评详情";
	self.view.backgroundColor = UIC_ALMOSTWHITE(1.0);

	if (IsSysVerGTE(7.0)) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}

	self.container = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,
	                                                                0.0,
	                                                                self.view.bounds.size.width,
	                                                                self.view.bounds.size.height - UINAVIGATIONBAR_HEIGHT - (IsSysVerGTE(7.0) ? UISTATUSBAR_HEIGHT : 0) - 45)];
	[self.view addSubview:self.container];

	self.crView = [[CommentReviewView alloc] initWithFrame:self.view.bounds];
	self.crView.showBookInfo = NO;
	self.crView.showMegaInfo = NO;
	self.crView.isDetailMode = YES;

	[self.container addSubview:self.crView];

	self.mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
	                                                               self.crView.frame.size.height,
	                                                               self.view.bounds.size.width,
	                                                               GENERAL_CELL_HEIGHT * 3)
	                                              style:UITableViewStylePlain];
	self.mainTable.delegate = self;
	self.mainTable.dataSource = self;
	self.mainTable.scrollEnabled = NO;
	if (IsSysVerGTE(7.0)) {
		self.mainTable.separatorInset = UIEdgeInsetsZero;
	}
	[self.container addSubview:self.mainTable];

	[self updateContainerContentSize];

	if (isLogin()) {
		self.responseTextField = [[SPTextView alloc] initWithFrame:CGRectMake(0.0,
		                                                                      self.container.frame.size.height,
		                                                                      self.view.frame.size.width - 70.0,
		                                                                      45.0)];
		self.responseTextField.backgroundColor = UIC_CERULEAN(1.0);
		self.responseTextField.textColor = UIC_ALMOSTWHITE(1.0);
		self.responseTextField.placeholder = @"输入回复内容";
		self.responseTextField.placeholderColor = UIC_ALMOSTWHITE(0.6);
		self.responseTextField.delegate = self;
		self.responseTextField.font = LARGE_FONT;
		[self.view addSubview:self.responseTextField];

		self.replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.replyButton.frame = CGRectMake(self.responseTextField.frame.size.width,
		                                    self.responseTextField.frame.origin.y,
		                                    70.0,
		                                    self.responseTextField.frame.size.height);
		[self.replyButton setBackgroundColor:UIC_BRIGHT_GRAY(1.0)];
		[self.replyButton addTarget:self action:@selector(replyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self.replyButton setTitle:@"回复" forState:UIControlStateNormal];
		[self.view addSubview:self.replyButton];

		self.overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self.overlayButton addTarget:self action:@selector(overlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self.overlayButton setBackgroundColor:[UIColor clearColor]];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[MobClick beginLogPageView:NSStringFromClass([self class])];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseAuthorNameTapped:) name:MSG_TAPPED_NICKNAME object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:MSG_ERROR object:nil];

	self.shouldScrollToLastResponse = NO;

	[self getCommentReviewDetail];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[MobClick endLogPageView:NSStringFromClass([self class])];

	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)getCommentReviewDetail {
	if (self.isReview) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDetail:) name:MSG_DID_GET_REVIEW_DETAIL object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetDetail:) name:MSG_FAIL_GET_REVIEW_DETAIL object:nil];

		[[NetworkClient sharedNetworkClient] getReviewDetailById:self.reviewId];
	}
	else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDetail:) name:MSG_DID_GET_COMMENT_DETAIL object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetDetail:) name:MSG_FAIL_GET_COMMENT_DETAIL object:nil];

		[[NetworkClient sharedNetworkClient] getCommentDetailByBookId:self.bookId authorId:self.authorId];
	}
}

- (void)updateContainerContentSize {
	self.container.contentSize = CGSizeMake(self.view.bounds.size.width, self.crView.calculatedHeight + self.mainTable.contentSize.height);
}

#pragma mark - Event handler
- (void)didGetDetail:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_REVIEW_DETAIL object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_COMMENT_DETAIL object:nil];

	self.reviewDetail = [[notification userInfo] objectForKey:@"data"];

	self.bookId = [self.reviewDetail objectForKey:@"BookId"];
	self.crView.comment = self.reviewDetail;
	self.crView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.crView.calculatedHeight);

	[self.mainTable reloadData];
	self.mainTable.frame = CGRectMake(0.0,
	                                  self.crView.calculatedHeight,
	                                  self.view.bounds.size.width,
	                                  self.mainTable.contentSize.height);

	[self updateContainerContentSize];

	if (self.shouldScrollToLastResponse) {
		if (self.container.contentSize.height > self.container.bounds.size.height) {
			CGPoint bottomOffset = CGPointMake(0, self.container.contentSize.height - self.container.bounds.size.height);
			[self.container setContentOffset:bottomOffset animated:YES];
		}
	}
}

- (void)failGetDetail:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_REVIEW_DETAIL object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_COMMENT_DETAIL object:nil];

	NSLog(@"%@", [notification userInfo]);
}

- (void)responseAuthorNameTapped:(NSNotification *)notification {
	UserProfileViewController *uesrProfileController = [[UserProfileViewController alloc] initWithUsername:[[notification userInfo] objectForKey:@"Nickname"]];

	[self pushViewController:uesrProfileController];
}

- (void)handleError:(NSNotification *)notification {
	NSLog(@"%@", [notification userInfo]);
}

- (void)thumbUpTapped:(UIButton *)sender {
	if (!isLogin()) {
		return;
	}

	if (self.isReview) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLike:) name:MSG_DID_LIKE_REVIEW object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failLikeOrDislike:) name:MSG_FAIL_LIKE_REVIEW object:nil];

		[[NetworkClient sharedNetworkClient] likeReviewByBookId:self.bookId reviewId:self.reviewId];
	}
	else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLike:) name:MSG_DID_LIKE_COMMENT object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failLikeOrDislike:) name:MSG_FAIL_LIKE_COMMENT object:nil];

		[[NetworkClient sharedNetworkClient] likeCommentByBookId:self.bookId authorId:self.authorId];
	}
}

- (void)thumbDownTapped:(UIButton *)sender {
	if (!isLogin()) {
		return;
	}

	if (self.isReview) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDislike:) name:MSG_DID_DISLIKE_REVIEW object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failLikeOrDislike:) name:MSG_FAIL_DISLIKE_REVIEW object:nil];

		[[NetworkClient sharedNetworkClient] dislikeReviewByBookId:self.bookId reviewId:self.reviewId];
	}
	else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDislike:) name:MSG_DID_DISLIKE_COMMENT object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failLikeOrDislike:) name:MSG_FAIL_DISLIKE_COMMENT object:nil];

		[[NetworkClient sharedNetworkClient] dislikeCommentByBookId:self.bookId authorId:self.authorId];
	}
}

- (void)chatTapped:(UIButton *)sender {
	if (!isLogin()) {
		return;
	}

	[self.responseTextField becomeFirstResponder];
}

- (void)replyButtonTapped:(UIButton *)sender {
	if ([self.responseTextField.text length] <= 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错啦" message:@"回复内容不能为空" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
		[alert show];
	}
	else {
		NSString *replyContent =  self.responseTextField.text;

		if (self.isReview) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResponse:) name:MSG_DID_RESPONSE_TO_REVIEW object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failResponse:) name:MSG_FAIL_RESPONSE_TO_REVIEW object:nil];

			[[NetworkClient sharedNetworkClient] responseToReview:replyContent bookId:self.bookId reviewId:self.reviewId];
		}
		else {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResponse:) name:MSG_DID_RESPONSE_TO_COMMENT object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failResponse:) name:MSG_FAIL_RESPONSE_TO_COMMENT object:nil];

			[[NetworkClient sharedNetworkClient] responseToComment:replyContent bookId:self.bookId commentAuthorId:self.authorId];
		}
	}
}

- (void)overlayButtonTapped:(UIButton *)sender {
	[self.responseTextField resignFirstResponder];
}

- (void)handleKeyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

	[UIView animateWithDuration:0.25 animations: ^{
	    self.responseTextField.frame = CGRectMake(keyboardBounds.origin.x,
	                                              keyboardBounds.origin.y - self.responseTextField.frame.size.height - UINAVIGATIONBAR_HEIGHT - UISTATUSBAR_HEIGHT,
	                                              self.responseTextField.frame.size.width,
	                                              self.responseTextField.frame.size.height);

	    self.replyButton.frame = CGRectMake(self.replyButton.frame.origin.x,
	                                        self.responseTextField.frame.origin.y,
	                                        self.replyButton.frame.size.width,
	                                        self.replyButton.frame.size.height);
	} completion: ^(BOOL finished) {
	    self.overlayButton.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.responseTextField.frame.origin.y);
	    [self.view addSubview:self.overlayButton];
	    if (self.textViewY <= 0) {
	        self.textViewY = self.responseTextField.frame.origin.y;
		}
	}];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

	[UIView animateWithDuration:0.25 animations: ^{
	    self.responseTextField.frame = CGRectMake(self.responseTextField.frame.origin.x,
	                                              ([self.responseTextField.text length] > 0 ? self.responseTextField.frame.origin.y : self.textViewY) + keyboardBounds.size.height,
	                                              self.responseTextField.frame.size.width,
	                                              ([self.responseTextField.text length] > 0 ? self.responseTextField.frame.size.height : 45));

	    self.container.frame = CGRectMake(self.container.frame.origin.x,
	                                      self.container.frame.origin.y,
	                                      self.container.frame.size.width,
	                                      self.view.bounds.size.height - self.responseTextField.frame.size.height);

	    self.replyButton.frame = CGRectMake(self.replyButton.frame.origin.x,
	                                        self.responseTextField.frame.origin.y,
	                                        self.replyButton.frame.size.width,
	                                        self.replyButton.frame.size.height);
	} completion: ^(BOOL finished) {
	    [self.overlayButton removeFromSuperview];
	}];
}

- (void)didLike:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:nil];

	[self getCommentReviewDetail];
}

- (void)didDislike:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:nil];

	[self getCommentReviewDetail];
}

- (void)failLikeOrDislike:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:nil];

	NSString *err = [[notification userInfo] objectForKey:@"ErrorMsg"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错啦" message:err delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
	[alert show];
}

- (void)didResponse:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:nil];

	[self.responseTextField resignFirstResponder];
	self.responseTextField.text = @"";

	self.shouldScrollToLastResponse = YES;

	[self getCommentReviewDetail];
}

- (void)failResponse:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:nil];

	NSString *err = [[notification userInfo] objectForKey:@"ErrorMsg"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错啦" message:err delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
	[alert show];
}

#pragma mark - UITextView delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		[self replyButtonTapped:self.replyButton];

		return NO;
	}
	else {
		if (self.textViewY <= 0) {
			self.oriSize = textView.contentSize;
			self.textViewY = textView.frame.origin.y;
		}
	}

	return YES;
}

- (void)textChanged:(NSNotification *)notification {
	SPTextView *textView = [notification object];

	if (self.oriSize.height != textView.contentSize.height) {
		[UIView animateWithDuration:0.15
		                 animations: ^{
		    CGRect newFrame = CGRectZero;

		    newFrame = CGRectMake(textView.frame.origin.x,
		                          MAX((self.textViewY - MAX(textView.contentSize.height, 45) + 45), 0),
		                          textView.frame.size.width,
		                          MIN((MAX(textView.contentSize.height, 45)), self.textViewY + 45));
		    self.responseTextField.frame = newFrame;

		    self.replyButton.frame = CGRectMake(self.replyButton.frame.origin.x,
		                                        self.responseTextField.frame.origin.y,
		                                        self.replyButton.frame.size.width,
		                                        self.responseTextField.frame.size.height);
		}];
	}
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section != 0) {
		return 30.0;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			return [UIImage imageNamed:@"ActionDivider"].size.height;

		case 1:
			return GENERAL_CELL_HEIGHT;

		case 2:
		{
			NSString *content = [[[self.reviewDetail objectForKey:@"Responses"] objectAtIndex:indexPath.row] objectForKey:@"Content"];
			CGFloat height = TextHeightWithFont(MEDIUM_FONT) + heightForMultilineTextWithFont(content, SMALL_FONT, self.view.frame.size.width - 20) + 15.0;
			return height;
		}

		default:
			return GENERAL_CELL_HEIGHT;
			break;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, tableView.frame.size.width, 20.0)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = SMALL_FONT;
	titleLabel.textColor = UIC_BRIGHT_GRAY(0.5);

	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, tableView.frame.size.width, 30.0)];
	view.backgroundColor = UIC_WHISPER(1.0);
	[view addSubview:titleLabel];

	switch (section) {
		case 1:
			titleLabel.text = @"以下为本评论相关书籍";
			break;

		case 2:
			titleLabel.text = @"回复";
			break;

		default:
			break;
	}

	return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 1) {
		BookDetailViewController *bookDetailController = [[BookDetailViewController alloc] initWithStyle:UITableViewStylePlain];
		bookDetailController.bookId = [self.reviewDetail objectForKey:@"BookId"];

		[self pushViewController:bookDetailController hideBottomBar:YES];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	if (section == 2) {
		return [[self.reviewDetail objectForKey:@"ResponseSum"] integerValue];
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
		{
			static NSString *CellIdentifier = @"Cell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

				self.thumbUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
				self.thumbUpButton.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width / 3, [UIImage imageNamed:@"ActionDivider"].size.height);
				[self.thumbUpButton setImage:[UIImage imageNamed:@"ThumbUp_CYAN"] forState:UIControlStateNormal];
				[self.thumbUpButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
				[self.thumbUpButton setTitleColor:UIC_CYAN(1.0) forState:UIControlStateNormal];
				[self.thumbUpButton setBackgroundImage:[UIImage imageWithColor:UIC_WHISPER(0.5)] forState:UIControlStateHighlighted];
				[self.thumbUpButton addTarget:self action:@selector(thumbUpTapped:) forControlEvents:UIControlEventTouchUpInside];
				[cell addSubview:self.thumbUpButton];

				self.thumbDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
				self.thumbDownButton.frame = CGRectMake(self.view.frame.size.width / 3, 0.0, self.view.frame.size.width / 3, [UIImage imageNamed:@"ActionDivider"].size.height);
				[self.thumbDownButton setImage:[UIImage imageNamed:@"ThumbDown_CYAN"] forState:UIControlStateNormal];
				[self.thumbDownButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
				[self.thumbDownButton setTitleColor:UIC_CYAN(1.0) forState:UIControlStateNormal];
				[self.thumbDownButton setBackgroundImage:[UIImage imageWithColor:UIC_WHISPER(0.5)] forState:UIControlStateHighlighted];
				[self.thumbDownButton addTarget:self action:@selector(thumbDownTapped:) forControlEvents:UIControlEventTouchUpInside];
				[cell addSubview:self.thumbDownButton];

				self.chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
				self.chatButton.frame = CGRectMake(self.view.frame.size.width * 2 / 3, 0.0, self.view.frame.size.width / 3, [UIImage imageNamed:@"ActionDivider"].size.height);
				[self.chatButton setImage:[UIImage imageNamed:@"Chat_CYAN"] forState:UIControlStateNormal];
				[self.chatButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
				[self.chatButton setTitleColor:UIC_CYAN(1.0) forState:UIControlStateNormal];
				[self.chatButton setBackgroundImage:[UIImage imageWithColor:UIC_WHISPER(0.5)] forState:UIControlStateHighlighted];
				[self.chatButton addTarget:self action:@selector(chatTapped:) forControlEvents:UIControlEventTouchUpInside];
				[cell addSubview:self.chatButton];

				cell.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"ActionDivider"] imageByApplyingAlpha:0.1]];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}

			[self.thumbUpButton setTitle:[NSString stringWithFormat:@"%ld", (long)[[self.reviewDetail objectForKey:@"LikeSum"] integerValue]] forState:UIControlStateNormal];
			[self.thumbDownButton setTitle:[NSString stringWithFormat:@"%ld", (long)[[self.reviewDetail objectForKey:@"DislikeSum"] integerValue]] forState:UIControlStateNormal];
			[self.chatButton setTitle:[NSString stringWithFormat:@"%ld", (long)[[self.reviewDetail objectForKey:@"ResponseSum"] integerValue]] forState:UIControlStateNormal];

			return cell;
		}

		case 1:
		{
			static NSString *CellIdentifier = @"Cell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

				UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 8.0, cell.bounds.size.width - 50, 20)];
				titleLabel.text = self.bookTitle;
				titleLabel.font = MEDIUM_FONT;
				[cell addSubview:titleLabel];

				UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
				                                                                   cell.bounds.size.height - TextHeightWithFont(SMALL_FONT) + 5,
				                                                                   cell.bounds.size.width - 50,
				                                                                   TextHeightWithFont(SMALL_FONT))];
				categoryLabel.text = self.bookCategory;
				categoryLabel.font = SMALL_FONT;
				categoryLabel.textColor = UIC_BRIGHT_GRAY(0.5);
				[cell addSubview:categoryLabel];

				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}

			return cell;
		}

		case 2:
		{
			static NSString *CellIdentifier = @"Cell";
			ResponseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

			if (cell == nil) {
				cell = [[ResponseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}

			cell.response = [[self.reviewDetail objectForKey:@"Responses"] objectAtIndex:indexPath.row];

			return cell;
		}

		default:
			return nil;
			break;
	}
	return nil;
}

@end
