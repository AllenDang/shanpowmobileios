//
//  BooklistDetailViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-28.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "BooklistDetailViewController.h"

@interface BooklistDetailViewController ()

@property (nonatomic, strong) NSString *booklistId;

@property (nonatomic, strong) BooklistDetailInfoViewController *booklistDetailController;
@property (nonatomic, strong) FilterViewController *filterController;

@end

@implementation BooklistDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithBooklistId:(NSString *)booklistId
{
    BooklistDetailInfoViewController *bdController = [[BooklistDetailInfoViewController alloc] initWithStyle:UITableViewStylePlain];
    bdController.booklistId = booklistId;
    
    FilterViewController *fController = [[FilterViewController alloc] initWithStyle:UITableViewStylePlain];
    
    self = [super initWithCenterViewController:bdController rightDrawerViewController:fController];
    if (self) {
        self.booklistId = booklistId;
        
        self.booklistDetailController = bdController;
        self.filterController = fController;
        self.filterController.dataSource = self.booklistDetailController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"书单详情";
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Filter"] style:UIBarButtonItemStylePlain target:self action:@selector(openFilter:)];
    [self.navigationItem setRightBarButtonItem:filterButton];
    
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
    
    [self setMaximumRightDrawerWidth:300.0];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event handler
- (void)openFilter:(UIBarButtonItem *)sender
{
    if ([self openSide] == MMDrawerSideRight) {
        self.title = @"书单详情";
        self.navigationItem.hidesBackButton = NO;
        [self closeDrawerAnimated:YES completion:^(BOOL finished) {
            
        }];
    } else {
        self.title = @"过滤";
        self.navigationItem.hidesBackButton = YES;
        [self openDrawerSide:MMDrawerSideRight animated:YES completion:^(BOOL finished) {
            
        }];
    }
}

@end
