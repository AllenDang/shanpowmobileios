//
//  ChatBubble.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-4.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Common.h"

typedef enum {
	CB_AvatarLocationLeft = 0,
	CB_AvatarLocationRight = 1,
	CB_AvatarLocationNone = 2
} CBAvatarLocation;

typedef enum {
	CBStyleDark = 0,
	CBStyleLight = 1
} CBStyle;

@interface ChatBubble : UIView

@property (nonatomic, strong) NSString *userAvatarUrl;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CBStyle style;
@property (nonatomic, assign) CBAvatarLocation avatarLocation;

@property (nonatomic, readonly) CGFloat calculatedHeight;

@end
