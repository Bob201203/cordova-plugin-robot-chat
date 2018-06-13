//
//  PDUIImageController.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/18.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIImageController.h"
#import "YFGIFImageView.h"

@interface PDUIImageController () <UIScrollViewDelegate>

@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIImageView* imageView;

@end


@implementation PDUIImageController

- (id)initWithPath:(NSString*)path
{
    self = [super init];
    if (self)
    {
        self.path = path;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBack)]];
    [self.view addSubview:self.scrollView];
    
    NSData* data = [NSData dataWithContentsOfFile:self.path];
    UIImage* image = [[UIImage alloc] initWithData:data];
    
    if ([YFGIFImageView isGIFData:data])
    {
        YFGIFImageView* imageView = [[YFGIFImageView alloc] initWithImage:image];
        imageView.gifData = data;
        [imageView startGIF];
        self.imageView = imageView;
    }
    else
    {
        self.imageView = [[UIImageView alloc] initWithImage:image];
    }
    
    [self.scrollView addSubview:self.imageView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize size = self.view.bounds.size;
    CGFloat scaleX = size.width / self.imageView.image.size.width;
    CGFloat scaleY = size.height / self.imageView.image.size.height;
    CGFloat scaleMin = scaleX < scaleY ? scaleX : scaleY;
    if (scaleMin>1.0f) scaleMin = 1.0f;
    CGFloat scaleMax = scaleMin * 2;
    if (scaleMax<1.0f) scaleMax = 1.0f;
    
    if (size.width<self.imageView.image.size.width) size.width = self.imageView.image.size.width;
    if (size.height<self.imageView.image.size.height) size.height = self.imageView.image.size.height;
    
    self.scrollView.contentSize = size;
    self.scrollView.minimumZoomScale = scaleMin;
    self.scrollView.maximumZoomScale = scaleMax;
    self.scrollView.zoomScale = scaleMin;
    
    [self scrollViewDidZoom:self.scrollView];
}

- (void)onTapBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end

