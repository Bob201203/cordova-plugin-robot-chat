//
//  PDInitInfo.h
//  PDBotLib
//
//  Created by wuyifan on 2017/12/26.
//  Copyright © 2017年 4Paradigm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDInitInfo : NSObject

// 以下为必填字断
@property (strong, nonatomic) NSString* accessKey;

// 以下为选填字断
@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) NSString* phone;
@property (strong, nonatomic) NSString* userName;

@end
