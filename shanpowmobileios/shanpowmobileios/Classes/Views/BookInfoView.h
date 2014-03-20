//
//  BookInfoView.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-19.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "Book.h"
#import "SPLabel.h"
#import "NSStringCategory.h"

typedef enum {
	BookInfoViewStyleMinimal = 0,
	BookInfoViewStyleMedium = 1,
	BookInfoViewStyleMaximum = 2
} BookInfoViewStyle;

typedef enum {
	BookInfoViewColorStyleDefault = 0,
	BookInfoViewColorStyleWhiteFont = 1
} BookInfoViewColorStyle;

@interface BookInfoView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) BookInfoViewStyle style;
@property (nonatomic, assign) BookInfoViewColorStyle colorStyle;
@property (nonatomic, strong) Book *book;
@property (nonatomic, assign) BOOL hasBookDescription;
@property (nonatomic, assign) BOOL hasBookComment;
@property (nonatomic, assign) NSInteger bookCommentPageCount;
@property (nonatomic, assign) NSInteger currentPage;

- (id)initWithStyle:(BookInfoViewStyle)style frame:(CGRect)frame;
- (void)scrollToPage:(NSInteger)pageNum animated:(BOOL)animated;

@end
