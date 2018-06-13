//
//  PDUIMessageRichTextCell.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/18.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIMessageRichTextCell.h"
#import "YFGIFImageView.h"

@implementation PDUIMessageRichTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.richCoverView = [[YFGIFImageView alloc] init];
        self.richCoverView.contentMode = UIViewContentModeScaleAspectFill;
        [self.messageContentView addSubview:self.richCoverView];
        
        self.richTitleLabel = [[UILabel alloc] init];
        self.richTitleLabel.textColor = [UIColor blackColor];
        self.richTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.richTitleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.richTitleLabel.numberOfLines = 0;
        self.richTitleLabel.lineBreakMode = NSLineBreakByClipping;
        [self.messageContentView addSubview:self.richTitleLabel];
        
        self.richDigestLabel = [[UILabel alloc] init];
        self.richDigestLabel.textColor = [UIColor grayColor];
        self.richDigestLabel.textAlignment = NSTextAlignmentLeft;
        self.richDigestLabel.font = [UIFont systemFontOfSize:14];
        self.richDigestLabel.numberOfLines = 0;
        self.richDigestLabel.lineBreakMode = NSLineBreakByClipping;
        [self.messageContentView addSubview:self.richDigestLabel];
        
        [self.messageContentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRichTap)]];
    }
    return self;
}

- (void)setMessageModel:(PDUIMessageModel*)model
{
    [super setMessageModel:model];
    
    self.messageBubbleView.hidden =  YES;
    
    PDMessageContentRichText* content = (PDMessageContentRichText*)model.content;
    if (![content isKindOfClass:[PDMessageContentRichText class]]) return;

    CGFloat width = self.messageContentView.bounds.size.width;
    CGFloat y = 0;
    
    NSString* document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString* path = [document stringByAppendingPathComponent:content.coverPath];
    NSData* data = [NSData dataWithContentsOfFile:path];
    UIImage* image = [[UIImage alloc] initWithData:data];
    CGFloat height = image ? width / image.size.width * image.size.height : 0;
    self.richCoverView.image = image;
    self.richCoverView.frame = CGRectMake(0, y, width, height);
    y += ceilf(height);
    
    self.richTitleLabel.text = content.title;
    height = [self.richTitleLabel sizeThatFits:CGSizeMake(width-16, MAXFLOAT)].height + 16;
    self.richTitleLabel.frame = CGRectMake(8, y, width-16, height);
    y += ceilf(height);
    
    self.richDigestLabel.text = content.digest;
    height = [self.richDigestLabel sizeThatFits:CGSizeMake(width-16, MAXFLOAT)].height;
    self.richDigestLabel.frame = CGRectMake(8, y, width-16, height);
    
    YFGIFImageView* richCoverView = (YFGIFImageView*)self.richCoverView;
    if ([YFGIFImageView isGIFData:data])
    {
        richCoverView.gifData = data;
        [richCoverView startGIF];
    }
    else
    {
        richCoverView.gifData = nil;
        if (richCoverView.isGIFPlaying) [richCoverView stopGIF];
    }
}

+ (CGSize)contentSizeForMessage:(nonnull PDUIMessageModel*)model withMaxWidth:(CGFloat)maxWidth
{
    PDMessageContentRichText* content = (PDMessageContentRichText*)model.content;
    if (![content isKindOfClass:[PDMessageContentRichText class]]) return CGSizeZero;

    if (maxWidth>320) maxWidth = 320;
    CGFloat height = 0;
    
    NSString* document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString* path = [document stringByAppendingPathComponent:content.coverPath];
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
    height += image ? maxWidth / image.size.width * image.size.height : 0;
    
    NSDictionary* attributesTitle = @{ NSFontAttributeName:[UIFont boldSystemFontOfSize:16] };
    height += [content.title boundingRectWithSize: CGSizeMake(maxWidth-16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesTitle context:nil].size.height;
    height += 10;
 
    NSDictionary* attributesDigest = @{ NSFontAttributeName:[UIFont systemFontOfSize:14] };
    height += [content.digest boundingRectWithSize: CGSizeMake(maxWidth-16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDigest context:nil].size.height;
    height += 10;

    height = ceilf(height);
    return CGSizeMake(maxWidth, height);
}

- (void)onRichTap
{
    PDMessageContentRichText* content = (PDMessageContentRichText*)self.model.content;
    if (![content isKindOfClass:[PDMessageContentRichText class]]) return;
    
    if ([self.delegate respondsToSelector:@selector(richTextCell:clickedContent:)])
        [self.delegate richTextCell:self clickedContent:content];
}

@end
