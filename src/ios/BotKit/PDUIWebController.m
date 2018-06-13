//
//  PDUIWebController.m
//  FPBotDemo
//
//  Created by wuyifan on 2018/1/18.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIWebController.h"
#import "PDUITools.h"
#import <WebKit/WebKit.h>

@interface PDUIWebController () <WKNavigationDelegate>

@property (nonatomic, strong) NSURL* url;
@property (nonatomic, strong) WKWebView* webView;

@end


@implementation PDUIWebController

- (id)initWithTitle:(NSString*)title andURL:(NSURL*)url;
{
    self = [super init];
    if (self)
    {
        self.title = title;
        self.url = url.scheme ? url : [NSURL URLWithString:[@"http://" stringByAppendingString:url.absoluteString]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:PDLocalString(@"Back") style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    self.navigationItem.leftBarButtonItem = item;
    self.navigationItem.title = self.title;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:self.url];
    [self.webView loadRequest:request];
}

- (void)onBack
{
    if (self.webView.canGoBack)
        [self.webView goBack];
    else
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.title==nil) self.navigationItem.title = webView.title;
}

@end
