//
//  ReadRecordViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-4.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "ReadRecordViewController.h"
#import "ReadRecordCell.h"
#import "NetworkClient.h"
#import "BookDetailViewController.h"

@interface ReadRecordViewController ()

@property (nonatomic, strong) NSMutableDictionary *books;
@property (nonatomic, strong) NSArray *originalBooks;
@property (nonatomic, strong) NSArray *currentKeys;
@property (nonatomic, assign) CGFloat recordHeight;
@property (nonatomic, assign) NSInteger currentShownStatus;
@property (nonatomic, assign) NSInteger currentPageNum;
@property (nonatomic, assign) NSInteger numPerPage;

@end

@implementation ReadRecordViewController

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
    self.title = @"读书记录和书评";
    self.view.backgroundColor = UIC_ALMOSTWHITE(1.0);
    self.recordHeight = GENERAL_CELL_HEIGHT * 3;
    self.numPerPage = 20;
    
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    self.currentShownStatus = 3;
    
    [self getBooksWithRange:NSMakeRange(1, self.numPerPage)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetReadRecords:) name:MSG_DID_GET_READ_RECORD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetReadRecords:) name:MSG_FAIL_GET_READ_RECORD object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

#pragma mark -
- (void)getBooksWithRange:(NSRange)range
{
    [[NetworkClient sharedNetworkClient] getReadRecordsByUserName:self.username markType:self.currentShownStatus range:range];
}

- (void)setAvatarUrl:(NSString *)avatarUrl
{
    if (![avatarUrl isEqualToString:_avatarUrl]) {
        _avatarUrl = avatarUrl;
    }
}

#pragma mark - Event handler
- (void)didChangeStatus:(UISegmentedControl *)sender
{
    self.currentShownStatus = sender.selectedSegmentIndex;
    
    self.books = nil;
    self.originalBooks = nil;
    [self.tableView reloadData];
    
    [self getBooksWithRange:NSMakeRange(1, self.numPerPage)];
}

- (void)didGetReadRecords:(NSNotification *)notification
{
    NSArray *data = [[notification userInfo] objectForKey:@"data"];

    if ((id)data != (id)[NSNull null]) {
        self.originalBooks = self.originalBooks ? [self.originalBooks arrayByAddingObjectsFromArray:data] : data;
        
        self.books = arrangeBooksByTime(self.originalBooks, TAMonth);
        self.currentKeys = [[NSMutableArray arrayWithArray:[self.books allKeys]] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSComparisonResult result = NSOrderedSame;
            
            NSArray *obj1Array = [(NSString *)obj1 componentsSeparatedByString:@"-"];
            NSArray *obj2Array = [(NSString *)obj2 componentsSeparatedByString:@"-"];
            
            if ([[obj1Array objectAtIndex:0] integerValue] > [[obj2Array objectAtIndex:0] integerValue]) {
                result = NSOrderedAscending;
            } else if ([[obj1Array objectAtIndex:0] integerValue] < [[obj2Array objectAtIndex:0] integerValue]) {
                result = NSOrderedDescending;
            } else {
                if ([[obj1Array objectAtIndex:1] integerValue] > [[obj2Array objectAtIndex:1] integerValue]) {
                    result = NSOrderedAscending;
                } else {
                    result = NSOrderedDescending;
                }
            }
            
            return result == NSOrderedDescending;
        }];
        
        [self.tableView reloadData];
        
        self.currentPageNum++;
    }
}

- (void)failGetReadRecords:(NSNotification *)notification
{
    
}

#pragma mark - Filter data source
- (void)filterDataWithReadStatus:(BOOL)showAll channel:(FilterChannel)channel categoryToShow:(NSString *)category scoreToShow:(NSInteger)score
{
    
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return GENERAL_CELL_HEIGHT;
    }
    
    return self.recordHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (isLastCell(tableView, indexPath)) {
        [self getBooksWithRange:NSMakeRange(self.currentPageNum + 1, self.numPerPage)];
    }
    
    NSString *sectionTitle = [self.currentKeys objectAtIndex:indexPath.section - 1];
    NSArray *books = [self.books objectForKey:sectionTitle];
    NSString *bookId = [[books objectAtIndex:indexPath.row] objectForKey:@"BookId"];
    
    BookDetailViewController *bookDetailController = [[BookDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    bookDetailController.bookId = bookId;
    [self pushViewController:bookDetailController];
    
    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    
    return GENERAL_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.view.frame.size.width - 20, GENERAL_HEADER_HEIGHT)];
    headerLabel.text = [self.currentKeys objectAtIndex:section - 1];
    headerLabel.textColor = UIC_BRIGHT_GRAY(1.0);
    headerLabel.font = MEDIUM_BOLD_FONT;
    headerLabel.backgroundColor= [UIColor clearColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, GENERAL_HEADER_HEIGHT)];
    [headerView addSubview:headerLabel];
    headerView.backgroundColor = UIC_WHISPER(1.0);
    
    return headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.currentKeys ? [self.currentKeys count] + 1 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section >= 1) {
        if (self.originalBooks) {
            NSString *currentKey = [self.currentKeys objectAtIndex:section - 1];
            NSArray *books = [self.books objectForKey:currentKey];
            
            if ([self.originalBooks count] % 20 == 0 && section == [self numberOfSectionsInTableView:tableView] - 1) {
                return [books count] + 1;
            } else {
                return [books count];
            }
        } else {
            return 0;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            static NSString *CellIdentifier0 = @"Cell0";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier0];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UISegmentedControl *readStatusSwitch = [[UISegmentedControl alloc] initWithItems:@[@"想读", @"在读", @"弃读", @"读过"]];
                readStatusSwitch.frame = CGRectMake(10.0, 7.0, self.view.bounds.size.width - 20, GENERAL_CELL_HEIGHT - 15);
                readStatusSwitch.tintColor = UIC_CERULEAN(1.0);
                NSDictionary *attributes = [NSDictionary dictionaryWithObject:MEDIUM_FONT
                                                                       forKey:NSFontAttributeName];
                [readStatusSwitch setTitleTextAttributes:attributes
                                                forState:UIControlStateNormal];
                readStatusSwitch.selectedSegmentIndex = 3;
                [readStatusSwitch addTarget:self action:@selector(didChangeStatus:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:readStatusSwitch];
            }
            
            return cell;
            break;
        }
        default:
            if (isLastCell(tableView, indexPath) && ([self.originalBooks count] % 20 == 0)) {
                static NSString *CellIdentifier2 = @"Cell2";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
                }
                
                cell.textLabel.text = @"点击加载更多";
                cell.textLabel.font = MEDIUM_FONT;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, GENERAL_CELL_HEIGHT);
                
                return cell;
            } else {
                static NSString *CellIdentifier1 = @"Cell1";
                ReadRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
                
                if (cell == nil) {
                    cell = [[ReadRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
                }
                
                NSString *currentKey = [self.currentKeys objectAtIndex:indexPath.section - 1];
                NSArray *books = [self.books objectForKey:currentKey];
                
                if (!isLastCell(tableView, indexPath)) {
                    cell.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.recordHeight);
                    cell.book = [books objectAtIndex:indexPath.row];
                    cell.avatarUrl = self.avatarUrl;
                }
                
                return cell;
            }
            break;
    }
    
    return nil;
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
