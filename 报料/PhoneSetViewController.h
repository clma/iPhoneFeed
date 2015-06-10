//
//  PhoneSetViewController.h
//  BreakingNews
//
//  Created by qianmenhui on 14-7-7.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhoneSetDelegate <NSObject>

- (void)getPhoneNumber:(NSString*)phoneNumber;

@end

@interface PhoneSetViewController : UIViewController <UITextFieldDelegate>
{
    UITextField *_textPhone;
    UILabel *_labelContent;
}

@property (nonatomic, assign) id <PhoneSetDelegate> delegate;


@end
