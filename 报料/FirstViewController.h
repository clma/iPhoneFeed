//
//  FirstViewController.h
//  BreakingNews
//
//  Created by qianmenhui on 14-7-3.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerController.h"

@interface FirstViewController : UIViewController <ELCImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, copy) NSMutableArray *chosenMedia;

@end
