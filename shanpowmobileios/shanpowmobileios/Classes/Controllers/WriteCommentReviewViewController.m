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
@property (nonatomic, strong) UISwitch *shareToQQSwitch;
@property (nonatomic, strong) UISwitch *shareToWeiBoSwitch;
@property (nonatomic, strong) UILabel *shareToQQLabel;
@property (nonatomic, strong) UILabel *shareToWeiBoLabel;

@property (nonatomic, strong) UIView *dividerForStatusAndStar;
@property (nonatomic, strong) UIView *dividerForStarAndShare;
@property (nonatomic, strong) UIView *dividerForShareAndReview;
@property (nonatomic, strong) UIView *dividerForTitleAndContent;

@property (nonatomic, strong) UIView *accessoryViewForContent;

@property (nonatomic, strong) NSString *markType;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *reviewTitle;
@property (nonatomic, assign) BOOL shareToQQ;
@property (nonatomic, assign) BOOL shareToWeiBo;

@property (nonatomic, assign) BOOL isKeyboardForTitle;

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
    
    // Section 1 - read status
    self.readStatus = [[UISegmentedControl alloc] initWithItems:@[@"想读", @"在读", @"弃读", @"读过"]];
    [self.view addSubview:self.readStatus];
    
    self.dividerForStatusAndStar = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.dividerForStatusAndStar];
    
    // Section 2 - rating star
    self.ratingStar = [[AMRatingControl alloc] initWithLocation:CGPointZero
                                                     emptyImage:[UIImage imageNamed:@"Star_Gray"]
                                                     solidImage:[UIImage imageNamed:@"Star_Red"]
                                                   andMaxRating:5];
    [self.view addSubview:self.ratingStar];
    
    self.dividerForStarAndShare = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                           self.ratingStar.frame.origin.y + self.ratingStar.bounds.size.height + 8.0,
                                                                           self.view.bounds.size.width,
                                                                           1.0)];
    self.dividerForStarAndShare.backgroundColor = UIC_BRIGHT_GRAY(0.1);
    [self.view addSubview:self.dividerForStarAndShare];
    
    // Section 3 - share
    self.shareToQQLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                    self.dividerForStarAndShare.frame.origin.y + self.dividerForStarAndShare.frame.size.height,
                                                                    [@"分享到腾讯微博" sizeWithFont:MEDIUM_FONT].width,
                                                                    30.0)];
    [self.view addSubview:self.shareToQQLabel];
    
    self.shareToQQSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 60,
                                                                      self.shareToQQLabel.frame.origin.y + 5,
                                                                      50.0,
                                                                      30.0)];
    [self.view addSubview:self.shareToQQSwitch];
    
    self.shareToWeiBoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                    self.dividerForStarAndShare.frame.origin.y + self.dividerForStarAndShare.frame.size.height,
                                                                    [@"分享到腾讯微博" sizeWithFont:MEDIUM_FONT].width,
                                                                    30.0)];
    [self.view addSubview:self.shareToWeiBoLabel];
    
    self.shareToWeiBoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 60,
                                                                      self.shareToQQLabel.frame.origin.y + 5,
                                                                      50.0,
                                                                      30.0)];
    [self.view addSubview:self.shareToWeiBoSwitch];
    
    self.dividerForShareAndReview = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                             self.shareToQQSwitch.frame.origin.y + self.shareToQQSwitch.bounds.size.height + 8.0,
                                                                             self.view.bounds.size.width,
                                                                             1.0)];
    self.dividerForShareAndReview.backgroundColor = UIC_BRIGHT_GRAY(0.1);
    [self.view addSubview:self.dividerForShareAndReview];
    
    // Section 4 - title
    self.reviewTitleTextView = [[UITextField alloc] initWithFrame:CGRectMake(10.0,
                                                                             self.dividerForShareAndReview.frame.origin.y + self.dividerForShareAndReview.frame.size.height,
                                                                             self.view.bounds.size.width - 20,
                                                                             40.0)];
    [self.view addSubview:self.reviewTitleTextView];
    
    self.dividerForTitleAndContent = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.reviewTitleTextView.frame.origin.y + self.reviewTitleTextView.bounds.size.height, self.view.bounds.size.width, 1.0)];
    [self.view addSubview:self.dividerForTitleAndContent];
    
    // Section 5 - content
    self.reviewContentTextView = [[SPTextView alloc] initWithFrame:CGRectMake(5.0,
                                                                              self.dividerForTitleAndContent.frame.origin.y + self.dividerForTitleAndContent.frame.size.height + 5.0,
                                                                              self.view.bounds.size.width - 10,
                                                                              self.view.bounds.size.height - self.dividerForTitleAndContent.frame.origin.y - self.tabBarController.tabBar.frame.size.height - UINAVIGATIONBAR_HEIGHT - UISTATUSBAR_HEIGHT - 10)];
    [self.view addSubview:self.reviewContentTextView];
    
    self.accessoryViewForContent = [[UIView alloc] init];
    self.accessoryViewForContent.backgroundColor = UIC_WHISPER(0.8);
    self.accessoryViewForContent.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 40.0);
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.frame = CGRectMake(self.view.bounds.size.width - 80, 0.0, 70.0, 40.0);
    [dismissButton setTitle:@"完成" forState:UIControlStateNormal];
    [dismissButton setTitleColor:UIC_BRIGHT_GRAY(1.0) forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.accessoryViewForContent addSubview:dismissButton];
    
    self.markType = @"read";
    self.score = 0;
    self.content = @"";
    self.reviewTitle = @"";
    self.shareToWeiBo = YES;
    self.shareToQQ = YES;
    
    [self updateUILayout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)updateUILayout
{
    // Section 1 - read status
    self.readStatus.frame = CGRectMake(10.0, 5.0, self.view.bounds.size.width - 20.0, 35.0);
    self.readStatus.tintColor = UIC_CERULEAN(1.0);
    self.readStatus.selectedSegmentIndex = 3;
    [self.readStatus addTarget:self action:@selector(readStatusChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.dividerForStatusAndStar.frame = CGRectMake(0.0,
                                                    self.readStatus.frame.origin.y * 2 + self.readStatus.bounds.size.height,
                                                    self.view.bounds.size.width,
                                                    1.0);
    self.dividerForStatusAndStar.backgroundColor = UIC_BRIGHT_GRAY(0.1);
    
    // Section 2 - rating star
    CGFloat starSize = [UIImage imageNamed:@"Star_Red"].size.width;
    self.ratingStar.frame = CGRectMake((self.view.bounds.size.width - starSize * 5 - 8.0 * 4) / 2,
                                       self.dividerForStatusAndStar.frame.origin.y + self.dividerForStatusAndStar.frame.size.height + 8.0,
                                       starSize * 5,
                                       starSize);
    self.ratingStar.starWidthAndHeight = starSize;
    self.ratingStar.starSpacing = 8.0;
    __block WriteCommentReviewViewController *me = self;
    self.ratingStar.editingChangedBlock = ^(NSUInteger rating)
    {
        [me editingRating:rating];
    };
    
    self.ratingStar.editingDidEndBlock = ^(NSUInteger rating)
    {
        [me editedRating:rating];
    };
    
    self.dividerForStarAndShare.frame = CGRectMake(0.0,
                                                   self.ratingStar.frame.origin.y + self.ratingStar.bounds.size.height + 8.0,
                                                   self.view.bounds.size.width,
                                                   1.0);
    self.dividerForStarAndShare.backgroundColor = UIC_BRIGHT_GRAY(0.1);
    
    // Section 3 - share
    self.shareToQQLabel.frame = CGRectMake(10.0,
                                           self.dividerForStarAndShare.frame.origin.y + self.dividerForStarAndShare.frame.size.height,
                                           [@"分享到腾讯微博" sizeWithFont:MEDIUM_FONT].width,
                                           45.0);
    self.shareToQQLabel.font = MEDIUM_FONT;
    self.shareToQQLabel.backgroundColor = [UIColor clearColor];
    self.shareToQQLabel.text = @"分享到腾讯微博";
    
    self.shareToQQSwitch.frame = CGRectMake(self.view.bounds.size.width - 60,
                                            self.shareToQQLabel.frame.origin.y + 5,
                                            50.0,
                                            45.0);
    self.shareToQQSwitch.tintColor = UIC_CYAN(1.0);
    self.shareToQQSwitch.onTintColor = UIC_CYAN(1.0);
    [self.shareToQQSwitch setOn:self.shareToQQ animated:NO];
    
    self.shareToWeiBoLabel.frame = CGRectMake(10.0,
                                           self.shareToQQLabel.frame.origin.y + self.shareToQQLabel.frame.size.height,
                                           [@"分享到新浪微博" sizeWithFont:MEDIUM_FONT].width,
                                           45.0);
    self.shareToWeiBoLabel.font = MEDIUM_FONT;
    self.shareToWeiBoLabel.backgroundColor = [UIColor clearColor];
    self.shareToWeiBoLabel.text = @"分享到新浪微博";
    
    self.shareToWeiBoSwitch.frame = CGRectMake(self.view.bounds.size.width - 60,
                                            self.shareToWeiBoLabel.frame.origin.y + 5,
                                            50.0,
                                            45.0);
    self.shareToWeiBoSwitch.tintColor = UIC_CYAN(1.0);
    self.shareToWeiBoSwitch.onTintColor = UIC_CYAN(1.0);
    [self.shareToWeiBoSwitch setOn:self.shareToWeiBo animated:NO];
    
    self.dividerForShareAndReview.frame = CGRectMake(0.0,
                                                     self.shareToWeiBoSwitch.frame.origin.y + self.shareToWeiBoSwitch.bounds.size.height + 8.0,
                                                     self.view.bounds.size.width,
                                                     1.0);
    self.dividerForShareAndReview.backgroundColor = UIC_BRIGHT_GRAY(0.1);
    
    // Section 4 - title
    self.reviewTitleTextView.frame = CGRectMake(10.0,
                                                self.dividerForShareAndReview.frame.origin.y + self.dividerForShareAndReview.frame.size.height,
                                                self.view.bounds.size.width - 20,
                                                40.0);
    self.reviewTitleTextView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"标题（可选）"
                                                                                     attributes:@{NSForegroundColorAttributeName: UIC_BRIGHT_GRAY(0.3)}];
    self.reviewTitleTextView.font = MEDIUM_FONT;
    self.reviewTitleTextView.delegate = self;
    self.reviewTitleTextView.inputAccessoryView = self.accessoryViewForContent;
    
    self.dividerForTitleAndContent.frame = CGRectMake(0.0, self.reviewTitleTextView.frame.origin.y + self.reviewTitleTextView.bounds.size.height, self.view.bounds.size.width, 1.0);
    self.dividerForTitleAndContent.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Dot"]];
    self.dividerForTitleAndContent.alpha = DOTTED_LINE_ALPHA;
    
    // Section 5 - content
    self.reviewContentTextView.frame = CGRectMake(5.0,
                                                  self.dividerForTitleAndContent.frame.origin.y + self.dividerForTitleAndContent.frame.size.height + 5.0,
                                                  self.view.bounds.size.width - 10,
                                                  self.view.bounds.size.height - self.dividerForTitleAndContent.frame.origin.y - self.tabBarController.tabBar.frame.size.height - UISTATUSBAR_HEIGHT - 10);
    self.reviewContentTextView.placeholder = @"评论（可选，大于140字后标题必填）";
    self.reviewContentTextView.placeholderColor = UIC_BRIGHT_GRAY(0.3);
    self.reviewContentTextView.font = MEDIUM_FONT;
    self.reviewContentTextView.backgroundColor = [UIColor clearColor];
    self.reviewContentTextView.delegate = self;
    self.reviewContentTextView.inputAccessoryView = self.accessoryViewForContent;
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
                                      @"score": [NSNumber numberWithInteger:self.score],
                                      @"isShareToQQ": [NSNumber numberWithBool:self.shareToQQ],
                                      @"isShareToWeibo": [NSNumber numberWithBool:self.shareToWeiBo]
                                      };
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMarkBook:) name:MSG_DID_POST_REVIEW object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failMarkBook:) name:MSG_FAIL_POST_REVIEW object:nil];
            [[NetworkClient sharedNetworkClient] postReviewWithBookId:self.bookId params:options];
        }
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMarkBook:) name:MSG_DID_MARK_BOOK object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failMarkBook:) name:MSG_FAIL_MARK_BOOK object:nil];
        [[NetworkClient sharedNetworkClient] markBookWithBookId:self.bookId markType:self.markType score:self.score content:self.content isShareToQQ:self.shareToQQ isShareToWeibo:self.shareToWeiBo];
    }
}

#pragma mark - Event handler
- (void)didMarkBook:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_POST_REVIEW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_MARK_BOOK object:nil];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_POST_REVIEW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_MARK_BOOK object:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"网络出了点问题，请重试" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alert show];
}

- (void)handleKeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame = CGRectMake(self.view.frame.origin.x,
                                                      UINAVIGATIONBAR_HEIGHT + UISTATUSBAR_HEIGHT + 80 - keyboardBounds.size.height,
                                                      self.view.frame.size.width,
                                                      self.view.frame.size.height);
                         if (!self.isKeyboardForTitle) {
                             self.reviewContentTextView.frame = CGRectMake(self.reviewContentTextView.frame.origin.x,
                                                                           self.reviewContentTextView.frame.origin.y,
                                                                           self.reviewContentTextView.frame.size.width,
                                                                           self.reviewContentTextView.frame.size.height - 80);
                         }
                     }
                     completion:^(BOOL finished) {
                         [self.reviewContentTextView scrollRangeToVisible:NSMakeRange((self.reviewContentTextView.text.length > 0 ? self.reviewContentTextView.text.length : 0), 0)];
                     }];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x,
                                     UINAVIGATIONBAR_HEIGHT + UISTATUSBAR_HEIGHT,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
        self.reviewContentTextView.frame = CGRectMake(self.reviewContentTextView.frame.origin.x,
                                                      self.reviewContentTextView.frame.origin.y,
                                                      self.reviewContentTextView.frame.size.width,
                                                      self.reviewContentTextView.frame.size.height + 80);
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.isKeyboardForTitle = NO;
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [textView scrollRangeToVisible:textView.selectedRange];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.reviewTitleTextView]) {
        self.isKeyboardForTitle = YES;
    } else {
        self.isKeyboardForTitle = NO;
    }
    return YES;
}

@end
