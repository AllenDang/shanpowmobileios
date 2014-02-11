//
//  Common.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-2.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "Common.h"

#pragma mark - Global Functions

BOOL isLogin()
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies) {
        if ([[cookie name] isEqualToString:@"REVEL_SESSION"]) {
            if ([[cookie value] rangeOfString:@"nickname"].location != NSNotFound &&
                [[cookie value] rangeOfString:@"email"].location != NSNotFound &&
                [[cookie value] rangeOfString:@"userId"].location != NSNotFound) {
                return YES;
            }
            else {
                return NO;
            }
        }
    }
    
    return NO;
}

#pragma mark - UIViewController category

@implementation UIViewController (ScreenAdapter)

- (void)addAdjustView
{
    UIView *adaptView = [[UIView alloc] init];
    adaptView.tag = ADAPT_VIEW_TAG;
    adaptView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height );
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        self.view.clipsToBounds = YES;
        CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        adaptView.frame =  CGRectMake(0, 0 - statusBarHeight, self.view.frame.size.width, self.view.frame.size.height + 20);
    }
    
    [self.view addSubview:adaptView];
}

- (void)setBackgroundImage:(UIImage *)image
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

@end

#pragma mark - UIImage category

@implementation UIImage (extended)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
