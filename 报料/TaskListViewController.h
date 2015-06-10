//
//  TaskListViewController.h
//  BreakingNews
//
//  Created by qianmenhui on 14-7-3.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTPHelper.h"

@interface TaskListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FTPHelperDelegate, UIActionSheetDelegate>
{
    NSMutableArray *_onTaskList;               //正在进行中的任务列表
    NSMutableArray *_saveTaskList;             //保存状态的任务列表
    NSMutableArray *_doneTaskList;             //已经完成的任务列表
    BOOL           _isOnUpload;
    UIScrollView   *_taskScrollView;
    UITableView    *_onTaskTableView;
    UITableView    *_saveTaskTableView;
    UITableView    *_doneTaskTableView;
    UIButton       *_btnOn;
    UIButton       *_btnSave;
    UIButton       *_btnDone;
    UISegmentedControl *_segmentedController;
    NSInteger      _indexSave;
}

@property (nonatomic, assign) long long uploadFileTotalSize;            //每个任务中需要上传的文件总大小
@property (nonatomic, assign) long long uploadedFileSize;               //已经被上传的文件大小，正在上传的不算
@property (nonatomic, retain) NSMutableArray *onTaskFileFullPathList;   //正在处理的任务中的所有文件


- (void)SendFile:(NSMutableDictionary*)info;

@end
