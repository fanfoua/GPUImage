//
//  RCFaceDetector.h
//  RRCameraDemo
//
//  Created by zhaodg on 15-4-23.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RCDetectorAccuracy) {
    RCDetectorAccuracyLow,
    RCDetectorAccuracyHigh,
};

@interface RCFaceDetectorModel : NSObject

@property (nonatomic, readonly, assign) CGRect bounds;
@property (nonatomic, readonly, assign) BOOL hasLeftEyePosition;
@property (nonatomic, readonly, assign) CGPoint leftEyePosition;
@property (nonatomic, readonly, assign) BOOL hasRightEyePosition;
@property (nonatomic, readonly, assign) CGPoint rightEyePosition;
@property (nonatomic, readonly, assign) BOOL hasMouthPosition;
@property (nonatomic, readonly, assign) CGPoint mouthPosition;

@end

@interface RCFaceDetector : NSObject



+ (instancetype)sharedInstance;

- (NSArray *)setImage:(UIImage *)image detectorAccuracy:(RCDetectorAccuracy)detectorAccuracy;

@end
