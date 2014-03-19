//
//  NSStringCategory.h
//  shanpowmobileios
//
//  Created by 木一 on 13-12-25.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (Extended)

- (CGSize)sizeWithFont:(UIFont *)font inRect:(CGRect)rect lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (NSString *)md5;

@end
