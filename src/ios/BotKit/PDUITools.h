//
//  PDUITools.h
//  PDBotKit
//
//  Created by wuyifan on 2018/1/4.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PDUITools : NSObject

+ (UIImage*)imageBundleNamed:(NSString*)name;
+ (UIImage*)scaleWithImage:(UIImage*)sourceImage andMaxSize:(CGFloat)maxSize;

@end

#define PDLocalString(key) NSLocalizedStringFromTable(key, @"PDBotKit", nil)
