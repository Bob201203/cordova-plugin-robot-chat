//
//  ScanViewController.h
//  PDBotDemo
//
//  Created by wuyifan on 2018/2/22.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScanViewController;

@protocol ScanViewControllerDelegate <NSObject>

- (void)scanViewController:(ScanViewController*)controller captureResult:(NSString*)result;

@end


@interface ScanViewController : UIViewController

@property (nonatomic, weak) id<ScanViewControllerDelegate> delegate;

@end
