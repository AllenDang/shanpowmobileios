//
//  FilterViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-27.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController ()

@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *readStatusTitles;
@property (nonatomic, strong) NSArray *channelTitles;

@property (nonatomic, assign) BOOL showAll;
@property (nonatomic, strong) NSString *categoryToShow;
@property (nonatomic, assign) NSInteger scoreToShow;
@property (nonatomic, assign) FilterChannel channel;

@property (nonatomic, assign) float cellHeight;

@property (nonatomic, strong) UITableViewCell *lastReadStatusCell;
@property (nonatomic, strong) UITableViewCell *lastChannelCell;
@property (nonatomic, strong) UITableViewCell *lastScoreCell;
@property (nonatomic, strong) CategoriesCell *categoriesCell;

@end

@implementation FilterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        if (IsSysVerGTE(7.0)) {
            self.tableView.separatorInset = UIEdgeInsetsZero;
        }
        
        self.sectionTitles = @[@"阅读状态", @"频道", @"分类", @"评分"];
        self.readStatusTitles = @[@"全部书籍", @"我没看过的书籍"];
        self.channelTitles = @[@"全部", @"男生频道", @"女生频道"];
        
        self.showAll = YES;
        self.categoryToShow = @"全部";
        self.scoreToShow = 0;
        self.channel = 0;
        
        self.cellHeight = 45.0;
        
        self.showChannel = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.backgroundColor = UIC_ALMOSTWHITE(1.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            if (!self.showReadStatus) {
                return 0;
            } else {
                return self.cellHeight;
            }
        }
        case 1:
        {
            if (!self.showChannel) {
                return 0;
            } else {
                return self.cellHeight;
            }
        }
        case 2:
        {
            if (indexPath.row == 1) {
                return 5 * self.cellHeight;
            } else {
                return self.cellHeight;
            }
        }
        default:
            return self.cellHeight;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            if (self.lastReadStatusCell) {
                self.lastReadStatusCell.accessoryType = UITableViewCellAccessoryNone;
            }
            UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
            currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.lastReadStatusCell = currentCell;
            
            if (indexPath.row == 0) {
                self.showAll = YES;
            } else {
                self.showAll = NO;
            }
            
            break;
        }
        case 1:
        {
            if (self.lastChannelCell) {
                self.lastChannelCell.accessoryType = UITableViewCellAccessoryNone;
            }
            UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
            currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.lastChannelCell = currentCell;
            
            self.channel = indexPath.row;
            
            break;
        }
        case 2:
        {
            if (indexPath.row == 0) {
                self.categoryToShow = @"全部";
                [self.categoriesCell clearSelection];
                
                UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
                [UIView animateWithDuration:0.25 animations:^{
                    currentCell.backgroundColor = UIC_BRIGHT_GRAY(0.2);
                }];
            }
            break;
        }
        case 3:
        {
            if (self.lastScoreCell) {
                self.lastScoreCell.accessoryType = UITableViewCellAccessoryNone;
            }
            UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
            currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.lastScoreCell = currentCell;
            
            if (indexPath.row == 0) {
                self.scoreToShow = 0;
            } else {
                self.scoreToShow = 6 - indexPath.row;
            }
            
            break;
        }
        default:
            break;
    }
    
    if (self.dataSource) {
        [self.dataSource filterDataWithReadStatus:self.showAll channel:self.channel categoryToShow:self.categoryToShow scoreToShow:self.scoreToShow];
    }
    
    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 && !self.showReadStatus) {
        return 0;
    }
    
    if (section == 1 && !self.showChannel) {
        return 0;
    }
    
    return GENERAL_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.view.frame.size.width - 20, GENERAL_HEADER_HEIGHT)];
    headerLabel.text = [self.sectionTitles objectAtIndex:section];
    headerLabel.textColor = UIC_ALMOSTWHITE(1.0);
    headerLabel.font = MEDIUM_BOLD_FONT;
    headerLabel.backgroundColor= [UIColor clearColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, GENERAL_HEADER_HEIGHT)];
    [headerView addSubview:headerLabel];
    headerView.backgroundColor = UIC_WHISPER(0.5);
    
    UIView *headerBGView = [[UIView alloc] initWithFrame:headerView.bounds];
    [headerBGView addSubview:headerView];
    headerBGView.backgroundColor = UIC_BRIGHT_GRAY(1.0);
    
    return headerBGView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 2;
        case 3:
            return 6;
        default:
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            static NSString *CellIdentifier = @"CellForReadStatus";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                if (indexPath.row == 0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    self.lastReadStatusCell = cell;
                }
            }
            
            cell.backgroundColor = UIC_BRIGHT_GRAY(1.0);
            cell.textLabel.textColor = UIC_ALMOSTWHITE(1.0);
            cell.textLabel.font = MEDIUM_FONT;
            if (IsSysVerGTE(7.0)) {
                [cell setTintColor:UIC_ALMOSTWHITE(1.0)];
            }
            
            cell.textLabel.text = [self.readStatusTitles objectAtIndex:indexPath.row];
            
            return cell;
            break;
        }
        case 1:
        {
            static NSString *CellIdentifier = @"CellForChannel";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                if (indexPath.row == 0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    self.lastChannelCell = cell;
                }
            }
            
            cell.backgroundColor = UIC_BRIGHT_GRAY(1.0);
            cell.textLabel.textColor = UIC_ALMOSTWHITE(1.0);
            cell.textLabel.font = MEDIUM_FONT;
            if (IsSysVerGTE(7.0)) {
                [cell setTintColor:UIC_ALMOSTWHITE(1.0)];
            }
            
            cell.textLabel.text = [self.channelTitles objectAtIndex:indexPath.row];
            
            return cell;
            break;
        }
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    static NSString *CellIdentifier = @"CellForCategoryAll";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    // Configure the cell...
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        cell.backgroundColor = UIC_BRIGHT_GRAY(0.2);
                    }
                    
                    cell.textLabel.textColor = UIC_ALMOSTWHITE(1.0);
                    cell.textLabel.font = MEDIUM_FONT;
                    cell.textLabel.backgroundColor = [UIColor clearColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    if (IsSysVerGTE(7.0)) {
                        [cell setTintColor:UIC_ALMOSTWHITE(1.0)];
                    }
                    
                    cell.textLabel.text = @"全部";
                    return cell;
                    break;
                }
                case 1:
                {
                    static NSString *CellIdentifier = @"CellForCategorySplitted";
                    CategoriesCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    // Configure the cell...
                    if (cell == nil) {
                        cell = [[CategoriesCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:CellIdentifier
                                                          cellHeight:self.cellHeight
                                                               width:self.view.bounds.size.width + 1];
                    }
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.delegate = self;
                    self.categoriesCell = cell;
                    
                    return cell;
                    break;
                }
                default:
                    return nil;
                    break;
            }
        }
        case 3:
        {
            static NSString *CellIdentifier = @"CellForRating";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                if (indexPath.row == 0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    self.lastScoreCell = cell;
                }
            }
            
            cell.backgroundColor = UIC_BRIGHT_GRAY(1.0);
            cell.textLabel.textColor = UIC_ALMOSTWHITE(1.0);
            cell.textLabel.font = MEDIUM_FONT;
            [cell setTintColor:UIC_ALMOSTWHITE(1.0)];
            
            if (indexPath.row == 0) {
                cell.textLabel.text = @"全部";
            } else {
                NSString *titleText = @"";
                for (long i = indexPath.row - 1; i < 5; i++) {
                    titleText = [titleText stringByAppendingString:@"★"];
                }
                cell.textLabel.text = titleText;
            }
            
            return cell;
            break;
        }
        default:
            return nil;
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - CategoriesCell delegate
- (BOOL)shouldSelectCategory:(NSString *)category
{
    return YES;
}

- (void)categorySelected:(NSString *)category
{
    self.categoryToShow = category;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[self.sectionTitles indexOfObject:@"分类"]];
    
    UITableViewCell *allCell = [self.tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1 animations:^{
        allCell.backgroundColor = UIC_BRIGHT_GRAY(1.0);
    }];
    
    if (self.dataSource) {
        [self.dataSource filterDataWithReadStatus:self.showAll channel:self.channel categoryToShow:self.categoryToShow scoreToShow:self.scoreToShow];
    }
}

@end
