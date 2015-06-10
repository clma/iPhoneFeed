//
//  DatePickerViewController.h
//  BreakingNews
//
//  Created by qianmenhui on 14-7-7.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerDelegate <NSObject>

- (void)GetPickedDate:(NSDate*)pickedDate;

@end

@interface DatePickerViewController : UIViewController

@property (nonatomic, assign) id <DatePickerDelegate> delegate;
@property (nonatomic, strong) UIDatePicker *datePicker;

@end
