//
//  TaskSourceView.h
//  BreakingNews
//
//  Created by qianmenhui on 14-7-2.
//  Copyright (c) 2014年 钱门慧. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TaskSourceViewDelegate;

@interface TaskSourceView : UIView
{
    BOOL _isNeedLayout;
    id <TaskSourceViewDelegate> _delegate;
}

@property (nonatomic, strong) id <TaskSourceViewDelegate> delegate;
@property (nonatomic, assign) CGFloat itemWidth;        //资源的宽度
@property (nonatomic, assign) CGFloat itemHeight;       //资源的高度
@property (nonatomic, strong) NSMutableArray *imgArray; //需要显示的资源图片信息

- (void)removeItemFromView:(NSInteger)index;
- (void)removeAllItems;
- (void)AppendItemsImgArray:(NSMutableArray *)newArray;

@end


@protocol TaskSourceViewDelegate <NSObject>

- (void)AddBtnClicked;
- (void)imgClicked:(NSInteger)index;
- (void)imageLongPress:(NSInteger)index;
- (void)layoutReset:(CGRect)viewRect;

@end