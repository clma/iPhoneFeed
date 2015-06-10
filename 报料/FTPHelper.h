//
//  FTPHelper.h
//  BreakingNews
//
//  Created by qianmenhui on 14-6-19.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>

@protocol FTPHelperDelegate <NSObject>
@optional
// Success
- (void)dataUploadFinished:(NSString *)uploadedFile;
- (void)progressAtPercent:(NSNumber *)uploadedSize;
- (void)createDirFinished:(NSString *)fileName;
// Failure
- (void)dataUploadFailed:(NSString *)reason;
- (void)createDirFailed:(NSString *)fileName;
@end


@interface FTPHelper : NSObject 
{
	NSString *urlString;
	id <FTPHelperDelegate> delegate;
	BOOL isBusy;
	NSString *uname;
	NSString *pword;
}
@property (retain) NSString *urlString;
@property (retain) id delegate;
@property (assign) BOOL isBusy;
@property (retain) NSString *uname;
@property (retain) NSString *pword;

- (void)upload:(NSURL *)fileItem svrDir:dirName;
- (void)uploadByData:(NSData *)anItem fileName:(NSString *)imageName;
- (void)createDir:(NSString*)dirName;
+ (FTPHelper *) sharedInstance;

@end


