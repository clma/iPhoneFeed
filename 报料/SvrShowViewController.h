//
//  SvrShowViewController.h
//  BreakingNews
//
//  Created by qianmenhui on 14-7-7.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SvrSetViewController.h"

@protocol SvrShowDelegate <NSObject>

- (void)refreshData:(NSString*)svrKeyword;

@end


@interface SvrShowViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SvrSetDelegate>
{
    NSMutableArray *_svrArrayList;      //服务器配置列表
    BOOL    _isFirstInit;               //是否是第一次初始化
}

@property (nonatomic, strong) UITableView *svrTableView;
@property (nonatomic, assign) id <SvrShowDelegate> delegate;
@property (nonatomic, assign) NSString *targetContent;
@property (nonatomic, assign) BOOL isSelSvr;     //如果是选择服务器列表

@end
