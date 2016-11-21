//
//  RCGPUImageSingleChannelFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/29.
//  Copyright (c) 2015年 renn. All rights reserved.
//
//官客 单通道滤镜
#import "RCGPUImageSingleChannelFilter.h"
#import "Modules/RCGPUImageContrastFilter.h"

NSString *const kRCGPUImageSingleChannelFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
  highp float pi=3.141592653;
 void main()
 {
     lowp vec4 textureColorsrc = texture2D(inputImageTexture, textureCoordinate);
     lowp float r = textureColorsrc.r;
     lowp float g = textureColorsrc.g;
     lowp float b = textureColorsrc.b;
     
     lowp float maxValue = max(r, max(g, b));
     lowp float minValue = min(r, min(g, b));
     
     //convert to hue
     highp float hue = 0.0;
     if (maxValue == minValue)
     {
         hue = 0.0;
     }
     else if (maxValue == r && g >= b)
     {
         hue = 60.0 * (g - b) / (maxValue - minValue);
     }
     else if (maxValue == r && g < b)
     {
         hue = 60.0 * (g - b) / (maxValue - minValue) + 360.0;
     }
     else if (maxValue == g)
     {
         hue = 60.0 * (b - r) / (maxValue - minValue) + 120.0;
     }
     else if (maxValue == b)
     {
         hue = 60.0 * (r - g) / (maxValue - minValue) + 240.0;
     }
     
     highp float s=0.0;
     if(maxValue>0.0)
     {
         s=(maxValue-minValue)/maxValue;
     }
     lowp vec4 textureColortmp=textureColorsrc;
     highp float ftmp = textureColortmp.r;//(textureColortmp.r+textureColortmp.b+textureColortmp.g)/3.0;
     if((hue>330.0||hue<=30.0)&&(s>=0.15)&&(maxValue>=0.2))
     {
             highp float utmp=(smoothstep(0.0,30.0,30.0-hue)+smoothstep(330.0,360.0,hue))*smoothstep(0.15,0.6,s)*smoothstep(0.2,0.45,maxValue);
         utmp=(utmp*utmp*utmp+utmp*utmp)/2.0;//(-cos(utmp*pi)+1.0)/2.0;
         //utmp=1.0-sqrt(1.0-utmp*utmp);
             highp float u1 = utmp*0.6+1.0;
             highp float u2 = (utmp*1.3+1.0);
             highp float u3 = (utmp*2.2+1.0);
             textureColortmp.r=min(ftmp*u1,1.0);
             textureColortmp.g=ftmp/u2;
             textureColortmp.b=ftmp/u3;
     }
     else
     {
         
         textureColortmp.r=ftmp;
         textureColortmp.g=ftmp;
         textureColortmp.b=ftmp;
     }
     gl_FragColor = textureColortmp;
 }
 );

@implementation RCGPUImageSingleChannelFilter
-(id) init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
       GPUImageFilter *filter = [[GPUImageFilter alloc] initWithFragmentShaderFromString:kRCGPUImageSingleChannelFragmentShaderString];
    
    RCGPUImageContrastFilter *ContrastFilter = [[RCGPUImageContrastFilter alloc] init];
    [(RCGPUImageContrastFilter *)ContrastFilter setContrast:50];
    [self addFilter:ContrastFilter];
    [filter addTarget:ContrastFilter];

    self.initialFilters = [NSArray arrayWithObjects:filter,nil];
    self.terminalFilter = ContrastFilter;
    return self;
}
@end
