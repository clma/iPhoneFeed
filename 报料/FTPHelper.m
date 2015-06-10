//
//  FTPHelper.m
//  BreakingNews
//
//  Created by qianmenhui on 14-6-19.
//  Copyright (c) 2014年 qianmenhui. All rights reserved.
//

#import "FTPHelper.h"

#define DELEGATE_CALLBACK(X, Y) if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(X)]) [sharedInstance.delegate performSelector:@selector(X) withObject:Y];
#define COMPLAIN_AND_BAIL(X) {NSLog(X); return;}
#define NUMBER(X) [NSNumber numberWithFloat:X]
#define kMyBufferSize  32768

typedef struct MyStreamInfo {
	
    CFWriteStreamRef  writeStream;
    CFReadStreamRef   readStream;
    SInt64            fileSize;
    UInt32            totalBytesWritten;
    UInt32            leftOverByteCount;
    UInt8             buffer[kMyBufferSize];
    CFStringRef       fileName;
	
} MyStreamInfo;

static const CFOptionFlags kNetworkEvents = 
kCFStreamEventOpenCompleted
| kCFStreamEventHasBytesAvailable
| kCFStreamEventEndEncountered
| kCFStreamEventCanAcceptBytes
| kCFStreamEventErrorOccurred;

static FTPHelper *sharedInstance = nil;

@implementation FTPHelper
@synthesize delegate;
@synthesize urlString;
@synthesize isBusy;
@synthesize uname;
@synthesize pword;



// MyStreamInfoCreate creates a MyStreamInfo 'object' with the specified read and write stream.
static void MyStreamInfoCreate(MyStreamInfo **info, CFReadStreamRef readStream, CFWriteStreamRef writeStream, CFStringRef fileName)
{
    MyStreamInfo * streamInfo;
	
    assert(info != NULL);
    // writeStream may be NULL (this is the case for the directory list operation)
    
    streamInfo = malloc(sizeof(MyStreamInfo));
    assert(streamInfo != NULL);
    
    streamInfo->readStream        = readStream;
    streamInfo->writeStream       = writeStream;
    streamInfo->fileSize          = 0;
    streamInfo->totalBytesWritten = 0;
    streamInfo->leftOverByteCount = 0;
    streamInfo->fileName = fileName;
	
    *info = streamInfo;
}

/* MyStreamInfoDestroy destroys a MyStreamInfo 'object', cleaning up any resources that it owns. */                                       
static void MyStreamInfoDestroy(MyStreamInfo * info)
{
    assert(info != NULL);
    
    if (info->readStream) {
        CFReadStreamUnscheduleFromRunLoop(info->readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        (void) CFReadStreamSetClient(info->readStream, kCFStreamEventNone, NULL, NULL);
        
        /* CFReadStreamClose terminates the stream. */
        CFReadStreamClose(info->readStream);
        CFRelease(info->readStream);
    }
	
    if (info->writeStream) {
        CFWriteStreamUnscheduleFromRunLoop(info->writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        (void) CFWriteStreamSetClient(info->writeStream, kCFStreamEventNone, NULL, NULL);
        
        /* CFWriteStreamClose terminates the stream. */
        CFWriteStreamClose(info->writeStream);
        CFRelease(info->writeStream);
    }
    
    if (info->fileName) {
        CFRelease(info->fileName);
    }
    
    free(info);
}

static void MyCFStreamSetUsernamePassword(CFTypeRef stream, CFStringRef username, CFStringRef password)
{
    Boolean success;
    assert(stream != NULL);
    assert( (username != NULL) || (password == NULL) );
    
    if (username && CFStringGetLength(username) > 0) {
		
        if (CFGetTypeID(stream) == CFReadStreamGetTypeID()) {
            success = CFReadStreamSetProperty((CFReadStreamRef)stream, kCFStreamPropertyFTPUserName, username);
            assert(success);
            if (password) {
                success = CFReadStreamSetProperty((CFReadStreamRef)stream, kCFStreamPropertyFTPPassword, password);
                assert(success);
            }
        }
		else if (CFGetTypeID(stream) == CFWriteStreamGetTypeID()) {
            success = CFWriteStreamSetProperty((CFWriteStreamRef)stream, kCFStreamPropertyFTPUserName, username);
            assert(success);
            if (password) {
                success = CFWriteStreamSetProperty((CFWriteStreamRef)stream, kCFStreamPropertyFTPPassword, password);
                assert(success);
            }
        } else {
            assert(false);
        }
    }
}


#pragma mark create directory

static void CreateDirCallBack(CFWriteStreamRef writeStream, CFStreamEventType type, void * clientCallBackInfo)
{
    MyStreamInfo     *info = (MyStreamInfo *)clientCallBackInfo;
    CFStreamError    error;
	
    assert(writeStream != NULL);
    assert(info        != NULL);
    assert(info->writeStream == writeStream);
	
    switch (type)
    {
        case kCFStreamEventOpenCompleted: // open complete
        {
            NSLog(@"kCFStreamEventOpenCompleted");
        }
            break;
        case kCFStreamEventCanAcceptBytes:
			break;
        case kCFStreamEventErrorOccurred:
        {
            error = CFWriteStreamGetError(info->writeStream);
			NSString *reason = [NSString stringWithFormat:@"CFReadStreamGetError returned (%ld, %d)", error.domain, (int)error.error];
            CFStreamStatus st = CFWriteStreamGetStatus(info->writeStream);
            NSLog(@"kCFStreamEventErrorOccurred: %ld ,reson:%@", st, reason);
			
            if (error.error == 550)
            {
                //表示已经存在，不用创建
                DELEGATE_CALLBACK(createDirFinished:, (__bridge id)(info->fileName));
            }
            else
            {
                DELEGATE_CALLBACK(createDirFailed:, (__bridge id)(info->fileName));
            }
            MyStreamInfoDestroy(info);
        }
            break;
        case kCFStreamEventEndEncountered:
        {
            CFStreamStatus st = CFWriteStreamGetStatus(info->writeStream);
            NSLog(@"kCFStreamEventEndEncountered: %ld", st);
            
            DELEGATE_CALLBACK(createDirFinished:, (__bridge id)(info->fileName));
            MyStreamInfoDestroy(info);
        }
            break;
        default:
            break;
    }
}

static Boolean CreateDirectory(CFStringRef uploadDirectory, CFStringRef fileName, CFStringRef username, CFStringRef password)
{
    CFWriteStreamRef       writeStream;
    CFStreamClientContext  context = { 0, NULL, NULL, NULL, NULL };
    CFURLRef               uploadURL, destinationURL;
    Boolean                success = true;
    MyStreamInfo           *streamInfo;
	
    assert(uploadDirectory != NULL);
    assert(fileName != NULL);
    assert(username != NULL);
    
    /* Create a CFURL from the upload directory string */
    destinationURL = CFURLCreateWithString(kCFAllocatorDefault, uploadDirectory, NULL);
    assert(destinationURL != NULL);
	
    /* Copy the end of the file path and use it as the file name. */
    
    NSLog(@"filename:%@",fileName);
	
    /* Create the destination URL by taking the upload directory and appending the file name. */
    uploadURL = CFURLCreateCopyAppendingPathComponent(NULL, destinationURL, fileName, true);

	assert(uploadURL != NULL);
    CFRelease(destinationURL);
    
    /* Create an FTP write stream for uploading operation to a FTP URL. If the URL specifies a
	 directory, the open will be followed by a close event/state and the directory will have been
	 created. Intermediary directory structure is not created. */
    writeStream = CFWriteStreamCreateWithFTPURL(NULL, uploadURL);
    assert(writeStream != NULL);
    CFRelease(uploadURL);
    
    /* Initialize our MyStreamInfo structure, which we use to store some information about the stream. */
    MyStreamInfoCreate(&streamInfo, NULL, writeStream, fileName);
    context.info = (void *)streamInfo;

    /* CFWriteStreamSetClient registers a callback to hear about interesting events that occur on a stream. */
    success = CFWriteStreamSetClient(writeStream, kNetworkEvents, CreateDirCallBack, &context);
    if (success)
    {
        /* Schedule a run loop on which the client can be notified about stream events.  The client
         callback will be triggered via the run loop.  It's the caller's responsibility to ensure that
         the run loop is running. */
        CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        
        MyCFStreamSetUsernamePassword(writeStream, username, password);
        
        /* CFWriteStreamOpen will return success/failure.  Opening a stream causes it to reserve all the
         system resources it requires.  If the stream can open non-blocking, this will always return TRUE;
         listen to the run loop source to find out when the open completes and whether it was successful. */
        success = CFWriteStreamOpen(writeStream);
        if (success == false)
        {
            MyStreamInfoDestroy(streamInfo);
        }
    }
    else
    {
        MyStreamInfoDestroy(streamInfo);
    }

    return success;
}

#pragma mark Upload

static void MyUploadCallBack(CFWriteStreamRef writeStream, CFStreamEventType type, void * clientCallBackInfo)
{
    MyStreamInfo     *info = (MyStreamInfo *)clientCallBackInfo;
    CFIndex          bytesRead;
    CFIndex          bytesAvailable;
    CFIndex          bytesWritten;
    CFStreamError    error;
	
    assert(writeStream != NULL);
    assert(info        != NULL);
    assert(info->writeStream == writeStream);
	
    switch (type)
    {
        case kCFStreamEventOpenCompleted: // open complete
        {
            NSLog(@"kCFStreamEventOpenCompleted!");
        }
            break;
        case kCFStreamEventCanAcceptBytes:
        {
            if (info->leftOverByteCount > 0)
            {
                //bytesRead = 0;
                bytesAvailable = info->leftOverByteCount;
            }
            else
            {
                bytesRead = CFReadStreamRead(info->readStream, info->buffer, kMyBufferSize);
//                if (bytesRead < 0)
//                {
//                    MyStreamInfoDestroy(info);
//                }
                bytesAvailable = bytesRead;
            }
            //bytesWritten = 0;
            
            if (bytesAvailable == 0)
            {
				DELEGATE_CALLBACK(dataUploadFinished:, (__bridge id)(info->fileName));
                MyStreamInfoDestroy(info);
            }
            else
            {
                bytesWritten = CFWriteStreamWrite(info->writeStream, info->buffer, bytesAvailable);
                if (bytesWritten > 0)
                {
                    info->totalBytesWritten += bytesWritten;
                    if (bytesWritten < bytesAvailable)
                    {
                        info->leftOverByteCount = (UInt32)(bytesAvailable - bytesWritten);
                        memmove(info->buffer, info->buffer + bytesWritten, info->leftOverByteCount);
                    }
                    else
                    {
                        info->leftOverByteCount = 0;
                    }
                    DELEGATE_CALLBACK(progressAtPercent:, NUMBER(info->totalBytesWritten/1024));
                    
                }
                else if (bytesWritten < 0)
                {
                    NSLog(@"bytesWritten < 0");
                }
            }
        }
			break;
        case kCFStreamEventErrorOccurred:
        {
            error = CFWriteStreamGetError(info->writeStream);
			NSString *reason = [NSString stringWithFormat:@"CFReadStreamGetError returned (%ld, %d)\n", error.domain, (int)error.error];
            NSLog(@"kCFStreamEventErrorOccurred:%@",reason);
			DELEGATE_CALLBACK(dataUploadFailed:, reason);
            MyStreamInfoDestroy(info);
        }
            break;
        case kCFStreamEventEndEncountered:
        {
            NSLog(@"kCFStreamEventEndEncountered");
            MyStreamInfoDestroy(info);
        }
            break;
        default:
            break;
    }
}

static Boolean MySimpleUpload(CFStringRef uploadDirectory, CFURLRef fileURL, CFStringRef svrDir, CFStringRef username, CFStringRef password)
{
    CFWriteStreamRef       writeStream;
    CFReadStreamRef        readStream;
    CFStreamClientContext  context = { 0, NULL, NULL, NULL, NULL };
    CFURLRef               uploadURL, destinationURL;
    CFStringRef            fileName;
    Boolean                success = true;
    MyStreamInfo           *streamInfo;
	
    assert(uploadDirectory != NULL);
    assert(fileURL != NULL);
    assert(username != NULL);
    
    /* Create a CFURL from the upload directory string */
    destinationURL = CFURLCreateWithString(kCFAllocatorDefault, uploadDirectory, NULL);
    assert(destinationURL != NULL);
	
    /* Copy the end of the file path and use it as the file name. */
    fileName = CFURLCopyLastPathComponent(fileURL);
    assert(fileName != NULL);
    
    NSLog(@"filename:%@",fileName);
	
    /* Create the destination URL by taking the upload directory and appending the file name. */
    CFURLRef tempURL = destinationURL;
    if (svrDir != NULL)
        tempURL = CFURLCreateCopyAppendingPathComponent(NULL, destinationURL, svrDir, true);
    
    uploadURL = CFURLCreateCopyAppendingPathComponent(NULL, tempURL, fileName, false);
    
	assert(uploadURL != NULL);
    CFRelease(destinationURL);
    if (svrDir != NULL)
        CFRelease(tempURL);
    
    /* Create a CFReadStream from the local file being uploaded. */
    readStream = CFReadStreamCreateWithFile(NULL, fileURL);
    assert(readStream != NULL);
    
    /* Create an FTP write stream for uploading operation to a FTP URL. If the URL specifies a
	 directory, the open will be followed by a close event/state and the directory will have been
	 created. Intermediary directory structure is not created. */
    writeStream = CFWriteStreamCreateWithFTPURL(NULL, uploadURL);
    assert(writeStream != NULL);
    CFRelease(uploadURL);
    
    /* Initialize our MyStreamInfo structure, which we use to store some information about the stream. */
    MyStreamInfoCreate(&streamInfo, readStream, writeStream, fileName);
    context.info = (void *)streamInfo;
	
    /* CFReadStreamOpen will return success/failure.  Opening a stream causes it to reserve all the
	 system resources it requires.  If the stream can open non-blocking, this will always return TRUE;
	 listen to the run loop source to find out when the open completes and whether it was successful. */
    success = CFReadStreamOpen(readStream);
    if (success)
    {
        /* CFWriteStreamSetClient registers a callback to hear about interesting events that occur on a stream. */
        success = CFWriteStreamSetClient(writeStream, kNetworkEvents, MyUploadCallBack, &context);
        if (success)
        {
            /* Schedule a run loop on which the client can be notified about stream events.  The client
			 callback will be triggered via the run loop.  It's the caller's responsibility to ensure that
			 the run loop is running. */
            CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            
            MyCFStreamSetUsernamePassword(writeStream, username, password);
            
            /* CFWriteStreamOpen will return success/failure.  Opening a stream causes it to reserve all the
			 system resources it requires.  If the stream can open non-blocking, this will always return TRUE;
			 listen to the run loop source to find out when the open completes and whether it was successful. */		
            success = CFWriteStreamOpen(writeStream);
            if (success == false)
            {
                NSLog(@"CFWriteStreamOpen failed");
                MyStreamInfoDestroy(streamInfo);
            }
        }
        else
        {
            NSLog(@"CFWriteStreamSetClient failed!");
            MyStreamInfoDestroy(streamInfo);
        }
    }
    else
    {
        NSLog(@"CFReadStreamOpen failed!");
        MyStreamInfoDestroy(streamInfo);
    }

    return success;
}

static Boolean MySimpleUploadByData(CFStringRef uploadDirectory, NSData *fileData, CFStringRef username, CFStringRef password, NSString *imageName)
{
    CFWriteStreamRef       writeStream;
    CFReadStreamRef        readStream;
    CFStreamClientContext  context = { 0, NULL, NULL, NULL, NULL };
    CFURLRef               uploadURL, destinationURL;
    CFStringRef            fileName;
    Boolean                success = true;
    MyStreamInfo           *streamInfo;
    
    assert(uploadDirectory != NULL);
	assert((username != NULL) || (password == NULL) );
    
    /* Create a CFURL from the upload directory string */
    destinationURL = CFURLCreateWithString(kCFAllocatorDefault, uploadDirectory, NULL);
    assert(destinationURL != NULL);
	
    /* Copy the end of the file path and use it as the file name. */
    fileName = (__bridge CFStringRef)imageName;
    assert(fileName != NULL);
	
    /* Create the destination URL by taking the upload directory and appending the file name. */
    uploadURL = CFURLCreateCopyAppendingPathComponent(kCFAllocatorDefault, destinationURL, fileName, false);
	assert(uploadURL != NULL);
    CFRelease(destinationURL);
    //CFRelease(fileName);
    
    /* Create a CFReadStream from the local file being uploaded. */
	NSUInteger len = [fileData length];
	Byte *byteData = (Byte *)malloc(len);
	memcpy(byteData,[fileData bytes],len);
	readStream = CFReadStreamCreateWithBytesNoCopy(kCFAllocatorDefault, byteData, len, kCFAllocatorNull);
	
    assert(readStream != NULL);
    free(byteData);   //amen
    byteData = NULL;
    
	writeStream = CFWriteStreamCreateWithFTPURL(kCFAllocatorDefault, uploadURL);
    assert(writeStream != NULL);
    CFRelease(uploadURL);
    
    MyStreamInfoCreate(&streamInfo, readStream, writeStream, fileName);
    context.info = (void *)streamInfo;
	
	success = CFReadStreamOpen(readStream);
    if (success) {
        
        /* CFWriteStreamSetClient registers a callback to hear about interesting events that occur on a stream. */
        success = CFWriteStreamSetClient(writeStream, kNetworkEvents, MyUploadCallBack, &context);
        if (success) {
            /* Schedule a run loop on which the client can be notified about stream events.  The client
			 callback will be triggered via the run loop.  It's the caller's responsibility to ensure that
			 the run loop is running. */
            CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            
            MyCFStreamSetUsernamePassword(writeStream, username, password);
            // MyCFStreamSetFTPProxy(writeStream, &streamInfo->proxyDict); // no proxies!
            
            /* CFWriteStreamOpen will return success/failure.  Opening a stream causes it to reserve all the
			 system resources it requires.  If the stream can open non-blocking, this will always return TRUE;
			 listen to the run loop source to find out when the open completes and whether it was successful. */
            success = CFWriteStreamOpen(writeStream);
            if (success == false) {
                fprintf(stderr, "CFWriteStreamOpen failed\n");
                MyStreamInfoDestroy(streamInfo);
            }
        } else {
            fprintf(stderr, "CFWriteStreamSetClient failed\n");
            MyStreamInfoDestroy(streamInfo);
        }
    } else {
        fprintf(stderr, "CFReadStreamOpen failed\n");
        MyStreamInfoDestroy(streamInfo);
    }
    return success;
}

//创建文件夹
- (void)createDir:(NSString*)dirName
{
    if (!self.uname)
    {
        NSLog(@"用户名不能为空！");
        return;
    }

    CreateDirectory((__bridge CFStringRef)self.urlString, (__bridge CFStringRef)dirName, (__bridge CFStringRef)uname, (__bridge CFStringRef)pword);
}

//上传
- (void)upload:(NSURL *)fileItem svrDir:dirName
{
    if (!self.uname)
    {
        NSLog(@"用户名不能为空！");
        return;
    }
    
	if (!self.urlString)
    {
        NSLog(@"服务器地址不能为空！");
        return;
    }

    MySimpleUpload((__bridge CFStringRef)self.urlString, (__bridge CFURLRef)fileItem, (__bridge CFStringRef)dirName, (__bridge CFStringRef)uname, (__bridge CFStringRef)pword);
}

- (void)uploadByData:(NSData *)anItem fileName:(NSString *)imageName
{
	MySimpleUploadByData((__bridge CFStringRef)self.urlString, anItem, (__bridge CFStringRef)uname, (__bridge CFStringRef)pword, imageName);
}

+ (FTPHelper *) sharedInstance
{
	if(!sharedInstance)
        sharedInstance = [[self alloc] init];
    return sharedInstance;
}

@end


