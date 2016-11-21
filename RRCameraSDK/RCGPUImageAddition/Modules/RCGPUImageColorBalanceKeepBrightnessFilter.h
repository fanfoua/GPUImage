//
//  RCGPUImageColorBalanceKeepBrightnessFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/1.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "RCGPUImageFourInputFilter.h"
@interface RCGPUImageColorBalanceKeepBrightnessFilter : RCGPUImageFourInputFilter
{
     int mshadowShiftR;
     int mshadowShiftG;
     int mshadowShiftB;
    
     int mmidShiftR;
     int mmidShiftG;
     int mmidShiftB;
    
     int mhighlightShiftR;
     int mhighlightShiftG;
     int mhighlightShiftB;
    
    GLint mshadowShiftRUniform;
    GLint mshadowShiftGUniform;
    GLint mshadowShiftBUniform;
    
    GLint mmidShiftRUniform;
    GLint mmidShiftGUniform;
    GLint mmidShiftBUniform;
    
    GLint mhighlightShiftRUniform;
    GLint mhighlightShiftGUniform;
    GLint mhighlightShiftBUniform;
    
    GPUImagePicture *ImageSource1;
    GPUImagePicture *ImageSource2;
    GPUImagePicture *ImageSource3;
}
- (int)setColorBalanceParamshadowShiftR:(float) shadowShiftR shadowShiftG:(float) shadowShiftG  shadowShiftB: (float) shadowShiftB midShiftR: (float) midShiftR midShiftG:(float) midShiftG midShiftB:(float) midShiftB highlightShiftR:(float) highlightShiftR highlightShiftG:(float) highlightShiftG highlightShiftB:(float) highlightShiftB;

- (id)initShadowShiftR:(NSInteger) shadowShiftR shadowShiftG:(NSInteger) shadowShiftG  shadowShiftB: (NSInteger) shadowShiftB midShiftR: (NSInteger) midShiftR midShiftG:(NSInteger) midShiftG midShiftB:(NSInteger) midShiftB highlightShiftR:(NSInteger) highlightShiftR highlightShiftG:(NSInteger) highlightShiftG highlightShiftB:(NSInteger) highlightShiftB;
@end
