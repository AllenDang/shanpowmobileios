//
//  SPLabel.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-25.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPLabel;

@protocol SPLabelDelegate <NSObject>

@required

- (void)touchInSPLabel:(SPLabel *)label;

@end

@interface SPLabel : UILabel

@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, weak) id<SPLabelDelegate> delegate;

- (void)setLineHeight:(float)lineHeight;

@end