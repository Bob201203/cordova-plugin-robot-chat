//
//  PDUIInitInfo.h
//  PDBotKit
//
//  Created by wuyifan on 2018/1/16.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDUIInitInfo : NSObject

// 以下为必填字断
@property (strong, nonatomic) NSString* accessKey;

// 以下为选填字断
@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) NSString* phone;
@property (strong, nonatomic) NSString* userName;

@property (strong, nonatomic) UIImage* userPortrait;
@property (strong, nonatomic) UIImage* robotPortrait;

@end
