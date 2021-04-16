//
//  JokeViewController.m
//  Rookieme
//
//  Created by Rookieme on 2019/1/2.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "JokeViewController.h"
#import "JokeService.h"
#import "JokeModel.h"
#import "JokeTableViewCell.h"
@interface JokeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, assign) NSInteger contPage;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@end

@implementation JokeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatList];
}

- (void)creatList {
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) style:UITableViewStylePlain];
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    [self.view addSubview:_listTableView];
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_listTableView registerClass:[JokeTableViewCell class] forCellReuseIdentifier:@"JokeTableViewCell"];
    [_listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    _listTableView.backgroundColor = [UIColor whiteColor];
    __weak __typeof(self)weakSelf = self;
    _listTableView.showsVerticalScrollIndicator = NO;
    _listTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getDataWithPage:weakSelf.contPage + 1];
    }];
    
    _listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getDataWithPage:1];
    }];
    
    [_listTableView.mj_header beginRefreshing];
}

- (void)getDataWithPage:(NSInteger)page {
    _contPage = page;
    if (_contPage == 1) {
        _timeInterval = 0;
        _dataArray = [NSArray new];
    }
    
    if (!_timeInterval) {
        _timeInterval = [[NSDate date] timeIntervalSince1970];
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [JokeService getJokeListIsBefore:YES time:_timeInterval page:_contPage pagesize:20 CompletionInfo:^(NSInteger state, NSDictionary * _Nonnull infoDic) {
        if (state == 0) {
            NSArray *data = infoDic[@"result"][@"data"];
            if (data && data.count > 0) {
                NSMutableArray *tempArray = [NSMutableArray new];
                for (NSDictionary *dict in data) {
                    [tempArray addObject:[JokeModel yy_modelWithDictionary:dict]];
                }
                NSMutableArray *tempDataArray = [NSMutableArray arrayWithArray:weakSelf.dataArray];
                [tempDataArray addObjectsFromArray:tempArray];
                weakSelf.dataArray = tempDataArray;
                [weakSelf.listTableView reloadData];
            }
        }
        [weakSelf.listTableView.mj_header endRefreshing];
        [weakSelf.listTableView.mj_footer endRefreshing];
    }];
}

#pragma mark -
#pragma mark - UITableViewDelegate
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

        JokeModel *infoModel = _dataArray[indexPath.row];
    
        return [tableView fd_heightForCellWithIdentifier:@"JokeTableViewCell" cacheByKey:infoModel.hashId configuration:^(JokeTableViewCell *cell) {
            cell.model = infoModel;
        }];
   
}


#pragma mark -
#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JokeModel *infoModel = _dataArray[indexPath.row];
    
    
    JokeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JokeTableViewCell"];
    if (!cell)
    {
        cell = [[JokeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JokeTableViewCell"];;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.model = infoModel;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
