//
//  FirstViewController.m
//  BreakingNews
//
//  Created by qianmenhui on 14-7-3.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AppDelegate.h"
#import "FirstViewController.h"
#import "BaseViewController.h"


@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize chosenMedia;

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
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //手机界面的高度和宽度
    int nViewWidth = self.view.bounds.size.width;
    int nViewHeight = self.view.bounds.size.height;
    
    //设置背景图片
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, nViewWidth, nViewHeight)];
    [bgView setImage:[UIImage imageNamed:@"bg2.png"]];
    
    int nTitleImgWidth = 300;
    int nTitleImgHeight = 60;
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(nViewWidth/2 - nTitleImgWidth/2, 80, nTitleImgWidth, nTitleImgHeight)];
    [titleView setImage:[UIImage imageNamed:@"logo.png"]];
    
    int nBtnWidth = 195;
    int nBtnHeight = 51;
    
    //创建2个按钮
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.frame = CGRectMake(nViewWidth/2 - nBtnWidth/2, nViewHeight/2 + 60, nBtnWidth, nBtnHeight);
    [cameraBtn setTitle:@"拍摄" forState:UIControlStateNormal];
    cameraBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    cameraBtn.tintColor = [UIColor whiteColor];
    cameraBtn.layer.cornerRadius = 7.0f;
    [cameraBtn setImage:[UIImage imageNamed:@"icon1.png"] forState:UIControlStateNormal];
    cameraBtn.tag = 2;
    [cameraBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *fromAlbumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    fromAlbumBtn.frame = CGRectMake(nViewWidth/2 - nBtnWidth/2, cameraBtn.frame.origin.y + cameraBtn.frame.size.height + 25, nBtnWidth, nBtnHeight);
    [fromAlbumBtn setTitle:@"从相册选取" forState:UIControlStateNormal];
    fromAlbumBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    fromAlbumBtn.tintColor = [UIColor whiteColor];
    fromAlbumBtn.layer.cornerRadius = 7.0f;
    [fromAlbumBtn setImage:[UIImage imageNamed:@"icon2.png"] forState:UIControlStateNormal];
    fromAlbumBtn.tag = 3;
    [fromAlbumBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:bgView];
    [bgView addSubview:titleView];
    
    [self.view addSubview:cameraBtn];
    [self.view addSubview:fromAlbumBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)btnClick:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (btn.tag == 2)
    {
        [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
    }
    else if (btn.tag == 3){
        //创建照片选择器
        ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
        elcPicker.imagePickerDelegate = self;
        //elcPicker.navigationController.delegate = self;
        elcPicker.maximumImagesCount = 9;
        elcPicker.returnsOriginalImage = YES;
        [self presentViewController:elcPicker animated:YES completion:^{}];
    }
}

- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    if([UIImagePickerController isSourceTypeAvailable:sourceType]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
        NSArray *arrMediatypes =  [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
        picker.mediaTypes = arrMediatypes;
        [self presentViewController:picker animated:YES completion:^{}];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息!" message:@"当前设备不支持拍摄功能!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
    }
}

//-(UIView *)findView:(UIView *)aView withName:(NSString *)name{
//    Class cl = [aView class];
//    NSString *desc = [cl description];
//    
//    if ([name isEqualToString:desc])
//        return aView;
//    
//    for (NSUInteger i = 0; i < [aView.subviews count]; i++)
//    {
//        UIView *subView = [aView.subviews objectAtIndex:i];
//        subView = [self findView:subView withName:name];
//        if (subView)
//            return subView;
//    }
//    return nil;
//}

//把retake和use按钮改成重拍和使用
//-(void)setShowElement:(UIViewController *)viewController{
//    UIView *PLCameraView=[self findView:viewController.view withName:@"PLCameraView"];
//    UIView *bottomBar=[self findView:PLCameraView withName:@"PLCropOverlayBottomBar"];
//    UIImageView *bottomBarImageForSave = [bottomBar.subviews objectAtIndex:0];
//    
//    NSLog(@"bottomBarImageForSave.subviews.count:%d",bottomBarImageForSave.subviews.count);
//    
//    UIButton *retakeButton = [bottomBarImageForSave.subviews objectAtIndex:0];
//    [retakeButton setTitle:@"重拍" forState:UIControlStateNormal];
//    
//    UIButton *playButton = [bottomBarImageForSave.subviews objectAtIndex:1];
//    [playButton setTitle:@"播放" forState:UIControlStateNormal];
//    
//}

//#pragma mark UINavagationController delegate 
//
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    [self setShowElement:viewController];
//}

#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    [returnArray addObject:info];
    
    //修改根视图
    BaseViewController *taskBase = [[BaseViewController alloc] initWithImgArray:returnArray];
    AppDelegate * baseView = [UIApplication sharedApplication].delegate;
    baseView.window.rootViewController = taskBase;
    
    //选择使用的相片和视频需要保存到相册中，防止找不到
    NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.movie"]) {
        NSURL *movie = [info objectForKey:UIImagePickerControllerMediaURL];
        
        //将其加到相册中
        NSString *movPath = [movie path];
        UISaveVideoAtPathToSavedPhotosAlbum(movPath, nil, nil, nil);
    }
    else
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //加到相册中
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
}

//取消挑选
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

#pragma ELCImagePickerControllerDelegate methods

//取消选择 
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"did cancel!");
}





@end





