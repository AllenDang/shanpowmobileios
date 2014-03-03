//
//  BooklistGridViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-18.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "BooklistGridViewController.h"
#import "BooklistCell.h"

@interface BooklistGridViewController ()

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) BooklistCell *lastSelectedCell;

@end

@implementation BooklistGridViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"书单列表";
    self.cellHeight = 80.0;
    self.showDescription = YES;
    
    if (IsSysVerGTE(7.0)) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBooklists:(NSArray *)booklists
{
    if (![booklists isEqual:_booklists]) {
        _booklists = booklists;
        
        [self.tableView reloadData];
    }
}

- (void)setMode:(BooklistGridMode)mode
{
    if (_mode != mode) {
        _mode = mode;
        
        [self.tableView reloadData];
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *booklistId = [[self.booklists objectAtIndex:indexPath.row] objectForKey:@"Id"];
    NSString *booklistTitle = [[self.booklists objectAtIndex:indexPath.row] objectForKey:@"Title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_SELECT_BOOKLIST object:self userInfo:@{@"booklistId": booklistId,
                                                                                                              @"booklistTitle": booklistTitle}];
    
    BooklistCell *currentCell = (BooklistCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.mode == BGM_SelectionMode) {
        if (self.lastSelectedCell) {
            self.lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        currentCell.tintColor = UIC_CERULEAN(1.0);
    }
    
    self.lastSelectedCell = currentCell;
    
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
    return (id)self.booklists != (id)[NSNull null] ? [self.booklists count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    BooklistCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[BooklistCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *desc = [[self.booklists objectAtIndex:indexPath.row] objectForKey:@"Description"];
    cell.title = [[self.booklists objectAtIndex:indexPath.row] objectForKey:@"Title"];
    cell.subTitle = [desc length] <= 0 ? @"（没有描述）" : desc;
    cell.showDescription = self.showDescription;
    
    switch (self.mode) {
        case BGM_DisplayMode:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case BGM_SelectionMode:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        default:
            break;
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

@end
