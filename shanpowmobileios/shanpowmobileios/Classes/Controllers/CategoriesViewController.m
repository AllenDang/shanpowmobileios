//
//  CategoriesViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-12.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "CategoriesViewController.h"

@interface CategoriesViewController ()

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, assign) CGFloat cellHeight;

@end

@implementation CategoriesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.categories = @[@"玄幻", @"奇幻", @"架空", @"仙侠", @"武侠", @"历史", @"穿越", @"言情", @"都市", @"青春", @"官场", @"悬疑", @"恐怖", @"军事", @"竞技", @"科幻"];
    
    self.title = @"分类";
    self.view.backgroundColor = UIC_ALMOSTWHITE(1.0);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.cellHeight = MAX((self.view.bounds.size.height - UINAVIGATIONBAR_HEIGHT) / (int)(([self.categories count] + 1) / 2), 60.0);
    
    if (self.cellHeight > 60.0) {
        self.tableView.scrollEnabled = NO;
    }
    
    if (isSysVerGTE(7.0)) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    self.tableView.separatorColor = UIC_BRIGHT_GRAY(0.4);
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
    
    return;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return ([self.categories count] + 1) / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIView *divider = [[UIView alloc] init];
        if (isSysVerGTE(7.0)) {
            divider.frame = CGRectMake(cell.bounds.size.width / 2, 0.0, 0.5, self.cellHeight);
        } else {
            divider.frame = CGRectMake(cell.bounds.size.width / 2, 0.0, 1.0, self.cellHeight);
        }
        divider.backgroundColor = tableView.separatorColor;
        [cell addSubview:divider];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.tag = indexPath.row * 10;
        leftButton.frame = CGRectMake(0.0, 0.0, cell.bounds.size.width / 2, self.cellHeight);
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0);
        [leftButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [leftButton setBackgroundImage:[UIImage imageWithColor:UIC_BRIGHT_GRAY(0.1)] forState:UIControlStateHighlighted];
        [leftButton setTitle:[self.categories objectAtIndex:indexPath.row * 2] forState:UIControlStateNormal];
        [leftButton setTitleColor:UIC_BRIGHT_GRAY(1.0) forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(categoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:leftButton];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.tag = indexPath.row * 10 + 1;
        rightButton.frame = CGRectMake(cell.bounds.size.width / 2, 0.0, cell.bounds.size.width / 2, self.cellHeight);
        rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        rightButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0);
        [rightButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [rightButton setBackgroundImage:[UIImage imageWithColor:UIC_BRIGHT_GRAY(0.1)] forState:UIControlStateHighlighted];
        [rightButton setTitle:[self.categories objectAtIndex:indexPath.row * 2 + 1] forState:UIControlStateNormal];
        [rightButton setTitleColor:UIC_BRIGHT_GRAY(1.0) forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(categoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:rightButton];
    }
    
    if (indexPath.row % 2) {
        cell.backgroundColor = UIC_WHISPER(1.0);
    } else {
        cell.backgroundColor = UIC_ALMOSTWHITE(1.0);
    }
    
    return cell;
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

#pragma mark - Event handler

- (void)categoryButtonTapped:(UIButton *)sender
{
    NSLog(@"%@", sender.titleLabel.text);
}

@end
