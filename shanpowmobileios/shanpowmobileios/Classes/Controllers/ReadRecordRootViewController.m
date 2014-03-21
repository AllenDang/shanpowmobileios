//
//  ReadRecordRootViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-4.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "ReadRecordRootViewController.h"

@interface ReadRecordRootViewController ()

@property (nonatomic, strong) ReadRecordViewController *readRecordController;
@property (nonatomic, strong) FilterViewController *filterController;

@end

@implementation ReadRecordRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (id)initWithUserName:(NSString *)username {
	ReadRecordViewController *rrController = [[ReadRecordViewController alloc] initWithStyle:UITableViewStylePlain];
	rrController.username = username;
	rrController.avatarUrl = self.avatarUrl;

	FilterViewController *fController = [[FilterViewController alloc] initWithStyle:UITableViewStylePlain];
	fController.showReadStatus = NO;

	self = [super initWithCenterViewController:rrController rightDrawerViewController:fController];
	if (self) {
		self.username = username;

		self.readRecordController = rrController;
		self.filterController = fController;
		self.filterController.dataSource = self.readRecordController;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.title = @"阅读记录和书评";

//    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Filter"] style:UIBarButtonItemStylePlain target:self action:@selector(openFilter:)];
//    [self.navigationItem setRightBarButtonItem:filterButton];

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

#pragma mark -
- (void)setUsername:(NSString *)username {
	if (![username isEqualToString:_username]) {
		_username = username;

		self.readRecordController.username = username;
	}
}

- (void)setAvatarUrl:(NSString *)avatarUrl {
	if (![avatarUrl isEqualToString:_avatarUrl]) {
		_avatarUrl = avatarUrl;

		self.readRecordController.avatarUrl = avatarUrl;
	}
}

#pragma mark - Event handler
- (void)openFilter:(UIBarButtonItem *)sender {
	if ([self openSide] == MMDrawerSideRight) {
		self.title = @"书单详情";
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
