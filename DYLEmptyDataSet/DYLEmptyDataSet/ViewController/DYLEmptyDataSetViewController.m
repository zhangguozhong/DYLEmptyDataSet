//
//  DYLEmptyDataSetViewController.m
//  DYLEmptyDataSet
//
//  Created by mannyi on 2017/7/18.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "DYLEmptyDataSetViewController.h"
#import "UIScrollView+DYLEmptyDataSet.h"
#import "DYLCustomView.h"

@interface DYLEmptyDataSetViewController () <UITableViewDataSource, DYLEmptyDataSetDelegate, DYLEmptyDataSetSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation DYLEmptyDataSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = @"有钱";
    return cell;
}


- (NSString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    return @"暂时无记录";
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return NO;
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    DYLCustomView *customView = [[DYLCustomView alloc] init];
    return customView;
}

@end
