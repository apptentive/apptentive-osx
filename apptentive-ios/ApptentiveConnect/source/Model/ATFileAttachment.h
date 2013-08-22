//
//  ATFileAttachment.h
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 2/20/13.
//  Copyright (c) 2013 Apptentive, Inc. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif
#import <CoreData/CoreData.h>

@class ATFileMessage;

typedef enum {
	ATFileAttachmentSourceUnknown,
	ATFileAttachmentSourceScreenshot,
	ATFileAttachmentSourceCamera,
	ATFileAttachmentSourcePhotoLibrary,
} ATFIleAttachmentSource;

//TODO: Add CGSize for images?
@interface ATFileAttachment : NSManagedObject
@property (nonatomic, retain) NSString *localPath;
@property (nonatomic, retain) NSString *mimeType;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *source;
@property (nonatomic, retain) NSNumber *transient;
@property (nonatomic, retain) NSNumber *userVisible;
@property (nonatomic, retain) ATFileMessage *fileMessage;

- (void)setFileData:(NSData *)data;
- (void)setFileFromSourcePath:(NSString *)sourceFilename;

- (NSString *)fullLocalPath;

#if TARGET_OS_IPHONE
- (UIImage *)thumbnailOfSize:(CGSize)size;
#elif TARGET_OS_MAC
#endif
- (void)createThumbnailOfSize:(CGSize)size completion:(void (^)(void))completion;
@end
