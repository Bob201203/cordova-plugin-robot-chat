//
//  PDUIAudioTools.h
//  PDBotKit
//
//  Created by wuyifan on 2018/1/8.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDUIAudioTools : NSObject

- (id)init;
- (BOOL)hasRecordPermission;
- (void)startRecord;
- (NSURL*)stopRecord;
- (void)cancelRecord;
- (float)getRecordVolume;
- (void)startPlay:(NSURL*)url;
- (void)stopPlay;
- (NSURL*)playingFile;

@property (nonatomic, assign) NSTimeInterval recordTime;

@end
