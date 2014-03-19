//
//  NSStringCategory.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-25.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "NSStringCategory.h"

@implementation NSString (Extended)

- (CGSize)sizeWithFont:(UIFont *)font inRect:(CGRect)rect lineBreakMode:(NSLineBreakMode)lineBreakMode
{
  if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
    CGSize size = [self sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, rect.size.height) lineBreakMode:lineBreakMode];
    return size;
  } else {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(rect.size.width, rect.size.height)
                              options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine 
                           attributes:@{
                                        NSFontAttributeName: font
                                        } 
                              context:nil];
    return rect.size;
  }
}

- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
