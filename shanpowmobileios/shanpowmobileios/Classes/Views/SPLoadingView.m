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
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        // Initialization code
        self.bkgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 160.0)];
        self.bkgView.center = self.center;
        self.bkgView.backgroundColor = UIC_BLACK(0.8);
        self.bkgView.layer.cornerRadius = 10.0;
        self.bkgView.layer.masksToBounds = YES;
        [self addSubview:self.bkgView];
        
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                  self.bkgView.bounds.size.height - 50,
                                                                  self.bkgView.bounds.size.width,
                                                                  TextHeightWithFont(MEDIUM_BOLD_FONT))];
        self.tipLabel.font = MEDIUM_BOLD_FONT;
        self.tipLabel.textColor = UIC_ALMOSTWHITE(1.0);
        self.tipLabel.backgroundColor = [UIColor clearColor];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.text = @"载入中...";
        [self.bkgView addSubview:self.tipLabel];
        
        self.circleView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.circleView.center = CGPointMake(self.center.x, self.center.y - 20);
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

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
}

- (void)hide
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
