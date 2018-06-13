//
//  FPDateFormater.h
//  PDBotKit
//
//  Created by wuyifan on 2018/1/9.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDUIDateFormatter : NSObject

+ (instancetype)sharedDateFormatter;
- (void)refreash;
- (NSString*)timeStringFromDate:(NSDate*)date;

@end
