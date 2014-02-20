//
//  BookDetailViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-20.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "BookDetailViewController.h"
#import "AMRatingControl.h"
#import "SPLabel.h"

@interface BookDetailViewController ()

@property (nonatomic, strong) NSArray *relatedInfoSectionItems;
@property (nonatomic, strong) NSDictionary *bookInfo;

@property (nonatomic, assign) float generalMargin;
@property (nonatomic, assign) float generalCellHeight;

#pragma mark - Section 0
@property (nonatomic, strong) UILabel *bookTitleLabel;
@property (nonatomic, strong) AMRatingControl *ratingStar;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *ratingSumLabel;
@property (nonatomic, strong) UILabel *authorTitleLabel;
@property (nonatomic, strong) SPLabel *authorLabel;
@property (nonatomic, strong) UILabel *statusTitleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *wordCountTitleLabel;
@property (nonatomic, strong) UILabel *wordCountLabel;
@property (nonatomic, strong) UILabel *categoryTitleLabel;
@property (nonatomic, strong) SPLabel *categoryLabel;
@property (nonatomic, strong) UILabel *lastUpdateTitleLabel;
@property (nonatomic, strong) UILabel *lastUpdateLabel;
@property (nonatomic, strong) UIView *section0Divider;
@property (nonatomic, strong) UILabel *summaryLabel;


@end

@implementation BookDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.relatedInfoSectionItems = @[@"本书作者还写过", @"喜欢这本书的人还喜欢", @"收录这本书的书单"];
        self.bookId = @"";
        self.generalMargin = 10.0;
        self.generalCellHeight = 50.0;
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
    
    if (IsSysVerGTE(7.0)) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)setBookId:(NSString *)bookId
{
    if (![_bookId isEqualToString:bookId]) {
        _bookId = bookId;
        
        if (bookId.length > 0) {
            [self getBookDetail];
        }
    }
}

- (void)setBookInfo:(NSDictionary *)bookInfo
{
    if (![_bookInfo isEqualToDictionary:bookInfo]) {
        _bookInfo = bookInfo;
        
        [self updateBookInfo];
    }
}

- (void)getBookDetail
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidGetBookDetail:) name:MSG_DID_GET_BOOK_DETAIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleErrorGetBookDetail:) name:MSG_FAIL_GET_BOOK_DETAIL object:nil];
    
    [[NetworkClient sharedNetworkClient] getBookDetail:self.bookId];
}

#pragma mark - UI related

-(void)updateBookInfo
{
    [self updateBookBasicInfoData];
    
    [self.tableView reloadData];
}

- (void)initBookBasicInfoLabels
{
    if (!self.bookTitleLabel)
    {
        self.bookTitleLabel = [[UILabel alloc] init];
        self.bookTitleLabel.font = LARGE_BOLD_FONT;
    }

    if (!self.ratingStar)
    {
        self.ratingStar = [[AMRatingControl alloc] initWithLocation:CGPointZero
                                                         emptyImage:[UIImage imageNamed:@"Star_Gray_Small"]
                                                         solidImage:[UIImage imageNamed:@"Star_Red_Small"]
                                                       andMaxRating:5];
        self.ratingStar.starWidthAndHeight = StarSize(@"Star_Red_Small");
        self.ratingStar.starSpacing = 1.0;
    }

    if (!self.scoreLabel)
    {
        self.scoreLabel = [[UILabel alloc] init];
        self.scoreLabel.font = MEDIUM_FONT;
    }

    if (!self.ratingSumLabel)
    {
        self.ratingSumLabel = [[UILabel alloc] init];
        self.ratingSumLabel.font = MEDIUM_FONT;
    }

    if (!self.authorTitleLabel)
    {
        self.authorTitleLabel = [[UILabel alloc] init];
        self.authorTitleLabel.font = MEDIUM_FONT;
    }

    if (!self.authorLabel)
    {
        self.authorLabel = [[SPLabel alloc] init];
        self.authorLabel.font = MEDIUM_FONT;
    }

    if (!self.statusTitleLabel)
    {
        self.statusTitleLabel = [[UILabel alloc] init];
        self.statusTitleLabel.font = MEDIUM_FONT;
    }

    if (!self.statusLabel)
    {
        self.statusLabel = [[UILabel alloc] init];
        self.statusLabel.font = MEDIUM_FONT;
    }

    if (!self.wordCountTitleLabel)
    {
        self.wordCountTitleLabel = [[UILabel alloc] init];
        self.wordCountTitleLabel.font = MEDIUM_FONT;
    }

    if (!self.wordCountLabel)
    {
        self.wordCountLabel = [[UILabel alloc] init];
        self.wordCountLabel.font = MEDIUM_FONT;
    }

    if (!self.categoryTitleLabel)
    {
        self.categoryTitleLabel = [[UILabel alloc] init];
        self.categoryTitleLabel.font = MEDIUM_FONT;
    }

    if (!self.categoryLabel)
    {
        self.categoryLabel = [[SPLabel alloc] init];
        self.categoryLabel.font = MEDIUM_FONT;
    }

    if (!self.lastUpdateTitleLabel)
    {
        self.lastUpdateTitleLabel = [[UILabel alloc] init];
        self.lastUpdateTitleLabel.font = MEDIUM_FONT;
    }

    if (!self.lastUpdateLabel)
    {
        self.lastUpdateLabel = [[UILabel alloc] init];
        self.lastUpdateLabel.font = MEDIUM_FONT;
    }

    if (!self.section0Divider)
    {
        self.section0Divider = [[UIView alloc] init];
    }

    if (!self.summaryLabel)
    {
        self.summaryLabel = [[UILabel alloc] init];
        self.summaryLabel.font = MEDIUM_FONT;
    }
}

- (void)updateBookBasicInfoLayout
{
    float segmentMargin = self.generalMargin * 1.5;
    
    // First Segment
    self.bookTitleLabel.frame = CGRectMake(self.generalMargin, segmentMargin, self.view.frame.size.width - 20.0, 20.0);
    
    // Second Segment
    self.ratingStar.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                       self.bookTitleLabel.frame.origin.y + self.bookTitleLabel.frame.size.height + segmentMargin,
                                       5 * StarSize(@"Star_Red_Small") + 4,
                                       StarSize(@"Star_Red_Small"));
    
    self.scoreLabel.frame = CGRectMake(self.ratingStar.frame.origin.x + self.ratingStar.frame.size.width + self.generalMargin,
                                       self.ratingStar.frame.origin.y - ABS(StarSize(@"Star_Red_Small") - TextHeightWithFont(MEDIUM_FONT)) / 2,
                                       50.0,
                                       TextHeightWithFont(self.scoreLabel.font));
    
    self.ratingSumLabel.frame = CGRectMake(self.scoreLabel.frame.origin.x + self.scoreLabel.frame.size.width + self.generalMargin,
                                       self.scoreLabel.frame.origin.y,
                                       self.view.frame.size.width - self.ratingStar.frame.size.width - self.scoreLabel.frame.size.width - self.generalMargin * 3,
                                       TextHeightWithFont(self.ratingSumLabel.font));
    
    // Third Segment
    self.authorTitleLabel.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                             self.ratingStar.frame.origin.y + self.ratingStar.frame.size.height + segmentMargin,
                                             50.0,
                                             TextHeightWithFont(self.authorTitleLabel.font));
    
    self.authorLabel.frame = CGRectMake(self.authorTitleLabel.frame.size.width + self.authorTitleLabel.frame.origin.x,
                                        self.authorTitleLabel.frame.origin.y,
                                        self.view.frame.size.width - self.authorTitleLabel.frame.origin.x - self.generalMargin * 2,
                                        TextHeightWithFont(self.authorLabel.font));
    self.authorLabel.textColor = UIC_CERULEAN(1.0);
    self.authorLabel.highlightedTextColor = UIC_CYAN(1.0);
    
    self.statusTitleLabel.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                             self.authorTitleLabel.frame.origin.y + self.authorTitleLabel.frame.size.height + self.generalMargin,
                                             50.0,
                                             TextHeightWithFont(self.statusTitleLabel.font));
    
    self.statusLabel.frame = CGRectMake(self.statusTitleLabel.frame.origin.x + self.statusTitleLabel.frame.size.width,
                                        self.statusTitleLabel.frame.origin.y,
                                        self.view.frame.size.width - self.statusTitleLabel.frame.size.width - self.generalMargin * 2,
                                        TextHeightWithFont(self.statusLabel.font));
    
    self.wordCountTitleLabel.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                                self.statusTitleLabel.frame.origin.y + self.statusTitleLabel.frame.size.height + self.generalMargin,
                                                50.0,
                                                TextHeightWithFont(self.wordCountTitleLabel.font));
    
    self.wordCountLabel.frame = CGRectMake(self.wordCountTitleLabel.frame.origin.x + self.wordCountTitleLabel.frame.size.width,
                                           self.wordCountTitleLabel.frame.origin.y,
                                           self.view.frame.size.width - self.wordCountTitleLabel.frame.size.width - self.generalMargin * 2,
                                           TextHeightWithFont(self.wordCountLabel.font));
    
    self.categoryTitleLabel.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                               self.wordCountTitleLabel.frame.origin.y + self.wordCountTitleLabel.frame.size.height + self.generalMargin,
                                               50.0,
                                               TextHeightWithFont(self.categoryTitleLabel.font));
    
    self.categoryLabel.frame = CGRectMake(self.categoryTitleLabel.frame.origin.x + self.categoryTitleLabel.frame.size.width,
                                          self.categoryTitleLabel.frame.origin.y,
                                          self.view.frame.size.width - self.categoryTitleLabel.frame.size.width - self.generalMargin * 2,
                                          TextHeightWithFont(self.categoryLabel.font));
    self.categoryLabel.textColor = UIC_CERULEAN(1.0);
    self.categoryLabel.highlightedTextColor = UIC_CYAN(1.0);
    
    self.lastUpdateTitleLabel.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                               self.categoryTitleLabel.frame.origin.y + self.categoryTitleLabel.frame.size.height + self.generalMargin,
                                               115.0,
                                               TextHeightWithFont(self.lastUpdateTitleLabel.font));
    
    self.lastUpdateLabel.frame = CGRectMake(self.lastUpdateTitleLabel.frame.origin.x + self.lastUpdateTitleLabel.frame.size.width,
                                          self.lastUpdateTitleLabel.frame.origin.y,
                                          self.view.frame.size.width - self.lastUpdateTitleLabel.frame.size.width - self.generalMargin * 2,
                                          TextHeightWithFont(self.lastUpdateLabel.font));
    
    // Fourth Segment
    self.section0Divider.frame = CGRectMake(0.0,
                                            self.lastUpdateTitleLabel.frame.origin.y + self.lastUpdateTitleLabel.frame.size.height + segmentMargin,
                                            self.view.frame.size.width,
                                            IsSysVerGTE(7.0) ? 0.5 : 1.0);
    self.section0Divider.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Dot"]];
    self.section0Divider.alpha = 0.5;
    
    // Fifth Segment
    self.summaryLabel.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                         self.section0Divider.frame.origin.y + self.section0Divider.frame.size.height + segmentMargin,
                                         self.view.frame.size.width - self.bookTitleLabel.frame.origin.x * 2,
                                         TextHeightWithFont(self.summaryLabel.font) * 7);
    self.summaryLabel.numberOfLines = 7;
}

#pragma mark - Data related

- (void)updateBookBasicInfoData
{
    self.bookTitleLabel.text = [self.bookInfo objectForKey:@"Title"];
    [self.ratingStar setRating:[[self.bookInfo objectForKey:@"Score"] integerValue] / 2];
    self.scoreLabel.text = [NSString stringWithFormat:@"%@ 分", [self.bookInfo objectForKey:@"Score"]];
    self.ratingSumLabel.text = [NSString stringWithFormat:@"（%@ 人评分）", [self.bookInfo objectForKey:@"ScoreSum"]];
    self.authorTitleLabel.text = @"作者：";
    self.authorLabel.text = [self.bookInfo objectForKey:@"Author"];
    self.statusTitleLabel.text = @"状态：";
    self.statusLabel.text = [self.bookInfo objectForKey:@"Status"];
    self.wordCountTitleLabel.text = @"字数：";
    self.wordCountLabel.text = [self.bookInfo objectForKey:@"WordCount"];
    self.categoryTitleLabel.text = @"类型：";
    self.categoryLabel.text = [self.bookInfo objectForKey:@"Category"];
    self.lastUpdateTitleLabel.text = @"最近更新时间：";
    self.lastUpdateLabel.text = [self.bookInfo objectForKey:@"LastUpdateDate"];
    self.summaryLabel.text = [self.bookInfo objectForKey:@"Summary"];
}

#pragma mark - Event handler

- (void)handleDidGetBookDetail:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_BOOK_DETAIL object:nil];
    
    self.bookInfo = [[notification userInfo] objectForKey:@"data"];
}

- (void)handleErrorGetBookDetail:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_BOOK_DETAIL object:nil];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return self.summaryLabel.frame.size.height + self.summaryLabel.frame.origin.y + self.generalMargin * 2;
            break;
        case 2:
            return 50.0;
            break;
        default:
            break;
    }
    return 50.0;
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
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 1:
            return 0;
            break;
        case 2:
            return 3;
            break;
        default:
            return 1;
            break;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [self initBookBasicInfoLabels];
            [self updateBookBasicInfoLayout];
            [self updateBookBasicInfoData];
            
            // Add label to cell
            [cell addSubview:self.bookTitleLabel];
            [cell addSubview:self.ratingStar];
            [cell addSubview:self.scoreLabel];
            [cell addSubview:self.ratingSumLabel];
            [cell addSubview:self.authorTitleLabel];
            [cell addSubview:self.authorLabel];
            [cell addSubview:self.statusTitleLabel];
            [cell addSubview:self.statusLabel];
            [cell addSubview:self.wordCountTitleLabel];
            [cell addSubview:self.wordCountLabel];
            [cell addSubview:self.categoryTitleLabel];
            [cell addSubview:self.categoryLabel];
            [cell addSubview:self.lastUpdateTitleLabel];
            [cell addSubview:self.lastUpdateLabel];
            [cell addSubview:self.section0Divider];
            [cell addSubview:self.summaryLabel];
        }
            break;
        case 2:
        {
            cell.textLabel.text = [self.relatedInfoSectionItems objectAtIndex:indexPath.row];
            cell.textLabel.font = MEDIUM_FONT;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            NSArray *numKeys = @[@"AuthorBookSum", @"SimilarBookSum", @"BooklistContainThisBookSum"];
            NSString *text = [NSString stringWithFormat:@"%d", [[self.bookInfo objectForKey:[numKeys objectAtIndex:indexPath.row]] integerValue]];
            UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                          0.0,
                                                                          self.view.frame.size.width - 40,
                                                                          self.generalCellHeight)];
            numLabel.text = [text isEqualToString:@"0"] ? @"" : text;
            numLabel.textColor = UIC_BLACK(0.3);
            numLabel.textAlignment = NSTextAlignmentRight;
            numLabel.font = SMALL_FONT;
            [cell addSubview:numLabel];
        }
            break;
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
