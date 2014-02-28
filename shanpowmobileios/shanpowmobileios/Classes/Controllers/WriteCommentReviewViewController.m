//
//  WriteCommentReviewViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-14.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "WriteCommentReviewViewController.h"

@interface WriteCommentReviewViewController ()

@property (nonatomic, strong) UISegmentedControl *readStatus;
@property (nonatomic, strong) AMRatingControl *ratingStar;
@property (nonatomic, strong) UITextField *reviewTitleTextView;
@property (nonatomic, strong) SPTextView *reviewContentTextView;
@property (nonatomic, strong) UIBarButtonItem *done;

@property (nonatomic, strong) NSString *markType;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *reviewTitle;

@end

@implementation WriteCommentReviewViewController

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
    self.title = @"写书评";
    self.view.backgroundColor = UIC_ALMOSTWHITE(1.0);
    
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.done = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(doneWrite:)];
    [self.navigationItem setRightBarButtonItem:self.done];
    
    self.readStatus = [[UISegmentedControl alloc] initWithItems:@[@"想读", @"在读", @"弃读", @"读过"]];
    self.readStatus.frame = CGRectMake(10.0, 5.0, self.view.bounds.size.width - 20.0, 35.0);
    self.readStatus.tintColor = UIC_CERULEAN(1.0);
    self.readStatus.selectedSegmentIndex = 3;
    [self.view addSubview:self.readStatus];
    [self.readStatus addTarget:self action:@selector(readStatusChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIView *dividerForStatusAndStar = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                               self.readStatus.frame.origin.y * 2 + self.readStatus.bounds.size.height,
                                                                               self.view.bounds.size.width,
                                                                               1.0)];
    dividerForStatusAndStar.backgroundColor = UIC_BRIGHT_GRAY(0.1);
    [self.view addSubview:dividerForStatusAndStar];
    
    CGFloat starSize = [UIImage imageNamed:@"Star_Red"].size.width;
    self.ratingStar = [[AMRatingControl alloc] initWithLocation:CGPointMake((self.view.bounds.size.width - starSize * 5 - 8.0 * 4) / 2,
                                                                            dividerForStatusAndStar.frame.origin.y + dividerForStatusAndStar.frame.size.height + 8.0)
                                                     emptyImage:[UIImage imageNamed:@"Star_Gray"]
                                                     solidImage:[UIImage imageNamed:@"Star_Red"]
                                                   andMaxRating:5];
    self.ratingStar.starWidthAndHeight = starSize;
    self.ratingStar.starSpacing = 8.0;
    [self.view addSubview:self.ratingStar];
    __block WriteCommentReviewViewController *me = self;
    self.ratingStar.editingChangedBlock = ^(NSUInteger rating)
    {
        [me editingRating:rating];
    };
    
    self.ratingStar.editingDidEndBlock = ^(NSUInteger rating)
    {
        [me editedRating:rating];
    };
    
    UIView *dividerForStarAndReview = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                               self.ratingStar.frame.origin.y + self.ratingStar.bounds.size.height + 8.0,
                                                                               self.view.bounds.size.width,
                                                                               1.0)];
    dividerForStarAndReview.backgroundColor = UIC_BRIGHT_GRAY(0.1);
    [self.view addSubview:dividerForStarAndReview];
    
    self.reviewTitleTextView = [[UITextField alloc] initWithFrame:CGRectMake(10.0,
                                                                             dividerForStarAndReview.frame.origin.y + dividerForStarAndReview.frame.size.height,
                                                                             self.view.bounds.size.width - 20,
                                                                             40.0)];
    self.reviewTitleTextView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"标题（可选）"
                                                                                       attributes:@{NSForegroundColorAttributeName: UIC_BRIGHT_GRAY(0.3)}];
    self.reviewTitleTextView.font = MEDIUM_FONT;
    [self.view addSubview:self.reviewTitleTextView];
    
    UIView *dividerForTitleAndContent = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.reviewTitleTextView.frame.origin.y + self.reviewTitleTextView.bounds.size.height, self.view.bounds.size.width, 1.0)];
    dividerForTitleAndContent.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Dot"]];
    dividerForTitleAndContent.alpha = DOTTED_LINE_ALPHA;
    [self.view addSubview:dividerForTitleAndContent];
    
    self.reviewContentTextView = [[SPTextView alloc] initWithFrame:CGRectMake(5.0,
                                                                              dividerForTitleAndContent.frame.origin.y + dividerForTitleAndContent.frame.size.height + 5.0,
                                                                              self.view.bounds.size.width - 10,
                                                                              self.view.bounds.size.height - dividerForTitleAndContent.frame.origin.y - self.tabBarController.tabBar.frame.size.height - UINAVIGATIONBAR_HEIGHT - UISTATUSBAR_HEIGHT - 10)];
    self.reviewContentTextView.placeholder = @"评论（可选，大于140字后标题必填）";
    self.reviewContentTextView.placeholderColor = UIC_BRIGHT_GRAY(0.3);
    self.reviewContentTextView.font = MEDIUM_FONT;
    self.reviewContentTextView.backgroundColor = [UIColor clearColor];
    self.reviewContentTextView.delegate = self;
    [self.view addSubview:self.reviewContentTextView];
    
    self.markType = @"read";
    self.score = 0;
    self.content = @"";
    self.reviewTitle = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissKeyboard
{
    [self.reviewTitleTextView resignFirstResponder];
    [self.reviewContentTextView resignFirstResponder];
}

- (void)doneWrite:(UIBarButtonItem *)sender
{
    self.score = self.ratingStar.rating;
    self.content = self.reviewContentTextView.text;
    
    if (self.reviewTitleTextView.text.length > 0 || self.reviewContentTextView.text.length > 140) {
        if (self.reviewTitleTextView.text.length <= 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                            message:@"必须填写书评标题"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            NSDictionary *options = @{
                                      @"bookTitle": self.bookTitle,
                                      @"bookImageUrl": self.bookImageUrl,
                                      @"bookCategory": self.bookCategory,
                                      @"reviewTitle": self.reviewTitleTextView.text,
                                      @"reviewContent": self.reviewContentTextView.text,
                                      @"markType": self.markType,
                                      @"score": [NSNumber numberWithInteger:self.score]
                                      };
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMarkBook:) name:MSG_DID_POST_REVIEW object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failMarkBook:) name:MSG_FAIL_POST_REVIEW object:nil];
            [[NetworkClient sharedNetworkClient] postReviewWithBookId:self.bookId params:options];
        }
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMarkBook:) name:MSG_DID_MARK_BOOK object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failMarkBook:) name:MSG_FAIL_MARK_BOOK object:nil];
        [[NetworkClient sharedNetworkClient] markBookWithBookId:self.bookId markType:self.markType score:self.score content:self.content];
    }
}

#pragma mark - Event handler
- (void)didMarkBook:(NSNotification *)notification
{
    NSString *msg = @"";
    if (self.reviewTitleTextView.text.length > 0) {
        msg = @"，并成功发表书评";
    } else if (self.reviewContentTextView.text.length > 0) {
        msg = @"，并成功发表一句话评论";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"成功"
                                                    message:[NSString stringWithFormat:@"成功保存阅读状%@", msg]
                                                   delegate:self
                                          cancelButtonTitle:@"好的"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)failMarkBook:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"网络出了点问题，请重试" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alert show];
}

- (void)handleKeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.reviewContentTextView.frame = CGRectMake(self.reviewContentTextView.frame.origin.x,
                                                            self.reviewContentTextView.frame.origin.y,
                                                            self.reviewContentTextView.frame.size.width,
                                                            self.reviewContentTextView.frame.size.height - keyboardBounds.size.height + self.tabBarController.tabBar.frame.size.height);
    } completion:^(BOOL finished) {
        [self.reviewContentTextView scrollRangeToVisible:NSMakeRange((self.reviewContentTextView.text.length > 0 ? self.reviewContentTextView.text.length : 0), 0)];
    }];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.reviewContentTextView.frame = CGRectMake(self.reviewContentTextView.frame.origin.x,
                                                            self.reviewContentTextView.frame.origin.y,
                                                            self.reviewContentTextView.frame.size.width,
                                                            self.reviewContentTextView.frame.size.height + keyboardBounds.size.height - self.tabBarController.tabBar.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)editingRating:(NSUInteger)rating
{
    [self dismissKeyboard];
}

- (void)editedRating:(NSUInteger)rating
{
    [self dismissKeyboard];
}

- (void)readStatusChanged:(UISegmentedControl *)segmentedControl
{
    [self dismissKeyboard];
    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            self.markType = @"wanttoread";
            break;
        case 1:
            self.markType = @"reading";
            break;
        case 2:
            self.markType = @"giveup";
            break;
        case 3:
            self.markType = @"read";
            break;
        default:
            self.markType = @"";
            break;
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextView delegate
- (BOOL)textView:(UITextView *)tView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    CGRect textRect = [tView.layoutManager usedRectForTextContainer:tView.textContainer];
    CGFloat sizeAdjustment = tView.font.lineHeight * [UIScreen mainScreen].scale;
    
    if (textRect.size.height >= tView.frame.size.height - sizeAdjustment) {
        if ([text isEqualToString:@"\n"]) {
            [UIView animateWithDuration:0.2 animations:^{
                [tView setContentOffset:CGPointMake(tView.contentOffset.x, tView.contentOffset.y + sizeAdjustment)];
            }];
        }
    }
    
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [textView scrollRangeToVisible:textView.selectedRange];
}

@end
