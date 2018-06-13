//
//  PDUIMessageMenuCell.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/17.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIMessageMenuCell.h"
#import "PDUITools.h"

@implementation PDUIMessageMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.messageBubbleView.hidden = YES;
        
        self.menuBackView = [[UIImageView alloc] initWithFrame:self.messageContentView.bounds];
        self.menuBackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.menuBackView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
        self.menuBackView.userInteractionEnabled = YES;
        self.menuBackView.layer.cornerRadius = 4;
        self.menuBackView.layer.masksToBounds = YES;
        self.menuBackView.layer.borderColor = self.menuBackView.backgroundColor.CGColor;
        self.menuBackView.layer.borderWidth = 1.0f;
        [self.messageContentView addSubview:self.menuBackView];
        
        self.menuHead = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.menuBackView.bounds.size.width, 22)];
        self.menuHead.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.menuHead.backgroundColor = [UIColor colorWithWhite:0.94f alpha:1.0f];
        self.menuHead.textColor = [UIColor grayColor];
        self.menuHead.font = [UIFont systemFontOfSize:12];
        self.menuHead.textAlignment = NSTextAlignmentCenter;
        self.menuHead.layer.borderColor = self.menuBackView.backgroundColor.CGColor;
        self.menuHead.layer.borderWidth = 0.5f;
        [self.menuBackView addSubview:self.menuHead];
                
        self.menuItemsList = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return self;
}

- (void)setMessageModel:(PDUIMessageModel*)model
{
    [super setMessageModel:model];
    
    PDMessageContentMenu* content = (PDMessageContentMenu*)model.content;
    if (![content isKindOfClass:[PDMessageContentMenu class]]) return;
    
    self.menuHead.text = PDLocalString(content.menuType==PDMessageMenuTypeMenu?@"MessageMenu":@"MessageRecommend");
    
    NSUInteger count = content.menuItems.count;
    while (self.menuItemsList.count>count)
    {
        [self.menuItemsList.lastObject removeFromSuperview];
        [self.menuItemsList removeLastObject];
    }
    while (self.menuItemsList.count<count)
    {
        NSInteger idx = self.menuItemsList.count;
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, idx*44+22, self.menuBackView.bounds.size.width, 44)];
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        button.tag = idx;
        button.backgroundColor = [UIColor whiteColor];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.layer.borderColor = self.menuBackView.backgroundColor.CGColor;
        button.layer.borderWidth = 0.5f;
   
        UIColor *norColor =  [UIColor  colorWithRed:1.f/255 green:71.f/255 blue:96.0f/255 alpha:1.0];
        [button setTitleColor:norColor forState:UIControlStateNormal];
 
        UIColor *higColor = [UIColor colorWithRed:94.f/255 green:108.f/255 blue:115.f/255 alpha:1.0];
        [button setTitleColor:higColor forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(onItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuBackView addSubview:button];
        [self.menuItemsList addObject:button];
    }
    
    for (NSUInteger i=0; i<count; i++)
    {
        PDMenuItem* item = [content.menuItems objectAtIndex:i];
        UIButton* button = [self.menuItemsList objectAtIndex:i];
        [button setTitle:item.content forState:UIControlStateNormal];
    }
}

+ (CGSize)contentSizeForMessage:(nonnull PDUIMessageModel*)model withMaxWidth:(CGFloat)maxWidth
{
    PDMessageContentMenu* content = (PDMessageContentMenu*)model.content;
    if (![content isKindOfClass:[PDMessageContentMenu class]]) return CGSizeZero;
    
    CGFloat width = 0;
    NSDictionary* attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:16] };
    for (PDMenuItem* item in content.menuItems)
    {
        CGFloat w = [item.content sizeWithAttributes:attributes].width;
        if (width<w) width = w;
    }
    
    CGFloat minWidth = content.menuType==PDMessageMenuTypeMenu ? 80 : 160;
    width = ceilf(width + 44);
    if (width<minWidth) width = minWidth;
    if (width>maxWidth) width = maxWidth;

    return CGSizeMake(width, content.menuItems.count*44.0f+22.0f);
}

- (void)onItemClick:(id)sender
{
    UIButton* button = (UIButton*)sender;
    if ([button isKindOfClass:[UIButton class]])
    {
        PDMessageContentMenu* content = (PDMessageContentMenu*)self.model.content;
        if ([content isKindOfClass:[PDMessageContentMenu class]])
        {
            if (content.menuItems.count>button.tag)
            {
                PDMenuItem* item = [content.menuItems objectAtIndex:button.tag];
                if ([self.delegate respondsToSelector:@selector(menuCell:clickedItem:withType:)])
                    [self.delegate menuCell:self clickedItem:item withType:content.menuType];
            }
        }
    }
}

@end
