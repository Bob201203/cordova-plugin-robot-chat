//
//  PDUIChatController.h
//  PDBotKit
//
//  Created by wuyifan on 2018/1/4.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PDBotLib/PDBotLib.h>
#import "PDUIInitInfo.h"
#import "PDUIPluginPanel.h"
#import "PDUISuggestionPanel.h"
#import "PDUIMessageTextCell.h"
#import "PDUIMessageMenuCell.h"
#import "PDUIMessageImageCell.h"
#import "PDUIMessageAudioCell.h"
#import "PDUIMessageRichTextCell.h"

@interface PDUIChatController : UIViewController <PDUISuggestionPanelDelegate, PDUIPluginPanelDelegate, PDUIMessageTextCellDelegate, PDUIMessageMenuCellDelegate, PDUIMessageImageCellDelegate, PDUIMessageAudioCellDelegate, PDUIMessageRichTextCellDelegate, PDBotLibClientDelegate>

/* 初始化配置 */
@property (nonatomic, strong) PDUIInitInfo* uiInitInfo;

/* 机器人对象 */
@property (nonatomic, strong) PDBotLibClient* botClient;

/* 聊天列表 */
@property (nonatomic, strong) UITableView* messageTableView;

- (id)initWithInfo:(PDUIInitInfo*)initInfo;
- (id)initWithInfo:(PDUIInitInfo*)initInfo  title:(NSString *) title bgUrl:(NSString *)bg avatarUrl: (NSString *)avatar;
- (void)reloadMessageList;
- (void)registerCellClass:(Class)cellClass forMessageType:(PDMessageContentType)type;
- (void)appendMessageList:(PDMessage*)message;

@end
