//
//  RCGPUImageAutoContrastFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/4/29.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageAutoContrastFilter.h"
#define max(x,y)  ( x>y?x:y )
#define min(x,y)  ( x<y?x:y )


NSString *const kGPUImageAutoContrastShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform highp float ga_HistLight[256];
 
 void main()
 {
     highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = vec4(ga_HistLight[int(textureColor.r*255.0)], ga_HistLight[int(textureColor.g*255.0)],
                         ga_HistLight[int(textureColor.b*255.0)], 1.0);
 }
 );
@implementation RCGPUImageAutoContrastFilter

int ga_HistR[256];
int ga_HistG[256];
int ga_HistB[256];
float ga_HistLight[256];

int F_GetHist(unsigned char *pimg, int w, int h, int step, float thr)
{
    memset(ga_HistR, 0, sizeof(ga_HistR));
    memset(ga_HistG, 0, sizeof(ga_HistG));
    memset(ga_HistB, 0, sizeof(ga_HistB));
    
    int size=w*h;
    int tmp=0;
    int steptmp=step*4;
    for (int i=0; i<size; i+=step)
    {
        ga_HistR[pimg[tmp]]++;
        ga_HistG[pimg[tmp+1]]++;
        ga_HistB[pimg[tmp+2]]++;
        tmp+=steptmp;
    }
    
    int count=size/step;
    count=count*thr;
    
    tmp=0;
    int min_R=0;
    for (int i=0; i<256; i++)
    {
        tmp+=ga_HistR[i];
        if (tmp>=count)
        {
            
            break;
        }
        
        if (ga_HistR[i]>0)
        {
            min_R=i;
        }
    }
    
    int max_R=255;
    tmp=0;
    for (int i=255; i>=0; i--)
    {
        tmp+=ga_HistR[i];
        if (tmp>=count)
        {
            break;
        }
        
        if (ga_HistR[i]>0)
        {
            max_R=i;
        }
    }
    
    tmp=0;
    int min_G=0;
    for (int i=0; i<256; i++)
    {
        tmp+=ga_HistG[i];
        if (tmp>=count)
        {
            
            break;
        }
        
        if (ga_HistG[i]>0)
        {
            min_G=i;
        }
    }
    
    int max_G=255;
    tmp=0;
    for (int i=255; i>=0; i--)
    {
        tmp+=ga_HistG[i];
        if (tmp>=count)
        {
            
            break;
        }
        
        if (ga_HistG[i]>0)
        {
            max_G=i;
        }
    }
    
    tmp=0;
    int min_B=0;
    for (int i=0; i<256; i++)
    {
        tmp+=ga_HistB[i];
        if (tmp>=count)
        {
            
            break;
        }
        
        if (ga_HistB[i]>0)
        {
            min_B=i;
        }
    }
    
    int max_B=255;
    tmp=0;
    for (int i=255; i>=0; i--)
    {
        tmp+=ga_HistB[i];
        if (tmp>=count)
        {
            
            break;
        }
        
        if (ga_HistB[i]>0)
        {
            max_B=i;
        }
    }
    
    int minLight,maxLight;
    minLight=min(min(min_R,min_G),min_B);
    maxLight=max(max(max_R,max_G),max_B);
    
    int minRes,maxRes;
    minRes=max(minLight-35, 0);
    maxRes=min(maxLight+35, 255);
    
    if (minLight>=maxLight)
    {
        for (int i=0; i<256; i++)
        {
            ga_HistLight[i] = i/255.0;
        }
    }
    else
    {
        for (int i=0; i<=minLight; i++)
        {
            ga_HistLight[i] = minRes/255.0;
        }
        
        for (int i=minLight+1; i<maxLight; i++)
        {
            ga_HistLight[i] = (((maxRes-minRes)*(i - minLight)*1.0 / (maxLight - minLight))+minRes)/255.0;
        }
        
        for (int i=maxLight; i<256; i++)
        {
            ga_HistLight[i] = maxRes/255.0;
        }
    }
    
    return 1;
}

- (id)initImg:(unsigned char *)img initW:(int)w initH:(int)h initThr:(float)thr
{
    int step;
    if ((w*h)>1000000)
    {
        step=8;
    }
    else
    {
        step=4;
    }
    F_GetHist(img, w, h, step, thr);
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageAutoContrastShaderString]))
    {
        return nil;
    }
    
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];

        histUniform = [filterProgram uniformIndex:@"ga_HistLight"];
        
    });
    return self;
}

//提供给GPUImgFilter调用的用来设置图片大小的回调函数
- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext setActiveShaderProgram:filterProgram];

        glUniform1fv(histUniform, 256, ga_HistLight);
    });
}
@end
