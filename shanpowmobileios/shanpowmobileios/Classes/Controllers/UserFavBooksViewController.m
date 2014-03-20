//
//  UserFavBooksViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-15.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "UserFavBooksViewController.h"
#import "BookGridViewController.h"
#import "BookDetailViewController.h"
#import "NetworkClient.h"


@interface UserFavBooksViewController ()


@property (nonatomic, strong) BookGridViewController *bookGridController;

@end

@implementation UserFavBooksViewController

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
	if (IsSysVerGTE(7.0)) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	self.title = @"喜欢的书";

	self.bookGridController = [[BookGridViewController alloc] initWithStyle:UITableViewStylePlain];
	self.bookGridController.view.frame = self.view.bounds;
	[self.view addSubview:self.bookGridController.view];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBook:) name:MSG_DID_SELECT_BOOK object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBooks:) name:MSG_DID_GET_BOOKS object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetBooks:) name:MSG_FAIL_GET_BOOKS object:nil];

	[self getFavBooks];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)getFavBooks {
	[[NetworkClient sharedNetworkClient] getFavBooksByUser:self.username];
}

#pragma mark - Event handler
- (void)didSelectBook:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_SELECT_BOOK object:nil];

	NSString *bookId = [[notification userInfo] objectForKey:@"BookId"];

	BookDetailViewController *bookDetailController = [[BookDetailViewController alloc] initWithStyle:UITableViewStylePlain];
	bookDetailController.bookId = bookId;

	[self pushViewController:bookDetailController];
}

- (void)didGetBooks:(NSNotification *)notification {
	NSArray *books = [[notification userInfo] objectForKey:@"data"];

	self.bookGridController.books = books;
	self.bookGridController.isPlain = YES;
}

- (void)failGetBooks:(NSNotification *)notification {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERR_TITLE message:ERR_FAIL_GET_DATA delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"重试", nil];
	[alert show];
}

@end
