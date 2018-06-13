//
//  PDUIMessageImageCell.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/17.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIMessageImageCell.h"
#import "PDUITools.h"
#import "YFGIFImageView.h"

@implementation PDUIMessageImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.imageContentView = [[YFGIFImageView alloc] initWithFrame:self.messageContentView.bounds];
        self.imageContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageContentView.userInteractionEnabled = YES;
        [self.imageContentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageTap)]];
        [self.messageContentView addSubview:self.imageContentView];
    }
    return self;
}

- (void)setMessageModel:(PDUIMessageModel*)model
{
    [super setMessageModel:model];
    
    PDMessageContentImage* content = (PDMessageContentImage*)model.content;
    if (![content isKindOfClass:[PDMessageContentImage class]]) return;
    
    NSString* document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString* path = [document stringByAppendingPathComponent:content.dataPath];
    NSData* data = [NSData dataWithContentsOfFile:path];
    UIImage* image = [[UIImage alloc] initWithData:data];
    self.messageBubbleView.hidden =  YES;
   
    if (!image) image = [PDUITools imageBundleNamed:@"message_image_broken"];
   
    self.imageContentView.image = image;
    self.imageContentView.layer.cornerRadius = 8;
    self.imageContentView.layer.masksToBounds = YES;
    
    
    YFGIFImageView* imageView = (YFGIFImageView*)self.imageContentView;
    if ([YFGIFImageView isGIFData:data])
    {
        imageView.gifData = data;
        [imageView startGIF];
    }
    else
    {
        imageView.gifData = nil;
        if (imageView.isGIFPlaying) [imageView stopGIF];
    }
}

+ (CGSize)contentSizeForMessage:(nonnull PDUIMessageModel*)model withMaxWidth:(CGFloat)maxWidth
{
    PDMessageContentImage* content = (PDMessageContentImage*)model.content;
    if (![content isKindOfClass:[PDMessageContentImage class]]) return CGSizeZero;
    
    const CGFloat maxHeight = 256;
    
    NSString* document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString* path = [document stringByAppendingPathComponent:content.dataPath];
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
    if (!image) return CGSizeMake(84, 60);
    
    CGSize size = image.size;
    if (size.width>maxWidth || size.height>maxHeight)
    {
        CGFloat scaleX = maxWidth / image.size.width;
        CGFloat scaleY = maxHeight / image.size.height;
        CGFloat scale = scaleX<scaleY ? scaleX : scaleY;
        size.width *= scale;
        size.height *= scale;
    }
    
    return size;
}

- (void)onImageTap
{
    PDMessageContentImage* content = (PDMessageContentImage*)self.model.content;
    if (![content isKindOfClass:[PDMessageContentImage class]]) return;

    if ([self.delegate respondsToSelector:@selector(imageCell:clickedContent:)])
        [self.delegate imageCell:self clickedContent:content];
}
                                                     
@end
