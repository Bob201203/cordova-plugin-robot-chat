//
//  SettingViewController.m
//  PDBotDemo
//
//  Created by wuyifan on 2018/3/12.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "SettingViewController.h"
#import "ScanViewController.h"
#import "BotChatViewController.h"
#import "HistoryViewController.h"
#import "HistoryDataManager.h"

@interface SettingViewController () <HistoryViewControllerDelegate, ScanViewControllerDelegate>

@property (strong, nonatomic) UITextField* textAccessKey;

@end


@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"设置";
    
    UIBarButtonItem* itemCancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    self.navigationItem.leftBarButtonItem = itemCancel;
    
    UIBarButtonItem* itemConfirm = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(onConfirm)];
    self.navigationItem.rightBarButtonItem = itemConfirm;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 100, 24)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:16];
    label.text = @"Access Key";
    [self.view addSubview:label];
    
    self.textAccessKey = [[UITextField alloc] initWithFrame:CGRectMake(16, 44, self.view.bounds.size.width-32, 32)];
    self.textAccessKey.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textAccessKey.borderStyle = UITextBorderStyleRoundedRect;
    self.textAccessKey.textColor = [UIColor blackColor];
    self.textAccessKey.font = [UIFont systemFontOfSize:12];
    self.textAccessKey.placeholder = @"用于绑定机器人，可在后台接入页面获取";
    [self.view addSubview:self.textAccessKey];
    
    UIButton* buttonHist = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonHist.frame = CGRectMake(16, 80, (self.view.bounds.size.width-32)/2, 44);
    buttonHist.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    buttonHist.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [buttonHist setTitle:@"历史记录" forState:UIControlStateNormal];
    [buttonHist addTarget:self action:@selector(onHist) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonHist];
    
    UIButton* buttonScan = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonScan.frame = CGRectMake(self.view.bounds.size.width/2, 80, (self.view.bounds.size.width-32)/2, 44);
    buttonScan.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    buttonScan.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [buttonScan setTitle:@"扫码获取" forState:UIControlStateNormal];
    [buttonScan addTarget:self action:@selector(onScan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonScan];

    self.textAccessKey.text = [[HistoryDataManager sharedHistoryDataManager] getRecentAccessKey];
}

- (void)onHist
{
    HistoryViewController* controller = [[HistoryViewController alloc] init];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onScan
{
    ScanViewController* controller = [[ScanViewController alloc] init];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)onCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onConfirm
{
    if (self.textAccessKey.text.length==0) return;
    
    NSString* accessKey = [[HistoryDataManager sharedHistoryDataManager] getRecentAccessKey];
    if ([accessKey isEqualToString:self.textAccessKey.text]) return [self onCancel];
    
    PDUIInitInfo* initInfo = [[PDUIInitInfo alloc] init];
    initInfo.accessKey = self.textAccessKey.text;
    
    BotChatViewController* controller = [[BotChatViewController alloc] initWithInfo:initInfo];
    NSMutableArray* viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [viewControllers removeAllObjects];
    [viewControllers addObject:controller];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

#pragma mark - HistoryViewControllerDelegate

- (void)historyViewController:(HistoryViewController*)controller didSelectAccessKey:(NSString*)accessKey
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (accessKey) self.textAccessKey.text = accessKey;
}

#pragma mark - ScanViewControllerDelegate

- (void)scanViewController:(ScanViewController*)controller captureResult:(NSString*)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (result) self.textAccessKey.text = result;
}

@end
