//
//  SvrShowViewController.m
//  BreakingNews
//
//  Created by qianmenhui on 14-7-7.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import "SvrShowViewController.h"
#import "SvrSetViewController.h"

@interface SvrShowViewController ()

@end

@implementation SvrShowViewController

@synthesize svrTableView;
@synthesize delegate;
@synthesize targetContent;
@synthesize isSelSvr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        isSelSvr = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"服务器列表";
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //self.view.backgroundColor = [UIColor grayColor];
    
    UIBarButtonItem *itemBack = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(btnBack)];
    self.navigationItem.leftBarButtonItem = itemBack;
    
    UIBarButtonItem *itemAdd = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(svrAdd)];
    self.navigationItem.rightBarButtonItem = itemAdd;
    
    //服务器列表
    svrTableView = [[UITableView alloc] initWithFrame:CGRectMake(1, 1, self.view.bounds.size.width - 2, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    svrTableView.delegate = self;
    svrTableView.dataSource = self;
    [self.view addSubview:svrTableView];
    
    _svrArrayList = [[NSMutableArray alloc] initWithCapacity:0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arraySvrList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"SvrList"]];
    if (arraySvrList.count > 0)
        [_svrArrayList addObjectsFromArray:arraySvrList];
    
    _isFirstInit = YES;
    
    NSLog(@"viewDidLoad");
}

-(void)viewWillAppear:(BOOL)animated
{
    if (_isFirstInit) {
        _isFirstInit = NO;
    }
    else   //已经初始化过，不是第一次显示
    {
        //从属性列表中获取目标服务器列表
        [_svrArrayList removeAllObjects];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *arraySvrList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"SvrList"]];
        if (arraySvrList.count > 0)
            [_svrArrayList addObjectsFromArray:arraySvrList];
        
        [svrTableView reloadData];
    }
    
    //隐藏tabbar
    CGRect curRect = self.tabBarController.view.frame;
    self.tabBarController.view.frame = CGRectMake(curRect.origin.x, curRect.origin.y, curRect.size.width, curRect.size.height + 50);
}

-(void)viewWillDisappear:(BOOL)animated
{
    //退出时要把隐藏的tabbar显示出来
    CGRect curRect = self.tabBarController.view.frame;
    self.tabBarController.view.frame = CGRectMake(curRect.origin.x, curRect.origin.y, curRect.size.width, curRect.size.height - 50);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"svrShow didReceiveMemoryWarning");
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)btnBack
{
    if (delegate && [delegate respondsToSelector:@selector(refreshData:)]) {
        //把之前传进来的再传出去
        [delegate refreshData:targetContent];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)svrAdd
{
    SvrSetViewController *svrSet = [[SvrSetViewController alloc] init];
    svrSet.delegate = self;
    svrSet.isModify = NO;
    [self.navigationController pushViewController:svrSet animated:YES];
}

#pragma mark svrSet delegate

- (void)refreshList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arraySvrList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"SvrList"]];
//    if (_svrArrayList) {
//        [_svrArrayList removeAllObjects];
//        [_svrArrayList release];
//    }
//    _svrArrayList = [[NSMutableArray alloc] initWithCapacity:0];
    [_svrArrayList removeAllObjects];
    [_svrArrayList addObjectsFromArray:arraySvrList];
    [svrTableView reloadData];
    
    //NSLog(@"_svrArrayList:%@",_svrArrayList);
}


#pragma mark UITableview delegate

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _svrArrayList.count;
}

//是否分组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//是否可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//编辑模式，删除或插入或none
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSLog(@"svrShow,remove index:%ld",(long)indexPath.row);
        [_svrArrayList removeObjectAtIndex:indexPath.row];
        //保存一下
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_svrArrayList forKey:@"SvrList"];
        [defaults synchronize];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadData];
    }
}

//选中一个cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did sel indexPath section is %ld,row is %ld",(long)indexPath.section, (long)indexPath.row);
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    //把当前选择的传进去
    NSMutableDictionary *dicTemp = [_svrArrayList objectAtIndex:indexPath.row];
    NSString *svrKeyWord = [dicTemp objectForKey:@"svrKeyword"];
    
    if (isSelSvr && delegate && [delegate respondsToSelector:@selector(refreshData:)]) {
        [delegate refreshData:svrKeyWord];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    SvrSetViewController *svrSet = [[SvrSetViewController alloc] init];
    svrSet.delegate = self;
    svrSet.dicCurrent = dicTemp;
    svrSet.isModify = YES;
    [self.navigationController pushViewController:svrSet animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"SvrShow, reloadRow");
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSLog(@"SvrShow, reloadRow:%ld",(long)indexPath.row);
    return indexPath;
}


//绑定数据源
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell3";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSMutableDictionary *dicTemp = [_svrArrayList objectAtIndex:indexPath.row];
    NSString *CreateDate = [dicTemp objectForKey:@"createDate"];
    NSString *svrKeyWord = [dicTemp objectForKey:@"svrKeyword"];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (isSelSvr && [targetContent isEqualToString:svrKeyWord])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

    cell.textLabel.text = svrKeyWord;
    cell.detailTextLabel.text = CreateDate;
    
    NSLog(@"cell:%ld", (long)indexPath.row);
    
    return cell;
}




@end
