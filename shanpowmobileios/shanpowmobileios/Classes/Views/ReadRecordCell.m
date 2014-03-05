//
//  ReadRecordCell.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-4.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "ReadRecordCell.h"
#import "AMRatingControl.h"
#import "ChatBubble.h"

@interface ReadRecordCell ()

@property (nonatomic, strong) UILabel *bookTitleLabel;
@property (nonatomic, strong) UILabel *bookAuthorLabel;
@property (nonatomic, strong) AMRatingControl *ratingStar;
@property (nonatomic, strong) ChatBubble *reviewBubble;

@end

@implementation ReadRecordCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.bookTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.bookAuthorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.ratingStar = [[AMRatingControl alloc] initWithLocation:CGPointZero
                                                         emptyImage:[UIImage imageNamed:@"Star_Gray_Small"]
                                                         solidImage:[UIImage imageNamed:@"Star_Red_Small"]
                                                       andMaxRating:5];
        self.reviewBubble = [[ChatBubble alloc] initWithFrame:CGRectZero];
        
        [self addSubview:self.bookTitleLabel];
        [self addSubview:self.bookAuthorLabel];
        [self addSubview:self.ratingStar];
        [self addSubview:self.reviewBubble];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setter
- (void)setBook:(NSDictionary *)book
{
    if (![book isEqualToDictionary:_book]) {
        _book = book;
    }
    
    [self updateUILayout];
    [self updateUIData];
}

- (void)setAvatarUrl:(NSString *)avatarUrl
{
    if (![avatarUrl isEqualToString:_avatarUrl]) {
        _avatarUrl = avatarUrl;
        
        self.reviewBubble.userAvatarUrl = avatarUrl;
    }
}

#pragma mark - UI
- (void)updateUILayout
{
    self.bookTitleLabel.frame = CGRectMake(10.0, 10.0, self.bounds.size.width - 20, TextHeightWithFont(MEDIUM_BOLD_FONT));
    self.bookTitleLabel.backgroundColor = [UIColor clearColor];
    self.bookTitleLabel.font = MEDIUM_BOLD_FONT;
    
    self.bookAuthorLabel.frame = CGRectMake(10.0,
                                            self.bookTitleLabel.frame.origin.y + self.bookTitleLabel.frame.size.height + 10.0,
                                            self.bounds.size.width - 20,
                                            TextHeightWithFont(MEDIUM_FONT));
    self.bookAuthorLabel.backgroundColor = [UIColor clearColor];
    self.bookAuthorLabel.font = MEDIUM_FONT;
    self.bookAuthorLabel.textColor = UIC_BRIGHT_GRAY(0.5);
    
    self.ratingStar.frame = CGRectMake(self.bounds.size.width - StarSize(@"Star_Red_Small") * 5 - 50,
                                       self.bookAuthorLabel.frame.origin.y,
                                       StarSize(@"Star_Red_Small") * 5,
                                       StarSize(@"Star_Red_Small"));
    self.ratingStar.starSpacing = -4;
    self.ratingStar.userInteractionEnabled = NO;
    
    self.reviewBubble.frame = CGRectMake(10.0,
                                         self.bookAuthorLabel.frame.origin.y + self.bookAuthorLabel.frame.size.height + 10,
                                         self.bounds.size.width - 20,
                                         self.frame.size.height - self.bookAuthorLabel.frame.origin.y - self.bookAuthorLabel.frame.size.height - 20);
    self.reviewBubble.textColor = UIC_ALMOSTWHITE(1.0);
}

- (void)updateUIData
{
    self.bookTitleLabel.text = [self.book objectForKey:@"BookTitle"];
    self.bookAuthorLabel.text = [self.book objectForKey:@"BookAuthor"];
    
    [self.ratingStar setRating:[[self.book objectForKey:@"Score"] integerValue]];
    
    if ([[self.book objectForKey:@"CommentTitle"] length] > 0) {
        self.reviewBubble.content = [self.book objectForKey:@"CommentTitle"];
    } else {
        if ([[self.book objectForKey:@"CommentContent"] length] > 0) {
            self.reviewBubble.content = [self.book objectForKey:@"CommentContent"];
        } else {
            self.reviewBubble.content = @"（没有留下任何评论）";
            self.reviewBubble.textColor = UIC_ALMOSTWHITE(0.5);
        }
    }
    
    self.reviewBubble.font = SMALL_FONT;
}

@end
