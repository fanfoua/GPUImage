//
//  RCGPUImageDressupFilter.h
//  Renren-iOS-StickerCamera
//
//  Created by 0153-00503 on 15/12/8.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageDressupFilter : GPUImageFilterGroup
{
    GPUImageTwoInputFilter *TwoInputFilter;
    GPUImageTwoInputFilter *TwoInputFilter2;
    GPUImageTwoInputFilter *TwoInputFilter3;
    GPUImagePicture *ImageSource1;
    GPUImagePicture *ImageSource2;
    GPUImagePicture *ImageSource3;
}
-(void)setBackImageDevicePosition:(int)model;
- (id)initIndex:(int)indx;
-(void)setBackImageProp:(CGFloat)prop Model:(int)model;
-(void)setBackImagerotationType: (int)rotationType Indx:(int)indxt;// previewRatio: (int)previewModel;
extern RCGPUImageDressupFilter *DressupFilter;
extern CGSize backImageSize;
extern int devModel;
@end
