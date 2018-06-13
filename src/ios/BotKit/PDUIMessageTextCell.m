//
//  PDUIMessageTextCell.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/8.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIMessageTextCell.h"
#import "KILabel.h"

@implementation PDUIMessageTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        KILabel* label = [[KILabel alloc] initWithFrame:CGRectMake(8, 0, self.messageContentView.bounds.size.width-16, self.messageContentView.bounds.size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:16];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        label.linkDetectionTypes = KILinkTypeOptionURL;
        label.urlLinkTapHandler = ^(KILabel * _Nonnull label, NSString * _Nonnull string, NSRange range) {
            if ([self.delegate respondsToSelector:@selector(textCell:clickedUrl:)])
            [self.delegate textCell:self clickedUrl:string];
        };
        
        self.textMessageLabel = label;
        [self.messageContentView addSubview:self.textMessageLabel];
        
        UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)setMessageModel:(PDUIMessageModel*)model
{
    [super setMessageModel:model];
    
    PDMessageContentText* content = (PDMessageContentText*)model.content;
    if (![content isKindOfClass:[PDMessageContentText class]]) return;
    
    self.textMessageLabel.text = content.text;
}

+ (CGSize)contentSizeForMessage:(nonnull PDUIMessageModel*)model withMaxWidth:(CGFloat)maxWidth
{
    PDMessageContentText* content = (PDMessageContentText*)model.content;
    if (![content isKindOfClass:[PDMessageContentText class]]) return CGSizeZero;
    
    NSDictionary* attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:16] };
    CGSize size = [content.text boundingRectWithSize: CGSizeMake(maxWidth-16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    size.width = ceilf(size.width + 16);
    size.height = ceilf(size.height + 16);
    return size;
}

- (void)longPressGestureRecognized:(UIGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [self becomeFirstResponder];
        UIMenuController* menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect:self.textMessageLabel.bounds inView:self.textMessageLabel];
        [menuController setMenuVisible:YES animated:YES];
    }
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return true;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return action == @selector(copy:);
}

- (void)copy:(id)sender
{
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.textMessageLabel.text];
}
@end
