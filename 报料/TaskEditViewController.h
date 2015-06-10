//
//  TaskEditViewController.h
//  BreakingNews
//
//  Created by qianmenhui on 14-7-4.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import "TaskSourceView.h"
#import "ELCImagePickerController.h"
#import "DatePickerViewController.h"
#import "SvrShowViewController.h"
#import "LocSetViewController.h"
#import "PhoneSetViewController.h"

@interface TaskEditViewController : UIViewController <TaskSourceViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIActionSheetDelegate, ELCImagePickerControllerDelegate, DatePickerDelegate, SvrShowDelegate, LocSetViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, PhoneSetDelegate, CLLocationManagerDelegate>
{
    NSMutableArray *_itemDicList;
    NSMutableDictionary *_itemDate;
    NSMutableDictionary *_itemTarget;
    NSMutableDictionary *_itemPhone;
    NSMutableDictionary *_itemLocation;
    UILabel *_textPlaceholder;
    UIView *_backgroundView;
    UIScrollView *_myScrollView;
    UIPageControl *_pageCtrl;
    UIActivityIndicatorView *indicator;
    CLLocationManager *_locationManager;
    NSInteger   _indexLongPress;
    MPMoviePlayerController *_movPlay;
}

@property (nonatomic, strong) DatePickerViewController *dataPicker;
@property (nonatomic, strong) NSMutableArray *selectImgArray;
@property (nonatomic, strong) UITextView *textDespView;
@property (nonatomic, strong) TaskSourceView *imgView;
@property (nonatomic, strong) UITableView *tableItemList;
@property (nonatomic, strong) SvrShowViewController *svrShow;
//@property (nonatomic, strong) LocSetViewController *LocSet;
@property (nonatomic, strong) PhoneSetViewController *phoneSet;

@end
