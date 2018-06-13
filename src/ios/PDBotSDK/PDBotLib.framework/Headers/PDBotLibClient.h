//
//  PDBotLibClient.h
//  PDBotLib
//
//  Created by wuyifan on 2017/12/26.
//  Copyright © 2017年 4Paradigm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDInitInfo.h"
#import "PDMessage.h"
#import "PDMenuItem.h"

#define PDBotLibVersion @"1.3.0"

typedef NS_ENUM(NSInteger, PDConnectionState)
{
    PDConnectionIdel            = 0,
    PDConnectionConnecting      = 1,
    PDConnectionConnected       = 2,
    PDConnectionError           = 3,
};

@protocol PDBotLibClientDelegate <NSObject>

@required

- (void)onReceivedSuggestion:(NSArray*)suggestions;
- (void)onAppendMessage:(PDMessage*)message;

- (void)onConnectionStateChanged:(PDConnectionState)state;

@end

@interface PDBotLibClient : NSObject

@property (nonatomic, weak) id<PDBotLibClientDelegate> delegate;
@property (nonatomic, assign) PDConnectionState connectionState;
@property (nonatomic, strong) NSString* robotName;

- (id)initWithInfo:(PDInitInfo*)initInfo;
- (void)connect;
- (void)disconnect;
- (void)askSuggestion:(NSString*)text;
- (void)askQuestion:(NSString*)text;
- (void)askQuestionByMenu:(PDMenuItem*)item andType:(PDMessageMenuType)type;
- (void)askQuestionByImage:(NSURL*)file;
- (void)askQuestionByAudio:(NSURL*)file;

- (NSArray*)getMessageList;
- (NSArray*)getMessageListBrfore:(int)msgId maxSize:(int)size;
- (void)removeMessage:(PDMessage*)message;
- (void)removeMessageBefore:(NSDate*)date;
- (void)removeAllMessages;

@end
