//
//  SPLoadingView.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-3.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "SPLoadingView.h"
#import "Common.h"

@interface SPLoadingView ()

@property (nonatomic, strong) UIActivityIndicatorView *circleView;
@property (nonatomic, strong) UIView *bkgView;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation SPLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.bkgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 160.0)];
        self.bkgView.center = CGPointMake(self.center.x, self.center.y - 20);
        self.bkgView.backgroundColor = UIC_BLACK(0.8);
        self.bkgView.layer.cornerRadius = 10.0;
        self.bkgView.layer.masksToBounds = YES;
        [self addSubview:self.bkgView];
        
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 30.0, self.bkgView.bounds.size.width, TextHeightWithFont(MEDIUM_BOLD_FONT))];
        self.tipLabel.font = MEDIUM_BOLD_FONT;
        self.tipLabel.textColor = UIC_ALMOSTWHITE(1.0);
        self.tipLabel.backgroundColor = [UIColor clearColor];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.text = @"载入中...";
        [self.bkgView addSubview:self.tipLabel];
        
        self.circleView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.circleView.center = self.center;
        [self addSubview:self.circleView];
        [self.circleView startAnimating];
    }
    return self;
}

- (void)setStyle:(UIActivityIndicatorViewStyle)style
{
    if (style != _style) {
        _style = style;
        
        self.circleView.activityIndicatorViewStyle = style;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
