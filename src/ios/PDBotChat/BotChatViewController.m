//
//  BotChatViewController.m
//  PDBotDemo
//
//  Created by wuyifan on 2018/1/19.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "BotChatViewController.h"
#import "SettingViewController.h"
#import "HistoryDataManager.h"

@interface BotChatViewController () <UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) UIViewController* popMenuController;

@end


@implementation BotChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"•••" style:UIBarButtonItemStylePlain target:self action:@selector(onMenu:)];
    self.navigationItem.rightBarButtonItem = item;
    
    
    
    UIBarButtonItem* itemleft = [[UIBarButtonItem alloc] initWithTitle:@"<---" style:UIBarButtonItemStylePlain target:self action:@selector(gobackh5:)];
    self.navigationItem.leftBarButtonItem = itemleft;
    
    
    [self makePopMenuController];
}

- (void)  gobackh5:(id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)makePopMenuController
{
    UIViewController* controller = [[UIViewController alloc] init];
    controller.preferredContentSize = CGSizeMake(88, 88);
    controller.modalPresentationStyle = UIModalPresentationPopover;
    
    UIButton* buttonClear = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonClear.frame = CGRectMake(0, 4, 88, 40);
    buttonClear.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [buttonClear setTitle:@"清空" forState:UIControlStateNormal];
    [buttonClear addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];
    [controller.view addSubview:buttonClear];
    
    UIButton* buttonSetting = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonSetting.frame = CGRectMake(0, 44, 88, 40);
    buttonSetting.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [buttonSetting setTitle:@"设置" forState:UIControlStateNormal];
    [buttonSetting addTarget:self action:@selector(onSetting) forControlEvents:UIControlEventTouchUpInside];
    [controller.view addSubview:buttonSetting];
    
    self.popMenuController = controller;
}

- (void)onMenu:(id)sender
{
    UIPopoverPresentationController* controller = [self.popMenuController popoverPresentationController];
    controller.delegate = self;
    controller.barButtonItem = sender;
    [self presentViewController:self.popMenuController animated:YES completion:nil];
}

- (void)onClear
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.botClient removeAllMessages];
    [self reloadMessageList];
}

- (void)onSetting
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIViewController* controller = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

- (void)onConnectionStateChanged:(PDConnectionState)state
{
    [super onConnectionStateChanged:state];
    
    if (state==PDConnectionConnected)
    {
        [[HistoryDataManager sharedHistoryDataManager] addHistoryAccessKey:self.uiInitInfo.accessKey withRobotName:self.botClient.robotName];
    }
}

@end

