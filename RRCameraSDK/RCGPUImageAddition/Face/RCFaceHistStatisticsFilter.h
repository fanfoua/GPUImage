//
//  RCFaceHistStatisticsFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/4/23.
//  Copyright (c) 2015年 renn. All rights reserved.
//
#ifndef _FACEHISTSTATISTICS
#define _FACEHISTSTATISTICS
//#import "GPUImageFilterGroup.h"
#import "Nativeclass.h"
#define max(x,y)  ( x>y?x:y )
#define min(x,y)  ( x<y?x:y )

struct FACERECT
{
    int face_x;
    int face_y;
    int face_w;
    int face_h;
    int eyeleft_x;
    int eyeleft_y;
    int eyeright_x;
    int eyeright_y;
};
extern struct FACERECT facere;
extern FacePointData faceData;
extern int ga_GrayHist[256];
extern int ga_HHist[360];
extern FaceSticker faceSticker;

//@interface RCFaceHistStatisticsFilter : GPUImageFilterGroup

int F_GetFaceColorAndLight(unsigned char *imgPixel, int w, int h, int *p_pgray, int *p_pgrayave);

#endif
