//
//  PDUIPluginPanel.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/15.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIPluginPanel.h"

@interface PDUIPluginPanel ()

@property (strong, nonatomic) NSMutableArray* itemLabelList;
@property (strong, nonatomic) NSMutableArray* itemButtonList;

@end

@implementation PDUIPluginPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.itemLabelList = [NSMutableArray arrayWithCapacity:8];
        self.itemButtonList = [NSMutableArray arrayWithCapacity:8];
    }
    return self;
}

- (void)insertItemWithImage:(UIImage*)image title:(NSString*)title atIndex:(NSUInteger)index tag:(NSInteger)tag
{
    if (index>self.itemButtonList.count) index = self.itemButtonList.count;
    
    UIButton* button = [[UIButton alloc] init];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    button.tag = tag;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    UILabel* label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [self addSubview:label];
    
    [self.itemLabelList insertObject:label atIndex:index];
    [self.itemButtonList insertObject:button atIndex:index];
    
    [self layoutItemViews];
}

- (void)insertItemWithImage:(UIImage*)image title:(NSString*)title tag:(NSInteger)tag
{
    [self insertItemWithImage:image title:title atIndex:self.itemButtonList.count tag:tag];
}

- (void)updateItemAtIndex:(NSUInteger)index image:(UIImage*)image title:(NSString*)title
{
    if (index>=self.itemButtonList.count) return;

    UIButton* button = [self.itemButtonList objectAtIndex:index];
    [button setImage:image forState:UIControlStateNormal];
    
    UILabel* label = [self.itemLabelList objectAtIndex:index];
    label.text = title;
}

- (void)updateItemWithTag:(NSInteger)tag image:(UIImage*)image title:(NSString*)title
{
    NSUInteger index = [self findItemWithTag:tag];
    [self updateItemAtIndex:index image:image title:title];
}

- (void)removeItemAtIndex:(NSUInteger)index
{
    if (index>=self.itemButtonList.count) return;
    
    [[self.itemLabelList objectAtIndex:index] removeFromSuperview];
    [[self.itemButtonList objectAtIndex:index] removeFromSuperview];

    [self.itemLabelList removeObjectAtIndex:index];
    [self.itemButtonList removeObjectAtIndex:index];
    
    [self layoutItemViews];
}

- (void)removeItemWithTag:(NSInteger)tag
{
    NSUInteger index = [self findItemWithTag:tag];
    [self removeItemAtIndex:index];
}

- (void)removeAllItems
{
    for (UILabel* label in self.itemLabelList) [label removeFromSuperview];
    for (UIButton* label in self.itemButtonList) [label removeFromSuperview];
    
    [self.itemLabelList removeAllObjects];
    [self.itemButtonList removeAllObjects];
    
    [self layoutItemViews];
}
                      
- (NSUInteger)findItemWithTag:(NSInteger)tag
{
    NSUInteger count = self.itemButtonList.count;
    NSUInteger index = count;
    for (NSUInteger i=0;i<count;i++)
    {
        UIButton* button = [self.itemButtonList objectAtIndex:i];
        if (button.tag==tag)
        {
            index = tag;
            break;
        }
    }
    return index;
}

- (void)layoutItemViews
{
    CGFloat x = 0;
    CGFloat y = 0;
    NSUInteger count = self.itemButtonList.count;
    for (NSUInteger i=0;i<count;i++)
    {
        UIButton* button = [self.itemButtonList objectAtIndex:i];
        UILabel* label = [self.itemLabelList objectAtIndex:i];

        button.frame = CGRectMake(x+30, y+20, 60, 60);
        label.frame = CGRectMake(x+30, y+80, 60, 30);
        
        x += 90;
        if (i+90>self.frame.size.width)
        {
            x = 0;
            y += 120;
        }
    }
}

- (void)onItemClicked:(id)sender
{
    if (![sender isKindOfClass:[UIButton class]]) return;
    UIButton* button = (UIButton*)sender;
    if ([self.delegate respondsToSelector:@selector(pluginPanel:clickedItemWithTag:)])
        [self.delegate pluginPanel:self clickedItemWithTag:button.tag];
}

@end
