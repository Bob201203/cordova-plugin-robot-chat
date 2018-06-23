//
//  PDUIChatController.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/4.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//  modify by  zhoubingquan  2018.6.6

#import "PDUIChatController.h"
#import "PDUITools.h"
#import "PDUIAudioTools.h"
#import "PDUIDateFormatter.h"
#import "PDUIRecordView.h"
#import "PDUIImageController.h"
#import "PDUIWebController.h"
#import <QuartzCore/QuartzCore.h>

#define PDUIPlugin_Photo    1001
#define PDUIPlugin_Camera   1002

@interface PDUIChatController ()
    <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    Class _messageCellClasses[8];
}

/* 消息数据 */
@property (nonatomic, strong) NSMutableArray* messageArray;

/* 输入面板 */
@property (nonatomic, strong) UIView* inputPanel;

/* 输入框 */
@property (nonatomic, strong) UITextView* inputTextView;
@property (nonatomic, strong) UIButton* inputButRecord;
@property (nonatomic, strong) UIButton* inputButVoice;
@property (nonatomic, strong) UIButton* inputButKey;
@property (nonatomic, strong) UIButton* inputButAdd;
@property (nonatomic, strong) UIButton* inputButPic;
@property (nonatomic, strong) UIButton* inputButSend;

/* 建议问题提示框 */
@property (nonatomic, strong) PDUISuggestionPanel* suggestionPanel;

/* 插件面板 */
@property (nonatomic, strong) PDUIPluginPanel* pluginView;

/* 录音状态显示 */
@property (nonatomic, strong) PDUIRecordView* recordView;

/* 录音对象 */
@property (nonatomic, strong) PDUIAudioTools* audioTools;

/* 录音定时器 */
@property (nonatomic, strong) NSTimer* audioRecordTimer;

/* 正在播放的消息 */
@property (nonatomic, weak) PDMessageContent* audioPlayingMessage;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) UIImage *abg;
@property (nonatomic, assign) CGFloat  moveY;

- (CGFloat) moveOffset;
- (void) leftGoBack:(id)sender;
- (void) createBackleftButton;
- (void) setImageWithAvatarUrl :(NSString *)avatar  avatarBgUrl: (NSString *)avatarBg;
@end

@implementation PDUIChatController

- (id)initWithInfo:(PDUIInitInfo*)initInfo
{
    self = [super init];
    if (self)
    {
        self.uiInitInfo = initInfo;
    }
    return self;
}


- (void) setImageWithAvatarUrl :(NSString *)avatar  avatarBgUrl: (NSString *)avatarBg{
    if (avatarBg && [avatarBg isKindOfClass:[NSString class]] && avatarBg.length > 0) {
        NSArray *aArray = [avatarBg componentsSeparatedByString:@"."];
        NSString *filename = [aArray objectAtIndex:0];
        NSString *sufix = [aArray objectAtIndex:1];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:filename ofType:sufix];
        self.abg =  [[UIImage alloc] initWithContentsOfFile:imagePath];
    }
    
    if (avatar && [avatar isKindOfClass:[NSString class]] && avatar.length > 0) {
        NSArray *aArray = [avatar componentsSeparatedByString:@"."];
        NSString *filename = [aArray objectAtIndex:0];
        NSString *sufix = [aArray objectAtIndex:1];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:filename ofType:sufix];
        self.avatar =  [[UIImage alloc] initWithContentsOfFile:imagePath];
    }
}

- (CGFloat) moveOffset {
    bool IsiPhoneX = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO);
    
    return   (IsiPhoneX ? 20.f:0.f);
}

- (id)initWithInfo:(PDUIInitInfo*)initInfo  title:(NSString *) title bgUrl:(NSString *)bg avatarUrl: (NSString *)avatar
{
    self = [super init];
    if (self) {
        self.uiInitInfo = initInfo;
        self.title = title;
        
        [self setImageWithAvatarUrl:avatar avatarBgUrl:bg];
    }
    return self;
}

- (void)dealloc {
    self.botClient = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.moveY = [self moveOffset];
    
    [self createBackleftButton];
    [[PDUIDateFormatter sharedDateFormatter] refreash];

    self.messageArray = [[NSMutableArray alloc] initWithCapacity:1024];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createTable];
    [self createInputPanel];
 
    [self createRobotClient];
    [self reloadMessageList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[PDUIDateFormatter sharedDateFormatter] refreash];
    
    if (self.messageTableView.contentOffset.y<0) [self scrollToBottom:NO];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self reloadMessageList];
        [self hidePluginPanel];
    } completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)createTable
{
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height- 61 - self.moveY) style:UITableViewStylePlain];
    
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.allowsSelection = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBack)]];
    [self.view addSubview:tableView];
    self.messageTableView = tableView;
    
    [self registerCellClass:[PDUIMessageTextCell class] forMessageType:PDMessageContentTypeText];
    [self registerCellClass:[PDUIMessageMenuCell class] forMessageType:PDMessageContentTypeMenu];
    [self registerCellClass:[PDUIMessageImageCell class] forMessageType:PDMessageContentTypeImage];
    [self registerCellClass:[PDUIMessageAudioCell class] forMessageType:PDMessageContentTypeAudio];
    [self registerCellClass:[PDUIMessageRichTextCell class] forMessageType:PDMessageContentTypeRichText];
}

- (void)createInputPanel
{
    UIView* inputView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-61 - self.moveY, self.view.frame.size.width, 61)];
    inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    inputView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:inputView];
    self.inputPanel = inputView;
    
    CGFloat  offy = 1;
    // 12 + 12 + 36  = 60
    UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(60, 12 + offy, inputView.frame.size.width-120, 36)];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.layer.cornerRadius = 4;
    textView.layer.masksToBounds = YES;
    textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView.layer.borderWidth = 0.5f;
    textView.backgroundColor = [UIColor whiteColor];
    textView.layoutManager.allowsNonContiguousLayout = NO;
    textView.font = [UIFont systemFontOfSize:16];
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES;
    textView.autoresizesSubviews = YES;
    textView.textAlignment = NSTextAlignmentLeft;
    textView.delegate = self;
   
    [self.inputPanel addSubview:textView];
    self.inputTextView = textView;
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, inputView.frame.size.width, 0.5f)];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    line.backgroundColor = [UIColor lightGrayColor];
    [inputView addSubview:line];
    
    if (self.moveY <=1.f) {
        line = [[UIView alloc] initWithFrame:CGRectMake(0, inputView.frame.size.height-0.5f, inputView.frame.size.width, 0.5f)];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        line.backgroundColor = [UIColor lightGrayColor];
        [inputView addSubview:line];
    }
    
//    self.inputButVoice = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
//    self.inputButVoice.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
//    [self.inputButVoice setImage:[PDUITools imageBundleNamed:@"chat_setmode_voice"] forState:UIControlStateNormal];
//    [self.inputButVoice addTarget:self action:@selector(onInputButVoice) forControlEvents:UIControlEventTouchUpInside];
//    [self.inputPanel addSubview:self.inputButVoice];
    
    self.inputButPic = [[UIButton alloc] initWithFrame:CGRectMake(12, offy + 12 , 36, 36)];
    self.inputButPic.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.inputButPic setImage:[PDUITools imageBundleNamed:@"icon_chat_image"] forState:UIControlStateNormal];
    [self.inputButPic addTarget:self action:@selector(onButPicture:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputPanel addSubview:self.inputButPic];
    
//    self.inputButKey = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
//    self.inputButKey.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
//    [self.inputButKey setImage:[PDUITools imageBundleNamed:@"chat_setmode_key"] forState:UIControlStateNormal];
//    [self.inputButKey addTarget:self action:@selector(onInputButKey) forControlEvents:UIControlEventTouchUpInside];
//    [self.inputPanel addSubview:self.inputButKey];
//    self.inputButKey.hidden = YES;
    
//    self.inputButAdd = [[UIButton alloc] initWithFrame:CGRectMake(self.inputPanel.frame.size.width-48, 0, 48, 48)];
//    self.inputButAdd.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//    [self.inputButAdd setImage:[PDUITools imageBundleNamed:@"chat_setmode_add"] forState:UIControlStateNormal];
//    [self.inputButAdd addTarget:self action:@selector(onInputButAdd) forControlEvents:UIControlEventTouchUpInside];
//    [self.inputPanel addSubview:self.inputButAdd];
    
   // inputButSend
    
    self.inputButSend = [[UIButton alloc] initWithFrame:CGRectMake(self.inputPanel.frame.size.width- 48, 12 + offy, 36, 36)];
    self.inputButSend.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.inputButSend setImage:[PDUITools imageBundleNamed:@"icon_chat_send"] forState:UIControlStateNormal];
    [self.inputButSend addTarget:self action:@selector(onInputButSend:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputPanel addSubview:self.inputButSend];
    
//    self.inputButRecord = [[UIButton alloc] initWithFrame:CGRectMake(48, 8, inputView.frame.size.width-96, 32)];
//    self.inputButRecord.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    [self.inputButRecord setTitle:PDLocalString(@"HoldToTalk") forState:UIControlStateNormal];
//    [self.inputButRecord setTitle:PDLocalString(@"ReleaseToSend") forState:UIControlStateHighlighted];
//    [self.inputButRecord setTitle:PDLocalString(@"ReleaseToCancel") forState:UIControlStateDisabled];
//    [self.inputButRecord setBackgroundImage:[PDUITools imageBundleNamed:@"chat_record_normal"] forState:UIControlStateNormal];
//    [self.inputButRecord setBackgroundImage:[PDUITools imageBundleNamed:@"chat_record_hilight"] forState:UIControlStateHighlighted];
//    [self.inputButRecord setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.inputButRecord addTarget:self action:@selector(onRecordStart) forControlEvents:UIControlEventTouchDown];
//    [self.inputButRecord addTarget:self action:@selector(onRecordFinish) forControlEvents:UIControlEventTouchUpInside];
//    [self.inputButRecord addTarget:self action:@selector(onRecordCancel) forControlEvents:UIControlEventTouchUpOutside];
//    [self.inputButRecord addTarget:self action:@selector(onRecordPause) forControlEvents:UIControlEventTouchDragExit];
//    [self.inputButRecord addTarget:self action:@selector(onRecordResume) forControlEvents:UIControlEventTouchDragEnter];
//    [self.inputPanel addSubview:self.inputButRecord];
//    self.inputButRecord.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
//    self.suggestionPanel = [[PDUISuggestionPanel alloc] initWithFrame:CGRectMake(0, self.inputPanel.frame.origin.y-128, self.view.frame.size.width, 128)];
//    self.suggestionPanel.delegate = self;
    
 
//    [self.view addSubview:self.suggestionPanel];
}


- (void)createPluginPanel
{
    self.pluginView = [[PDUIPluginPanel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 220)];
    self.pluginView.delegate = self;
    self.pluginView.hidden = YES;
    [self.view addSubview:self.pluginView];
    
    [self.pluginView insertItemWithImage:[PDUITools imageBundleNamed:@"chat_plugin_photo"] title:PDLocalString(@"Photo") tag:PDUIPlugin_Photo];
    [self.pluginView insertItemWithImage:[PDUITools imageBundleNamed:@"chat_plugin_camera"] title:PDLocalString(@"Camera") tag:PDUIPlugin_Camera];
}

- (void)createRecordViews
{
    self.audioTools = [[PDUIAudioTools alloc] init];
    
    self.recordView = [[PDUIRecordView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.recordView];
    self.recordView.hidden = YES;
}

- (void)createRobotClient
{
    PDInitInfo* initInfo = [[PDInitInfo alloc] init];
    initInfo.accessKey = self.uiInitInfo.accessKey;
    initInfo.userId = self.uiInitInfo.userId;
    initInfo.phone = self.uiInitInfo.phone;
    initInfo.userName = self.uiInitInfo.userName;
    
    self.botClient = [[PDBotLibClient alloc] initWithInfo:initInfo];
    self.botClient.delegate = self;
    [self.botClient connect];
    
    [self.botClient removeMessageBefore:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*30]];
}

- (void)reloadMessageList
{
    [self.messageArray removeAllObjects];
    
    NSArray* messageList = [self.botClient getMessageList];
    for (PDMessage* message in messageList)
    {
        [self appendMessageList:message];
    }
    
    [self.messageTableView reloadData];
}

- (void)registerCellClass:(Class)cellClass forMessageType:(PDMessageContentType)type
{
    _messageCellClasses[type] = cellClass;
    [self.messageTableView registerClass:cellClass forCellReuseIdentifier:[PDMessage contentTypeToString:type]];
}

- (void)appendMessageList:(PDMessage*)message
{
    PDUIMessageModel* model = [PDUIMessageModel modelWithMessage:message];
    PDUIMessageModel* lastModel = self.messageArray.lastObject;
    model.isDisplayMessageTime = !lastModel || [model.sendTime timeIntervalSinceDate:lastModel.sendTime] > 300;
    
    if (model.direction==PDMessageDirectionRecv)
    {
        model.portraitImage = self.uiInitInfo.robotPortrait ? self.uiInitInfo.robotPortrait : [PDUITools imageBundleNamed:@"image_support_avatar"];
    }
    else
    {
        if (self.abg && self.avatar) {
            model.portraitBg = self.abg;
            model.portraitImage  = self.avatar;
        }
        else {
        model.portraitImage = self.uiInitInfo.userPortrait ? self.uiInitInfo.userPortrait : [PDUITools imageBundleNamed:@"portrait_user"];
        }
    }
    
    CGFloat width = self.messageTableView.bounds.size.width;
    Class cellCless = _messageCellClasses[model.contentType];
    if (!cellCless) cellCless = [PDUIMessageBaseCell class];
    [cellCless setCellSizeForMessage:model withMaxWidth:width];
    
    [self.messageArray addObject:model];
}

- (void)moveInputPanel:(CGFloat)y withDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.messageTableView.frame;
        frame.size.height = y - self.inputPanel.frame.size.height;
        self.messageTableView.frame = frame;
        
        frame = self.inputPanel.frame;
        frame.origin.y = y - self.inputPanel.frame.size.height;
        self.inputPanel.frame = frame;
        
//        frame = self.suggestionPanel.frame;
//        frame.origin.y = self.inputPanel.frame.origin.y - self.suggestionPanel.frame.size.height;
//        self.suggestionPanel.frame = frame;
    }];
}

- (void)ajustInputPanelHeight:(CGFloat)height
{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.inputPanel.frame;
        CGFloat offset = frame.size.height - height;
        
        frame = self.inputPanel.frame;
        frame.origin.y += offset;
        frame.size.height = height;
        self.inputPanel.frame = frame;
        
//        frame = self.suggestionPanel.frame;
//        frame.origin.y = self.inputPanel.frame.origin.y - self.suggestionPanel.frame.size.height;
//        self.suggestionPanel.frame = frame;
        
        frame = self.messageTableView.frame;
        frame.size.height += offset;
        self.messageTableView.frame = frame;
        
    } completion:^(BOOL finished) {
        CGSize size = self.inputTextView.contentSize;
        CGRect rect = self.inputTextView.bounds;
        rect.origin.y = size.height - rect.size.height;
        [self.inputTextView scrollRectToVisible:rect animated:YES];
    }];
}

- (void)scrollToBottom:(BOOL)animated
{
    NSInteger cnt = [self tableView:self.messageTableView numberOfRowsInSection:0];
    if (cnt>0)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:cnt-1 inSection:0];
        [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self hidePluginPanel];
    [self moveInputPanel:height withDuration:duration];
    [self scrollToBottom:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self moveInputPanel:height withDuration:duration];
}

- (void)onInputButVoice
{
    if (!self.pluginView.hidden) [self hidePluginPanel];
    [self.view endEditing:YES];
    self.inputTextView.hidden = YES;
    self.inputButVoice.hidden = YES;
    self.inputButKey.hidden = NO;
    self.inputButRecord.hidden = NO;
    [self ajustInputPanelHeight:60];
}

- (void)onInputButKey
{
    self.inputTextView.hidden = NO;
    self.inputButVoice.hidden = NO;
    self.inputButKey.hidden = YES;
    self.inputButRecord.hidden = YES;
    [self textViewDidChange:self.inputTextView];
}

- (void)onInputButAdd
{
    if (self.pluginView.hidden)
    {
        [self showPluginPanel];
    }
    else
    {
        [self hidePluginPanel];
    }
}

- (void)showPluginPanel
{
    if (!self.pluginView.hidden) return;
    if (self.inputButVoice.hidden) [self onInputButKey];
    
    [self.view endEditing:YES];
    
    NSTimeInterval duration = 0.25;
    self.pluginView.hidden = NO;
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.pluginView.frame;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        self.pluginView.frame = frame;
    }];
    
    [self moveInputPanel:self.view.frame.size.height-self.pluginView.frame.size.height withDuration:duration];
    [self scrollToBottom:YES];
}

- (void)hidePluginPanel
{
    if (self.pluginView.hidden) return;
    
    NSTimeInterval duration = 0.25;
    [self moveInputPanel:self.view.frame.size.height withDuration:duration];
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.pluginView.frame;
        frame.origin.y = self.view.frame.size.height;
        self.pluginView.frame = frame;
    } completion:^(BOOL finished) {
         self.pluginView.hidden = YES;
    }];
}

- (void)onTapBack
{
    [self.view endEditing:YES];
}

# pragma mark - Record

- (void)onRecordStart
{
    if (![self.audioTools hasRecordPermission])
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:PDLocalString(@"MicrophoneAccessRight") message:nil delegate:nil cancelButtonTitle:PDLocalString(@"OK") otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    self.recordView.hidden = NO;
    [self.recordView setVolume:0.0f];
    [self.recordView setCancel:false];
    
    [self.audioTools startRecord];
    if (self.audioRecordTimer) [self.audioRecordTimer invalidate];
    self.audioRecordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onRecordTimer) userInfo:nil repeats:YES];
}

- (void)onRecordFinish
{
    self.recordView.hidden = YES;
    NSURL* recordUrl = [self.audioTools stopRecord];
    [self.audioRecordTimer invalidate];
    self.audioRecordTimer = nil;
    
    if (recordUrl)
    {
        NSString* fileName = [NSString stringWithFormat:@"record%0.0lf.mp3", [[NSDate date] timeIntervalSince1970]*1000];
        NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
        [[NSFileManager defaultManager] moveItemAtURL:recordUrl toURL:fileUrl error:nil];
        [self.botClient askQuestionByAudio:fileUrl];
    }
}

- (void)onRecordCancel
{
    self.inputButRecord.enabled = YES;
    self.recordView.hidden = YES;
    [self.audioTools cancelRecord];
    [self.audioRecordTimer invalidate];
    self.audioRecordTimer = nil;
}

- (void)onRecordPause
{
    self.inputButRecord.enabled = NO;
    [self.recordView setCancel:YES];
}

- (void)onRecordResume
{
    self.inputButRecord.enabled = YES;
    [self.recordView setCancel:NO];
}

- (void)onRecordTimer
{
    float volume = [self.audioTools getRecordVolume];
    [self.recordView setVolume:volume];
}

# pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PDUIMessageModel* model = [self.messageArray objectAtIndex:indexPath.row];
    NSString* identifier = [PDMessage contentTypeToString:model.contentType];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell)
    {
        if ([cell isKindOfClass:[PDUIMessageBaseCell class]])
        {
            PDUIMessageBaseCell* messageCell = (PDUIMessageBaseCell*)cell;
            [messageCell setMessageModel:model];
            [messageCell setDelegate:self];
        }
    }
    else
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.text = PDLocalString(@"UnsupportedMessage");
    }
    
    return cell;
}

# pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PDUIMessageModel* model = [self.messageArray objectAtIndex:indexPath.row];
    return model.cellSize.height;
}

# pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        NSString* text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (text.length>0)
        {
            [self.botClient askQuestion:text];
            textView.text = nil;
            [self textViewDidChange:textView];
//            self.suggestionPanel.hidden = YES;
            return NO;
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat height = textView.contentSize.height + 12;
    if (height<61) height = 61;
    else if (height>128) height = 128;
    
    if (self.inputPanel.frame.size.height!=height) [self ajustInputPanelHeight:height];
    
    if (textView.text.length>0)
    {
        [self.botClient askSuggestion:textView.text];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    self.suggestionPanel.hidden = YES;
}

# pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    image = [PDUITools scaleWithImage:image andMaxSize:1600];
    
    NSString* fileName = [NSString stringWithFormat:@"photo%0.0lf.jpg", [[NSDate date] timeIntervalSince1970]*1000];
    NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSData* imageDate = UIImageJPEGRepresentation(image, 0.8f);
    [imageDate writeToFile:filePath atomically:YES];

    [self.botClient askQuestionByImage:[NSURL fileURLWithPath:filePath]];
}

# pragma mark - PDUISuggestionPanelDelegate

//- (void)suggestionPanel:(PDUISuggestionPanel*)suggestionPanel clickedItem:(PDMenuItem*)item
//{
//    self.inputTextView.text = item.content;
//    suggestionPanel.hidden = YES;
//}

# pragma mark - PDUIPluginPanelDelegate

- (void)pluginPanel:(PDUIPluginPanel*)pluginPanel clickedItemWithTag:(NSInteger)tag
{
    [self hidePluginPanel];
    if (tag==PDUIPlugin_Photo)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController* controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            controller.allowsEditing = NO;
            controller.delegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:PDLocalString(@"DeviceUnsupport") message:nil delegate:nil cancelButtonTitle:PDLocalString(@"OK") otherButtonTitles:nil];
            [alertView show];
        }
    }
    else if (tag==PDUIPlugin_Camera)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController* controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            controller.allowsEditing = NO;
            controller.delegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:PDLocalString(@"DeviceUnsupport") message:nil delegate:nil cancelButtonTitle:PDLocalString(@"OK") otherButtonTitles:nil];
            [alertView show];
        }
    }
}

# pragma mark - PDUIMessageTextCellDelegate

- (void)textCell:(PDUIMessageTextCell* _Nonnull)textCell clickedUrl:(NSString* _Nonnull)url;
{
    PDUIWebController* webController = [[PDUIWebController alloc] initWithTitle:nil andURL:[NSURL URLWithString:url]];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:webController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

# pragma mark - PDUIMessageMenuCellDelegate

- (void)menuCell:(PDUIMessageMenuCell*)menuCell clickedItem:(PDMenuItem*)item withType:(PDMessageMenuType)type
{
    [self.botClient askQuestionByMenu:item andType:type];
}

# pragma mark - PDUIMessageImageCellDelegate

- (void)imageCell:(PDUIMessageImageCell*)imageCell clickedContent:(PDMessageContentImage*)content;
{
    NSString* document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString* path = [document stringByAppendingPathComponent:content.dataPath];
    PDUIImageController* imageController = [[PDUIImageController alloc] initWithPath:path];
    [self presentViewController:imageController animated:YES completion:nil];
}

# pragma mark - PDUIMessageAudioCellDelegate

- (void)audioCell:(PDUIMessageAudioCell*)audioCell clickedContent:(PDMessageContentAudio*)content
{
    NSString* document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString* path = [document stringByAppendingPathComponent:content.dataPath];
    NSURL* url = [NSURL fileURLWithPath:path];
    if (self.audioTools.playingFile && self.audioPlayingMessage==content)
    {
        [self.audioTools stopPlay];
        self.audioPlayingMessage = nil;
    }
    else
    {
        [self.audioTools startPlay:url];
        self.audioPlayingMessage = content;
    }
}

# pragma mark - PDUIMessageRichTextCellDelegate

- (void)richTextCell:(PDUIMessageRichTextCell*)richTextCell clickedContent:(PDMessageContentRichText*)content
{
    NSURL* url = [NSURL URLWithString:content.url];
    PDUIWebController* webController = [[PDUIWebController alloc] initWithTitle:content.title andURL:url];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:webController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

# pragma mark - PDBotLibClientDelegate

- (void)onReceivedSuggestion:(NSArray*)suggestions
{
//    [self.suggestionPanel setSuggestionArray:suggestions];
}

- (void)onAppendMessage:(PDMessage*)message
{
    [self appendMessageList:message];
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
    [self.messageTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)onConnectionStateChanged:(PDConnectionState)state
{
    switch (state)
    {
        case PDConnectionIdel:
            self.navigationItem.title = PDLocalString(@"ConnectionClosed");
            break;
        case PDConnectionConnecting:
            self.navigationItem.title = PDLocalString(@"Connecting");
            break;
        case PDConnectionConnected:
            self.navigationItem.title = self.botClient.robotName;
            break;
        default:
            self.navigationItem.title = PDLocalString(@"ConnectionFailed");
            break;
    }
}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}


#pragma mark leftGoBack  createBackleftButton

- (void)  leftGoBack:(id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) createBackleftButton {
    UIButton *button =  [[UIButton alloc]  initWithFrame:CGRectMake(0, 0, 24, 24)];
    UIImage *nor = [PDUITools imageBundleNamed:@"icon_back_d"];
    UIImage *up = [PDUITools imageBundleNamed:@"icon_back_w"];
    
    [button setImage:nor forState:UIControlStateNormal];
    [button setImage:up forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(leftGoBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]  initWithCustomView:button];
}


- (void) onButPicture : (id)  sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController* controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.allowsEditing = NO;
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:PDLocalString(@"DeviceUnsupport") message:nil delegate:nil cancelButtonTitle:PDLocalString(@"OK") otherButtonTitles:nil];
        [alertView show];
    }
}

- (void) onInputButSend: (id)sender {
    if (self.inputTextView.text.length > 0 && ![self.inputTextView.text isEqualToString:@"\n"])
    {
        NSString* text = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (text.length>0)
        {
            [self.botClient askQuestion:text];
            self.inputTextView.text = nil;
        }
    }
}




@end
