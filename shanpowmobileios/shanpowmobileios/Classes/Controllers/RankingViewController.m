//
//  RankingViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-13.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "RankingViewController.h"
#import "RankingDetailViewController.h"
#import "BookDetailViewController.h"

@interface RankingViewController ()

@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) UIBarButtonItem *historyModeButton;

@property (nonatomic, assign) BOOL historyMode;

@end

@implementation RankingViewController

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

	RankingDetailViewController *detailViewController = [[RankingDetailViewController alloc] init];
	detailViewController.rankingTitle = self.currentRankingTitle;
	detailViewController.version = self.currentRankingVersion;

	self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
	self.pageController.dataSource = self;
	self.pageController.delegate = self;
	self.pageController.view.backgroundColor = UIC_BRIGHT_GRAY(1.0);
	[self.pageController setViewControllers:@[detailViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion: ^(BOOL finished) {}];
	[self.view addSubview:self.pageController.view];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[MobClick beginLogPageView:NSStringFromClass([self class])];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBook:) name:MSG_DID_SELECT_BOOK object:nil];
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

#pragma mark - Event handler
- (void)didSelectBook:(NSNotification *)notificatioin {
	NSString *bookId = [[notificatioin userInfo] objectForKey:@"BookId"];

	BookDetailViewController *bookDetailController = [[BookDetailViewController alloc] initWithStyle:UITableViewStylePlain];
	bookDetailController.bookId = bookId;

	[self pushViewController:bookDetailController];
}

#pragma mark -
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
	RankingDetailViewController *detailViewController = [[RankingDetailViewController alloc] init];
	detailViewController.rankingTitle = self.currentRankingTitle;

	RankingDetailViewController *controller = (RankingDetailViewController *)viewController;
	if ([controller.version integerValue] == 1) {
		return nil;
	}
	detailViewController.version = [NSString stringWithFormat:@"%d", [controller.version integerValue] - 1];

	return detailViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
	RankingDetailViewController *detailViewController = [[RankingDetailViewController alloc] init];
	detailViewController.rankingTitle = self.currentRankingTitle;

	RankingDetailViewController *controller = (RankingDetailViewController *)viewController;
	if ([controller.version integerValue] == [self.currentRankingVersion integerValue]) {
		return nil;
	}
	detailViewController.version = [NSString stringWithFormat:@"%d", [controller.version integerValue] + 1];

	return detailViewController;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
	NSLog(@"%@", pendingViewControllers);
}

@end
