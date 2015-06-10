//
//  TaskSetViewController.m
//  BreakingNews
//
//  Created by qianmenhui on 14-7-3.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "TaskSetViewController.h"
#import "SvrShowViewController.h"
#import "PhoneSetViewController.h"

@interface TaskSetViewController ()

@end

@implementation TaskSetViewController

@synthesize taskTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.title = @"设置";
    //self.view.backgroundColor = [UIColor lightGrayColor];
    
    taskTableView = [[UITableView alloc] initWithFrame:CGRectMake(1, 1, self.view.frame.size.width - 2, self.view.frame.size.height - 1) style:UITableViewStyleGrouped];
    taskTableView.delegate = self;
    taskTableView.dataSource = self;
    [self.view addSubview:taskTableView];
    
    isInitFirst = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPhoneNumber:(NSString*)phoneNumber
{
//    [taskTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].detailTextLabel.text = phoneNumber;
    [taskTableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if (!isInitFirst) {
        [taskTableView reloadData];
    }
    isInitFirst = NO;
    NSLog(@"TaskSetViewController:viewWillAppear");
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"TaskSetViewController:viewDidAppear");
}

#pragma mark SvrShow delegate

- (void)refreshData:(NSString*)svrKeyword
{
    [taskTableView reloadData];

}

#pragma mark UITableview delegate

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

//是否分组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//是否可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

//编辑模式，删除或插入或none
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

//选中一个cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {      //显示服务器列表
        SvrShowViewController *svrShow = [[SvrShowViewController alloc] init];
        svrShow.delegate = self;
        [self.navigationController pushViewController:svrShow animated:YES];
    }
    else if (indexPath.row == 1)    //显示电话号码设置
    {
        PhoneSetViewController *phoneSet = [[PhoneSetViewController alloc] init];
        phoneSet.delegate = self;
        [self.navigationController pushViewController:phoneSet animated:YES];
    }
}

//绑定数据源
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell4";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"发送目标";
        
        NSMutableArray *arraySvrList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"SvrList"]];
        if (arraySvrList.count > 0)
            cell.detailTextLabel.text = [NSString stringWithFormat:@"共%lu条", (unsigned long)arraySvrList.count];
        else
            cell.detailTextLabel.text = @"未设置";
        
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"本机号码";
        
        NSString *phoneNum = [defaults objectForKey:@"phoneNum"];
        if (!phoneNum || [phoneNum isEqualToString:@""])
            cell.detailTextLabel.text = @"未设置";
        else
            cell.detailTextLabel.text = phoneNum;
    }
    NSLog(@"taskSet, cell init!");
    
    return cell;
}



@end
