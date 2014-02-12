//
//  BookGridViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-12.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "BookGridViewController.h"

@interface BookGridViewController ()

@property (nonatomic, assign) float headerHeight;

@end

@implementation BookGridViewController

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

    self.headerHeight = 40.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.headerHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    return;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.view.frame.size.width - 20, self.headerHeight)];
    headerLabel.text = [[self.books objectAtIndex:section] objectForKey:@"Category"];
    headerLabel.textColor = UIC_BRIGHT_GRAY(1.0);
    headerLabel.backgroundColor= [UIColor clearColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    [headerView addSubview:headerLabel];
    headerView.backgroundColor = [UIColor colorWithRed:0.843 green:0.835 blue:0.722 alpha:1.0];
    
    return headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.books == nil) {
        return 0;
    }
    return [self.books count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.books == nil) {
        return 0;
    }
    return [[[self.books objectAtIndex:section] objectForKey:@"Books"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    BookInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *bookInfo = [[[self.books objectAtIndex:indexPath.section] objectForKey:@"Books"] objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[BookInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.bookInfoView.style = BookInfoViewStyleMedium;
        cell.bookInfoView.colorStyle = BookInfoViewColorStyleDefault;
    }
    
    Book *book = [Book bookFromDictionary:bookInfo];
    [cell.bookInfoView setBook:book];
    
    if (book.summary) {
        cell.bookInfoView.hasBookDescription = YES;
    }
    if (book.simpleComment) {
        cell.bookInfoView.hasBookComment = YES;
    }
    
    UIView *cellBackground = [[UIView alloc] initWithFrame:cell.bounds];
    cellBackground.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    cell.selectedBackgroundView = cellBackground;
    
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        cell.contentView.backgroundColor = cell.backgroundColor;
    }
    
    cell.indexPath = indexPath;
    
    [cell addSubview:cell.bookInfoView];
    
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

@end