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
@property (nonatomic, strong) HotBooksViewController *hotBookController;

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
    self.title = @"首页";
    self.view.backgroundColor = UIC_WHISPER(1.0);
    
    self.menuItemTexts = @[@"热门书籍", @"一键治书荒", @"大家都在看", @"书评", @"分类"];
    self.menuItemImages = @[@"Hot", @"Wizard", @"MinNa", @"Review", @"Category"];
    
    self.cellHeight = 55.0;
    
    CGFloat visibleHeight = self.view.bounds.size.height - UINAVIGATIONBAR_HEIGHT - self.tabBarController.tabBar.bounds.size.height;
    
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
    if (isSysVerGTE(7.0)) {
        self.mainMenuTable.separatorInset = UIEdgeInsetsZero;
    }
    [self.view addSubview:self.mainMenuTable];
    
    UIImageView *titlePlaceholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TitlePlaceholder"]];
    titlePlaceholder.frame = CGRectMake(40.0, 60.0, 232.0, 29.0);
    [self.view addSubview:titlePlaceholder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            self.hotBookController = [[HotBooksViewController alloc] init];
            [MAIN_NAVIGATION_CONTROLLER pushViewController:self.hotBookController animated:YES];
            break;
            
        default:
            break;
    }
    
    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (isSysVerGTE(7.0)) {
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
