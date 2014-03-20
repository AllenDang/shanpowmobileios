//
//  Common.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-2.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "Common.h"

#pragma mark - Global Functions

BOOL isLogin() {
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

CGFloat heightForMultilineTextWithFont(NSString *text, UIFont *font, CGFloat width) {
	CGFloat height = 0.0;
	if (IsSysVerGTE(7.0)) {
		height = [text boundingRectWithSize:CGSizeMake(width, INFINITY)
		                            options:NSStringDrawingUsesLineFragmentOrigin
		                         attributes:@{ NSFontAttributeName: font }
		                            context:nil].size.height;
	}
	else {
		height = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, INFINITY) lineBreakMode:NSLineBreakByClipping].height;
	}
	return height;
}

BOOL isLastCell(UITableView *tableView, NSIndexPath *indexPath) {
	if (!tableView || !indexPath) {
		return NO;
	}

	NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
	NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;

	NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];

	if (indexPath.section == pathToLastRow.section && indexPath.row == pathToLastRow.row) {
		return YES;
	}
	else {
		return NO;
	}

	return NO;
}

NSArray *arrangeBooksByCategories(NSArray *books, NSArray *categories) {
	if (books) {
		if (categories) {
			NSMutableArray *arrangedBooks = [NSMutableArray arrayWithCapacity:40];

			for (NSDictionary *category in categories) {
				NSString *categoryName = [category objectForKey:@"Category"];

				BOOL shouldContinue = NO;
				for (NSDictionary *cat in arrangedBooks) {
					if ([categoryName isEqualToString:[cat objectForKey:@"Category"]]) {
						shouldContinue = YES;
						break;
					}
				}
				if (shouldContinue) {
					continue;
				}

				NSMutableDictionary *categoryWithBooks = [NSMutableDictionary dictionaryWithCapacity:40];
				[categoryWithBooks setObject:categoryName forKey:@"Category"];

				NSMutableArray *booksInCategory = [NSMutableArray arrayWithCapacity:40];
				for (NSDictionary *book in books) {
					if ([[book objectForKey:@"Category"] isEqualToString:categoryName]) {
						[booksInCategory addObject:book];
					}
				}
				[categoryWithBooks setObject:booksInCategory forKey:@"Books"];

				[arrangedBooks addObject:categoryWithBooks];
			}

			return arrangedBooks;
		}
		else {
			return books;
		}
	}

	return nil;
}

extern NSMutableDictionary *arrangeBooksByTime(NSArray *books, TimeAccuracy accuracy) {
	if (books) {
		NSMutableDictionary *arrangedBooks = [NSMutableDictionary dictionaryWithCapacity:40];

		for (NSDictionary *book in books) {
			NSString *timeString = [book objectForKey:@"CreationTime"];

			NSString *time = [timeString substringToIndex:accuracy];

			NSMutableArray *timedBooks = [NSMutableArray arrayWithArray:[arrangedBooks objectForKey:time]];
			[timedBooks addObject:book];
			[arrangedBooks setObject:timedBooks forKey:time];
		}

		return arrangedBooks;
	}

	return nil;
}

#pragma mark - UIViewController category

@implementation UIViewController (ScreenAdapter)

- (void)addAdjustView {
	UIView *adaptView = [[UIView alloc] init];
	adaptView.tag = ADAPT_VIEW_TAG;
	adaptView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);

	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
		self.view.clipsToBounds = YES;
		CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
		adaptView.frame =  CGRectMake(0, 0 - statusBarHeight, self.view.frame.size.width, self.view.frame.size.height + 20);
	}

	[self.view addSubview:adaptView];
}

- (void)setBackgroundImage:(UIImage *)image {
	self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)pushViewController:(UIViewController *)controller {
	controller.hidesBottomBarWhenPushed = YES;

	[self.navigationController pushViewController:controller animated:YES];
}

- (void)pushViewController:(UIViewController *)controller hideBottomBar:(BOOL)hideBottomBar {
	self.hidesBottomBarWhenPushed = YES;

	[self.navigationController pushViewController:controller animated:YES];

	self.hidesBottomBarWhenPushed = hideBottomBar;
}

@end

#pragma mark - UIImage category

@implementation UIImage (extended)

+ (UIImage *)imageWithColor:(UIColor *)color {
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

- (UIImage *)makeRoundedImageWithRadius:(float)radius {
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

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
	UIGraphicsBeginImageContext(newSize);
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return newImage;
}

- (UIImage *)scaledToSize:(CGSize)newSize {
	UIGraphicsBeginImageContext(newSize);
	[self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return newImage;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha {
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

- (UIImage *)maskWithColor:(UIColor *)color {
	CGImageRef maskImage = self.CGImage;
	CGFloat width = self.size.width * 2;
	CGFloat height = self.size.height * 2;
	CGRect bounds = CGRectMake(0, 0, width, height);

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
	CGContextClipToMask(bitmapContext, bounds, maskImage);
	CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
	CGContextFillRect(bitmapContext, bounds);

	CGImageRef cImage = CGBitmapContextCreateImage(bitmapContext);
	UIImage *coloredImage = [UIImage imageWithCGImage:cImage];

	CGContextRelease(bitmapContext);
	CGColorSpaceRelease(colorSpace);
	CGImageRelease(cImage);

	return coloredImage;
}

@end

#pragma mark - UILabel category
@implementation UILabel (Clipboard)

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	return (action == @selector(copy:));
}

- (void)copy:(id)sender {
	UIPasteboard *pboard = [UIPasteboard generalPasteboard];
	pboard.string = self.text;
}

@end

#pragma mark - UINavigationItem category
@implementation UINavigationItem (BackButtonTitle)

- (UIBarButtonItem *)backBarButtonItem {
	return [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end

#pragma mark - NSObject category
@implementation NSObject (null)

- (BOOL)isNull {
	if (self == [NSNull null] || self == nil) {
		return YES;
	}
	else {
		return NO;
	}
}

@end
