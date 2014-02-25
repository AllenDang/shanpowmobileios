//
//  BookInfoView.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-19.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "BookInfoView.h"

@interface BookInfoView ()

@property (nonatomic, strong) SPLabel *titleLabel;
@property (nonatomic, strong) SPLabel *authorLabel;
@property (nonatomic, strong) SPLabel *categoryLabel;
@property (nonatomic, strong) SPLabel *scoreLabel;
@property (nonatomic, strong) SPLabel *ratingSumLabel;
@property (nonatomic, strong) SPLabel *descriptionLabel;
@property (nonatomic, strong) SPLabel *commentContentLabel;
@property (nonatomic, strong) SPLabel *commentAuthorLabel;

@property (nonatomic, strong) UIColor *mainFontColor;
@property (nonatomic, strong) UIColor *mutedFontColor;
@property (nonatomic, strong) UIColor *highlightFontColor;

@property (nonatomic, strong) UIView *basicInfoView;
@property (nonatomic, strong) UIView *descriptionView;
@property (nonatomic, strong) UIView *commentView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

- (void)initControls;
- (void)drawMinimalLayout;
- (void)drawMediumLayout;
- (void)drawMaximumLayout;

@end

@implementation BookInfoView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    if (!self.style) {
      self.style = BookInfoViewStyleMinimal;
    }
  }
  return self;
}

- (id)initWithStyle:(BookInfoViewStyle)style frame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.style = style;
    self.colorStyle = BookInfoViewColorStyleDefault;
    self.currentPage = 0;
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:self.tapRecognizer];
  }
  [self initControls];
  return self;
}

- (void)scrollToPage:(NSInteger)pageNum animated:(BOOL)animated
{
  [self.scrollView scrollRectToVisible:CGRectMake(pageNum * self.bounds.size.width, 0.0, self.bounds.size.width, self.bounds.size.height) animated:animated];
}

#pragma mark -

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)setBook:(Book *)newBook
{
  if (![_book isEqual:newBook]) {
    _book = newBook;
    self.titleLabel.text = [newBook.status isEqualToString:@"已完本"] ? [NSString stringWithFormat:@"%@（完）", newBook.title] : newBook.title;
    self.authorLabel.text = [NSString stringWithFormat:@"%@", newBook.author];
    self.categoryLabel.text = [NSString stringWithFormat:@"%@", newBook.category];
    self.scoreLabel.text = [NSString stringWithFormat:@"%.1f", newBook.score];
    self.ratingSumLabel.text = [NSString stringWithFormat:@"%ld人评分", newBook.ratingSum];
    self.descriptionLabel.text = [NSString stringWithFormat:@"%@", newBook.summary];
    if (newBook.simpleComment) {
      self.commentAuthorLabel.text = [NSString stringWithFormat:@"—— %@", [newBook.simpleComment objectForKey:@"Author"]];
      self.commentContentLabel.text = [NSString stringWithFormat:@"%@", [newBook.simpleComment objectForKey:@"Content"]];
    }
    
    [self scrollToPage:0 animated:NO];
  }
  [self layoutSubviews];
}

- (void)setColorStyle:(BookInfoViewColorStyle)colorStyle
{
  _colorStyle = colorStyle;
  
  switch (self.colorStyle) {
    case BookInfoViewColorStyleDefault:
      self.mainFontColor = UIC_BRIGHT_GRAY(1.0);
      self.mutedFontColor = UIC_BRIGHT_GRAY(0.6);
      self.highlightFontColor = UIC_BRIGHT_GRAY(1.0);
      break;
    case BookInfoViewColorStyleWhiteFont:
      self.mainFontColor = [UIColor whiteColor];
      self.mutedFontColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
      self.highlightFontColor = [UIColor colorWithRed:0.596 green:0.949 blue:0.953 alpha:1.0];
      break;
    default:
      self.mainFontColor = [UIColor blackColor];
      self.mutedFontColor = [UIColor grayColor];
      self.highlightFontColor = [UIColor lightGrayColor];
      break;
  }
}

- (void)setHasBookComment:(BOOL)hasBookComment
{
  if (_hasBookComment != hasBookComment) {
    _hasBookComment = hasBookComment;
    
    if (hasBookComment) {
      CGSize contentSize = self.scrollView.contentSize;
      contentSize.width = contentSize.width + self.bounds.size.width;
      self.scrollView.contentSize = contentSize;
      
      if (!self.commentView) {
        self.commentView = [[UIView alloc] initWithFrame:CGRectMake(self.hasBookDescription ? self.basicInfoView.frame.size.width * 2 : self.basicInfoView.frame.size.width, 0.0, self.basicInfoView.frame.size.width, self.basicInfoView.frame.size.height)];
        
        // Comment label
        self.commentAuthorLabel.edgeInsets = UIEdgeInsetsMake(5.0, 10.0, 10.0, 5.0);
        self.commentAuthorLabel.backgroundColor = [UIColor clearColor];
        [self.commentView addSubview:self.commentAuthorLabel];
        
        self.commentContentLabel.edgeInsets = UIEdgeInsetsMake(5.0, 10.0, 10.0, 5.0);
        self.commentContentLabel.backgroundColor = [UIColor clearColor];
        [self.commentView addSubview:self.commentContentLabel];
      }
      [self.scrollView addSubview:self.commentView];
    } else {
      CGSize contentSize = self.scrollView.contentSize;
      contentSize.width = contentSize.width - self.bounds.size.width;
      self.scrollView.contentSize = contentSize;
      [self.commentView removeFromSuperview];
    }
  }
}

- (void)setHasBookDescription:(BOOL)hasBookDescription
{
  if (_hasBookDescription != hasBookDescription) {
    _hasBookDescription = hasBookDescription;
    
    if (hasBookDescription) {
      CGSize contentSize = self.scrollView.contentSize;
      contentSize.width = contentSize.width + self.bounds.size.width;
      self.scrollView.contentSize = contentSize;
      
      if (!self.descriptionView) {
        self.descriptionView = [[UIView alloc] initWithFrame:CGRectMake(self.basicInfoView.frame.size.width, 0.0, self.basicInfoView.frame.size.width, self.basicInfoView.frame.size.height)];
        
        // Description label
        self.descriptionLabel.edgeInsets = UIEdgeInsetsMake(5.0, 10.0, 10.0, 5.0);
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        [self.descriptionView addSubview:self.descriptionLabel];
      }
      [self.scrollView addSubview:self.descriptionView];
    } else {
      CGSize contentSize = self.scrollView.contentSize;
      contentSize.width = contentSize.width - self.bounds.size.width;
      self.scrollView.contentSize = contentSize;
      [self.descriptionView removeFromSuperview];
    }
  }
}

- (void)initControls
{
  self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
  self.scrollView.scrollsToTop = NO;
  self.scrollView.scrollEnabled = YES;
  self.scrollView.userInteractionEnabled = YES;
  self.scrollView.contentSize = self.bounds.size;
  self.scrollView.pagingEnabled = YES;
  self.scrollView.showsHorizontalScrollIndicator = NO;
  self.scrollView.showsVerticalScrollIndicator = NO;
  self.scrollView.canCancelContentTouches = NO;
  self.scrollView.bounces = YES;
  self.scrollView.delegate = self;
  [self addSubview:self.scrollView];
  
  self.hasBookDescription = NO;
  self.hasBookComment = NO;
  
  self.basicInfoView = [[UIView alloc] initWithFrame:self.bounds];
  [self.scrollView addSubview:self.basicInfoView];
  
  self.titleLabel = [[SPLabel alloc] initWithFrame:CGRectZero];
  self.authorLabel = [[SPLabel alloc] initWithFrame:CGRectZero];
  self.categoryLabel = [[SPLabel alloc] initWithFrame:CGRectZero];
  self.scoreLabel = [[SPLabel alloc] initWithFrame:CGRectZero];
  self.ratingSumLabel = [[SPLabel alloc] initWithFrame:CGRectZero];
  self.descriptionLabel = [[SPLabel alloc] initWithFrame:CGRectZero];
  self.commentContentLabel = [[SPLabel alloc] initWithFrame:CGRectZero];
  self.commentAuthorLabel = [[SPLabel alloc] initWithFrame:CGRectZero];
  
  // Title label
  self.titleLabel.backgroundColor = [UIColor clearColor];
  self.titleLabel.edgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
  [self.basicInfoView addSubview:self.titleLabel];
  
  // Author label
  self.authorLabel.backgroundColor = [UIColor clearColor];
  self.authorLabel.edgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
  [self.basicInfoView addSubview:self.authorLabel];
  
  // Score label
  self.scoreLabel.backgroundColor = [UIColor clearColor];
  self.scoreLabel.edgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
  [self.basicInfoView addSubview:self.scoreLabel];
  
  // RatingSum label
  self.ratingSumLabel.backgroundColor = [UIColor clearColor];
  self.ratingSumLabel.edgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
  [self.basicInfoView addSubview:self.ratingSumLabel];
}

#pragma mark - Draw layout

- (void)layoutSubviews
{
  switch (self.style) {
    case BookInfoViewStyleMinimal:
      [self drawMinimalLayout];
      break;
    case BookInfoViewStyleMedium:
      [self drawMediumLayout];
      break;
    case BookInfoViewStyleMaximum:
      [self drawMaximumLayout];
      break;
    default:
      [self drawMinimalLayout];
      break;
  }
  
  self.scrollView.frame = self.bounds;
  //    self.basicInfoView.frame = self.scrollView.bounds;
  
  [super layoutSubviews];
}

- (void)drawMinimalLayout
{
  self.titleLabel.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height / 2);
}

- (void)drawMediumLayout
{
  /*
   * Basic Info View
   */
  // Title label
  self.titleLabel.font = LARGE_FONT;
  CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
  self.titleLabel.frame = CGRectMake(0.0, 
                                     0.0, 
                                     MIN(titleSize.width, self.frame.size.width * 4 / 5),
                                     titleSize.height);
  self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
  self.titleLabel.textColor = self.mainFontColor;
  
  // Author label
  self.authorLabel.font = SMALL_FONT;
  CGSize authorSize = [self.authorLabel.text sizeWithFont:self.authorLabel.font];
  self.authorLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, 
                                      self.frame.size.height - authorSize.height - self.authorLabel.edgeInsets.top - self.authorLabel.edgeInsets.bottom, 
                                      MIN(authorSize.width, self.frame.size.width / 2), 
                                      authorSize.height);
  self.authorLabel.textColor = self.mutedFontColor;
  
  // Score label
  self.scoreLabel.font = [UIFont fontWithName:@"Calibri-BoldItalic" size:32.0];
  CGSize scoreSize = [self.scoreLabel.text sizeWithFont:self.scoreLabel.font];
  self.scoreLabel.frame = CGRectMake(self.frame.size.width - scoreSize.width - self.scoreLabel.edgeInsets.left - self.scoreLabel.edgeInsets.right, 
                                     0.0,
                                     MIN(scoreSize.width, self.frame.size.width / 3),
                                     scoreSize.height);
  self.scoreLabel.textAlignment = NSTextAlignmentRight;
  self.scoreLabel.textColor = self.highlightFontColor;
  
  // RatingSum label
  self.ratingSumLabel.font = SMALL_FONT;
  CGSize ratingSumSize = [self.ratingSumLabel.text sizeWithFont:self.ratingSumLabel.font];
  self.ratingSumLabel.frame = CGRectMake(self.frame.size.width - ratingSumSize.width - self.ratingSumLabel.edgeInsets.left - self.ratingSumLabel.edgeInsets.right,
                                         self.frame.size.height - ratingSumSize.height - self.ratingSumLabel.edgeInsets.top,
                                         MIN(ratingSumSize.width, self.frame.size.width / 2), 
                                         ratingSumSize.height);
  self.ratingSumLabel.textAlignment = NSTextAlignmentRight;
  self.ratingSumLabel.textColor = self.mutedFontColor;
  
  
  /*
   * Description View
   */
  // Description label
  self.descriptionLabel.font = SMALL_FONT;
  self.descriptionLabel.frame = CGRectMake(0.0,
                                           0.0, 
                                           self.frame.size.width - self.descriptionLabel.edgeInsets.left - self.descriptionLabel.edgeInsets.right, 
                                           self.frame.size.height - self.descriptionLabel.edgeInsets.top - self.descriptionLabel.edgeInsets.bottom);
  self.descriptionLabel.numberOfLines = 5;
  self.descriptionLabel.textColor = self.mainFontColor;
  
  /*
   * Comment View
   */
  // Comment content label
  self.commentContentLabel.font = SMALL_FONT;
  self.commentContentLabel.frame = CGRectMake(0.0,
                                              0.0, 
                                              self.frame.size.width - self.commentContentLabel.edgeInsets.left - self.commentContentLabel.edgeInsets.right, 
                                              (self.frame.size.height - self.commentContentLabel.edgeInsets.top - self.commentContentLabel.edgeInsets.bottom) * 2 / 3);
  self.commentContentLabel.numberOfLines = 2;
  self.commentContentLabel.textColor = self.mainFontColor;
  
  // Comment author label
  self.commentAuthorLabel.font = SMALL_FONT;
  CGSize commentAuthorSize = [self.commentAuthorLabel.text sizeWithFont:self.commentAuthorLabel.font];
  self.commentAuthorLabel.frame = CGRectMake(0.0,
                                             self.frame.size.height - commentAuthorSize.height - self.commentAuthorLabel.edgeInsets.top - self.commentAuthorLabel.edgeInsets.bottom, 
                                             self.frame.size.width - self.commentAuthorLabel.edgeInsets.left - self.commentAuthorLabel.edgeInsets.right, 
                                             commentAuthorSize.height);
  self.commentAuthorLabel.textAlignment = NSTextAlignmentRight;
  self.commentAuthorLabel.textColor = self.highlightFontColor;
}

- (void)drawMaximumLayout
{
  
}

#pragma mark - Event handler

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
  [[NSNotificationCenter defaultCenter] postNotificationName:MSG_INT_BOOKINFOVIEW_TAPPED object:self userInfo:@{@"BookId": self.book.Id}];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  self.currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
}

@end
