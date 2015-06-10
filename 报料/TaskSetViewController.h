//
//  TaskSetViewController.h
//  BreakingNews
//
//  Created by qianmenhui on 14-7-3.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSetViewController.h"
#import "SvrShowViewController.h"

@interface TaskSetViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PhoneSetDelegate, SvrShowDelegate>
{
    BOOL isInitFirst;
}

@property (nonatomic, strong) UITableView *taskTableView;

@end
