//
//  UserListViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-18.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "UserListViewController.h"

@interface UserListViewController ()

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat avatarSize;

@end

@implementation UserListViewController

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
    self.title = @"用户";
    self.isSimple = YES;
    self.avatarSize = 40.0;
    self.cellHeight = 60.0;
    
    if (IsSysVerGTE(7.0)) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUsers:(NSArray *)users
{
    if (![users isEqual:_users]) {
        _users = users;
        
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
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImageView *avatarImageView = nil;
    NSDictionary *user = [self.users objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(self.isSimple ? UITableViewCellStyleDefault : UITableViewCellStyleSubtitle) reuseIdentifier:CellIdentifier];
        
        avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, (self.cellHeight - self.avatarSize) / 2, self.avatarSize, self.avatarSize)];
        [cell addSubview:avatarImageView];
        
        if (self.isSimple) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0 + self.avatarSize, 0.0, cell.frame.size.width - 20, self.cellHeight)];
            titleLabel.text = [user objectForKey:@"Nickname"];
            titleLabel.font = LARGE_FONT;
            [cell addSubview:titleLabel];
        }
        // TODO: Add subtitle label
    }
    
    __block UIImageView *imageViewForBlock = avatarImageView;
    __block UserListViewController *me = self;
    [avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[user objectForKey:@"AvatarUrl"]]]
                          placeholderImage:[[[UIImage imageNamed:@"DefaultUser50"] scaledToSize:CGSizeMake(self.avatarSize * 2, self.avatarSize * 2)] imageByApplyingAlpha:0.3]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       UIImage *scaledImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(me.avatarSize * 2, me.avatarSize * 2)];
                                       UIImage *avatarImage = [scaledImage makeRoundedImageWithRadius:me.avatarSize];
                                       imageViewForBlock.image = avatarImage;
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       
                                   }];
    
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
