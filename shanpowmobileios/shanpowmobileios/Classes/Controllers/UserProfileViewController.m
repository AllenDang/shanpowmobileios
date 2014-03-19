//
//  UserProfileViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-13.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "UserProfileViewController.h"
#import "BooklistListViewController.h"
#import "ReadRecordRootViewController.h"
#import "UserListViewController.h"
#import "SPLoadingView.h"
#import "UserFavBooksViewController.h"

@interface UserProfileViewController ()

@property (nonatomic, strong) UIImageView *userAvatar;
@property (nonatomic, strong) UIImageView *userAvatarBlurBackground;
@property (nonatomic, strong) UITableView *userMenu;
@property (nonatomic, strong) UIButton *followingButton;
@property (nonatomic, strong) UIButton *followedButton;
@property (nonatomic, strong) UIButton *followActionButton;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *readCountLabel;
@property (nonatomic, strong) UILabel *reviewCountLabel;
@property (nonatomic, strong) UILabel *likedAuthorTitleLabel;
@property (nonatomic, strong) UILabel *likedCategoriesTitleLabel;
@property (nonatomic, strong) UILabel *likedAuthorLabel;
@property (nonatomic, strong) UILabel *likedCategoriesLabel;
@property (nonatomic, strong) SPLabel *followingLabel;
@property (nonatomic, strong) SPLabel *followedLabel;
@property (nonatomic, strong) SPLabel *followActionLabel;
@property (nonatomic, strong) UIImageView *followIcon;
@property (nonatomic, strong) UIButton *sendMessageButton;

@property (nonatomic, strong) UIBarButtonItem *logoutButton;

@property (nonatomic, strong) NSArray *userMenuItems;

@property (nonatomic, assign) BOOL followingMe;
@property (nonatomic, assign) BOOL followedByMe;

@property (nonatomic, assign) BOOL hasShown;

@property (nonatomic, assign) BOOL shouldCancelSelectUser;

@property (nonatomic, assign) float avatarSectionHeight;

@property (nonatomic, strong) NSDictionary *userBasicInfo;

- (void)updateData;
- (void)updateUI;

@end

@implementation UserProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUsername:(NSString *)username
{
    self = [super init];
    if (self) {
        self.username = username;
        
        if (isLogin()) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CURRENT_USER] == username) {
                self.isSelf = YES;
            } else {
                self.isSelf = NO;
            }
        } else {
            self.isSelf = NO;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = @"用户信息";
    self.shouldCancelSelectUser = NO;
    
    self.tableView.separatorColor = UIC_BRIGHT_GRAY(0.4);
    if (IsSysVerGTE(7.0)) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    self.userMenuItems = @[@"喜欢的书", @"读书记录和书评", @"创建的书单", @"收藏的书单"];
    self.avatarSectionHeight = 300.0;
    
    self.userAvatarBlurBackground = [[UIImageView alloc] init];
    
    self.userAvatar = [[UIImageView alloc] init];
    [self.userAvatarBlurBackground addSubview:self.userAvatar];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.userAvatarBlurBackground addSubview:self.usernameLabel];
    
    self.readCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.userAvatarBlurBackground addSubview:self.readCountLabel];
    
    self.reviewCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.userAvatarBlurBackground addSubview:self.reviewCountLabel];
    
    self.likedAuthorTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.userAvatarBlurBackground addSubview:self.likedAuthorTitleLabel];
    
    self.likedAuthorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.userAvatarBlurBackground addSubview:self.likedAuthorLabel];
    
    self.likedCategoriesTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.userAvatarBlurBackground addSubview:self.likedCategoriesTitleLabel];
    
    self.likedCategoriesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.userAvatarBlurBackground addSubview:self.likedCategoriesLabel];
    
    
    self.followActionLabel = [[SPLabel alloc] initWithFrame:CGRectZero];
    [self.userAvatarBlurBackground addSubview:self.followActionLabel];
    
    self.followingLabel = [[SPLabel alloc] initWithFrame:CGRectZero];
    [self.userAvatarBlurBackground addSubview:self.followingLabel];
    
    self.followedLabel = [[SPLabel alloc] initWithFrame:CGRectZero];
    [self.userAvatarBlurBackground addSubview:self.followedLabel];
    
    self.followActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.followActionButton addTarget:self action:@selector(followActionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.followedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.followedButton addTarget:self action:@selector(followedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.followingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.followingButton addTarget:self action:@selector(followingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.followIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.followActionLabel addSubview:self.followIcon];
    
    self.sendMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self updateData];
    
    self.logoutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Logout"] style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.shouldCancelSelectUser = YES;
    
    if (isLogin()) {
        self.navigationItem.rightBarButtonItem = self.logoutButton;
    }
    
    if (!self.hasShown) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBasicUserInfo:) name:MSG_DID_GET_BASIC_USER_INFO object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailGetInfo:) name:MSG_FAIL_GET_BASIC_USER_INFO object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFollowUser:) name:MSG_DID_FOLLOW_USER object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failFollowUser:) name:MSG_FAIL_FOLLOW_USER object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUnfollowUser:) name:MSG_DID_UNFOLLOW_USER object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failUnfollowUser:) name:MSG_FAIL_UNFOLLOW_USER object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetUserList:) name:MSG_DID_GET_USERLIST object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetUserList:) name:MSG_FAIL_GET_USERLIST object:nil];
        
        [self getUserBasicInfo];
        
        self.hasShown = YES;
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.hasShown = NO;
    
    [super viewWillDisappear:animated];
}

- (void)setIsSelf:(BOOL)isSelf
{
    if (isSelf != _isSelf) {
        _isSelf = isSelf;
        
        if (isSelf) {
            if (isLogin()) {
                self.username = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CURRENT_USER];
            }
        }
        
        [self updateUI];
    }
}

- (void)setUserBasicInfo:(NSDictionary *)userBasicInfo
{
    if (![userBasicInfo isEqualToDictionary:_userBasicInfo]) {
        _userBasicInfo = userBasicInfo;
        
        self.followedByMe = [[userBasicInfo objectForKey:@"IsFollowedByMe"] boolValue];
        
        [self updateData];
        [self updateUI];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)getUserBasicInfo
{
    [[NetworkClient sharedNetworkClient] getBasicUserInfo:self.username];
}

- (void)logout:(UIBarButtonItem *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登出" message:@"确定要登出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 1001;
    [alert show];
}

- (void)updateData
{
    self.usernameLabel.text = [self.userBasicInfo objectForKey:@"Nickname"];
    self.readCountLabel.text = [NSString stringWithFormat:@"%@ 本书", [self.userBasicInfo objectForKey:@"ReadBookSum"]];
    self.reviewCountLabel.text = [NSString stringWithFormat:@"%@ 篇书评", [self.userBasicInfo objectForKey:@"ReviewSum"]];
    
    self.likedAuthorTitleLabel.text = @"喜欢的作者";
    self.likedAuthorLabel.text = [[self.userBasicInfo objectForKey:@"FavAuthors"] stringByReplacingOccurrencesOfString:@"," withString:@"，"];
    // Make one line text align top
    self.likedAuthorLabel.text = [NSString stringWithFormat:@"%@ \n\n ", self.likedAuthorLabel.text];
    
    self.likedCategoriesTitleLabel.text = @"喜欢的分类";
    self.likedCategoriesLabel.text = [[self.userBasicInfo objectForKey:@"FavCategories"] stringByReplacingOccurrencesOfString:@"," withString:@"，"];
    // Make one line text align top
    self.likedCategoriesLabel.text = [NSString stringWithFormat:@"%@ \n\n ", self.likedCategoriesLabel.text];
    
    self.followingLabel.text = [NSString stringWithFormat:@"%d\n关注", [[self.userBasicInfo objectForKey:@"FollowUserSum"] intValue]];
    
    self.followedLabel.text = [NSString stringWithFormat:@"%d\n粉丝", [[self.userBasicInfo objectForKey:@"FollowedBySum"] intValue]];
}

- (void)updateUI
{
    [self updateUserAvatar];
    
    [self updateUserInfoSection];
    
    [self updateFollowStatusSection];
    
    [self updateSendMessageButton];
}

- (void)updateUserAvatar
{
    CGFloat avatarSize = 80.0;
    
    self.userAvatarBlurBackground.image = [[UIImage imageWithColor:UIC_WHISPER(1.0)] scaledToSize:self.view.bounds.size];
    
    __block UserProfileViewController *me = self;
    __block UIImageView *imageViewForBlock = self.userAvatar;
    __block UIImageView *bkgImageViewForBlock = self.userAvatarBlurBackground;
    
    NSMutableURLRequest *avatarRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self.userBasicInfo objectForKey:@"AvatarUrl"]]];
    [avatarRequest setValue:@"http://www.shanpow.com" forHTTPHeaderField:@"Referer"];
    
    [self.userAvatar setImageWithURLRequest:avatarRequest
                           placeholderImage:[[[UIImage imageNamed:@"DefaultUser50"] scaledToSize:CGSizeMake(avatarSize * 2, avatarSize * 2)] imageByApplyingAlpha:0.3]
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        UIImage *img = image;
                                        
                                        // Scale small image before blur it. This step will make avatar more awesome.
                                        if (img.size.width < me.view.bounds.size.width) {
                                            img = [UIImage imageWithImage:img scaledToSize:me.view.bounds.size];
                                        }
                                        UIImage *blurredAvatar = [img applyBlurWithRadius:15.0 tintColor:UIC_BLACK(0.4) saturationDeltaFactor:1.2 maskImage:nil];
                                        bkgImageViewForBlock.image = blurredAvatar;
                                        
                                        UIImage *scaledImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(avatarSize * 2, avatarSize * 2)];
                                        UIImage *avatarImage = [scaledImage makeRoundedImageWithRadius:avatarSize];
                                        
                                        imageViewForBlock.image = avatarImage;
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        NSLog(@"%@", error);
                                    }];
    
    self.userAvatarBlurBackground.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.avatarSectionHeight);
    self.userAvatar.frame = CGRectMake(15.0, 20.0, 80.0, 80.0);
}

- (void)updateUserInfoSection
{
    self.usernameLabel.frame = CGRectMake(110.0, 24.0, self.view.bounds.size.width - 110.0, 24.0);
    self.usernameLabel.textColor = UIC_WHITE(1.0);
    self.usernameLabel.font = XLARGE_BOLD_FONT;
    self.usernameLabel.backgroundColor = [UIColor clearColor];
    
    self.readCountLabel.frame = CGRectMake(110.0, 52.0, self.view.bounds.size.width - 110.0, 20.0);
    self.readCountLabel.textColor = UIC_WHITE(1.0);
    self.readCountLabel.font = MEDIUM_FONT;
    self.readCountLabel.backgroundColor = [UIColor clearColor];
    
    self.reviewCountLabel.frame = CGRectMake(110.0, 75.0, self.view.bounds.size.width - 110.0, 20.0);
    self.reviewCountLabel.textColor = UIC_WHITE(1.0);
    self.reviewCountLabel.font = MEDIUM_FONT;
    self.reviewCountLabel.backgroundColor = [UIColor clearColor];
    
    self.likedAuthorTitleLabel.frame = CGRectMake(15.0, 110.0, self.view.bounds.size.width, 15.0);
    self.likedAuthorTitleLabel.textColor = UIC_WHITE(1.0);
    self.likedAuthorTitleLabel.font = MEDIUM_BOLD_FONT;
    self.likedAuthorTitleLabel.backgroundColor = [UIColor clearColor];
    
    self.likedAuthorLabel.frame = CGRectMake(15.0, 128.0, self.view.bounds.size.width - 30, 40.0);
    self.likedAuthorLabel.textColor = UIC_WHITE(1.0);
    self.likedAuthorLabel.font = MEDIUM_FONT;
    self.likedAuthorLabel.backgroundColor = [UIColor clearColor];
    self.likedAuthorLabel.numberOfLines = 2;
    
    self.likedCategoriesTitleLabel.frame = CGRectMake(15.0, 178.0, self.view.bounds.size.width, 15.0);
    self.likedCategoriesTitleLabel.textColor = UIC_WHITE(1.0);
    self.likedCategoriesTitleLabel.font = MEDIUM_BOLD_FONT;
    self.likedCategoriesTitleLabel.backgroundColor = [UIColor clearColor];
    
    self.likedCategoriesLabel.frame = CGRectMake(15.0, 196.0, self.view.bounds.size.width - 30, 40.0);
    self.likedCategoriesLabel.textColor = UIC_WHITE(1.0);
    self.likedCategoriesLabel.font = MEDIUM_FONT;
    self.likedCategoriesLabel.backgroundColor = [UIColor clearColor];
    self.likedCategoriesLabel.numberOfLines = 2;
}

- (void)updateFollowStatusSection
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];
    
    if (self.isSelf) {
        self.followActionLabel.frame = CGRectMake((self.view.bounds.size.width - 1.0) / 2,
                                                  self.userAvatarBlurBackground.bounds.size.height - 60.0,
                                                  1.0,
                                                  60.0);
    } else {
        self.followActionLabel.frame = CGRectMake((self.view.bounds.size.width - 105.0) / 2,
                                                  self.userAvatarBlurBackground.bounds.size.height - 60.0,
                                                  105.0,
                                                  60.0);
    }
    if (self.followedByMe) {
        self.followActionLabel.backgroundColor = UIC_BLACK(0.4);
    } else {
        self.followActionLabel.backgroundColor = UIC_WHITE(0.6);
    }
    
    self.followActionLabel.text = @"\n关注";
    self.followActionLabel.textColor = UIC_WHITE(1.0);
    self.followActionLabel.font = MEDIUM_FONT;
    self.followActionLabel.numberOfLines = 2;
    self.followActionLabel.textAlignment = NSTextAlignmentCenter;
    [self.followActionLabel setLineHeight:5.0];
    
    if (!self.isSelf) {
        if (self.followedByMe) {
            self.followIcon.image = [UIImage imageNamed:@"CheckMark"];
        } else {
            self.followIcon.image = [UIImage imageNamed:@"Plus"];
        }
    }
    self.followIcon.frame = CGRectMake((self.followActionLabel.frame.size.width - 16.0) / 2,
                                       10.0,
                                       16.0,
                                       16.0);
    
    self.followingLabel.frame = CGRectMake(0.0,
                                           self.userAvatarBlurBackground.bounds.size.height - 60.0,
                                           (self.view.bounds.size.width - self.followActionLabel.frame.size.width) / 2,
                                           60.0);
    self.followingLabel.backgroundColor = UIC_WHITE(0.4);
    self.followingLabel.textColor = UIC_WHITE(1.0);
    self.followingLabel.font = MEDIUM_FONT;
    self.followingLabel.numberOfLines = 2;
    self.followingLabel.textAlignment = NSTextAlignmentCenter;
    [self.followingLabel setLineHeight:5.0];
    
    self.followedLabel.frame = CGRectMake(self.followingLabel.frame.size.width + self.followActionLabel.frame.size.width,
                                          self.userAvatarBlurBackground.bounds.size.height - 60.0,
                                          (self.view.bounds.size.width - self.followActionLabel.frame.size.width) / 2,
                                          60.0);
    self.followedLabel.backgroundColor = UIC_WHITE(0.4);
    self.followedLabel.textColor = UIC_WHITE(1.0);
    self.followedLabel.font = MEDIUM_FONT;
    self.followedLabel.numberOfLines = 2;
    self.followedLabel.textAlignment = NSTextAlignmentCenter;
    [self.followedLabel setLineHeight:5.0];
    
    self.followingButton.frame = self.followingLabel.frame;
    [self.followingButton setBackgroundColor:[UIColor clearColor]];
    [self.followingButton setBackgroundImage:[UIImage imageWithColor:UIC_BLACK(0.2)] forState:UIControlStateHighlighted];
    
    self.followedButton.frame = self.followedLabel.frame;
    [self.followedButton setBackgroundColor:[UIColor clearColor]];
    [self.followedButton setBackgroundImage:[UIImage imageWithColor:UIC_BLACK(0.2)] forState:UIControlStateHighlighted];
    
    if (!self.isSelf) {
        self.followActionButton.frame = self.followActionLabel.frame;
        [self.followActionButton setBackgroundColor:[UIColor clearColor]];
        [self.followActionButton setBackgroundImage:[UIImage imageWithColor:UIC_BLACK(0.2)] forState:UIControlStateHighlighted];
    }
}

- (void)updateSendMessageButton
{
    self.sendMessageButton.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 45.0);
    [self.sendMessageButton setBackgroundImage:[UIImage imageWithColor:UIC_CYAN(1.0)] forState:UIControlStateNormal];
    [self.sendMessageButton setBackgroundImage:[UIImage imageWithColor:UIC_CERULEAN(1.0)] forState:UIControlStateHighlighted];
    [self.sendMessageButton setTitle:@"发消息" forState:UIControlStateNormal];
    [self.sendMessageButton addTarget:self action:@selector(followedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -

- (void)followingButtonTapped:(UIButton *)sender
{
    [self getUserList:YES];
}

- (void)followedButtonTapped:(UIButton *)sender
{
    [self getUserList:NO];
}

- (void)followActionButtonTapped:(UIButton *)sender
{
    if (self.followedByMe) {
        [[NetworkClient sharedNetworkClient] unfollowUser:self.username];
    } else {
        [[NetworkClient sharedNetworkClient] followUser:self.username];
    }
}

- (void)getUserList:(BOOL)isFollowing
{
    if (isFollowing) {
        [[NetworkClient sharedNetworkClient] getFollowingsByUser:self.username];
    } else {
        [[NetworkClient sharedNetworkClient] getFollowersByUser:self.username];
    }
}

#pragma mark - Event handler

- (void)didGetBasicUserInfo:(NSNotification *)notification
{
    self.userBasicInfo = [[notification userInfo] objectForKey:@"data"];
    
    [self updateUI];
    [self updateData];
}

- (void)handleFailGetInfo:(NSNotification *)notification
{

    
    NSString *errorMsg = [[notification userInfo] objectForKey:@"ErrorMsg"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERR_TITLE message:errorMsg delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"重试", nil];
    [alert show];
}

- (void)didGetUserList:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_USERLIST object:nil];
    
    NSArray *users = [[notification userInfo] objectForKey:@"data"];
    
    UserListViewController *userListController = [[UserListViewController alloc] initWithStyle:UITableViewStylePlain];
    userListController.users = users;
    
    self.shouldCancelSelectUser = NO;
    [self pushViewController:userListController];
}

- (void)failGetUserList:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_USERLIST object:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERR_TITLE message:ERR_FAIL_GET_DATA delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"重试", nil];
    alert.tag = 1000;
    [alert show];
}

- (void)didFollowUser:(NSNotification *)notification
{
    [self getUserBasicInfo];
}

- (void)failFollowUser:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERR_TITLE message:ERR_FAIL_GET_DATA delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"重试", nil];
    [alert show];
}

- (void)didUnfollowUser:(NSNotification *)notification
{
    [self getUserBasicInfo];
}

- (void)failUnfollowUser:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERR_TITLE message:ERR_FAIL_GET_DATA delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"重试", nil];
    [alert show];
}

- (void)didLogout:(NSNotification *)notification
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    self.tabBarController.selectedIndex = 0;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return self.avatarSectionHeight;
    }

    if (indexPath.row == 5) {
        return 0;
    }

    return 45.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 1:
        {
            UserFavBooksViewController *userFavBooksController = [[UserFavBooksViewController alloc] init];
            userFavBooksController.username = self.username;
            self.shouldCancelSelectUser = YES;
            [self pushViewController:userFavBooksController];
            
            break;
        }
        case 2:
        {
            NSString *username = self.username;
            ReadRecordRootViewController *readRecordController = [[ReadRecordRootViewController alloc] initWithUserName:username];
            readRecordController.avatarUrl = [self.userBasicInfo objectForKey:@"AvatarUrl"];
            self.shouldCancelSelectUser = YES;
            [self pushViewController:readRecordController];
            
            break;
        }
        case 3:
        {
            BooklistListViewController *booklistsController = [[BooklistListViewController alloc] init];
            booklistsController.title = @"创建的书单";
            booklistsController.dataSource = BLDS_CreateAuthor;
            booklistsController.userId = self.isSelf ? [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CURRENT_USER_ID] : self.userId;
            self.shouldCancelSelectUser = YES;
            [self pushViewController:booklistsController];
            
            break;
        }
        case 4:
        {
            BooklistListViewController *booklistsController = [[BooklistListViewController alloc] init];
            booklistsController.title = @"收藏的书单";
            booklistsController.dataSource = BLDS_FavedBy;
            booklistsController.userId = self.isSelf ? [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CURRENT_USER_ID] : self.userId;
            self.shouldCancelSelectUser = YES;
            [self pushViewController:booklistsController];
            
            if (self.isSelf) {
                self.hidesBottomBarWhenPushed = NO;
            }
            
            break;
        }
        default:
            break;
    }
    
    return;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.userMenuItems count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if (indexPath.row == 0) {
            [cell addSubview:self.userAvatarBlurBackground];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell addSubview:self.followedButton];
            [cell addSubview:self.followingButton];
            [cell addSubview:self.followActionButton];
        } else if (indexPath.row == [tableView numberOfRowsInSection:0] - 1) {
            [cell addSubview:self.sendMessageButton];
        } else {
            cell.textLabel.text = [self.userMenuItems objectAtIndex:indexPath.row - 1];
            cell.textLabel.font = MEDIUM_FONT;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1000:
        {
            if (buttonIndex == 1) {
                [self getUserBasicInfo];
            }
            
            break;
        }
        case 1001:
        {
            if (buttonIndex == 1) {
                [[NetworkClient sharedNetworkClient] logout];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:MSG_DID_LOGOUT object:nil];
            }
            
            break;
        }
        default:
            break;
    }
}

@end
