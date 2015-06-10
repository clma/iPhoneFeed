//
//  SvrSetViewController.h
//  BreakingNews
//
//  Created by qianmenhui on 14-7-7.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SvrSetDelegate <NSObject>

- (void)refreshList;

@end

@interface SvrSetViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
//    UITextField *_textSvrName;          //服务器名称
//    UITextField *_textAddr;             //服务器地址
//    UITextField *_textPort;             //服务器端口
//    UITextField *_textUser;             //用户名
//    UITextField *_textPwd;              //密码
    UITableView *_svrListSetTable;
}

@property (nonatomic, assign) id <SvrSetDelegate> delegate;
@property (nonatomic, assign) NSMutableDictionary *dicCurrent;
@property (nonatomic, assign) BOOL isModify;    //是否为修改，或添加

@end
