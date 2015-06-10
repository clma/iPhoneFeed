//
//  LocSetViewController.h
//  BreakingNews
//
//  Created by qianmenhui on 14-7-8.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>


@protocol LocSetViewDelegate <NSObject>

- (void)setCurrentLoc:(NSString*)currentLoc;

@end

@interface LocSetViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) UISwitch *switchBtn;
@property (nonatomic, strong) UITextField *textLoc;
@property (nonatomic, strong) MKMapView *myMapView;
@property (nonatomic, strong) id <LocSetViewDelegate> delegate;
@property(nonatomic,retain) CLLocationManager* locationmanager;

@end
