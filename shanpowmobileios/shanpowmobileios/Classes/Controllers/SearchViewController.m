//
//  SearchViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-12.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) SearchResultViewController *searchResultController;

@end

@implementation SearchViewController

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

	self.title = @"搜索";
	self.view.backgroundColor = UIC_ALMOSTWHITE(1.0);
	if (IsSysVerGTE(7.0)) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}

	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)];
	self.searchBar.placeholder = @"搜索书名、作者、分类等";
	self.searchBar.delegate = self;
	[self.view addSubview:self.searchBar];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[MobClick beginLogPageView:NSStringFromClass([self class])];

	[self.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[MobClick endLogPageView:NSStringFromClass([self class])];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSearchResult:) name:MSG_DID_GET_SEARCH_RESULT object:nil];

	NSString *keyword = self.searchBar.text;
	[[NetworkClient sharedNetworkClient] searchWithKeyword:keyword];
}

#pragma mark - Event handler

- (void)didGetSearchResult:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_SEARCH_RESULT object:nil];

	self.searchResultController = [[SearchResultViewController alloc] initWithSearchResult:[[notification userInfo] objectForKey:@"data"]];

	[self pushViewController:self.searchResultController];
}

@end
