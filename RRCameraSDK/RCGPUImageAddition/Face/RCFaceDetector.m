//
//  RCFaceDetector.m
//  RRCameraDemo
//
//  Created by zhaodg on 15-4-23.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCFaceDetector.h"

@interface RCFaceDetectorModel()

@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) BOOL hasLeftEyePosition;
@property (nonatomic, assign) CGPoint leftEyePosition;
@property (nonatomic, assign) BOOL hasRightEyePosition;
@property (nonatomic, assign) CGPoint rightEyePosition;
@property (nonatomic, assign) BOOL hasMouthPosition;
@property (nonatomic, assign) CGPoint mouthPosition;

@end

@implementation RCFaceDetectorModel

@end

@interface RCFaceDetector()

@property (nonatomic, nonatomic, strong) UIImage *image;

@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, assign) RCDetectorAccuracy detectorAccuracy;


@end

@implementation RCFaceDetector

+ (instancetype)sharedInstance
{
    static RCFaceDetector *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (NSArray *)setImage:(UIImage *)image detectorAccuracy:(RCDetectorAccuracy)detectorAccuracy
{
    self.image = image;
    self.detectorAccuracy = detectorAccuracy;

    NSMutableArray *results = [NSMutableArray array];

    int exifOrientation;
    switch (self.image.imageOrientation) {
        case UIImageOrientationUp:
            exifOrientation = 1;
            break;
        case UIImageOrientationDown:
            exifOrientation = 3;
            break;
        case UIImageOrientationLeft:
            exifOrientation = 8;
            break;
        case UIImageOrientationRight:
            exifOrientation = 6;
            break;
        case UIImageOrientationUpMirrored:
            exifOrientation = 2;
            break;
        case UIImageOrientationDownMirrored:
            exifOrientation = 4;
            break;
        case UIImageOrientationLeftMirrored:
            exifOrientation = 5;
            break;
        case UIImageOrientationRightMirrored:
            exifOrientation = 7;
            break;
        default:
            break;
    }

    NSDictionary *detectorOptions = nil;
    switch (self.detectorAccuracy) {
        case RCDetectorAccuracyLow:
            detectorOptions = @{ CIDetectorAccuracy : CIDetectorAccuracyLow};
            break;
        case RCDetectorAccuracyHigh:
            detectorOptions = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh};
            break;
        default:
            break;
    }
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];

    NSArray *features = [faceDetector featuresInImage:[CIImage imageWithCGImage:self.image.CGImage]
                                              options:@{CIDetectorImageOrientation:[NSNumber numberWithInt:exifOrientation]}];

    for (CIFaceFeature * feature in features) {
        CGRect faceBounds = [self boundsForImage:self.image fromBounds:feature.bounds];
        CGPoint leftEyePoint = [self pointForImage:self.image fromPoint:feature.leftEyePosition];
        CGPoint rightEyePoint = [self pointForImage:self.image fromPoint:feature.rightEyePosition];
        CGPoint mouthPoint = [self pointForImage:self.image fromPoint:feature.mouthPosition];

        RCFaceDetectorModel *detectorModel = [[RCFaceDetectorModel alloc] init];
        detectorModel.bounds = faceBounds;
        detectorModel.leftEyePosition = leftEyePoint;
        detectorModel.rightEyePosition = rightEyePoint;
        detectorModel.mouthPosition = mouthPoint;
        detectorModel.hasLeftEyePosition = feature.hasLeftEyePosition;
        detectorModel.hasRightEyePosition = feature.hasRightEyePosition;
        detectorModel.hasMouthPosition = feature.hasMouthPosition;
        [results addObject:detectorModel];
    }

    return results;
}

#pragma mark - internal func

- (CGPoint)pointForImage:(UIImage*)image fromPoint:(CGPoint)originalPoint {

    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;

    CGPoint convertedPoint;

    switch (image.imageOrientation) {
        case UIImageOrientationUp:
            convertedPoint.x = originalPoint.x;
            convertedPoint.y = imageHeight - originalPoint.y;
            break;
        case UIImageOrientationDown:
            convertedPoint.x = imageWidth - originalPoint.x;
            convertedPoint.y = originalPoint.y;
            break;
        case UIImageOrientationLeft:
            convertedPoint.x = imageWidth - originalPoint.y;
            convertedPoint.y = imageHeight - originalPoint.x;
            break;
        case UIImageOrientationRight:
            convertedPoint.x = originalPoint.y;
            convertedPoint.y = originalPoint.x;
            break;
        case UIImageOrientationUpMirrored:
            convertedPoint.x = imageWidth - originalPoint.x;
            convertedPoint.y = imageHeight - originalPoint.y;
            break;
        case UIImageOrientationDownMirrored:
            convertedPoint.x = originalPoint.x;
            convertedPoint.y = originalPoint.y;
            break;
        case UIImageOrientationLeftMirrored:
            convertedPoint.x = imageWidth - originalPoint.y;
            convertedPoint.y = originalPoint.x;
            break;
        case UIImageOrientationRightMirrored:
            convertedPoint.x = originalPoint.y;
            convertedPoint.y = imageHeight - originalPoint.x;
            break;
        default:
            break;
    }
    return convertedPoint;
}

- (CGSize) sizeForImage:(UIImage *) image fromSize:(CGSize) originalSize{
    CGSize convertedSize;

    switch (image.imageOrientation) {
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            convertedSize.width = originalSize.width;
            convertedSize.height = originalSize.height;
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            convertedSize.width = originalSize.height;
            convertedSize.height = originalSize.width;
            break;
        default:
            break;
    }
    return convertedSize;
}

- (CGRect) boundsForImage:(UIImage *) image fromBounds:(CGRect) originalBounds{

    CGPoint convertedOrigin = [self pointForImage:image fromPoint:originalBounds.origin];;
    CGSize convertedSize = [self sizeForImage:image fromSize:originalBounds.size];

    switch (image.imageOrientation) {
        case UIImageOrientationUp:
            convertedOrigin.y -= convertedSize.height;
            break;
        case UIImageOrientationDown:
            convertedOrigin.x -= convertedSize.width;
            break;
        case UIImageOrientationLeft:
            convertedOrigin.x -= convertedSize.width;
            convertedOrigin.y -= convertedSize.height;
        case UIImageOrientationRight:
            break;
        case UIImageOrientationUpMirrored:
            convertedOrigin.y -= convertedSize.height;
            convertedOrigin.x -= convertedSize.width;
            break;
        case UIImageOrientationDownMirrored:
            break;
        case UIImageOrientationLeftMirrored:
            convertedOrigin.x -= convertedSize.width;
            convertedOrigin.y += convertedSize.height;
        case UIImageOrientationRightMirrored:
            convertedOrigin.y -= convertedSize.height;
            break;
        default:
            break;
    }

    return CGRectMake(convertedOrigin.x, convertedOrigin.y,
                      convertedSize.width, convertedSize.height);
}

@end