//
//  LocSetViewController.m
//  BreakingNews
//
//  Created by qianmenhui on 14-7-8.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LocSetViewController.h"

@interface LocSetViewController ()

@end

@implementation LocSetViewController

@synthesize switchBtn;
@synthesize textLoc;
@synthesize myMapView;
@synthesize delegate;
@synthesize locationmanager;

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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, self.navigationController.navigationBar.frame.size.height + 30, self.view.frame.size.width/2, 30)];
    label.text = @"是否手动填写位置";
    label.textColor = [UIColor grayColor];
    [self.view addSubview:label];
    
    //创建保存按钮
    UIBarButtonItem *itemSave = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(locSave)];
    self.navigationItem.rightBarButtonItem = itemSave;
    
    switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70, self.navigationController.navigationBar.frame.size.height + 30, 60, 30)];
    [switchBtn setOn:NO animated:YES];
    [switchBtn addTarget:self action:@selector(switchClicked) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switchBtn];
    
    textLoc = [[UITextField alloc] initWithFrame:CGRectMake(15, label.frame.origin.y + label.frame.size.height + 5, self.view.frame.size.width - 30, 30)];
    //textLoc.placeholder = @"请输入所在位置...";
    textLoc.enabled = NO;
    textLoc.layer.borderWidth = 1.0f;
    textLoc.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textLoc.layer.cornerRadius = 5.0f;
    textLoc.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:textLoc];
    
    //加载地图
    myMapView = [[MKMapView alloc] initWithFrame:CGRectMake(1, textLoc.frame.origin.y + textLoc.frame.size.height + 8, self.view.frame.size.width - 2, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 105)];
    myMapView.mapType = MKMapTypeStandard;
    myMapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    myMapView.delegate = self;
    myMapView.zoomEnabled = YES;
    myMapView.scrollEnabled = YES;
    myMapView.showsUserLocation = YES;
    [self.view addSubview:myMapView];

    //定位管理
    locationmanager = [[CLLocationManager alloc] init];
    locationmanager.delegate = self;
    //设置定位的精度
    [locationmanager setDesiredAccuracy:kCLLocationAccuracyBest];
    locationmanager.distanceFilter = 50;   //50米更新一次位置
    //开始定位
    [locationmanager startUpdatingLocation];
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

//保存当前的位置
- (void)locSave
{
    if (delegate && [delegate respondsToSelector:@selector(setCurrentLoc:)]) {
        [delegate setCurrentLoc:textLoc.text];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

//是使用手动填写还是自动获取当前位置
- (void)switchClicked
{
    if (switchBtn.isOn)
    {
        textLoc.enabled = YES;
        [locationmanager stopUpdatingLocation];
    }
    else
    {
        textLoc.enabled = NO;
        [locationmanager startUpdatingLocation];
    }
}

#pragma mark CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    if (locations.count <= 0)
        return;

    //显示地图定位的区域
    CLLocation *location = [locations lastObject];
    NSLog(@"location:%@",location);
    myMapView.centerCoordinate = location.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000);
    //[myMapView setRegion:viewRegion animated:YES];
    MKCoordinateRegion adjustedRegion = [myMapView regionThatFits:viewRegion];
    [myMapView setRegion:adjustedRegion animated:YES];
    
    //解析位置所在地址
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"failed with error is:%@",error);
        }
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = [placemarks objectAtIndex:0];
            NSString *loc = placeMark.name;
            textLoc.text = loc;
            NSLog(@"citycode is:%@",loc);
            
            [locationmanager stopUpdatingLocation];
        }
    }];
}

#pragma mark MKMapView delegate

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"地图加载错误" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

//定位别针
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin_annotation"];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin_annotation"];
    }
    annotationView.canShowCallout = YES;
    annotationView.pinColor = MKPinAnnotationColorRed;
    annotationView.highlighted = YES;
    annotationView.draggable = YES;
    
    return annotationView;
}



@end
