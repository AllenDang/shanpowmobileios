//
//  BooklistDetailViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-27.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "BooklistDetailInfoViewController.h"
#import "Common.h"
#import "BookGridViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "NetworkClient.h"
#import "BooklistDetailInfoCell.h"
#import "UserProfileViewController.h"
#import "BookGridCell.h"
#import "FilterViewController.h"
#import "BooklistListViewController.h"

@interface BooklistDetailInfoViewController ()

@property (nonatomic, assign) float generalCellHeight;
@property (nonatomic, assign) float generalMargin;
@property (nonatomic, strong) NSArray *menuItems;

@property (nonatomic, strong) NSDictionary *booklist;
@property (nonatomic, strong) NSDictionary *originalData;

@end

@implementation BooklistDetailInfoViewController

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
    self.view.backgroundColor = UIC_ALMOSTWHITE(1.0);
    self.generalCellHeight = 55.0;
    self.generalMargin = 10.0;
    self.menuItems = @[@"本书单作者的其他书单", @"相关回复"];
    
    if (IsSysVerGTE(7.0)) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nicknameTapped:) name:MSG_TAPPED_NICKNAME object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_SELECT_BOOK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBook:) name:MSG_DID_SELECT_BOOK object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)setBooklistId:(NSString *)booklistId
{
    if (![booklistId isEqualToString:_booklistId]) {
        _booklistId = booklistId;
        
        [self getBooklistDetail];
    }
}

- (void)getBooklistDetail
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBooklistDetail:) name:MSG_DID_GET_BOOKLIST_DETAIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetBooklistDetail:) name:MSG_FAIL_GET_BOOKLIST_DETAIL object:nil];
    
    [[NetworkClient sharedNetworkClient] getBooklistDetailById:self.booklistId];
}



#pragma mark - Filter data source
- (void)filterDataWithReadStatus:(BOOL)showAll channel:(FilterChannel)channel categoryToShow:(NSString *)category scoreToShow:(NSInteger)score
{
    if (showAll && [category isEqualToString:@"全部"] && score == 0) {
        self.booklist = self.originalData;
        
        [self.tableView reloadData];
        
        return;
    }
    
    NSMutableDictionary *booklist = [NSMutableDictionary dictionaryWithDictionary:self.originalData];
    NSArray *books = [booklist objectForKey:@"Books"];
    NSArray *categories = [booklist objectForKey:@"Categories"];
    
    NSMutableArray *newBooks = [NSMutableArray arrayWithCapacity:40];
    
    NSMutableArray *sushiBooks = [NSMutableArray arrayWithCapacity:40];
    
    NSMutableArray *finalBooks = [NSMutableArray arrayWithCapacity:40];
    NSMutableArray *finalCategories = [NSMutableArray arrayWithCapacity:40];
    
    // filter category
    if ([category isEqualToString:@"全部"]) {
        newBooks = [NSMutableArray arrayWithArray:books];
    } else {
        for (NSDictionary *book in books) {
            if ([[book objectForKey:@"Category"] isEqualToString:category]) {
                [newBooks addObject:book];
            }
        }
    }
    
    // filter score
    if (score != 0) {
        for (NSDictionary *newBook in newBooks) {
            if ([[newBook objectForKey:@"Score"] integerValue] == score) {
                [sushiBooks addObject:newBook];
            }
        }
    } else {
        sushiBooks = newBooks;
    }
    
    // filter read status
    if (showAll) {
        finalBooks = sushiBooks;
    } else {
        for (NSDictionary *book in sushiBooks) {
            if ([[book objectForKey:@"MarkStatus"] integerValue] != 4) {
                [finalBooks addObject:book];
            }
        }
    }
    
    // add categories
    for (NSDictionary *book in finalBooks) {
        NSString *cateName = [book objectForKey:@"Category"];
        
        for (NSDictionary *category in categories) {
            if ([[category objectForKey:@"Category"] isEqualToString:cateName]) {
                [finalCategories addObject:category];
            }
        }
    }
    
    [booklist setObject:finalBooks forKey:@"Books"];
    [booklist setObject:finalCategories forKey:@"Categories"];
    
    self.booklist = booklist;
    
    [self.tableView reloadData];
}

#pragma mark - Event handler
- (void)didGetBooklistDetail:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_BOOKLIST_DETAIL object:nil];
    
    self.booklist = [[notification userInfo] objectForKey:@"data"];
    self.originalData = [[notification userInfo] objectForKey:@"data"];
    
    [self.tableView reloadData];
}

- (void)failGetBooklistDetail:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERR_TITLE message:ERR_FAIL_GET_DATA delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"重试", nil];
    [alert show];
}

- (void)nicknameTapped:(NSNotification *)notification
{
    NSString *nickname = [[notification userInfo] objectForKey:@"Nickname"];
    
    UserProfileViewController *userProfileController = [[UserProfileViewController alloc] initWithUsername:nickname];
    
    self.mm_drawerController.hidesBottomBarWhenPushed = YES;
    [self.mm_drawerController.navigationController pushViewController:userProfileController animated:YES];
    self.mm_drawerController.hidesBottomBarWhenPushed = NO;
}

- (void)didSelectBook:(NSNotification *)notification
{
    NSString *bookId = [[notification userInfo] objectForKey:@"BookId"];
    
    BookDetailViewController *bookDetailController = [[BookDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    bookDetailController.bookId = bookId;
    
    [self pushViewController:bookDetailController];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 195;
            break;
        case 1:
            return self.generalCellHeight;
            break;
        case 2:
        {
            NSInteger bookCount = [self.booklist objectForKey:@"Books"] == [NSNull null] ? 0 : [[self.booklist objectForKey:@"Books"] count];
            NSInteger categoryCount = [self.booklist objectForKey:@"Categories"] == [NSNull null] ? 0 : [[self.booklist objectForKey:@"Categories"] count];
            
            return categoryCount * 40.0 + bookCount * 70.0;
        }
            break;
        default:
            break;
    }
    return self.generalCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        BooklistListViewController *booklistListController = [[BooklistListViewController alloc] init];
        booklistListController.title = @"其他书单";
        booklistListController.filterId = self.booklistId;
        booklistListController.dataSource = BLDS_CreateAuthor;
        booklistListController.userId = [[self.booklist objectForKey:@"Author"] objectForKey:@"Id"];
        
        [self pushViewController:booklistListController];
    }
    
    return;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            static NSString *CellIdentifier = @"Cell1";
            BooklistDetailInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[BooklistDetailInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.title = [self.booklist objectForKey:@"Title"];
            cell.avatarUrl = [[self.booklist objectForKey:@"Author"] objectForKey:@"AvatarUrl"];
            cell.nickname = [[self.booklist objectForKey:@"Author"] objectForKey:@"Nickname"];
            cell.timeStamp = [self.booklist objectForKey:@"LastUpdateTime"];
            cell.description = [self.booklist objectForKey:@"Description"];
            
            return cell;
        }
            break;
        case 1:
        {
            static NSString *CellIdentifier = @"Cell2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
            cell.textLabel.font = MEDIUM_FONT;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
            break;
        case 2:
        {
            static NSString *CellIdentifier = @"Cell3";
            BookGridCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[BookGridCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.bookController.isPlain = NO;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.bookController.books = arrangeBooksByCategories([self.booklist objectForKey:@"Books"], [self.booklist objectForKey:@"Categories"]);
            cell.bookController.tableView.scrollEnabled = NO;
            [cell.bookController.tableView reloadData];
            
            return cell;
        }
            break;
        default:
        {
            static NSString *CellIdentifier = @"Cell0";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            return cell;
        }
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

@end
