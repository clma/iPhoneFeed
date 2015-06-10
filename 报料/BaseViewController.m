//
//  BaseViewController.m
//  BreakingNews
//
//  Created by qianmenhui on 14-7-3.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import "BaseViewController.h"
#import "TaskEditViewController.h"
#import "TaskListViewController.h"
#import "TaskSetViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithImgArray:(NSMutableArray*)imgArray
{
    self = [super init];
    if (self) {
        //初始化各个页面
        TaskEditViewController *taskEdit = [[TaskEditViewController alloc] init];
        if (imgArray.count > 0) {
            [taskEdit.selectImgArray addObjectsFromArray:imgArray];
        }
        UITabBarItem *taskEditItem = [[UITabBarItem alloc] initWithTitle:@"报料" image:[UIImage imageNamed:@"bar1.png"] tag:6];
        taskEdit.tabBarItem = taskEditItem;
        UINavigationController *navTaskEdit = [[UINavigationController alloc] initWithRootViewController:taskEdit];
        //navTaskEdit.title = @"报料";
        
        TaskListViewController *taskList = [[TaskListViewController alloc] init];
        UITabBarItem *taskListItem = [[UITabBarItem alloc] initWithTitle:@"列表" image:[UIImage imageNamed:@"bar2.png"] tag:7];
        taskList.tabBarItem = taskListItem;
        UINavigationController *navTaskList = [[UINavigationController alloc] initWithRootViewController:taskList];
        //navTaskList.title = @"列表";
        
        TaskSetViewController *taskSet = [[TaskSetViewController alloc] init];
        UITabBarItem *taskSetItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:[UIImage imageNamed:@"bar3.png"] tag:8];
        taskSet.tabBarItem = taskSetItem;
        UINavigationController *navTaskSet = [[UINavigationController alloc] initWithRootViewController:taskSet];
        //navTaskSet.title = @"设置";
        
        NSArray *controllers = [NSArray arrayWithObjects:navTaskEdit, navTaskList, navTaskSet, nil];
        self.viewControllers = controllers;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
