//
//  HistoryViewController.h
//  PDBotDemo
//
//  Created by wuyifan on 2018/5/17.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HistoryViewController;


@protocol HistoryViewControllerDelegate <NSObject>

- (void)historyViewController:(HistoryViewController*)controller didSelectAccessKey:(NSString*)accessKey;

@end


@interface HistoryViewController : UIViewController

@property (nonatomic, weak) id<HistoryViewControllerDelegate> delegate;

@end
