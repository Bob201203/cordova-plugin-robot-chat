//
//  PDUISuggestionPanel.m
//  FPBotDemo
//
//  Created by wuyifan on 2018/1/15.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUISuggestionPanel.h"

@interface PDUISuggestionPanel () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) NSArray* suggestionItemArray;

@end

@implementation PDUISuggestionPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self addSubview:self.tableView];
        
        self.hidden = YES;
    }
    return self;
}

- (void)setSuggestionArray:(NSArray*)array
{
    self.suggestionItemArray = array;
    [self.tableView reloadData];
    
    if (self.suggestionItemArray.count>0)
    {
        self.hidden = NO;
        CGRect frame = self.bounds;
        CGFloat topInsets = frame.size.height - 32 * self.suggestionItemArray.count;
        if (topInsets>0)
        {
            frame.origin.y += topInsets;
            frame.size.height -= topInsets;
        }
        self.tableView.frame = frame;
    }
    else
    {
        self.hidden = YES;
    }
}

# pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.suggestionItemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* Identifier = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.backgroundColor = [UIColor colorWithWhite:0.98f alpha:1.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    PDMenuItem* item = [self.suggestionItemArray objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[PDMenuItem class]])
    {
        cell.textLabel.text = item.content;
    }
    
    return cell;
}

# pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 32;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PDMenuItem* item = [self.suggestionItemArray objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[PDMenuItem class]])
    {
        if ([self.delegate respondsToSelector:@selector(suggestionPanel:clickedItem:)])
            [self.delegate suggestionPanel:self clickedItem:item];
    }
}

@end
