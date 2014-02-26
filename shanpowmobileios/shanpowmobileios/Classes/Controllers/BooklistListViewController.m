//
//  BooklistListViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-26.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "BooklistListViewController.h"
#import "Common.h"
#import "BooklistGridViewController.h"
#import "NetworkClient.h"

@interface BooklistListViewController ()

@property (nonatomic, strong) BooklistGridViewController *booklistsController;

@end

@implementation BooklistListViewController

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
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.booklistsController = [[BooklistGridViewController alloc] initWithStyle:UITableViewStylePlain];
    self.booklistsController.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:self.booklistsController.view];
    
    [self getBooklists];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)getBooklists
{
    switch (self.dataSource) {
        case BLDS_CreateAuthor:
        {
            if (!self.authorId) {
                return;
            } else {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBooklists:) name:MSG_DID_GET_BLS_CREATED_BY_AUTHOR object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetBooklists:) name:MSG_FAIL_GET_BLS_CREATED_BY_AUTHOR object:nil];
                
                [[NetworkClient sharedNetworkClient] getBooklistsByAuthorId:self.authorId];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Event handler
- (void)didGetBooklists:(NSNotification *)notification
{
    NSArray *booklists = [[notification userInfo] objectForKey:@"data"];
    self.booklistsController.booklists = booklists;
}

- (void)failGetBooklists:(NSNotification *)notification
{
    
}

@end
