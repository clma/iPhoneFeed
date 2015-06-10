//
//  SvrSetViewController.m
//  BreakingNews
//
//  Created by qianmenhui on 14-7-7.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SvrSetViewController.h"
#import "TaskCustomCell.h"

@interface SvrSetViewController ()

@end

@implementation SvrSetViewController

@synthesize delegate;
@synthesize dicCurrent;
@synthesize isModify;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dicCurrent = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //创建保存按钮
    UIBarButtonItem *itemSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(svrSave)];
    self.navigationItem.rightBarButtonItem = itemSave;
    
//    //创建服务器名称编辑框
//    _textSvrName = [[UITextField alloc] initWithFrame:CGRectMake(2, self.navigationController.navigationBar.frame.size.height + 26, self.view.bounds.size.width - 4, 30)];
//    _textSvrName.borderStyle = UITextBorderStyleRoundedRect;
//    _textSvrName.backgroundColor = [UIColor whiteColor];
//    _textSvrName.placeholder = @"服务器关键字,如:中央台焦点访谈,必填";
//    _textSvrName.font = [UIFont systemFontOfSize:14];
//    _textSvrName.delegate = self;
//    _textSvrName.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    [self.view addSubview:_textSvrName];
//    
//    //服务器地址
//    _textAddr = [[UITextField alloc] initWithFrame:CGRectMake( 2, _textSvrName.frame.origin.y + _textSvrName.frame.size.height + 8, self.view.bounds.size.width - 4, 30)];
//    _textAddr.borderStyle = UITextBorderStyleRoundedRect;
//    _textAddr.backgroundColor = [UIColor whiteColor];
//    _textAddr.placeholder = @"服务器地址,必填";
//    _textAddr.font = [UIFont systemFontOfSize:14];
//    _textAddr.delegate = self;
//    _textAddr.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    [self.view addSubview:_textAddr];
//    
//    //端口
//    _textPort = [[UITextField alloc] initWithFrame:CGRectMake( 2, _textAddr.frame.origin.y + _textAddr.frame.size.height + 8, self.view.bounds.size.width - 4, 30)];
//    _textPort.borderStyle = UITextBorderStyleRoundedRect;
//    _textPort.backgroundColor = [UIColor whiteColor];
//    _textPort.placeholder = @"端口号，默认为21,可不填";
//    _textPort.delegate = self;
//    _textPort.font = [UIFont systemFontOfSize:14];
//    [self.view addSubview:_textPort];
//    
//    //用户名
//    _textUser = [[UITextField alloc] initWithFrame:CGRectMake( 2, _textPort.frame.origin.y + _textPort.frame.size.height + 8, (self.view.bounds.size.width - 6)/2, 30)];
//    _textUser.borderStyle = UITextBorderStyleRoundedRect;
//    _textUser.backgroundColor = [UIColor whiteColor];
//    _textUser.placeholder = @"用户名，必填";
//    _textUser.font = [UIFont systemFontOfSize:14];
//    _textUser.delegate = self;
//    _textUser.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    [self.view addSubview:_textUser];
//    
//    //密码
//    _textPwd = [[UITextField alloc] initWithFrame:CGRectMake( _textUser.frame.origin.x + _textUser.frame.size.width + 2, _textPort.frame.origin.y + _textPort.frame.size.height + 8, (self.view.bounds.size.width - 6)/2, 30)];
//    _textPwd.borderStyle = UITextBorderStyleRoundedRect;
//    _textPwd.backgroundColor = [UIColor whiteColor];
//    _textPwd.placeholder = @"密码";
//    _textPwd.font = [UIFont systemFontOfSize:14];
//    _textPwd.delegate = self;
//    _textPwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    [self.view addSubview:_textPwd];
    
    _svrListSetTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _svrListSetTable.delegate = self;
    _svrListSetTable.dataSource = self;
    [self.view addSubview:_svrListSetTable];
    
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
}

-(void)viewWillDisappear:(BOOL)animated
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
        
        _svrListSetTable.frame = CGRectMake(0, -54, self.view.frame.size.width, self.view.frame.size.height + 54);
    }];
    
    [nc addObserverForName:UIKeyboardWillHideNotification object:nil queue:mainQueue usingBlock:^(NSNotification *note) {
        [self.navigationController.view removeGestureRecognizer:singleTapGr];
    }];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    _svrListSetTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self.navigationController.view endEditing:YES];
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

//保存当前所输入的服务器信息
- (void)svrSave
{
    TaskCustomCell *cellSvrKeyword = (TaskCustomCell*)[_svrListSetTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    TaskCustomCell *cellSvrAddr = (TaskCustomCell*)[_svrListSetTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    TaskCustomCell *cellSvrPort = (TaskCustomCell*)[_svrListSetTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    TaskCustomCell *cellSvrUsrName = (TaskCustomCell*)[_svrListSetTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    TaskCustomCell *cellSvrPwd = (TaskCustomCell*)[_svrListSetTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    
    NSString *svrKeyword = cellSvrKeyword.textSvrInfo.text;
    NSString *svrAddress = cellSvrAddr.textSvrInfo.text;
    NSString *svrPort = cellSvrPort.textSvrInfo.text;
    NSString *svrUserName = cellSvrUsrName.textSvrInfo.text;
    NSString *svrPwd = cellSvrPwd.textSvrInfo.text;
    
    //判断必填项，没有填的用红色框标示
    if (svrKeyword == nil || [svrKeyword isEqualToString:@""])
    {
        cellSvrKeyword.textSvrInfo.layer.borderWidth = 3.0;
        cellSvrKeyword.textSvrInfo.layer.borderColor = [UIColor redColor].CGColor;
        return;
    }
    
    if (svrAddress == nil || [svrAddress isEqualToString:@""])
    {
        cellSvrKeyword.textSvrInfo.layer.borderWidth = 0;
        cellSvrAddr.textSvrInfo.layer.borderWidth = 3.0;
        cellSvrAddr.textSvrInfo.layer.borderColor = [UIColor redColor].CGColor;
        return;
    }
    
    if (svrUserName == nil || [svrUserName isEqualToString:@""])
    {
        cellSvrKeyword.textSvrInfo.layer.borderWidth = 0;
        cellSvrAddr.textSvrInfo.layer.borderWidth = 0;
        cellSvrUsrName.textSvrInfo.layer.borderWidth = 3.0;
        cellSvrUsrName.textSvrInfo.layer.borderColor = [UIColor redColor].CGColor;
        return;
    }
    
    if (svrPort == nil || [svrPort isEqualToString:@""])
    {
        svrPort = @"21";
    }

    //判断是否有相同的目标服务器，主要判断服务器关键字，相同就弹框提示是否替换
    BOOL isSvrExist = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arraySvrList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"SvrList"]];
    for (int i=0; i<arraySvrList.count; i++) {
        NSMutableDictionary *dicTemp = [arraySvrList objectAtIndex:i];
        NSString *svrKeywordTemp = [dicTemp objectForKey:@"svrKeyword"];
        if ([svrKeyword isEqualToString:svrKeywordTemp]) {
            isSvrExist = YES;
            break;
        }
    }
    
    if (isModify) {
        NSDateFormatter *formatDate = [[NSDateFormatter alloc] init];
        [formatDate setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
        NSString *createDate = [formatDate stringFromDate:[NSDate date]];
        
        //把信息存在字典中
        NSMutableDictionary *dicSvr = [[NSMutableDictionary alloc] init];
        [dicSvr setObject:svrKeyword forKey:@"svrKeyword"];
        [dicSvr setObject:svrAddress forKey:@"svrAddress"];
        [dicSvr setObject:svrPort forKey:@"svrPort"];
        [dicSvr setObject:svrUserName forKey:@"svrUserName"];
        if (svrPwd == nil) {
            svrPwd = @"";
        }
        [dicSvr setObject:svrPwd forKey:@"svrPwd"];
        [dicSvr setObject:createDate forKey:@"createDate"];
        
        NSString *modifyKeyword = [dicCurrent valueForKey:@"svrKeyword"];
        for (int j=0; j<arraySvrList.count; j++) {
            NSMutableDictionary *dicTemp = [arraySvrList objectAtIndex:j];
            NSString *svrKeywordTemp = [dicTemp objectForKey:@"svrKeyword"];
            if ([modifyKeyword isEqualToString:svrKeywordTemp]) {
                
                [arraySvrList removeObjectAtIndex:j];
                break;
            }
        }
        
        [arraySvrList addObject:dicSvr];
        [defaults setObject:arraySvrList forKey:@"SvrList"];
        [defaults synchronize];
        
        if (delegate && [delegate respondsToSelector:@selector(refreshList)]) {
            [delegate refreshList];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (isSvrExist) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该服务器已经存在，是否替换？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"替换", nil];
        [alert show];
        return;
    }
    
    //写入属性列表，新加了创建时间
    NSDateFormatter *formatDate = [[NSDateFormatter alloc] init];
    [formatDate setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *createDate = [formatDate stringFromDate:[NSDate date]];
    
    //把信息存在字典中
    NSMutableDictionary *dicSvr = [[NSMutableDictionary alloc] init];
    [dicSvr setObject:svrKeyword forKey:@"svrKeyword"];
    [dicSvr setObject:svrAddress forKey:@"svrAddress"];
    [dicSvr setObject:svrPort forKey:@"svrPort"];
    [dicSvr setObject:svrUserName forKey:@"svrUserName"];
    if (!svrPwd)
        [dicSvr setObject:@"" forKey:@"svrPwd"];
    else
        [dicSvr setObject:svrPwd forKey:@"svrPwd"];
    [dicSvr setObject:createDate forKey:@"createDate"];
    
    [arraySvrList addObject:dicSvr];
    [defaults setObject:arraySvrList forKey:@"SvrList"];
    [defaults synchronize];

    if (delegate && [delegate respondsToSelector:@selector(refreshList)]) {
        [delegate refreshList];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    
    NSLog(@"svrSet,begin edit!");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text != nil) {
        textField.layer.borderWidth = 0;
    }
    
    NSLog(@"svrSet,end edit!");
}


#pragma mark UIAlertView Delegate
//如果服务器已经存在，是否替换
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) //替换
    {
        //替换相同的目标服务器
        TaskCustomCell *cellSvrKeyword = (TaskCustomCell*)[_svrListSetTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        TaskCustomCell *cellSvrAddr = (TaskCustomCell*)[_svrListSetTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        TaskCustomCell *cellSvrPort = (TaskCustomCell*)[_svrListSetTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        TaskCustomCell *cellSvrUsrName = (TaskCustomCell*)[_svrListSetTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        TaskCustomCell *cellSvrPwd = (TaskCustomCell*)[_svrListSetTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        
        NSString *svrKeyword = cellSvrKeyword.textSvrInfo.text;
        NSString *svrAddress = cellSvrAddr.textSvrInfo.text;
        NSString *svrPort = cellSvrPort.textSvrInfo.text;
        NSString *svrUserName = cellSvrUsrName.textSvrInfo.text;
        NSString *svrPwd = cellSvrPwd.textSvrInfo.text;
        
        if (svrPort == nil || [svrPort isEqualToString:@""]) {
            svrPort = @"21";
        }
        
        NSDateFormatter *formatDate = [[NSDateFormatter alloc] init];
        [formatDate setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
        NSString *createDate = [formatDate stringFromDate:[NSDate date]];
        
        //把信息存在字典中
        NSMutableDictionary *dicSvr = [[NSMutableDictionary alloc] init];
        [dicSvr setObject:svrKeyword forKey:@"svrKeyword"];
        [dicSvr setObject:svrAddress forKey:@"svrAddress"];
        [dicSvr setObject:svrPort forKey:@"svrPort"];
        [dicSvr setObject:svrUserName forKey:@"svrUserName"];
        if (svrPwd == nil) {
            svrPwd = @"";
        }
        [dicSvr setObject:svrPwd forKey:@"svrPwd"];
        [dicSvr setObject:createDate forKey:@"createDate"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *arraySvrList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"SvrList"]];
        for (int i=0; i<arraySvrList.count; i++) {
            NSMutableDictionary *dicTemp = [arraySvrList objectAtIndex:i];
            NSString *svrKeywordTemp = [dicTemp objectForKey:@"svrKeyword"];
            if ([svrKeyword isEqualToString:svrKeywordTemp]) {
                
                [arraySvrList removeObjectAtIndex:i];
                break;
            }
        }
        
        [arraySvrList addObject:dicSvr];
        [defaults setObject:arraySvrList forKey:@"SvrList"];
        [defaults synchronize];
        
        if (delegate && [delegate respondsToSelector:@selector(refreshList)]) {
            [delegate refreshList];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UITableview delegate

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"ftp信息";
}

//编辑模式，删除或插入或none
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.0f;
}

//绑定数据源
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellSvr";
    TaskCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TaskCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *textContent = nil;
    if (indexPath.row == 0) {
        cell.labelDesp.text = @"关键字";
        cell.textSvrInfo.placeholder = @"服务器关键字，必填";
        textContent = [dicCurrent valueForKey:@"svrKeyword"];
    }
    else if (indexPath.row == 1)
    {
        cell.labelDesp.text = @"地址";
        cell.textSvrInfo.placeholder = @"服务器地址，必填";
        textContent = [dicCurrent valueForKey:@"svrAddress"];
    }
    else if (indexPath.row == 2)
    {
        cell.labelDesp.text = @"端口";
        cell.textSvrInfo.placeholder = @"服务器端口";
        textContent = [dicCurrent valueForKey:@"svrPort"];
    }
    else if (indexPath.row == 3)
    {
        cell.labelDesp.text = @"用户名";
        cell.textSvrInfo.placeholder = @"用户名，必填";
        textContent = [dicCurrent valueForKey:@"svrUserName"];
    }
    else if (indexPath.row == 4)
    {
        cell.labelDesp.text = @"密码";
        cell.textSvrInfo.placeholder = @"密码";
        textContent = [dicCurrent valueForKey:@"svrPwd"];
    }
    cell.textSvrInfo.delegate = self;
    if (isModify && dicCurrent) {
        cell.textSvrInfo.text = textContent;
    }
    
    NSLog(@"svrSet, cell init!");
    
    return cell;
}


@end
