//
//  FPDateFormater.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/9.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIDateFormatter.h"
#import "PDUITools.h"

@interface PDUIDateFormatter ()

@property (strong, nonatomic) NSDateFormatter* formatterToday;
@property (strong, nonatomic) NSDateFormatter* formatterYesterday;
@property (strong, nonatomic) NSDateFormatter* formatterThisWeek;
@property (strong, nonatomic) NSDateFormatter* formatterOther;
@property (nonatomic, assign) NSTimeInterval today;
@property (nonatomic, assign) NSTimeInterval yesterday;
@property (nonatomic, assign) NSTimeInterval thisWeek;

@end

static PDUIDateFormatter* _instance = nil;

@implementation PDUIDateFormatter

+ (instancetype)sharedDateFormatter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil)
        {
            _instance = [[PDUIDateFormatter alloc] init];
        }
    });
    return _instance;
}

- (id)init
{
	if (self = [super init])
	{
		self.formatterToday = [[NSDateFormatter alloc] init];
		self.formatterToday.dateFormat = @"HH:mm";
        self.formatterYesterday = [[NSDateFormatter alloc] init];
        self.formatterYesterday.dateFormat = [NSString stringWithFormat:@"%@ HH:mm", PDLocalString(@"Yesterday")];
        self.formatterThisWeek = [[NSDateFormatter alloc] init];
        self.formatterThisWeek.dateFormat = @"EEEE HH:mm";
		self.formatterOther = [[NSDateFormatter alloc] init];
		self.formatterOther.dateFormat = @"yyyy-MM-dd HH:mm";
			
		[self refreash];
	}
	return self;
}

- (void)refreash
{
    NSInteger offset = NSTimeZone.localTimeZone.secondsFromGMT;
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	self.today = floor((now + offset) / 86400) * 86400 - offset;
    self.yesterday = self.today - 86400;
    self.thisWeek = self.today - 86400 * 7;
}

- (NSString*)timeStringFromDate:(NSDate*)date;
{
	NSTimeInterval d = [date timeIntervalSince1970];
    if (d>=self.today) return [self.formatterToday stringFromDate:date];
    if (d>=self.yesterday) return [self.formatterYesterday stringFromDate:date];
    if (d>=self.thisWeek) return [self.formatterThisWeek stringFromDate:date];
	return [self.formatterOther stringFromDate:date];
}

@end
