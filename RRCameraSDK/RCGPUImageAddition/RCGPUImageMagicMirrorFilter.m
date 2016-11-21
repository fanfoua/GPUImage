//
//  RCGPUImageMagicMirrorFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/30.
//  Copyright (c) 2015年 renn. All rights reserved.
//
//官客 哈哈镜
#import "RCGPUImageMagicMirrorFilter.h"
NSString *const kRCGPUImageMagicMirrorFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 highp float pi=3.141592653;
 void main()
 {
     highp vec2 textureCoordinatetmp = smoothstep(0.1,0.9,textureCoordinate);
     lowp vec2 tmp1=step(vec2(0.125),textureCoordinatetmp);
     lowp vec2 tmp2=step(vec2(0.875),textureCoordinatetmp);
     lowp vec2 tmp3=step(vec2(1.0),textureCoordinatetmp);
     
     mediump vec4 textureColor = texture2D(inputImageTexture, sin(((1.0-tmp1)*textureCoordinatetmp*2.0+(tmp1*(1.0-tmp2))*((textureCoordinatetmp-0.5)/1.5+0.5)+tmp2*((textureCoordinatetmp-0.875)*2.0+0.75))*pi*2.0)/14.0+textureCoordinate);
     gl_FragColor = textureColor;
 }
 );
@implementation RCGPUImageMagicMirrorFilter
-(id) init;
{
    if (!(self = [super init]))
    {
        return nil;
    }

    GPUImageFilter *filter = [[GPUImageFilter alloc] initWithFragmentShaderFromString:kRCGPUImageMagicMirrorFragmentShaderString];
    
    self.initialFilters = [NSArray arrayWithObjects:filter,nil];
    self.terminalFilter = filter;
    
    return self;
}
@end
