//
//  TaskListViewController.m
//  BreakingNews
//
//  Created by qianmenhui on 14-7-3.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import <Foundation/NSXMLParser.h>
#import <QuartzCore/QuartzCore.h>
#import "TaskListViewController.h"
#import "TaskCustomCell.h"
#import "FTPHelper.h"



@interface TaskListViewController ()

@end

@implementation TaskListViewController

@synthesize uploadFileTotalSize;
@synthesize uploadedFileSize;
@synthesize onTaskFileFullPathList;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isOnUpload = NO;
        _indexSave = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(BarEditbtnClicked)];
//    self.navigationItem.leftBarButtonItem = btnEdit;
//    [btnEdit release];
    
    NSArray *array = [NSArray arrayWithObjects:@"进行中",@"已保存",@"已完成", nil];
    _segmentedController = [[UISegmentedControl alloc] initWithItems:array];
    //segmentedController.segmentedControlStyle = UISegmentedControlSegmentCenter;
    _segmentedController.tintColor=[UIColor blueColor];
    _segmentedController.selectedSegmentIndex = 0;
    [_segmentedController addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _segmentedController;
    
    NSLog(@"self.view:%@",self.view);
    NSLog(@"navBar:%f,tabbar:%f",self.navigationController.navigationBar.frame.size.height, self.tabBarController.tabBar.frame.size.height);
    
    //创建scroll页面
    CGFloat scrollHeight = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20 - self.tabBarController.tabBar.frame.size.height;
    _taskScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 20, self.view.bounds.size.width, scrollHeight)];
    _taskScrollView.contentSize = CGSizeMake((_taskScrollView.bounds.size.width)*3, _taskScrollView.bounds.size.height);
    _taskScrollView.pagingEnabled = NO;
    _taskScrollView.scrollEnabled = NO;
    _taskScrollView.showsHorizontalScrollIndicator = NO;
    _taskScrollView.showsVerticalScrollIndicator = NO;
    _taskScrollView.backgroundColor = [UIColor redColor];
    _taskScrollView.delegate = self;
    [self.view addSubview:_taskScrollView];
    
    //正在进行的任务列表
    _onTaskTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -20-self.navigationController.navigationBar.frame.size.height, _taskScrollView.bounds.size.width, _taskScrollView.bounds.size.height) style:UITableViewStylePlain];
    _onTaskTableView.delegate = self;
    _onTaskTableView.dataSource = self;
    _onTaskTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_taskScrollView addSubview:_onTaskTableView];
    
    //已保存的任务列表
    _saveTaskTableView = [[UITableView alloc] initWithFrame:CGRectMake(_taskScrollView.bounds.size.width, -20-self.navigationController.navigationBar.frame.size.height, _taskScrollView.bounds.size.width, _taskScrollView.bounds.size.height) style:UITableViewStylePlain];
    _saveTaskTableView.delegate = self;
    _saveTaskTableView.dataSource = self;
    _saveTaskTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_taskScrollView addSubview:_saveTaskTableView];
    
    //已完成的任务列表
    _doneTaskTableView = [[UITableView alloc] initWithFrame:CGRectMake(_taskScrollView.bounds.size.width*2, -20-self.navigationController.navigationBar.frame.size.height, _taskScrollView.bounds.size.width, _taskScrollView.bounds.size.height) style:UITableViewStylePlain];
    _doneTaskTableView.delegate = self;
    _doneTaskTableView.dataSource = self;
    _doneTaskTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_taskScrollView addSubview:_doneTaskTableView];
    
    //获取数据
    _onTaskList = [[NSMutableArray alloc] init];
    _saveTaskList = [[NSMutableArray alloc] init];
    _doneTaskList = [[NSMutableArray alloc] init];
    
    //从属性列表中获取任务信息列表
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
    
    for (int i = (int)arrayTaskList.count - 1; i>=0; i--)
    {
        NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
        if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"on"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"standby"])
            [_onTaskList addObject:dicTemp];
        else if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"save"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"error"])
            [_saveTaskList addObject:dicTemp];
        else                                    //没有状态的任务算已完成
            [_doneTaskList addObject:dicTemp];
    }
    
    //初始化定时器
//    myTimer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(updateTaskStatus) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSDefaultRunLoopMode];
    
    NSLog(@"init arrayTaskList.count is %lu", (unsigned long)arrayTaskList.count);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"TaskListViewController:viewWillAppear");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
    if (arrayTaskList.count != _onTaskList.count + _saveTaskList.count + _doneTaskList.count) {
        _onTaskList = [[NSMutableArray alloc] init];
        _saveTaskList = [[NSMutableArray alloc] init];
        _doneTaskList = [[NSMutableArray alloc] init];
        for (int i = (int)arrayTaskList.count - 1; i>=0; i--)
        {
            NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
            if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"on"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"standby"])
                [_onTaskList addObject:dicTemp];
            else if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"save"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"error"])
                [_saveTaskList addObject:dicTemp];
            else                                    //没有状态的任务算已完成
                [_doneTaskList addObject:dicTemp];
        }
        [_onTaskTableView reloadData];
        [_saveTaskTableView reloadData];
        [_doneTaskTableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!_isOnUpload) {
        NSMutableDictionary *dicSend = nil;
        BOOL progressStatusDone = NO;
        while (!progressStatusDone)     //查找正在进行并且保存完毕的任务
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
            for (int i = (int)arrayTaskList.count - 1; i>=0; i--)
            {
                NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
                if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"on"])
                {
                    _isOnUpload = YES;
                    
                    TaskCustomCell *cell = (TaskCustomCell*)[_onTaskTableView viewWithTag:101];
                    NSString *status = [dicTemp objectForKey:@"progressStatus"];
                    if ([status isEqualToString:@"正在保存"]) {
                        if (cell)
                            cell.labelProgress.text = status;
                    }
                    if ([status isEqualToString:@"保存完毕"])
                    {
                        dicSend = dicTemp;
                        if (cell)
                            cell.labelProgress.text = status;
                        
                        progressStatusDone = YES;
                        break;
                    }
                }
            }
            
            if (!_isOnUpload)
                break;
            
            if (!progressStatusDone)
                [NSThread sleepForTimeInterval:1.5];
        }
        
        if (_isOnUpload) {
            NSLog(@"sendFile Start!");
            
            if (dicSend)
                [self SendFile:dicSend];
            else
                NSLog(@"dicSend is nil");
        }
    }
}

- (void)SendFile:(NSMutableDictionary*)info
{
    if (!info)
    {
        NSLog(@"info is nil!");
        [self createDirFailed:nil];
        return;
    }
    
//    if (![self isNetworkRunning]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息!" message:@"网络不通" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
//        [alert show];
//        [alert release];
//        [self createDirFailed:nil];
//        return;
//    }
    
    NSLog(@"sendFile begin");
    
    NSString *svrTarget = [info objectForKey:@"taskTarget"];
    NSString *taskDate = [info objectForKey:@"taskDate"];
    
    //获取目标服务器FTP信息
    NSDictionary *dicTarget = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arraySvrList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"SvrList"]];
    for (int i=0; i<arraySvrList.count; i++) {
        NSDictionary *dicTemp = [arraySvrList objectAtIndex:i];
        NSString *svrKeywordTemp = [dicTemp objectForKey:@"svrKeyword"];
        if ([svrTarget isEqualToString:svrKeywordTemp]) {
            dicTarget = dicTemp;
            break;
        }
    }
    
    if (!dicTarget) {
        NSLog(@"未找到目标服务器信息！");
        [self createDirFailed:nil];
        return;
    }
    
    //计算上传总的大小
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *sourceDir = [NSString stringWithFormat:@"%@/%@", docDir, taskDate];
    NSArray *arrayFile = [fileManager contentsOfDirectoryAtPath:sourceDir error:nil];
    
    self.uploadFileTotalSize = 0;
    self.uploadedFileSize = 0;
    onTaskFileFullPathList = [[NSMutableArray alloc] init];
    for (int j=0; j<arrayFile.count; j++)
    {
        NSString *fileName = [arrayFile objectAtIndex:j];
        NSString *fileFullPath = [sourceDir stringByAppendingPathComponent:fileName];
        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:fileFullPath isDirectory:NO];
        NSData *data = [NSData dataWithContentsOfURL:fileUrl];
        if ([[fileName substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"a_"]) {//已上传过的物理文件会被改名，加过前缀a_,记录已上传的大小
            self.uploadedFileSize += data.length;
        }
        else
        {
            //记录正在执行任务中的文件全路径，只包括没有上传过的
            [onTaskFileFullPathList addObject:fileFullPath];
        }
        self.uploadFileTotalSize += data.length;
    }
    //设置上传用户名、密码等
    NSString *ftpPort = [dicTarget objectForKey:@"svrPort"];
    NSString *ftpUrl = [[dicTarget objectForKey:@"svrAddress"] stringByAppendingString:[NSString stringWithFormat:@":%@",ftpPort]];
    NSString *ftpUser = [dicTarget objectForKey:@"svrUserName"];
    NSString *ftpPwd = [dicTarget objectForKey:@"svrPwd"];
    [FTPHelper sharedInstance].delegate = self;
    [FTPHelper sharedInstance].urlString = ftpUrl;
    [FTPHelper sharedInstance].uname = ftpUser;
    [FTPHelper sharedInstance].pword = ftpPwd;
    
    NSLog(@"createDir:%@",taskDate);
    [[FTPHelper sharedInstance] createDir:taskDate];
    
    for (int k=0; k<onTaskFileFullPathList.count; k++)
    {
        NSString *fileFullPath = [onTaskFileFullPathList objectAtIndex:k];
        NSURL *fileUpUrl = [[NSURL alloc] initFileURLWithPath:fileFullPath isDirectory:NO];
        
        NSLog(@"upload:%@",fileFullPath);
        [[FTPHelper sharedInstance] upload:fileUpUrl svrDir:taskDate];
    }
}

- (void)segmentAction:(UISegmentedControl *)Seg
{
    NSInteger index = Seg.selectedSegmentIndex;
    
    [_taskScrollView scrollRectToVisible:CGRectMake((_taskScrollView.bounds.size.width)*index, -20-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height, _taskScrollView.bounds.size.width, _taskScrollView.bounds.size.height) animated:NO];
}
//-(BOOL)isNetworkRunning
//{
//    Reachability *reachAble = [Reachability reachabilityWithHostName:@"http://www.baidu.com"];
//    switch ([reachAble currentReachabilityStatus]) {
//        case NotReachable:
//            return FALSE;
//            break;
//        case ReachableViaWWAN:
//            return TRUE;
//            break;
//        case ReachableViaWiFi:
//            return TRUE;
//            break;
//    }
//    return FALSE;
//}



#pragma mark FTPHelper delegate

//创建文件夹后再上传到此文件夹中
- (void)createDirFinished:(NSString *)fileName
{
    NSLog(@"%@ create finished",fileName);
}

//创建文件夹失败
- (void)createDirFailed:(NSString *)fileName
{
    [self setTaskStatus:@"on" toStatus:@"error"];
}

//上传进度,单位为KB
- (void)progressAtPercent:(NSNumber *)uploadedSize
{
    float prog = ((self.uploadedFileSize/1024) + uploadedSize.floatValue)/(self.uploadFileTotalSize/1024);
    TaskCustomCell *cell = (TaskCustomCell*)[_onTaskTableView viewWithTag:101];
    if (cell) {
        cell.labelProgress.text = [NSString stringWithFormat:@"%.0f％", prog*100];
    }
    
    NSLog(@"progress:%.0f％", prog*100);
}

//每个文件上传完成都会调用
- (void)dataUploadFinished:(NSString *)uploadedFile
{
    NSLog(@"finished!");
    for (int k=0; k < onTaskFileFullPathList.count; k++)
    {
        NSString *fileFullPath = [onTaskFileFullPathList objectAtIndex:k];
        NSString *fileName = [fileFullPath substringWithRange:NSMakeRange(fileFullPath.length - uploadedFile.length, uploadedFile.length)];
        if ([uploadedFile isEqualToString:fileName])
        {
            //将此文件大小加到_uploadedFileSize中
            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:fileFullPath isDirectory:NO]];
            self.uploadedFileSize += data.length;
            
            //已上传要在名称前加a，区别于未上传的
            NSString *newName = [NSString stringWithFormat:@"a_%@",uploadedFile];
            NSString *newFullPath = [[fileFullPath substringWithRange:NSMakeRange(0, fileFullPath.length - uploadedFile.length)] stringByAppendingString:newName];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager moveItemAtPath:fileFullPath toPath:newFullPath error:nil]) {
                [fileManager removeItemAtPath:fileFullPath error:nil];
            }
            
            //去掉本条,_onTaskFileFullPathList只记录未上传的
            [onTaskFileFullPathList removeObjectAtIndex:k];
        }
    }
    
    //表示全部上传完成,可以启动下一条等待的任务
    if (onTaskFileFullPathList.count == 0)
    {
        //设置当前正在执行的任务状态为done，刷新任务列表
        [self setTaskStatus:@"on" toStatus:@"done"];
        
        NSLog(@"next step!");
        //执行下一条任务
        [self startNextStandbyTask];
    }
}

//上传失败
- (void)dataUploadFailed:(NSString *)reason
{
    NSLog(@"upload failed,reason:%@",reason);
    
    //设置当前正在执行的任务状态为error，刷新任务列表
    [self setTaskStatus:@"on" toStatus:@"error"];
    
    //执行下一条任务
    [self startNextStandbyTask];
}

//设置任务状态，并且重新获取各个任务的状态，并刷新列表
- (void)setTaskStatus:(NSString*)originStatus toStatus:(NSString*)newStatus
{
    //把当前任务状态改为已完成
    BOOL bIsExist = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
    for (int j = (int)arrayTaskList.count - 1; j>=0; j--)
    {
        NSMutableDictionary *dicTemp = [NSMutableDictionary dictionaryWithDictionary:[arrayTaskList objectAtIndex:j]];
        if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:originStatus])
        {
            bIsExist = YES;
            //如果正在进行的状态变成完成，则把进度状态改为完成
            if ([originStatus isEqualToString:@"on"] && [newStatus isEqualToString:@"done"]) {
                [dicTemp setObject:@"上传完成" forKey:@"progressStatus"];
            }
            //如果正在进行的状态变成错误，则进度状态改为错误
            if ([originStatus isEqualToString:@"on"] && [newStatus isEqualToString:@"error"]) {
                [dicTemp setObject:@"错误" forKey:@"progressStatus"];
            }
            
            [dicTemp setObject:newStatus forKey:@"taskStatus"];
            [arrayTaskList replaceObjectAtIndex:j withObject:dicTemp];
            [defaults setObject:arrayTaskList forKey:@"taskList"];
            [defaults synchronize];
            break;
        }
    }
    
    if (!bIsExist)
        return;
    
    //重新获取各种状态的任务,此时无on状态
    [_onTaskList removeAllObjects];
    [_saveTaskList removeAllObjects];
    [_doneTaskList removeAllObjects];
    for (int i = (int)arrayTaskList.count - 1; i>=0; i--)
    {
        NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
        if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"standby"])
        {
            [_onTaskList addObject:dicTemp];
        }
        else if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"save"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"error"])
            [_saveTaskList addObject:dicTemp];
        else                                    //没有状态的任务算已完成
            [_doneTaskList addObject:dicTemp];
    }
    //重新刷一下
    [_onTaskTableView reloadData];
    [_saveTaskTableView reloadData];
    [_doneTaskTableView reloadData];
}

//执行下一条正在等待的任务
- (void)startNextStandbyTask
{
    //如果无需要上传的任务，就返回
    if (_onTaskList.count <= 0) {
        _isOnUpload = NO;
        return;
    }
    
    NSMutableDictionary *dicTask = [_onTaskList objectAtIndex:0];
    
    //将状态置为on
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
    for (int i = 0; i < arrayTaskList.count; i++)
    {
        NSMutableDictionary *dicTemp = [NSMutableDictionary dictionaryWithDictionary:[arrayTaskList objectAtIndex:i]];
        NSString *strDate = [dicTemp objectForKey:@"taskDate"];
        if ([strDate isEqualToString:[dicTask valueForKey:@"taskDate"]])
        {
            [dicTemp setObject:@"on" forKey:@"taskStatus"];
            [arrayTaskList replaceObjectAtIndex:i withObject:dicTemp];
            [defaults setObject:arrayTaskList forKey:@"taskList"];
            [defaults synchronize];
            break;
        }
    }
    
    //重新获取各种状态
    [_onTaskList removeAllObjects];
    [_saveTaskList removeAllObjects];
    [_doneTaskList removeAllObjects];
    for (int i = (int)arrayTaskList.count - 1; i>=0; i--)
    {
        NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
        if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"standby"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"on"])
        {
            [_onTaskList addObject:dicTemp];
        }
        else if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"save"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"error"])
            [_saveTaskList addObject:dicTemp];
        else                                    //没有状态的任务算已完成
            [_doneTaskList addObject:dicTemp];
    }
    //重新刷一下
    [_onTaskTableView reloadData];
    [_saveTaskTableView reloadData];
    [_doneTaskTableView reloadData];
    
    //保存完毕或错误的状态都可以发送。错误的状态是保存过的，但发送出现错误的任务，所以是可以继续发送的
    if ([[dicTask valueForKey:@"progressStatus"] isEqualToString:@"保存完毕"] || [[dicTask valueForKey:@"progressStatus"] isEqualToString:@"错误"]) {
        //发送任务
        NSLog(@"task begin send:%@", [dicTask valueForKey:@"taskDate"]);
        [self SendFile:dicTask];
    }
}


#pragma mark UITableview delegate

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _onTaskTableView)
        return _onTaskList.count;
    else if (tableView == _saveTaskTableView)
        return _saveTaskList.count;
    else
        return _doneTaskList.count;
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
    if (tableView == _onTaskTableView)
        return @"重置";
    else if (tableView == _saveTaskTableView)
        return @"更多";
    else
        return @"删除";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (tableView == _onTaskTableView)  //重置,将状态置为已保存
        {
            NSMutableDictionary *dicReset = [NSMutableDictionary dictionaryWithDictionary:[_onTaskList objectAtIndex:indexPath.row]];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
            for (int i = 0; i < arrayTaskList.count; i++)
            {
                NSMutableDictionary *dicTemp = [NSMutableDictionary dictionaryWithDictionary:[arrayTaskList objectAtIndex:i]];
                NSString *strDate = [dicTemp objectForKey:@"taskDate"];
                if ([strDate isEqualToString:[dicReset valueForKey:@"taskDate"]])
                {
                    [dicTemp setObject:@"save" forKey:@"taskStatus"];
                    [dicTemp setObject:@"保存完毕" forKey:@"progressStatus"];
                    [arrayTaskList replaceObjectAtIndex:i withObject:dicTemp];
                    [defaults setObject:arrayTaskList forKey:@"taskList"];
                    [defaults synchronize];
                    break;
                }
            }
            
            //重新获取各种状态
            [_onTaskList removeAllObjects];
            [_saveTaskList removeAllObjects];
            [_doneTaskList removeAllObjects];
            for (int i = (int)arrayTaskList.count - 1; i>=0; i--)
            {
                NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
                if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"standby"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"on"])
                {
                    [_onTaskList addObject:dicTemp];
                }
                else if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"save"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"error"])
                    [_saveTaskList addObject:dicTemp];
                else                                    //没有状态的任务算已完成
                    [_doneTaskList addObject:dicTemp];
            }
            //重新刷一下
            [_onTaskTableView reloadData];
            [_saveTaskTableView reloadData];
            [_doneTaskTableView reloadData];
        }
        else if (tableView == _saveTaskTableView)    //发送
        {
            _indexSave = indexPath.row;
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"发送" otherButtonTitles:@"删除", nil];
            actionSheet.tag = 18;
            [actionSheet showInView:self.navigationController.view];
         }
        else        //删除
        {
            //删除物理文件、plist数据
            NSMutableDictionary *dicTemp = [_doneTaskList objectAtIndex:indexPath.row];
            NSString *taskDate = [dicTemp objectForKey:@"taskDate"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docDir = [paths objectAtIndex:0];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *sourceDir = [NSString stringWithFormat:@"%@/%@", docDir, taskDate];
            BOOL dirExist = [fileManager fileExistsAtPath:sourceDir];
            if (dirExist) {
                //先删除文件夹内的文件
                NSArray *arrayFile = [fileManager contentsOfDirectoryAtPath:sourceDir error:nil];
                for (int j=0; j<arrayFile.count; j++)
                {
                    NSString *filePath = [arrayFile objectAtIndex:j];
                    [fileManager removeItemAtPath:[sourceDir stringByAppendingPathComponent:filePath] error:nil];
                }
                //再删文件夹
                [fileManager removeItemAtPath:sourceDir error:nil];
            }

            //再把plist数据信息删除
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
            for (int i = 0; i < arrayTaskList.count; i++)
            {
                NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
                NSString *strDate = [dicTemp objectForKey:@"taskDate"];
                if ([strDate isEqualToString:taskDate])
                {
                    [arrayTaskList removeObjectAtIndex:i];
                    [defaults setObject:arrayTaskList forKey:@"taskList"];
                    [defaults synchronize];
                    break;
                }
            }
            
            NSLog(@"tasklist,del indexPath.section:%ld , row:%ld ", (long)indexPath.section, (long)indexPath.row);
            
            [_doneTaskList removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView reloadData];
        }
    }
}

//绑定数据源
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    TaskCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TaskCustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSMutableDictionary *dicTemp = nil;//[[NSMutableDictionary alloc] init];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (tableView == _onTaskTableView)
    {
        dicTemp = [_onTaskList objectAtIndex:indexPath.row];
        if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"on"]) {
            cell.labelProgress.textColor = [UIColor redColor];
            cell.tag = 101;
        }
    }
    else if (tableView == _saveTaskTableView)
    {
        dicTemp = [_saveTaskList objectAtIndex:indexPath.row];
    }
    else
    {
        dicTemp = [_doneTaskList objectAtIndex:indexPath.row];
    }
    
    NSString *taskDate = [dicTemp objectForKey:@"taskDate"];
    NSString *taskLoc = [dicTemp objectForKey:@"taskLocation"];
    NSString *taskDesp = [dicTemp objectForKey:@"taskDesperation"];
    NSString *taskProgressStatus = [dicTemp objectForKey:@"progressStatus"];
    
    cell.labelNum.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
    cell.labelDate.text = [NSString stringWithFormat:@"%@", taskDate];
    cell.labelLoc.text = [NSString stringWithFormat:@"%@", taskLoc];
    cell.labelDesp.text = [NSString stringWithFormat:@"%@", taskDesp];
    cell.labelProgress.text = taskProgressStatus;
    
    return cell;
}


#pragma mark UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 18) {
        if (buttonIndex == 0) {  // 发送
            
            if (_indexSave < 0)
                return;
            
            NSMutableDictionary *dicSend = [NSMutableDictionary dictionaryWithDictionary:[_saveTaskList objectAtIndex:_indexSave]];
            
            //先判断有没有任务正在进行
            if (_isOnUpload) { //有正在进行的任务,就保存为standby状态
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
                for (int i = 0; i < arrayTaskList.count; i++)
                {
                    NSMutableDictionary *dicTemp = [NSMutableDictionary dictionaryWithDictionary:[arrayTaskList objectAtIndex:i]];
                    NSString *strDate = [dicTemp objectForKey:@"taskDate"];
                    if ([strDate isEqualToString:[dicSend valueForKey:@"taskDate"]])
                    {
                        [dicTemp setObject:@"standby" forKey:@"taskStatus"];
                        [arrayTaskList replaceObjectAtIndex:i withObject:dicTemp];
                        [defaults setObject:arrayTaskList forKey:@"taskList"];
                        [defaults synchronize];
                        break;
                    }
                }
                //重新获取各种状态
                [_onTaskList removeAllObjects];
                [_saveTaskList removeAllObjects];
                [_doneTaskList removeAllObjects];
                for (int i = (int)arrayTaskList.count - 1; i>=0; i--)
                {
                    NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
                    if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"standby"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"on"])
                    {
                        [_onTaskList addObject:dicTemp];
                    }
                    else if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"save"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"error"])
                        [_saveTaskList addObject:dicTemp];
                    else                                    //没有状态的任务算已完成
                        [_doneTaskList addObject:dicTemp];
                }
                //重新刷一下
                [_onTaskTableView reloadData];
                [_saveTaskTableView reloadData];
                [_doneTaskTableView reloadData];
            }
            else
            {
                //将状态置为on
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
                for (int i = 0; i < arrayTaskList.count; i++)
                {
                    NSMutableDictionary *dicTemp = [NSMutableDictionary dictionaryWithDictionary:[arrayTaskList objectAtIndex:i]];
                    NSString *strDate = [dicTemp objectForKey:@"taskDate"];
                    if ([strDate isEqualToString:[dicSend valueForKey:@"taskDate"]])
                    {
                        [dicTemp setObject:@"on" forKey:@"taskStatus"];
                        [arrayTaskList replaceObjectAtIndex:i withObject:dicTemp];
                        [defaults setObject:arrayTaskList forKey:@"taskList"];
                        [defaults synchronize];
                        break;
                    }
                }
                
                //重新获取各种状态
                [_onTaskList removeAllObjects];
                [_saveTaskList removeAllObjects];
                [_doneTaskList removeAllObjects];
                for (int i = (int)arrayTaskList.count - 1; i>=0; i--)
                {
                    NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
                    if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"standby"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"on"])
                    {
                        [_onTaskList addObject:dicTemp];
                    }
                    else if ([[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"save"] || [[dicTemp objectForKey:@"taskStatus"] isEqualToString:@"error"])
                        [_saveTaskList addObject:dicTemp];
                    else                                    //没有状态的任务算已完成
                        [_doneTaskList addObject:dicTemp];
                }
                //重新刷一下
                [_onTaskTableView reloadData];
                [_saveTaskTableView reloadData];
                [_doneTaskTableView reloadData];
                
                NSLog(@"list click send!");
                
                //保存完毕或错误的状态都可以发送。错误的状态是保存过的，但发送出现错误的任务，所以是可以继续发送的
                if ([[dicSend valueForKey:@"progressStatus"] isEqualToString:@"保存完毕"] || [[dicSend valueForKey:@"progressStatus"] isEqualToString:@"错误"]) {
                    //发送任务
                    [self SendFile:dicSend];
                }
            }
        }
        else if (buttonIndex == 1)   //删除
        {
            //删除物理文件、plist数据
            NSMutableDictionary *dicTemp = [_saveTaskList objectAtIndex:_indexSave];
            NSString *taskDate = [dicTemp objectForKey:@"taskDate"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docDir = [paths objectAtIndex:0];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *sourceDir = [NSString stringWithFormat:@"%@/%@", docDir, taskDate];
            BOOL dirExist = [fileManager fileExistsAtPath:sourceDir];
            if (dirExist) {
                //先删除文件夹内的文件
                NSArray *arrayFile = [fileManager contentsOfDirectoryAtPath:sourceDir error:nil];
                for (int j=0; j<arrayFile.count; j++)
                {
                    NSString *filePath = [arrayFile objectAtIndex:j];
                    [fileManager removeItemAtPath:[sourceDir stringByAppendingPathComponent:filePath] error:nil];
                }
                //再删文件夹
                [fileManager removeItemAtPath:sourceDir error:nil];
            }
            
            //再把plist数据信息删除
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
            for (int i = 0; i < arrayTaskList.count; i++)
            {
                NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
                NSString *strDate = [dicTemp objectForKey:@"taskDate"];
                if ([strDate isEqualToString:taskDate])
                {
                    [arrayTaskList removeObjectAtIndex:i];
                    [defaults setObject:arrayTaskList forKey:@"taskList"];
                    [defaults synchronize];
                    break;
                }
            }
            
            [_saveTaskList removeObjectAtIndex:_indexSave];
            [_saveTaskTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:_indexSave inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_saveTaskTableView reloadData];
        }
        
        _indexSave = -1;
    }
    
}



@end
