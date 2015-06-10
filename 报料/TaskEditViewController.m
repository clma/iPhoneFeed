//
//  TaskEditViewController.m
//  BreakingNews
//
//  Created by qianmenhui on 14-7-4.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//
#import <SystemConfiguration/SystemConfiguration.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "sys/utsname.h"
#import "TaskEditViewController.h"
#import "TaskSourceView.h"
#import "ELCImagePickerController.h"
#import "DatePickerViewController.h"
#import "SvrShowViewController.h"
#import "LocSetViewController.h"
#import "PhoneSetViewController.h"
#import "GDataXMLNode.h"

@interface TaskEditViewController ()

@end

@implementation TaskEditViewController

@synthesize dataPicker;
@synthesize selectImgArray;
@synthesize textDespView;
@synthesize imgView;
@synthesize tableItemList;
@synthesize svrShow;
//@synthesize LocSet;
@synthesize phoneSet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        selectImgArray = [[NSMutableArray alloc] initWithCapacity:0];
        _indexLongPress = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //初始化一下图片下方的列表信息
    _itemDicList = [[NSMutableArray alloc] initWithCapacity:0];
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.title = @"报料";
    
    //建两个按钮
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(BarbtnClicked:)];
    btnSave.tag = 11;
    UIBarButtonItem *btnSend = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(BarbtnClicked:)];
    btnSend.tag = 12;
    self.navigationItem.leftBarButtonItem = btnSave;
    self.navigationItem.rightBarButtonItem = btnSend;
    
    //先创建描述框
    //if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
    //}
    CGRect textDespRect = CGRectMake(1, self.navigationController.navigationBar.frame.size.height + 22, self.view.frame.size.width - 2, 55);
    textDespView = [[UITextView alloc] initWithFrame:textDespRect];
    //textDespView.backgroundColor = [UIColor grayColor];
    textDespView.layer.borderWidth = 1.0;
    textDespView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [textDespView.layer setCornerRadius:4.0];
    textDespView.delegate = self;
    textDespView.contentOffset = CGPointMake(1, self.navigationController.navigationBar.frame.size.height + 25);
    textDespView.font = [UIFont fontWithName:@"Arial" size:17.0];
    textDespView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:textDespView];
    
    //描述框上面的placeholder
    _textPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(2, 1, 250, 30)];
    _textPlaceholder.text = @"简要说说报料的内容...";
    _textPlaceholder.textColor = [UIColor lightGrayColor];
    [textDespView addSubview:_textPlaceholder];
    
    //资源显示控件
    imgView = [[TaskSourceView alloc] init];
    imgView.frame = CGRectMake(1, textDespView.frame.origin.y + textDespView.frame.size.height + 1, self.view.frame.size.width - 2, 1);
    imgView.itemWidth = 61.2;
    imgView.itemHeight = 61.2;
    //imgView.layer.borderWidth = 1.0;
    //imgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //imgView.layer.cornerRadius = 4.0;
    if (selectImgArray.count > 0) {
        for (int i=0; i<selectImgArray.count; i++) {
            NSDictionary *dict = [selectImgArray objectAtIndex:i];
            NSString *mediaType = [dict valueForKey:UIImagePickerControllerMediaType];
            if ([mediaType isEqualToString:@"public.movie"]) {
                NSURL *movie = [dict objectForKey:UIImagePickerControllerMediaURL];
                
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:movie options:nil];
                AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                gen.appliesPreferredTrackTransform = YES;
                CMTime time = CMTimeMakeWithSeconds(0.0, 600);
                NSError *error = nil;
                CMTime actualTime;
                CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
                UIImage *img = [[UIImage alloc] initWithCGImage:image];
                CGImageRelease(image);
                
                [imgView.imgArray addObject:img];
                continue;
            }
            
            UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
            [imgView.imgArray addObject:image];
        }
    }
    imgView.delegate = self;
    [self.view addSubview:imgView];

    [self setUpForDismissKeyboard];

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    NSString *TextLoc = [_itemLocation valueForKey:@"content"];
    if (!TextLoc || [TextLoc isEqualToString:@""] || [TextLoc isEqualToString:@"未设置"]) {
        if ([CLLocationManager locationServicesEnabled]) {
            //设置定位的精度
            [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
            _locationManager.distanceFilter = 50;   //50米更新一次位置
            NSLog(@"开始定位");
            //开始定位
            [_locationManager startUpdatingLocation];
        }
    }
}

- (void)clearTaskPage
{
    NSLog(@"clearTaskPage");
    NSDateFormatter *formatDate = [[NSDateFormatter alloc] init];
    [formatDate setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *taskDate = [formatDate stringFromDate:[NSDate date]];
    [_itemDate setObject:taskDate forKey:@"content"];
    [_itemTarget setObject:@"未设置" forKey:@"content"];
    [_itemLocation setObject:@"未设置" forKey:@"content"];
    textDespView.text = @"";
    _textPlaceholder.hidden = NO;
    //刷新一下列表
    [tableItemList reloadData];
    
    if (selectImgArray.count > 0)
    {
        [selectImgArray removeAllObjects];
        [imgView removeAllItems];
    }
    
    [_locationManager startUpdatingLocation];
}

- (void)setUpForDismissKeyboard
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer *singleTapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAnywhereToDismissKeyboard:)];
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [nc addObserverForName:UIKeyboardWillShowNotification object:nil queue:mainQueue usingBlock:^(NSNotification *note) {
        [self.navigationController.view addGestureRecognizer:singleTapGr];
    }];
    
    [nc addObserverForName:UIKeyboardWillHideNotification object:nil queue:mainQueue usingBlock:^(NSNotification *note) {
        [self.navigationController.view removeGestureRecognizer:singleTapGr];
    }];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    [self.navigationController.view endEditing:YES];
    
    NSLog(@"endEditing!");
}

- (void)showWaiting
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(130, 220, 60, 60)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [indicator setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2)];
    indicator.backgroundColor = [UIColor grayColor];
    indicator.layer.cornerRadius = 6.0f;
    [window addSubview:indicator];
    [indicator startAnimating];
}

- (void)stopWaiting
{
    if (indicator) {
        [indicator removeFromSuperview];
        indicator = nil;
    }
}

- (GDataXMLElement*)CreateXml:(NSMutableDictionary*)dicContent fileInfo:(NSMutableArray*)fileArray
{
    NSString *taskDate = [dicContent valueForKey:@"taskDate"];
    //NSString *taskTarget = [dicContent valueForKey:@"taskTarget"];
    NSString *taskLocation = [dicContent valueForKey:@"taskLocation"];
    NSString *taskPhone = [dicContent valueForKey:@"taskPhone"];
    NSString *taskDesp = [dicContent valueForKey:@"taskDesperation"];
    
    //创建XML根节点
    GDataXMLElement *rootNode = [GDataXMLNode elementWithName:@"ObjectData"];
    //创建object节点
    GDataXMLElement *objectNode = [GDataXMLNode elementWithName:@"Object"];
    //创建object节点的属性
    GDataXMLNode *attrCcid = [GDataXMLNode attributeWithName:@"CCID" stringValue:@"phonepage"];
    [objectNode addAttribute:attrCcid];
    
    //创建metaData节点和属性
    GDataXMLElement *metaDataNode = [GDataXMLNode elementWithName:@"MetaData"];
    GDataXMLNode *attrCount = [GDataXMLNode attributeWithName:@"MetaDataCount" stringValue:@"6"];   //此数字代表属性个数
    [metaDataNode addAttribute:attrCount];
    
    //metaData节点下的标题节点
    GDataXMLElement *attrNode1 = [GDataXMLNode elementWithName:@"sAttribute" stringValue:taskDesp];
    GDataXMLNode *attrName1 = [GDataXMLNode attributeWithName:@"strName" stringValue:@"标题"];
    [attrNode1 addAttribute:attrName1];
    GDataXMLNode *attrType1 = [GDataXMLNode attributeWithName:@"enumType" stringValue:@"0"];
    [attrNode1 addAttribute:attrType1];
    [metaDataNode addChild:attrNode1];
    
    //metaData节点下的正文节点
    GDataXMLElement *attrNode2 = [GDataXMLNode elementWithName:@"sAttribute" stringValue:taskDesp];
    GDataXMLNode *attrName2 = [GDataXMLNode attributeWithName:@"strName" stringValue:@"正文"];
    [attrNode2 addAttribute:attrName2];
    GDataXMLNode *attrType2 = [GDataXMLNode attributeWithName:@"enumType" stringValue:@"0"];
    [attrNode2 addAttribute:attrType2];
    [metaDataNode addChild:attrNode2];
    
    //metaData节点下的来源节点
    GDataXMLElement *attrNode3 = [GDataXMLNode elementWithName:@"sAttribute" stringValue:taskPhone];
    GDataXMLNode *attrName3 = [GDataXMLNode attributeWithName:@"strName" stringValue:@"来源"];
    [attrNode3 addAttribute:attrName3];
    GDataXMLNode *attrType3 = [GDataXMLNode attributeWithName:@"enumType" stringValue:@"0"];
    [attrNode3 addAttribute:attrType3];
    [metaDataNode addChild:attrNode3];
    
    //metaData节点下的发布时间节点
    GDataXMLElement *attrNode4 = [GDataXMLNode elementWithName:@"sAttribute" stringValue:taskDate];
    GDataXMLNode *attrName4 = [GDataXMLNode attributeWithName:@"strName" stringValue:@"发布时间"];
    [attrNode4 addAttribute:attrName4];
    GDataXMLNode *attrType4 = [GDataXMLNode attributeWithName:@"enumType" stringValue:@"3"];
    [attrNode4 addAttribute:attrType4];
    [metaDataNode addChild:attrNode4];
    
    //metaData节点下的头像文件地址节点
    GDataXMLElement *attrNode5 = [GDataXMLNode elementWithName:@"sAttribute" stringValue:taskLocation];
    GDataXMLNode *attrName5 = [GDataXMLNode attributeWithName:@"strName" stringValue:@"头像文件地址"];
    [attrNode5 addAttribute:attrName5];
    GDataXMLNode *attrType5 = [GDataXMLNode attributeWithName:@"enumType" stringValue:@"0"];
    [attrNode5 addAttribute:attrType5];
    [metaDataNode addChild:attrNode5];
    
    NSDateFormatter *formatDate = [[NSDateFormatter alloc] init];
    [formatDate setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *taskSendDate = [formatDate stringFromDate:[NSDate date]];
    //metaData节点下的发送时间节点
    GDataXMLElement *attrNode6 = [GDataXMLNode elementWithName:@"sAttribute" stringValue:taskSendDate];
    GDataXMLNode *attrName6 = [GDataXMLNode attributeWithName:@"strName" stringValue:@"发送时间"];
    [attrNode6 addAttribute:attrName6];
    GDataXMLNode *attrType6 = [GDataXMLNode attributeWithName:@"enumType" stringValue:@"0"];
    [attrNode6 addAttribute:attrType6];
    [metaDataNode addChild:attrNode6];
    
    [objectNode addChild:metaDataNode];
    
    GDataXMLElement *contentNode = [GDataXMLNode elementWithName:@"Content"];
    for (int i=0; i<fileArray.count; i++) {
        NSString *fileName = [fileArray objectAtIndex:i];
        
        //Content节点下的各个节点
        GDataXMLElement *contentFileNode = [GDataXMLNode elementWithName:@"ContentFile"];
        GDataXMLNode *contentAttrName = [GDataXMLNode attributeWithName:@"strName" stringValue:fileName];
        [contentFileNode addAttribute:contentAttrName];
        NSString *path = [taskDate stringByAppendingString:@"/"];
        GDataXMLNode *contentAttrPath = [GDataXMLNode attributeWithName:@"strPath" stringValue:path];
        [contentFileNode addAttribute:contentAttrPath];
        GDataXMLNode *contentAttrType = [GDataXMLNode attributeWithName:@"enumType" stringValue:@"100"];
        [contentFileNode addAttribute:contentAttrType];
        GDataXMLNode *contentAttrLen = [GDataXMLNode attributeWithName:@"dwLength" stringValue:@"0"];
        [contentFileNode addAttribute:contentAttrLen];
        
        [contentNode addChild:contentFileNode];
    }
    
    [objectNode addChild:contentNode];
    
    [rootNode addChild:objectNode];
    
    return rootNode;
}

//保存和发送按钮
- (void)BarbtnClicked:(id)sender
{
    UIBarButtonItem *btnItem = (UIBarButtonItem*)sender;
    if (btnItem.tag == 11) {    //保存
        
        if (selectImgArray.count <= 0)
            return;
        
        NSString *taskDate = [_itemDate valueForKey:@"content"];
        NSString *taskTarget = [_itemTarget valueForKey:@"content"];
        NSString *taskLocation = [_itemLocation valueForKey:@"content"];
        NSString *taskPhone = [_itemPhone valueForKey:@"content"];
        NSString *taskDesp = textDespView.text;
        
        NSString *alertMsg = nil;
        if (taskTarget == nil || [taskTarget isEqualToString:@"未设置"]) {
            alertMsg = @"请选择发送目标！";
        }
        if (!taskPhone || [taskPhone isEqualToString:@"未设置"]) {
            if (alertMsg)
                alertMsg = [alertMsg stringByAppendingString:@"并填写您的电话号，以便我们确认消息来源！"];
            else
                alertMsg = @"请填写您的电话号，以便我们确认消息来源！";
        }
        if (!taskLocation || [taskLocation isEqualToString:@"未设置"]) {
            if (alertMsg)
                alertMsg = [alertMsg stringByAppendingString:@"请确认当前的位置！"];
            else
                alertMsg = @"请填写当前位置！";
        }
        
        if (alertMsg) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"⚠" message:alertMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        
        //显示等待控件
        [self showWaiting];
        
        //把信息存在字典中
        NSMutableDictionary *dicTask = [[NSMutableDictionary alloc] init];
        if (taskDate)
            [dicTask setObject:taskDate forKey:@"taskDate"];
        if (taskTarget)
            [dicTask setObject:taskTarget forKey:@"taskTarget"];
        if (taskLocation)
            [dicTask setObject:taskLocation forKey:@"taskLocation"];
        if (taskPhone)
            [dicTask setObject:taskPhone forKey:@"taskPhone"];
        if (taskDesp)
            [dicTask setObject:taskDesp forKey:@"taskDesperation"];
        
        [dicTask setObject:@"save" forKey:@"taskStatus"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
        //判断信息是否已经保存过，保存过的话询问是否替换
        if (arrayTaskList != nil && arrayTaskList.count > 0)
        {
            BOOL isTaskExist = NO;
            for (NSMutableDictionary *dicTemp in arrayTaskList )
            {
                NSString *strDate = [dicTemp objectForKey:@"taskDate"];
                NSString *strStatus = [dicTemp objectForKey:@"taskStatus"];
                if ([strDate isEqualToString:taskDate])
                {
                    isTaskExist = YES;
                    if ([strStatus isEqualToString:@"on"]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"⚠" message:@"存在正在进行的同名任务，请稍后保存！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                        
                        [self stopWaiting];
                        return;
                    }
                }
            }
            if (isTaskExist)    //存在
            {
                [self stopWaiting];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息" message:@"任务已存在，是否替换？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"替换", nil];
                alert.tag = 21;
                [alert show];
                
                return;
            }
            else                //不存在
            {
                [arrayTaskList addObject:dicTask];
                [defaults setObject:arrayTaskList forKey:@"taskList"];
                [defaults synchronize];
                
                NSMutableDictionary *dicObj = [[NSMutableDictionary alloc] init];
                if (!taskDate)
                    taskDate = @"";
                [dicObj setObject:taskDate forKey:@"fileName"];
                [dicObj setObject:@"yes" forKey:@"isNeedHints"];
                [NSThread detachNewThreadSelector:@selector(WriteFileToDoc:) toTarget:self withObject:dicObj];
            }
        }
        else    //没有taskList列表
        {
            NSMutableArray *arrTaskList = [[NSMutableArray alloc] initWithObjects:dicTask, nil];
            [defaults setObject:arrTaskList forKey:@"taskList"];
            [defaults synchronize];
            
            NSMutableDictionary *dicObj = [[NSMutableDictionary alloc] init];
            if (!taskDate)
                taskDate = @"";
            [dicObj setObject:taskDate forKey:@"fileName"];
            [dicObj setObject:@"yes" forKey:@"isNeedHints"];
            [NSThread detachNewThreadSelector:@selector(WriteFileToDoc:) toTarget:self withObject:dicObj];
        }
        
    }
    else if (btnItem.tag == 12) //发送
    {
        if (selectImgArray.count <= 0)
            return;
        
        NSString *taskDate = [_itemDate valueForKey:@"content"];
        NSString *taskTarget = [_itemTarget valueForKey:@"content"];
        NSString *taskLocation = [_itemLocation valueForKey:@"content"];
        NSString *taskPhone = [_itemPhone valueForKey:@"content"];
        NSString *taskDesp = textDespView.text;
        
        NSString *alertMsg = nil;
        if (taskTarget == nil || [taskTarget isEqualToString:@"未设置"]) {
            alertMsg = @"请选择发送目标！";
        }
        if (!taskPhone || [taskPhone isEqualToString:@"未设置"]) {
            if (alertMsg)
                alertMsg = [alertMsg stringByAppendingString:@"并填写您的电话号，以便我们确认消息来源！"];
            else
                alertMsg = @"请填写您的电话号，以便我们确认消息来源！";
        }
        if (!taskLocation || [taskLocation isEqualToString:@""]) {
            if (alertMsg)
                alertMsg = [alertMsg stringByAppendingString:@"请确认当前的位置！"];
            else
                alertMsg = @"请填写当前位置！";
        }
        
        if (alertMsg) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"⚠" message:alertMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        //把信息存在字典中
        NSMutableDictionary *dicTask = [[NSMutableDictionary alloc] init];
        if (taskDate)
            [dicTask setObject:taskDate forKey:@"taskDate"];
        if (taskTarget)
            [dicTask setObject:taskTarget forKey:@"taskTarget"];
        if (taskLocation)
            [dicTask setObject:taskLocation forKey:@"taskLocation"];
        if (taskPhone)
            [dicTask setObject:taskPhone forKey:@"taskPhone"];
        if (taskDesp)
            [dicTask setObject:taskDesp forKey:@"taskDesperation"];
        
        BOOL isOnExist = NO;
        [dicTask setObject:@"on" forKey:@"taskStatus"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
        //判断信息是否已经保存过，保存过就直接替换
        if (arrayTaskList != nil && arrayTaskList.count > 0)
        {
            //判断任务是否存在并且为正在进行的任务
            for (int i = 0; i < arrayTaskList.count; i++)
            {
                NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
                NSString *strDate = [dicTemp objectForKey:@"taskDate"];
                NSString *strStatus = [dicTemp objectForKey:@"taskStatus"];
                if ([strStatus isEqualToString:@"on"])
                {
                    if ([strDate isEqualToString:taskDate]) {
                        alertMsg = @"存在正在进行的同名任务，请稍后再发送！";
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"⚠" message:alertMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                    isOnExist = YES;
                }
            }
            
            if (isOnExist) {
                [dicTask setObject:@"standby" forKey:@"taskStatus"];
            }
            
            //路径下如果有文件，先删除
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docDir = [paths objectAtIndex:0];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *sourceDir = [NSString stringWithFormat:@"%@/%@", docDir, taskDate];
            NSArray *arrayFile = [fileManager contentsOfDirectoryAtPath:sourceDir error:nil];
            for (int j=0; j<arrayFile.count; j++)
            {
                NSString *filePath = [arrayFile objectAtIndex:j];
                [fileManager removeItemAtPath:[sourceDir stringByAppendingPathComponent:filePath] error:nil];
            }
            
            //再把数据信息替换
            for (int i = 0; i < arrayTaskList.count; i++)
            {
                NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
                NSString *strDate = [dicTemp objectForKey:@"taskDate"];
                if ([strDate isEqualToString:taskDate])
                {
                    [arrayTaskList removeObjectAtIndex:i];
                    break;
                }
            }
            
            [arrayTaskList addObject:dicTask];
            [defaults setObject:arrayTaskList forKey:@"taskList"];
            [defaults synchronize];
            
            NSLog(@"WriteFileToDoc begin!");
            NSMutableDictionary *dicObj = [[NSMutableDictionary alloc] init];
            if (!taskDate)
                taskDate = @"";
            [dicObj setObject:taskDate forKey:@"fileName"];
            [dicObj setObject:@"no" forKey:@"isNeedHints"];
            [NSThread detachNewThreadSelector:@selector(WriteFileToDoc:) toTarget:self withObject:dicObj];
            NSLog(@"WriteFileToDoc end!");
        }
        else    //没有taskList列表
        {
            NSMutableArray *arrTaskList = [[NSMutableArray alloc] initWithObjects:dicTask, nil];
            [defaults setObject:arrTaskList forKey:@"taskList"];
            [defaults synchronize];
            
            NSLog(@"1WriteFileToDoc begin!");
            NSMutableDictionary *dicObj = [[NSMutableDictionary alloc] init];
            if (!taskDate)
                taskDate = @"";
            [dicObj setObject:taskDate forKey:@"fileName"];
            [dicObj setObject:@"no" forKey:@"isNeedHints"];
            [NSThread detachNewThreadSelector:@selector(WriteFileToDoc:) toTarget:self withObject:dicObj];
            NSLog(@"1WriteFileToDoc end!");
        }
        
        //跳到列表页
        self.tabBarController.selectedIndex = 1;
    }
}

- (void)WriteFileToDoc:(NSMutableDictionary*)info
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *taskDate = [info valueForKey:@"fileName"];
    NSString *isNeedHints = [info valueForKey:@"isNeedHints"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
    //任务进度状态设置为 保存到doc
    for (int i = 0; i < arrayTaskList.count; i++)
    {
        NSMutableDictionary *dicTemp = [NSMutableDictionary dictionaryWithDictionary:[arrayTaskList objectAtIndex:i]];
        NSString *strDate = [dicTemp objectForKey:@"taskDate"];
        if ([strDate isEqualToString:taskDate])
        {
            [dicTemp setObject:@"正在保存" forKey:@"progressStatus"];
            [arrayTaskList replaceObjectAtIndex:i withObject:dicTemp];
            [defaults setObject:arrayTaskList forKey:@"taskList"];
            [defaults synchronize];
            break;
        }
    }
    
    //存文件到doc目录下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *sourceDir = [NSString stringWithFormat:@"%@/%@", docDir, taskDate];
    BOOL dirExist = [fileManager fileExistsAtPath:sourceDir];
    if (!dirExist)
    {
        //创建目录
        [fileManager createDirectoryAtPath:sourceDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSMutableArray *fileArray = [[NSMutableArray alloc] initWithCapacity:0];
    int i = 0;
    for (NSMutableDictionary *dict in selectImgArray)
    {
        i++;
        NSString *mediaType = [dict objectForKey:UIImagePickerControllerMediaType];
        //如果是视频
        if ([mediaType isEqualToString:ALAssetTypeVideo])
        {
            NSData *movData = [dict objectForKey:UIImagePickerControllerMediaMetadata];
            NSString *movPath = [sourceDir stringByAppendingPathComponent:[NSString stringWithFormat:@"mov_%d.mov", i]];
            [movData writeToFile:movPath atomically:YES];
            
            [fileArray addObject:[NSString stringWithFormat:@"mov_%d.mov", i]];
        }
        else if ([mediaType isEqualToString:ALAssetTypePhoto] || [mediaType isEqualToString:@"public.image"])
        {
            UIImage *img = [dict objectForKey:UIImagePickerControllerOriginalImage];
            NSString *imgPath;
            
            NSData *dataImg;
            if (UIImageJPEGRepresentation(img, 1) != nil)
            {
                dataImg = UIImageJPEGRepresentation(img, 1);
                imgPath = [sourceDir stringByAppendingPathComponent:[NSString stringWithFormat:@"img_%d.jpg", i]];
                
                [fileArray addObject:[NSString stringWithFormat:@"img_%d.jpg", i]];
            }
            else
            {
                dataImg = UIImagePNGRepresentation(img);
                imgPath = [sourceDir stringByAppendingPathComponent:[NSString stringWithFormat:@"img_%d.png", i]];
                
                [fileArray addObject:[NSString stringWithFormat:@"img_%d.png", i]];
            }
            
            [dataImg writeToFile:imgPath atomically:YES];
        }
        else if ([mediaType isEqualToString:@"public.movie"])
        {
            NSURL *movieUrl = [dict objectForKey:UIImagePickerControllerMediaURL];
            NSData *movData = [NSData dataWithContentsOfURL:movieUrl];
            NSString *movPath = [sourceDir stringByAppendingPathComponent:[NSString stringWithFormat:@"mov_%d.mov", i]];
            [movData writeToFile:movPath atomically:YES];
            
            [fileArray addObject:[NSString stringWithFormat:@"mov_%d.mov", i]];
        }
    }
    
    //保存完毕必须重新再取一次，因为保存的时候有可能列表增加或减少了
    NSMutableDictionary *xmlDic = nil;
    NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
    NSMutableArray *TaskListArr = [NSMutableArray arrayWithArray:[defaultUser objectForKey:@"taskList"]];
    //任务进度状态设置为saveDone
    for (int k = 0; k < TaskListArr.count; k++)
    {
        NSMutableDictionary *dicTemp = [NSMutableDictionary dictionaryWithDictionary:[TaskListArr objectAtIndex:k]];
        NSString *strDate = [dicTemp objectForKey:@"taskDate"];
        if ([strDate isEqualToString:taskDate])
        {
            xmlDic = dicTemp;
            [dicTemp setObject:@"保存完毕" forKey:@"progressStatus"];
            [TaskListArr replaceObjectAtIndex:k withObject:dicTemp];
            [defaults setObject:TaskListArr forKey:@"taskList"];
            [defaults synchronize];
            break;
        }
    }
    
    //创建并保存xml
    if (xmlDic) {
        GDataXMLElement *rootElement = [self CreateXml:xmlDic fileInfo:fileArray];
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithRootElement:rootElement];
        NSString *xmlPath = [sourceDir stringByAppendingPathComponent:@"task.xml"];
        [doc.XMLData writeToFile:xmlPath atomically:YES];
        
        NSLog(@"doc.XMLData writeToFile success");
    }
    else
        NSLog(@"xmlDic is nil");
    
    if ([isNeedHints isEqualToString:@"yes"]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"任务已保存" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alert show];
        
        [self performSelectorOnMainThread:@selector(stopWaiting) withObject:nil waitUntilDone:YES];
    }

    //清空当前页面
    [self performSelectorOnMainThread:@selector(clearTaskPage) withObject:nil waitUntilDone:YES];
}

- (NSString*)deviceString
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    return deviceString;
}

#pragma mark CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    if (locations.count <= 0)
        return;
    
    NSString *TextLoc = [_itemLocation valueForKey:@"content"];
    if (!(!TextLoc || [TextLoc isEqualToString:@""] || [TextLoc isEqualToString:@"未设置"])) {
        [_locationManager stopUpdatingLocation];
        return;
    }
    
    CLLocation *location = [locations lastObject];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"failed with error is:%@",error);
        }
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = [placemarks objectAtIndex:0];
            NSString *loc = placeMark.name;
            
            NSLog(@"citycode is:%@",loc);
            
            if (loc.length > 5 && [[loc substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"中国"]) { //中国两个字没必要显示
                loc = [loc substringFromIndex:2];
            }
            
            [_itemLocation setObject:loc forKey:@"content"];
            [_itemDicList replaceObjectAtIndex:3 withObject:_itemLocation];
            
            [tableItemList reloadData];
            [_locationManager stopUpdatingLocation];
        }
    }];
}

#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 21)   //替换
    {
        [self showWaiting];
        //先替换plist里的信息
        NSString *taskDate = [_itemDate valueForKey:@"content"];
        NSString *taskTarget = [_itemTarget valueForKey:@"content"];
        NSString *taskLocation = [_itemLocation valueForKey:@"content"];
        NSString *taskPhone = [_itemPhone valueForKey:@"content"];
        NSString *taskDesp = textDespView.text;
        
        //把信息存在字典中
        NSMutableDictionary *dicTask = [[NSMutableDictionary alloc] init];
        if (taskDate)
            [dicTask setObject:taskDate forKey:@"taskDate"];
        if (taskTarget)
            [dicTask setObject:taskTarget forKey:@"taskTarget"];
        if (taskLocation)
            [dicTask setObject:taskLocation forKey:@"taskLocation"];
        if (taskPhone)
            [dicTask setObject:taskPhone forKey:@"taskPhone"];
        if (taskDesp)
            [dicTask setObject:taskDesp forKey:@"taskDesperation"];
        
        [dicTask setObject:@"save" forKey:@"taskStatus"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *arrayTaskList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"taskList"]];
        for (int i = 0; i < arrayTaskList.count; i++)
        {
            NSMutableDictionary *dicTemp = [arrayTaskList objectAtIndex:i];
            NSString *strDate = [dicTemp objectForKey:@"taskDate"];
            if ([strDate isEqualToString:taskDate])
            {
                [arrayTaskList removeObjectAtIndex:i];
                break;
            }
        }
        
        [arrayTaskList addObject:dicTask];
        [defaults setObject:arrayTaskList forKey:@"taskList"];
        [defaults synchronize];
        
        //再替换物理文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *sourceDir = [NSString stringWithFormat:@"%@/%@", docDir, taskDate];
        NSArray *arrayFile = [fileManager contentsOfDirectoryAtPath:sourceDir error:nil];
        for (int j=0; j<arrayFile.count; j++)
        {
            NSString *filePath = [arrayFile objectAtIndex:j];
            [fileManager removeItemAtPath:[sourceDir stringByAppendingPathComponent:filePath] error:nil];
        }
        
        NSMutableDictionary *dicObj = [[NSMutableDictionary alloc] init];
        if (!taskDate)
            taskDate = @"";
        [dicObj setObject:taskDate forKey:@"fileName"];
        [dicObj setObject:@"yes" forKey:@"isNeedHints"];
        [NSThread detachNewThreadSelector:@selector(WriteFileToDoc:) toTarget:self withObject:dicObj];
    }
    
//    if (buttonIndex == 0 && alertView.tag == 22)
//    {
//        [self clearTaskPage];
//    }
}

#pragma mark UITextView delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView == textDespView) {
        _textPlaceholder.hidden = YES;
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == textDespView && (textView.text == nil || [textView.text isEqualToString:@""])) {
        _textPlaceholder.hidden = NO;
    }
}

#pragma mark TaskSourceView delegate

- (void)layoutReset:(CGRect)viewRect
{
    NSLog(@"layout Reset:%f,%f,%f,%f",viewRect.origin.x, viewRect.origin.y, viewRect.size.width, viewRect.size.height);
    CGRect listRect = CGRectMake(2, viewRect.origin.y + viewRect.size.height + 2, self.navigationController.view.frame.size.width - 2, 200);
    if (!tableItemList) {
        //创建一个列表
        tableItemList = [[UITableView alloc] initWithFrame:listRect style:UITableViewStylePlain];
        tableItemList.scrollEnabled = NO;
        tableItemList.delegate = self;
        tableItemList.dataSource = self;
        [self.view addSubview:tableItemList];
        
        _itemDate = [[NSMutableDictionary alloc] initWithCapacity:0];
        [_itemDate setObject:@"时间" forKey:@"keyword"];
        NSDateFormatter *formatDate = [[NSDateFormatter alloc] init];
        [formatDate setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
        NSString *taskDate = [formatDate stringFromDate:[NSDate date]];
        [_itemDate setObject:taskDate forKey:@"content"];
        [_itemDicList addObject:_itemDate];
        
        _itemTarget = [[NSMutableDictionary alloc] initWithCapacity:0];
        [_itemTarget setObject:@"发送目标" forKey:@"keyword"];
        [_itemTarget setObject:@"未设置" forKey:@"content"];
        [_itemDicList addObject:_itemTarget];
        
        _itemPhone = [[NSMutableDictionary alloc] initWithCapacity:0];
        [_itemPhone setObject:@"本机号码" forKey:@"keyword"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *phoneNum = [defaults valueForKey:@"phoneNum"];
        if (!phoneNum)
            phoneNum = @"未设置";
        [_itemPhone setObject:phoneNum forKey:@"content"];
        [_itemDicList addObject:_itemPhone];
        
        _itemLocation = [[NSMutableDictionary alloc] initWithCapacity:0];
        [_itemLocation setObject:@"所在位置" forKey:@"keyword"];
        [_itemLocation setObject:@"未设置" forKey:@"content"];
        [_itemDicList addObject:_itemLocation];
    }
    else   //已存在，就改变一下位置
    {
        tableItemList.frame = listRect;
    }
}

//增加资源按钮
- (void)AddBtnClicked
{
    NSLog(@"AddBtnClicked");
    
    if (selectImgArray.count >= 9) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"⚠" message:@"资源数已到显示上限！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍摄" otherButtonTitles:@"从相册选取",nil];
    actionSheet.tag = 15;
    [actionSheet showInView:self.navigationController.view];
}

//响应点击播放屏幕上的done按钮处理
- (void)movieCallback:(NSNotification*)notify
{
    MPMoviePlayerController *mov = [notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:mov];
    [mov.view removeFromSuperview];
    _movPlay = nil;
    NSLog(@"callback did");
}

//长按了一张图片
- (void)imageLongPress:(NSInteger)index
{
    _indexLongPress = index;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除此资源么?" otherButtonTitles:nil];
    actionSheet.tag = 16;
    [actionSheet showInView:self.navigationController.view];
    
    NSLog(@"imageLongPress:%ld",(long)index);
}

//按了某一个图片
- (void)imgClicked:(NSInteger)index
{
    NSLog(@"imgClicked:%ld",(long)index);
    
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    
    NSDictionary *dicTemp = [selectImgArray objectAtIndex:index];
    NSString *mediaType = [dicTemp objectForKey:UIImagePickerControllerMediaType];
    //如果是视频
    if ([mediaType isEqualToString:ALAssetTypeVideo])
    {
        NSURL *movieUrl = [dicTemp objectForKey:UIImagePickerControllerReferenceURL];
        //NSData *movData = [NSData dataWithContentsOfURL:movieUrl];
        _movPlay = [[MPMoviePlayerController alloc] initWithContentURL:movieUrl];
        _movPlay.controlStyle = MPMovieControlStyleFullscreen;
        [_movPlay.view setFrame:[UIScreen mainScreen].bounds];
        _movPlay.initialPlaybackTime = -1;
        [window addSubview:_movPlay.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:_movPlay];
        [_movPlay play];
        
        return;
    }
    if ([mediaType isEqualToString:@"public.movie"]) {
        NSURL *movieUrl = [dicTemp objectForKey:UIImagePickerControllerMediaURL];
        _movPlay = [[MPMoviePlayerController alloc] initWithContentURL:movieUrl];
        _movPlay.controlStyle = MPMovieControlStyleFullscreen;
        [_movPlay.view setFrame:[UIScreen mainScreen].bounds];
        _movPlay.initialPlaybackTime = -1;
        [window addSubview:_movPlay.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:_movPlay];
        [_movPlay play];
        
        return;
    }

    if (!_backgroundView) {
        
        _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _backgroundView.backgroundColor=[UIColor blackColor];
        [window addSubview:_backgroundView];
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideScrollView:)];
        [_backgroundView addGestureRecognizer:tap];
        
        _myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _backgroundView.bounds.size.width, _backgroundView.bounds.size.height)];
        _myScrollView.contentSize = CGSizeMake((_myScrollView.bounds.size.width)*(selectImgArray.count), _backgroundView.bounds.size.height);
        _myScrollView.pagingEnabled = YES;
        _myScrollView.showsHorizontalScrollIndicator = YES;
        _myScrollView.showsVerticalScrollIndicator = NO;
        _myScrollView.delegate = self;
        [_backgroundView addSubview:_myScrollView];
        
        //创建翻页控件
        _pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _backgroundView.bounds.size.height - 25, _backgroundView.bounds.size.width, 25)];
        _pageCtrl.backgroundColor = [UIColor clearColor];
        _pageCtrl.pageIndicatorTintColor = [UIColor grayColor];
        _pageCtrl.hidesForSinglePage = YES;
        _pageCtrl.numberOfPages = selectImgArray.count;
        [_backgroundView addSubview:_pageCtrl];
    }
//    else
//    {
//        //有可能增加了图片数目
//        _myScrollView.contentSize = CGSizeMake((_myScrollView.bounds.size.width)*(selectImgArray.count), _backgroundView.bounds.size.height);
//        _pageCtrl.numberOfPages = selectImgArray.count;
//        _backgroundView.hidden = NO;
//    }
    
    if (index >= 1)
        [self loadImgViewToBgView:(index - 1)];
    
    [self loadImgViewToBgView:index];
    
    if (index < selectImgArray.count - 1)
        [self loadImgViewToBgView:(index + 1)];
    
    _pageCtrl.currentPage = index;
    [_myScrollView scrollRectToVisible:CGRectMake((_myScrollView.bounds.size.width)*index, 0, _myScrollView.bounds.size.width, _myScrollView.bounds.size.height) animated:NO];
}

- (void)hideScrollView:(UITapGestureRecognizer*)tapGesture
{
    [_backgroundView removeGestureRecognizer:tapGesture];
    for (UIView *imgSubView in _myScrollView.subviews) {
        [imgSubView removeFromSuperview];
    }
    
    [_myScrollView removeFromSuperview];
    [_pageCtrl removeFromSuperview];
    [_backgroundView removeFromSuperview];
    
    _myScrollView = nil;
    _pageCtrl = nil;
    _backgroundView = nil;
}

- (void)loadImgViewToBgView:(NSInteger)page
{
    NSLog(@"loadImgViewToBgView,page:%ld",(long)page);
    if (!_myScrollView)
        return;
    
    if (selectImgArray.count <= 0)
        return;
    
    UIImageView *pageView = (UIImageView*)[_myScrollView viewWithTag:(51 + page)];
    if (!pageView) {
        UIImage *img = nil;
        NSDictionary *dicTemp = [selectImgArray objectAtIndex:page];
        NSString *mediaType = [dicTemp valueForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.movie"]) {
            NSURL *movie = [dicTemp objectForKey:UIImagePickerControllerMediaURL];
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:movie options:nil];
            AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            gen.appliesPreferredTrackTransform = YES;
            CMTime time = CMTimeMakeWithSeconds(0.0, 600);
            NSError *error = nil;
            CMTime actualTime;
            CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
            img = [[UIImage alloc] initWithCGImage:image];
            CGImageRelease(image);
        }
        else
        {
            img = [dicTemp objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        CGFloat showImgWidth = img.size.width;
        CGFloat showImgHeight = img.size.height;
        CGFloat pageWidth = CGRectGetWidth(_myScrollView.frame);
        CGFloat pageHeight = CGRectGetHeight(_myScrollView.frame);
        
        NSLog(@"loadImgViewToBgView,pageView is null");
        
        pageView = [[UIImageView alloc] initWithImage:img];
        
        if (showImgWidth/showImgHeight > pageWidth/pageHeight) {
            showImgWidth = pageWidth;
            showImgHeight = showImgWidth*img.size.height/img.size.width;
            
            [pageView setFrame:CGRectMake(pageWidth*page, (pageHeight - showImgHeight)/2, showImgWidth, showImgHeight)];
        }
        else
        {
            showImgHeight = pageHeight;
            showImgWidth = showImgHeight*img.size.width/img.size.height;
            
            [pageView setFrame:CGRectMake(pageWidth*page + (pageWidth - showImgWidth)/2, 0, showImgWidth, showImgHeight)];
        }
    
        pageView.tag = 51 + page;
        [_myScrollView addSubview:pageView];
    }
}

#pragma mark UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
    if (scrollView == _myScrollView) {
        CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
        NSInteger pageNum = fabs(scrollView.contentOffset.x) / pageWidth;
        
        NSLog(@"did scroll,pagenum:%ld",(long)pageNum);
        _pageCtrl.currentPage = pageNum;
        
        if (pageNum >= 1) {
            [self loadImgViewToBgView:(pageNum - 1)];
        }
        [self loadImgViewToBgView:pageNum];
        
        if (pageNum < selectImgArray.count - 1) {
            [self loadImgViewToBgView:(pageNum + 1)];
        }
    }
}

#pragma mark UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 15) {
        if (buttonIndex == 0) {     //拍摄
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = NO;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                NSArray *arrMediatypes =  [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
                picker.mediaTypes = arrMediatypes;
                [self presentViewController:picker animated:YES completion:^{}];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息!" message:@"当前设备不支持拍摄功能" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
                [alert show];
            }
        }
        else if (buttonIndex == 1)  //从相册选取
        {
            //创建照片选择器
            ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
            elcPicker.imagePickerDelegate = self;
            elcPicker.maximumImagesCount = 9;
            elcPicker.returnsOriginalImage = YES;
            [self presentViewController:elcPicker animated:YES completion:^{}];
        }
        else if (buttonIndex == 2)  //取消
        {
        }
    }
    
    if (actionSheet.tag == 16) {   //长按
        if (buttonIndex == 0) {  //删除
            if (_indexLongPress < 0 || _indexLongPress >= selectImgArray.count)
                return;
            
            [selectImgArray removeObjectAtIndex:_indexLongPress];
            [imgView removeItemFromView:_indexLongPress];
        }
    }
}

#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    
    if (info == nil)
        return;
    
    [selectImgArray addObject:info];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.movie"]) {
        NSURL *movie = [info objectForKey:UIImagePickerControllerMediaURL];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:movie options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *img = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        
        [tempArray addObject:img];
        
        //将其加到相册中
        NSString *movPath = [movie path];
        UISaveVideoAtPathToSavedPhotosAlbum(movPath, nil, nil, nil);
    }
    else
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [tempArray addObject:image];
        
        //加到相册中
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }

    [imgView AppendItemsImgArray:tempArray];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark UITableView delegate

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _itemDicList.count;
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

//设置cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self deviceString] isEqualToString:@"iPhone 5C"])
        return 50.0f;
    
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Select row is %ld",(long)indexPath.row);
    
    if (indexPath.row == 0)         //时间选择
    {
        if (!dataPicker) {
            dataPicker = [[DatePickerViewController alloc] init];
            dataPicker.delegate = self;
        }
        [self.navigationController pushViewController:dataPicker animated:YES];
    }
    else if (indexPath.row == 1)    //服务器目标选择
    {
        if (!svrShow) {
            svrShow = [[SvrShowViewController alloc] init];
            svrShow.delegate = self;
        }
        svrShow.targetContent = [_itemTarget objectForKey:@"content"];
        svrShow.isSelSvr = YES;
        [self.navigationController pushViewController:svrShow animated:YES];
    }
    else if (indexPath.row == 2)    //本机号码
    {
        if (!phoneSet) {
            phoneSet = [[PhoneSetViewController alloc] init];
            phoneSet.delegate = self;
        }
        [self.navigationController pushViewController:phoneSet animated:YES];
    }
    else if (indexPath.row == 3)    //所在位置
    {
        NSString *TextLoc = [_itemLocation valueForKey:@"content"];
        if (!TextLoc || [TextLoc isEqualToString:@""] || [TextLoc isEqualToString:@"未设置"]) {
            [_locationManager stopUpdatingLocation];
        }
        LocSetViewController *LocSet = [[LocSetViewController alloc] init];
        LocSet.delegate = self;
        [self.navigationController pushViewController:LocSet animated:YES];
    }
}

//绑定数据源
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell5";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//    }
    UITableViewCell  *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSMutableDictionary *dicTemp = [_itemDicList objectAtIndex:indexPath.row];
    
    NSString *keyWord = [dicTemp objectForKey:@"keyword"];
    NSString *content = [dicTemp objectForKey:@"content"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    cell.textLabel.text = keyWord;
    cell.detailTextLabel.text = content;
    
    NSLog(@"edit,init cell %ld",(long)indexPath.row);
    
    return cell;
}

#pragma mark ELCImagePicker Delegate

//选择资源后的处理
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([info count] <= 0)
        return;
    
    NSLog(@"info count is %lu",(unsigned long)[info count]);
    
    //转换成image的array,只支持显示9个资源
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int k=0; k<info.count; k++) {
        NSDictionary *dict = [info objectAtIndex:k];
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        [tempArray addObject:image];
        [selectImgArray addObject:dict];
        if (selectImgArray.count >= 9)
            break;
    }
    
    [imgView AppendItemsImgArray:tempArray];
}

//取消选择
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark DataPicker delegate

- (void)GetPickedDate:(NSDate*)pickedDate
{
    if (!pickedDate)
        return;
    
    NSDateFormatter *formatDate = [[NSDateFormatter alloc] init];
    [formatDate setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *taskDate = [formatDate stringFromDate:pickedDate];
    
    [_itemDate setObject:taskDate forKey:@"content"];
    [_itemDicList replaceObjectAtIndex:0 withObject:_itemDate];
    
    [tableItemList reloadData];
    //[tableItemList reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark SvrShowView delegate

- (void)refreshData:(NSString*)svrKeyword
{
    [_itemTarget setObject:svrKeyword forKey:@"content"];
    [_itemDicList replaceObjectAtIndex:1 withObject:_itemTarget];
    
    [tableItemList reloadData];
    //[tableItemList reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark phoneSet delegate

- (void)getPhoneNumber:(NSString*)phoneNumber
{
    [_itemPhone setObject:phoneNumber forKey:@"content"];
    [_itemDicList replaceObjectAtIndex:2 withObject:_itemPhone];
    
    [tableItemList reloadData];
}

#pragma mark LocSetView delegate

- (void)setCurrentLoc:(NSString*)currentLoc
{
    if (!currentLoc) {
        currentLoc = @"";
    }
    if (currentLoc.length > 5 && [[currentLoc substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"中国"]) { //中国两个字没必要显示
        currentLoc = [currentLoc substringFromIndex:2];
    }
    [_itemLocation setObject:currentLoc forKey:@"content"];
    [_itemDicList replaceObjectAtIndex:3 withObject:_itemLocation];
    
    [tableItemList reloadData];
    //[tableItemList reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

}




@end
