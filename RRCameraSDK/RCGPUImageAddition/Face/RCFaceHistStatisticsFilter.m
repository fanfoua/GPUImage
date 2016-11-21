//
//  RCFaceHistStatisticsFilter.cpp
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/5/5.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#include <stdio.h>
#include "RCFaceHistStatisticsFilter.h"

struct FACERECT facere;
FacePointData faceData;
FaceSticker faceSticker;
int ga_GrayHist[256];
int ga_HHist[360];

int F_GetFaceColorAndLight(unsigned char *imgPixel, int w, int h, int *p_pgray, int *p_pgrayave)
{
    int i,j;
    
    int w_sta,w_end,h_sta,h_end;
    unsigned char r,g,b,ucGray;
    int ntmp1,ntmp2;
    memset(ga_GrayHist, 0,sizeof(ga_GrayHist));
    memset(ga_HHist, 0, sizeof(ga_HHist));
    w_sta=facere.face_x;
    w_end=facere.face_x+facere.face_w;
    h_sta=facere.face_y;
    h_end=facere.face_y+facere.face_h;
    ntmp1=h_sta*w*4;
    for (i=h_sta; i<h_end; i++)
    {
        ntmp2=w_sta*4;
        for (j=w_sta; j<w_end; j++)
        {
            r=imgPixel[ntmp1+ntmp2];
            g=imgPixel[ntmp1+ntmp2+1];
            b=imgPixel[ntmp1+ntmp2+2];
            ucGray=max(max(r,g),b);
            ga_GrayHist[ucGray]++;

            ntmp2+=4;
        }
        ntmp1+=w*4;
    }
    
    int ncount=facere.face_w*facere.face_h;
    int ncount1=ncount*0.85;
    int ncount2=ncount*0.5;
    int nadd=0;
    int grayres=0;
    int grayave=255;
    //    int hres=0;
    for (i=0; i<256; i++)
    {
        nadd+=ga_GrayHist[255-i];
        if (nadd>=ncount1)
        {
            grayres=255-i;
            break;
        }
        if (nadd>=ncount2&&grayave==255)
        {
            grayave=255-i;
        }
    }
    *p_pgray=grayres;
    *p_pgrayave=grayave;
    return 1;
}
