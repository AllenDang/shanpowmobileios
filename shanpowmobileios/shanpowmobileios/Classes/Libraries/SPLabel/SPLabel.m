//
//  SPLabel.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-25.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "SPLabel.h"

@interface SPLabel ()

@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;

@end

@implementation SPLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.backgroundColor = [UIColor clearColor];
        self.paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (void)setFrame:(CGRect)frame
{
    CGRect newFrame = frame;
    newFrame.size.width = frame.size.width + self.edgeInsets.left + self.edgeInsets.right;
    newFrame.size.height = frame.size.height + self.edgeInsets.top + self.edgeInsets.bottom;
    
    [super setFrame:newFrame];
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_edgeInsets, edgeInsets)) {
        _edgeInsets = edgeInsets;
        
        CGRect oldFrame = self.frame;
        [self setFrame:oldFrame];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)setLineHeight:(float)lineHeight
{
    [self.paragraphStyle setLineSpacing:lineHeight];
    
    self.attributedText = [[NSAttributedString alloc] initWithString:(self.text ? self.text : @"") attributes:@{NSParagraphStyleAttributeName: self.paragraphStyle}];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    
    self.paragraphStyle.alignment = textAlignment;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [string addAttributes:@{NSParagraphStyleAttributeName: self.paragraphStyle} range:NSMakeRange(0, self.text.length)];
    self.attributedText = string;
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    [super setLineBreakMode:lineBreakMode];
    
    self.paragraphStyle.lineBreakMode = lineBreakMode;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [string addAttributes:@{NSParagraphStyleAttributeName: self.paragraphStyle} range:NSMakeRange(0, self.text.length)];
    self.attributedText = string;
}

#pragma mark - Touch event handler

// 点击该label的时候, 来个高亮显示
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setTextColor:self.highlightedTextColor];
}
// 还原label颜色,获取手指离开屏幕时的坐标点, 在label范围内的话就可以触发自定义的操作
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setTextColor:self.textColor];
    UITouch *touch = [touches anyObject];
    CGPoint points = [touch locationInView:self];
    if (points.x >= self.frame.origin.x && points.y >= self.frame.origin.x && points.x <= self.frame.size.width && points.y <= self.frame.size.height)
    {
        [self.delegate touchInSPLabel:self];
    }
}

@end
