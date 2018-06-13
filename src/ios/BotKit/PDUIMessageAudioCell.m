//
//  PDUIMessageAudioCell.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/17.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIMessageAudioCell.h"
#import "PDUITools.h"

@implementation PDUIMessageAudioCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.audioImageView = [[UIImageView alloc] initWithFrame:self.messageContentView.bounds];
        self.audioImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.audioImageView.contentMode = UIViewContentModeCenter;
        self.audioImageView.userInteractionEnabled = YES;
        [self.audioImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAudioTap)]];
        [self.messageContentView addSubview:self.audioImageView];
    }
    return self;
}

- (void)setMessageModel:(PDUIMessageModel*)model
{
    [super setMessageModel:model];
    
    if (model.direction==PDMessageDirectionRecv)
    {
        self.audioImageView.image = [PDUITools imageBundleNamed:@"message_audio_from"];
    }
    else
    {
        self.audioImageView.image = [PDUITools imageBundleNamed:@"message_audio_to"];
    }
}

+ (CGSize)contentSizeForMessage:(nonnull PDUIMessageModel*)model withMaxWidth:(CGFloat)maxWidth
{
    return CGSizeMake(80, 36);
}

- (void)onAudioTap
{
    PDMessageContentAudio* content = (PDMessageContentAudio*)self.model.content;
    if (![content isKindOfClass:[PDMessageContentAudio class]]) return;
    
    if ([self.delegate respondsToSelector:@selector(audioCell:clickedContent:)])
        [self.delegate audioCell:self clickedContent:content];
}

@end
