//
//  SPLabel.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-25.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "SPLabel.h"

@implementation SPLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
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

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
