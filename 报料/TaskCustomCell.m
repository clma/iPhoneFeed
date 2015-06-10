//
//  TaskCustomCell.m
//  BreakingNews
//
//  Created by qianmenhui on 14-6-23.
//  Copyright (c) 2014年 钱门慧. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "TaskCustomCell.h"

@implementation TaskCustomCell

@synthesize labelNum;
@synthesize labelDate;
@synthesize labelLoc;
@synthesize labelDesp;
@synthesize labelProgress;
@synthesize textSvrInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        if (style == UITableViewCellStyleDefault) {
            [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 35)];
            
            //cell中的事件描述
            labelDesp = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 70, 35)];
            labelDesp.text = @"描述";
            labelDesp.textAlignment = NSTextAlignmentLeft;
            labelDesp.font = [UIFont systemFontOfSize:14];
            [self.contentView addSubview:labelDesp];
            
            textSvrInfo = [[UITextField alloc] initWithFrame:CGRectMake(81, 0, [UIScreen mainScreen].bounds.size.width - 95, 35)];
            textSvrInfo.backgroundColor = [UIColor whiteColor];
            textSvrInfo.font = [UIFont systemFontOfSize:14];
            //textSvrInfo.delegate = self;
            textSvrInfo.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [self.contentView addSubview:textSvrInfo];
            
        }
        else
        {
            [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
            
            //序号显示标签
            labelNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 59)];
            labelNum.text = @"序号";
            labelNum.textAlignment = NSTextAlignmentCenter;
            labelNum.backgroundColor = [UIColor cyanColor];
            labelNum.layer.cornerRadius = 5.0f;
            [self.contentView addSubview:labelNum];
            
            //cell中的事件描述
            labelDesp = [[UILabel alloc] initWithFrame:CGRectMake(20, 1, 200, 18)];
            labelDesp.text = @"事件描述";
            labelDesp.textAlignment = NSTextAlignmentLeft;
            labelDesp.font = [UIFont systemFontOfSize:14];
            [self.contentView addSubview:labelDesp];
            
            //cell中的地点
            labelLoc = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 18)];
            labelLoc.text = @"地点";
            labelLoc.textAlignment = NSTextAlignmentLeft;
            labelLoc.font = [UIFont systemFontOfSize:14];
            [self.contentView addSubview:labelLoc];
            
            //cell中的时间
            labelDate = [[UILabel alloc] initWithFrame:CGRectMake(20, 39, 200, 18)];
            labelDate.text = @"创建时间";
            labelDate.textAlignment = NSTextAlignmentLeft;
            labelDate.font = [UIFont systemFontOfSize:14];
            [self.contentView addSubview:labelDate];
            
            //cell中的进度
            labelProgress = [[UILabel alloc] initWithFrame:CGRectMake(221, 1, 65, 56)];
            labelProgress.textAlignment = NSTextAlignmentCenter;
            labelProgress.font = [UIFont systemFontOfSize:14];
            [self.contentView addSubview:labelProgress];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
