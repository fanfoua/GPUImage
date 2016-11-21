//
//  RCGPUImageColorBalanceKeepBrightnessMainFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/3.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageColorBalanceKeepBrightnessMainFilter : GPUImageFilterGroup
{
    GPUImagePicture *ImageSource1;
    GPUImagePicture *ImageSource2;
    GPUImagePicture *ImageSource3;
}
- (id)initShadowShiftR:(NSInteger) shadowShiftR shadowShiftG:(NSInteger) shadowShiftG  shadowShiftB: (NSInteger) shadowShiftB midShiftR: (NSInteger) midShiftR midShiftG:(NSInteger) midShiftG midShiftB:(NSInteger) midShiftB highlightShiftR:(NSInteger) highlightShiftR highlightShiftG:(NSInteger) highlightShiftG highlightShiftB:(NSInteger) highlightShiftB;
@end
