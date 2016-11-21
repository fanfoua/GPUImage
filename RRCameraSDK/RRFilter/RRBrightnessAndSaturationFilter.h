//
//  RRBrightnessAndSaturationFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 14-8-8.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#ifndef RRCameraSDK_RRBrightnessAndSaturationFilter_h
#define RRCameraSDK_RRBrightnessAndSaturationFilter_h

//channels == 4
//return value:
//  -1 , -2: parameter error
//  0: correct
int BrightnessAndSaturation(unsigned char* src, int height,  int width,
                             int channels);

#endif

