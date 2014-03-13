//
//  MainMenuViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-10.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@property (nonatomic, strong) NSArray *menuItemTexts;
@property (nonatomic, strong) NSArray *menuItemImages;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) UITableView *mainMenuTable;

@property (nonatomic, strong) SearchViewController *searchController;
@property (nonatomic, strong) RankingListViewController *rankingListController;
@property (nonatomic, strong) CategoriesViewController *categoriesController;
@property (nonatomic, strong) ReviewListRootViewController *reviewListController;
@property (nonatomic, strong) WizardResultViewController *wizardController;

@property (nonatomic, strong) UIBarButtonItem *searchButton;

@end

@implementation MainMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"专治书荒";
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = UIC_WHISPER(1.0);
    
    self.menuItemTexts = @[@"榜单", @"一键治书荒", @"书评", @"分类"];
    self.menuItemImages = @[@"Hot", @"Wizard", @"Review", @"Category"];
    
    self.cellHeight = 55.0;
    
    CGFloat visibleHeight = self.view.bounds.size.height - UINAVIGATIONBAR_HEIGHT - UISTATUSBAR_HEIGHT - self.tabBarController.tabBar.bounds.size.height;
    if (!IsSysVerGTE(7.0)) {
        visibleHeight += UISTATUSBAR_HEIGHT;
    }
    
    self.mainMenuTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                       visibleHeight - [self.menuItemTexts count] * self.cellHeight,
                                                                       self.view.bounds.size.width,
                                                                       [self.menuItemTexts count] * self.cellHeight)
                                                      style:UITableViewStylePlain];
    self.mainMenuTable.backgroundColor = UIC_ALMOSTWHITE(1.0);
    self.mainMenuTable.delegate = self;
    self.mainMenuTable.dataSource = self;
    self.mainMenuTable.scrollEnabled = NO;
    self.mainMenuTable.separatorColor = UIC_BRIGHT_GRAY(0.4);
    if (IsSysVerGTE(7.0)) {
        self.mainMenuTable.separatorInset = UIEdgeInsetsZero;
    }
    [self.view addSubview:self.mainMenuTable];
    
    UIImageView *titlePlaceholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TitlePlaceholder"]];
    titlePlaceholder.frame = CGRectMake(40.0, 60.0, 232.0, 29.0);
    [self.view addSubview:titlePlaceholder];
    
    self.searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchView:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (isLogin()) {
        [self.navigationItem setRightBarButtonItem:self.searchButton];
    }
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Show sub-level views

- (void)showSearchView:(id)sender
{
    self.searchController = [[SearchViewController alloc] init];
    [self pushViewController:self.searchController];
}

- (void)showHotBooks
{
    self.rankingListController = [[RankingListViewController alloc] init];
    
    [self pushViewController:self.rankingListController];
}

- (void)showWizard
{
    self.wizardController = [[WizardResultViewController alloc] init];
    
    [self pushViewController:self.wizardController];
}

- (void)showReviews
{
    self.reviewListController = [[ReviewListRootViewController alloc] init];
    [self pushViewController:self.reviewListController];
}

- (void)showCategories
{
    self.categoriesController = [[CategoriesViewController alloc] init];
    [self pushViewController:self.categoriesController];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self showHotBooks];
            break;
        case 1:
            [self showWizard];
            break;
        case 2:
            [self showReviews];
            break;
        case 3:
            [self showCategories];
            break;
        default:
            break;
    }
    
    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (IsSysVerGTE(7.0)) {
        return 0.5;
    }
    return 1.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    headerView.backgroundColor = UIC_BRIGHT_GRAY(0.4);
    
    return headerView;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menuItemTexts count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.menuItemTexts objectAtIndex:indexPath.row];
    cell.textLabel.font = MEDIUM_FONT;
    cell.textLabel.textColor = UIC_BRIGHT_GRAY(1.0);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    
    if (indexPath.row < [self.menuItemImages count]) {
        cell.imageView.image = [UIImage imageNamed:[self.menuItemImages objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

@end
