//
//  CategoryBooksViewController.h
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-5.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface CategoryBooksViewController : UIViewController

@property (nonatomic, strong) NSString *category;

- (id)initWithCategory:(NSString *)category;

@end
