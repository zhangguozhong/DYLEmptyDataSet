//
//  ViewController.m
//  DYLEmptyDataSet
//
//  Created by mannyi on 2017/7/18.
//  Copyright © 2017年 mannyi. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+DYLEmptyDataSet.h"
#import "DYLEmptyDataSetViewController.h"

@interface ViewController () <UITableViewDataSource, DYLEmptyDataSetSource, DYLEmptyDataSetDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"点击" style:UIBarButtonItemStylePlain target:self action:@selector(handleAction:)];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
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


- (void)handleAction:(UIButton *)sender
{
    DYLEmptyDataSetViewController *viewController = [[DYLEmptyDataSetViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (NSString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return @"暂时无记录";
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return NO;
}

@end
