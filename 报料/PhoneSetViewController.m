//
//  PhoneSetViewController.m
//  BreakingNews
//
//  Created by qianmenhui on 14-7-7.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "PhoneSetViewController.h"

@interface PhoneSetViewController ()

@end

@implementation PhoneSetViewController

@synthesize delegate;

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
    
    self.navigationItem.title = @"本机号码设置";
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //self.view.backgroundColor = [UIColor lightGrayColor];
    
    //创建保存按钮
    UIBarButtonItem *itemSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(phoneSave)];
    self.navigationItem.rightBarButtonItem = itemSave;
    
    //创建电话号码输入框
    _textPhone = [[UITextField alloc] initWithFrame:CGRectMake(10, self.navigationController.navigationBar.frame.size.height + 31, self.view.frame.size.width - 20, 35)];
    _textPhone.backgroundColor = [UIColor whiteColor];
    _textPhone.layer.cornerRadius = 5.0f;
    _textPhone.placeholder = @"请输入您的手机号码";
    _textPhone.layer.borderWidth = 1.0f;
    _textPhone.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:_textPhone];
    
    //提示信息
    _labelContent = [[UILabel alloc] initWithFrame:CGRectMake(10, _textPhone.frame.origin.y + _textPhone.frame.size.height + 1, self.view.frame.size.width - 20, 60)];
    _labelContent.textColor = [UIColor grayColor];
    _labelContent.text = @"此处设置的手机号码在发送报料信息时需要，以便接收报料信息方能联系到您，确认信息的准确度等等.";
    _labelContent.font = [UIFont systemFontOfSize:14];
    _labelContent.numberOfLines = 4;
    [self.view addSubview:_labelContent];
    
    [self setUpForDismissKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    //隐藏tabbar
    CGRect curRect = self.tabBarController.view.frame;
    self.tabBarController.view.frame = CGRectMake(curRect.origin.x, curRect.origin.y, curRect.size.width, curRect.size.height + 50);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phoneNum = [defaults valueForKey:@"phoneNum"];
    if (phoneNum)
        _textPhone.text = phoneNum;
}

- (void)viewWillDisappear:(BOOL)animated
{
    //退出时要把隐藏的tabbar显示出来
    CGRect curRect = self.tabBarController.view.frame;
    self.tabBarController.view.frame = CGRectMake(curRect.origin.x, curRect.origin.y, curRect.size.width, curRect.size.height - 50);
}

- (void)setUpForDismissKeyboard
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer *singleTapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAnywhereToDismissKeyboard:)];
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [nc addObserverForName:UIKeyboardWillShowNotification object:nil queue:mainQueue usingBlock:^(NSNotification *note) {
        [self.navigationController.view addGestureRecognizer:singleTapGr];
        NSLog(@"add tapsingle!");
    }];
    
    [nc addObserverForName:UIKeyboardWillHideNotification object:nil queue:mainQueue usingBlock:^(NSNotification *note) {
        [self.navigationController.view removeGestureRecognizer:singleTapGr];
        NSLog(@"remove singtap!");
    }];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    [self.navigationController.view endEditing:YES];
    
    NSLog(@"endEditing!");
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

//- (void)btnBack
//{
//    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
//
//}

//保存编辑框中的电话号码
- (void)phoneSave
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phoneNum = _textPhone.text;
    if (phoneNum == nil) {
        phoneNum = @"";
    }
    
    [defaults setObject:phoneNum forKey:@"phoneNum"];
    [defaults synchronize];
    
    if (delegate && [delegate respondsToSelector:@selector(getPhoneNumber:)]) {
        [delegate getPhoneNumber:phoneNum];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}




@end
