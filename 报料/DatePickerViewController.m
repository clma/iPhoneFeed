//
//  DatePickerViewController.m
//  BreakingNews
//
//  Created by qianmenhui on 14-7-7.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController ()

@end

@implementation DatePickerViewController

@synthesize delegate;
@synthesize datePicker;

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
    
    self.navigationItem.title = @"时间选择";
    
    UIBarButtonItem *itemOk = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(ItemBtnOk:)];
    self.navigationItem.rightBarButtonItem = itemOk;
    
    //创建日期选择器
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(1, self.navigationController.navigationBar.frame.size.height + 21, self.view.frame.size.width - 5, 0)];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.date = [NSDate date];
    [self.view addSubview:datePicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)viewWillAppear:(BOOL)animated
{
    //隐藏tabbar
    CGRect curRect = self.tabBarController.view.frame;
    self.tabBarController.view.frame = CGRectMake(curRect.origin.x, curRect.origin.y, curRect.size.width, curRect.size.height + 50);
}

- (void)viewWillDisappear:(BOOL)animated
{
    //退出时要把隐藏的tabbar显示出来
    CGRect curRect = self.tabBarController.view.frame;
    self.tabBarController.view.frame = CGRectMake(curRect.origin.x, curRect.origin.y, curRect.size.width, curRect.size.height - 50);
}

- (void)ItemBtnOk:(UIButton*)sender
{
    NSDate *date = datePicker.date;
    
    if ([self.delegate respondsToSelector:@selector(GetPickedDate:)]) {
        [self.delegate GetPickedDate:date];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
