//
//  SimilarBooksViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-12.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "OtherBooksViewController.h"
#import "BookGridViewController.h"
#import "NetworkClient.h"

#import "BookDetailViewController.h"

@interface OtherBooksViewController ()

@property (nonatomic, strong) BookGridViewController *bookGridController;



@end

@implementation OtherBooksViewController

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

	self.bookGridController = [[BookGridViewController alloc] initWithStyle:UITableViewStylePlain];
	self.bookGridController.view.frame = self.view.bounds;
	self.bookGridController.isPlain = YES;
	[self.view addSubview:self.bookGridController.view];
}

- (void)viewDidAppear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSimilarBooks:) name:MSG_DID_GET_BOOKS object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetSimilarBooks:) name:MSG_FAIL_GET_BOOKS object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:MSG_ERROR object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBook:) name:MSG_DID_SELECT_BOOK object:nil];

	[self getBooks];

	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

/*
   #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender,
   {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */

#pragma mark -
- (void)getBooks {
	if (self.bookId) {
		[[NetworkClient sharedNetworkClient] getSimilarBooksById:self.bookId];
	}
	else if (self.author) {
		[[NetworkClient sharedNetworkClient] getBooksBySameAuthor:self.author];
	}
}

#pragma mark - Event handler
- (void)didGetSimilarBooks:(NSNotification *)notification {
	self.bookGridController.books = [[notification userInfo] objectForKey:@"data"];

	[self.bookGridController.tableView reloadData];
}

- (void)failGetSimilarBooks:(NSNotification *)notification {
}

- (void)handleError:(NSNotification *)notification {
}

- (void)didSelectBook:(NSNotification *)notification {
	BookDetailViewController *bookDetailController = [[BookDetailViewController alloc] initWithStyle:UITableViewStylePlain];
	bookDetailController.bookId = [[notification userInfo] objectForKey:@"BookId"];

	[self pushViewController:bookDetailController];
}

@end
