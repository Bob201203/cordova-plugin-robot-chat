//
//  PDUITools.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/4.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUITools.h"

@implementation PDUITools

+ (UIImage*)imageBundleNamed:(NSString*)name
{
    NSString* fullName = [@"PDBotKit.bundle/" stringByAppendingString:name];
    return [UIImage imageNamed:fullName];
}

+ (UIImage*)scaleWithImage:(UIImage*)sourceImage andMaxSize:(CGFloat)maxSize
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    if (width>maxSize || height>maxSize)
    {
        if (width>height)
        {
            CGFloat scale = maxSize / width;
            width = maxSize;
            height = height * scale;
        }
        else
        {
            CGFloat scale = maxSize / height;
            height = maxSize;
            width = width * scale;
        }
        
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [sourceImage drawInRect:CGRectMake(0, 0, width, height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    else
    {
        return sourceImage;
    }
}

@end
