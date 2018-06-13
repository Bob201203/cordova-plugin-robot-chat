//
//  HistoryViewController.m
//  PDBotDemo
//
//  Created by wuyifan on 2018/5/17.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryDataManager.h"

@interface HistoryViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray* historyDataList;

@end

@implementation HistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"历史记录";
    
    self.historyDataList = [[HistoryDataManager sharedHistoryDataManager] getHistoryDataList];
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)onCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

# pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historyDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    HistoryDataItem* item = [self.historyDataList objectAtIndex:indexPath.row];
    cell.textLabel.text = item.robotName;
    cell.detailTextLabel.text = item.accessKey;
    
    return cell;
}

# pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryDataItem* item = [self.historyDataList objectAtIndex:indexPath.row];
    [self.delegate historyViewController:self didSelectAccessKey:item.accessKey];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
