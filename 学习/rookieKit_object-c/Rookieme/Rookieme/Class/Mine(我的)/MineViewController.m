//
//  MineViewController.m
//  Rookieme
//
//  Created by Rookieme on 2019/1/3.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "MineViewController.h"
#import "MovieTicketController.h"
#import "MovieTicketService.h"
@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) UITableView *listTableView;
@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = @[@"猫眼电影"];
    [self creatList];
    // Do any additional setup after loading the view.
}

- (void)creatList {
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) style:UITableViewStylePlain];
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    [self.view addSubview:_listTableView];
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    _listTableView.backgroundColor = [UIColor whiteColor];
    _listTableView.showsVerticalScrollIndicator = NO;
   
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
    
    return 44.f;
    
}


#pragma mark -
#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    QMUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MineTableViewCell"];
    if (!cell)
    {
        cell = [[QMUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MineTableViewCell"];;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = _dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self getUrl];
}

- (void)getUrl {
    __weak __typeof(self)weakSelf = self;
    QMUITips *tips = [QMUITips showLoadingInView:self.view];
    [MovieTicketService getMovieTicketCompletionInfo:^(NSInteger state, NSDictionary * _Nonnull infoDic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [tips hideAnimated:YES];
        });
        if (state == 0) {
            //            self.originalUrlString = ;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf addMovieWithtUrl:infoDic[@"result"][@"h5url"]];
            });
            
            
        }
    }];
}

- (void)addMovieWithtUrl:(NSString *)urlString {
    MovieTicketController *controller1 = [[MovieTicketController alloc] initWithUrl:urlString linkType:YUrlLinkTypeOuterchain];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:controller1 animated:YES completion:^{
        
    }];
    
    
    
}

@end
