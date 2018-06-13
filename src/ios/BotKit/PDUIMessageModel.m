//
//  PDUIMessageModel.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/9.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIMessageModel.h"

@implementation PDUIMessageModel

+ (instancetype)modelWithMessage:(PDMessage*)message;
{
    return [[PDUIMessageModel alloc] initWithMessage:message];
}

- (instancetype)initWithMessage:(PDMessage *)message;
{
    self = [super init];
    if (self)
    {
        self.direction = message.direction;
        self.sendTime = message.sendTime;
        self.contentType = message.contentType;
        self.content = message.content;
    }
    return self;
}

@end
