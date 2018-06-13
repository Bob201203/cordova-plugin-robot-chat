//
//  HistoryDataManager.h
//  PDBotDemo
//
//  Created by wuyifan on 2018/5/17.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryDataItem : NSObject

@property (nonatomic, strong) NSString* _Nonnull accessKey;
@property (nonatomic, strong) NSString* _Nonnull robotName;

@end


@interface HistoryDataManager : NSObject

+ (instancetype)sharedHistoryDataManager;

- (NSString*)getRecentAccessKey;
- (NSArray*)getHistoryDataList;
- (void)addHistoryAccessKey:(NSString*)accessKey withRobotName:(NSString*)robotName;

@end
