//
//  ReviewListRootViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-6.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "ReviewListRootViewController.h"
#import "ReviewListViewController.h"
#import "FilterViewController.h"

@interface ReviewListRootViewController ()

@property (nonatomic, strong) ReviewListViewController *reviewListController;
@property (nonatomic, strong) FilterViewController *filterController;

@end

@implementation ReviewListRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (id)init {
	ReviewListViewController *rrController = [[ReviewListViewController alloc] initWithStyle:UITableViewStylePlain];

	FilterViewController *fController = [[FilterViewController alloc] initWithStyle:UITableViewStylePlain];
	fController.showReadStatus = NO;
	fController.showChannel = YES;
	fController.dataSource = rrController;

	self = [super initWithCenterViewController:rrController rightDrawerViewController:fController];
	if (self) {
		self.reviewListController = rrController;
		self.filterController = fController;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	self.title = @"书评";

	UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Filter"] style:UIBarButtonItemStylePlain target:self action:@selector(openFilter:)];
	[self.navigationItem setRightBarButtonItem:filterButton];

	if (IsSysVerGTE(7.0)) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	[self setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
	[self setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];

	[self setMaximumRightDrawerWidth:300.0];
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

#pragma mark - Event handler
- (void)openFilter:(UIBarButtonItem *)sender {
	if ([self openSide] == MMDrawerSideRight) {
		self.title = @"书评";
		self.navigationItem.hidesBackButton = NO;
		[self closeDrawerAnimated:YES completion: ^(BOOL finished) {
		}];
	}
	else {
		self.title = @"过滤";
		self.navigationItem.hidesBackButton = YES;
		[self openDrawerSide:MMDrawerSideRight animated:YES completion: ^(BOOL finished) {
		}];
	}
}

@end
