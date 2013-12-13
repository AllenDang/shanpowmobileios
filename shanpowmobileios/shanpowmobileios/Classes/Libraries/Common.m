//
//  Common.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-2.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "Common.h"

@implementation Common

@end

static void * const kMyPropertyAssociatedStorageKey = (void*)&kMyPropertyAssociatedStorageKey;

@implementation UIViewController (ScreenAdapter)

- (void)addAdjustView
{
    UIView *adaptView = [[UIView alloc] init];
    adaptView.tag = ADAPT_VIEW_TAG;
    adaptView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height );
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        self.view.clipsToBounds = YES;
        adaptView.frame =  CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height + 20);
    }
    
    [self.view addSubview:adaptView];
}

- (void)setBackgroundImage:(UIImage *)image
{
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:image];
    backgroundView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height );
    [self.view addSubview:backgroundView];
}

@end
