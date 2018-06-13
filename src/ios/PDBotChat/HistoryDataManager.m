//
//  HistoryDataManager.m
//  PDBotDemo
//
//  Created by wuyifan on 2018/5/17.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "HistoryDataManager.h"

//NSString* DefaultAccessKey = @"OTgjNDRiNmU3MjItNGI5YS00ODIyLTgxM2YtYjM3YmUwOWY3MmEwIzRiYTk1OGQwLWYzODQtNGM3NS1hYzY4LWY1N2U5Y2JmZjA0MCM1MTcxYWU2ZWE4OWI2NWI4MjM1YTUxYzI0OGNlYWM5MA==";

NSString *DefaultAccessKey  = @"MTMwNyM4NjY3NTZjMy0yNDY4LTRiOGUtYTQ0MS1mMmEyMjczY2Y1NzEjMTYzNzZhZDktOTNiOS00NmY5LWJlNzUtOGViZDA4NzA0ZWJiI2MyNGVkMDkwMmI1ZmVmYzA5MGY1ZjAyOTg1Y2FjMzc5";

@implementation HistoryDataManager

+ (instancetype)sharedHistoryDataManager
{
    static HistoryDataManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HistoryDataManager alloc] init];
    });
    return manager;
}

- (NSString*)getRecentAccessKey
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* accessKey = [userDefaults stringForKey:@"AccessKey"];
    if (!accessKey) accessKey = DefaultAccessKey;
    return accessKey;
}

- (NSArray*)getHistoryDataList
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* accessKeyHistory = [userDefaults stringArrayForKey:@"AccessKeyHistory"];
    
    NSMutableArray* historyDataList = [[NSMutableArray alloc] initWithCapacity:accessKeyHistory.count];
    for (NSString* historyItem in accessKeyHistory)
    {
        NSArray* items = [historyItem componentsSeparatedByString:@":"];
        if (items.count<2) continue;
        HistoryDataItem* item = [[HistoryDataItem alloc] init];
        item.accessKey = items[0];
        item.robotName = items[1];
        [historyDataList addObject:item];
    }
    return historyDataList;
}

- (void)addHistoryAccessKey:(NSString*)accessKey withRobotName:(NSString*)robotName
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* historyDataList = [userDefaults stringArrayForKey:@"AccessKeyHistory"];
    
    NSMutableArray* accessKeyHistory = [[NSMutableArray alloc] initWithCapacity:historyDataList.count];
    [accessKeyHistory addObject:[NSString stringWithFormat:@"%@:%@", accessKey, robotName]];
    for (NSString* historyItem in historyDataList)
    {
        if ([historyItem hasPrefix:accessKey]) continue;
        [accessKeyHistory addObject:historyItem];
    }
    
    [userDefaults setObject:accessKey forKey:@"AccessKey"];
    [userDefaults setObject:accessKeyHistory forKey:@"AccessKeyHistory"];
    [userDefaults synchronize];
}

@end


@implementation HistoryDataItem
@end
