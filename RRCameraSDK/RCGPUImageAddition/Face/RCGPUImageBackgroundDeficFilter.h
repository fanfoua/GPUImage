//
//  RCGPUImageBackgroundDeficFilter.h
//  Renren-iOS-StickerCamera
//
//  Created by 0153-00503 on 15/12/7.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "Nativeclass.h"

@interface RCGPUImageBackgroundDeficFilter : GPUImageFilterGroup
{
    GPUImageTwoInputFilter *TwoInputFilter;
}
- (id)initFaceStruct:(FacePointData *)faceData;
-(void)setFaceRect:(FacePointData *)faceData Model: (int)viModel;
extern RCGPUImageBackgroundDeficFilter *BackgroundDeficFilter;
@end
