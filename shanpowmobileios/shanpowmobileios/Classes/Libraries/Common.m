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

- (void)pushViewController:(UIViewController *)controller
{
    self.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:controller animated:YES];
    
    self.hidesBottomBarWhenPushed = NO;
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

- (UIImage *)makeRoundedImageWithRadius:(float)radius
{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    imageLayer.contents = (id)self.CGImage;
    
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = radius;
    
    UIGraphicsBeginImageContext(self.size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

+ (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

#pragma mark - UILabel category
@implementation UILabel (Clipboard)

- (BOOL) canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}

-(void)copy:(id)sender
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.text;
}

@end
