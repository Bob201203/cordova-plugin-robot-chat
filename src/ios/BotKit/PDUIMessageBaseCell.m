//
//  PDUIMessageBaseCell.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/8.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIMessageBaseCell.h"
#import "PDUITools.h"
#import "PDUIDateFormatter.h"

@implementation PDUIMessageBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.messageTimeLabel = [[UILabel alloc] init];
        self.messageTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.messageTimeLabel.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
        self.messageTimeLabel.textColor = [UIColor whiteColor];
        self.messageTimeLabel.font = [UIFont systemFontOfSize:12];
        self.messageTimeLabel.layer.cornerRadius = 4;
        self.messageTimeLabel.layer.masksToBounds = YES;
        [self addSubview:self.messageTimeLabel];
        
        self.portraitImageView = [[UIImageView alloc] init];
        self.bgPortraitImageView = [[UIImageView alloc] init];
        
        [self addSubview:self.bgPortraitImageView];
        [self addSubview:self.portraitImageView];
        
        
        self.messageBubbleView = [[UIImageView alloc] init];
        [self addSubview:self.messageBubbleView];
        
        self.messageContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
        [self addSubview:self.messageContentView];
    }
    return self;
}

- (void)setMessageModel:(PDUIMessageModel*)model
{
    self.model = model;
    
    if (model.isDisplayMessageTime) self.messageTimeLabel.text = [[PDUIDateFormatter sharedDateFormatter] timeStringFromDate:self.model.sendTime];
    self.messageTimeLabel.hidden = !model.isDisplayMessageTime;

    self.portraitImageView.image = self.model.portraitImage;
    
    CGFloat cornerRadius = self.portraitImageView.bounds.size.width * .5;
    self.portraitImageView.layer.masksToBounds = YES;
    self.portraitImageView.layer.cornerRadius = cornerRadius;
    
    self.bgPortraitImageView.layer.masksToBounds = YES;
    self.bgPortraitImageView.layer.cornerRadius = cornerRadius;
    
    if ( self.model.portraitBg) {
         self.bgPortraitImageView.image = self.model.portraitBg;
    }

    

    [self layoutCellViews];
}

- (void)layoutCellViews
{
    CGFloat y = 0;
    CGSize cellSize = self.model.cellSize;
    CGSize contentSize = self.model.contentSize;
    
    if (self.model.isDisplayMessageTime)
    {
        CGFloat width = [self.messageTimeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width + 16;
        self.messageTimeLabel.frame = CGRectMake((cellSize.width-width)/2, 20, width, 20);
        y += 44;
    }
    
    if (self.model.direction==PDMessageDirectionRecv)
    {
        self.messageBubbleView.backgroundColor = [UIColor  whiteColor];
        self.messageBubbleView.layer.cornerRadius = 8;
        self.messageBubbleView.layer.masksToBounds = YES;
        self.messageBubbleView.layer.borderWidth = 0.5f;
        self.messageBubbleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        self.bgPortraitImageView.frame = CGRectMake(10, y+10, 34, 34);
        self.portraitImageView.frame = CGRectMake(10, y+10, 34, 34);
        self.messageBubbleView.frame = CGRectMake(48, y+10, contentSize.width+14, contentSize.height+8);
        self.messageContentView.frame = CGRectMake(48+10, y+14, contentSize.width, contentSize.height);
    }
    else
    {
        self.messageBubbleView.backgroundColor = [UIColor  colorWithRed:0 green:188.f/255 blue:1 alpha:1];
        self.messageBubbleView.layer.cornerRadius = 8;
        self.messageBubbleView.layer.masksToBounds = YES;

        self.bgPortraitImageView.frame = CGRectMake(cellSize.width-10-34, y+10, 34, 34);
        self.portraitImageView.frame = CGRectMake(cellSize.width-10-34, y+10, 34, 34);
        self.messageBubbleView.frame = CGRectMake(cellSize.width-48-(contentSize.width+14), y+10, contentSize.width+14, contentSize.height+8);
        self.messageContentView.frame = CGRectMake(cellSize.width-48-(contentSize.width+11), y+14, contentSize.width, contentSize.height);
    }
}

+ (void)setCellSizeForMessage:(nonnull PDUIMessageModel*)model withMaxWidth:(CGFloat)maxWidth;
{
    CGSize size = [self contentSizeForMessage:model withMaxWidth:maxWidth-120];
    model.contentSize = size;
    
    if (size.height<44) size.height = 44;
    if (model.isDisplayMessageTime) size.height += 44;
    size.width = maxWidth;
    size.height += 20 + 8;
    model.cellSize = size;
}

+ (CGSize)contentSizeForMessage:(PDUIMessageModel* _Nonnull)model withMaxWidth:(CGFloat)maxWidth;
{
    return CGSizeZero;
}

@end
