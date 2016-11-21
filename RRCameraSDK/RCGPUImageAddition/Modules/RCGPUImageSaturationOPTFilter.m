//
//  RCGPUImageSaturationOPTFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-3-18.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageSaturationOPTFilter.h"

NSString *const kRCGPUImageSaturationOPTFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform highp float saturation;
 
 void main()
 {
     mediump float S;
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp float maxVal=max(textureColor.r,max(textureColor.g,textureColor.b));
     lowp float minVal=min(textureColor.r,min(textureColor.g,textureColor.b));
     mediump float delta=maxVal-minVal;
     mediump float adVal=maxVal+minVal;
     mediump float L=adVal/2.0;
     mediump float bps = 0.001;
     
     
     if (L<0.5)
     {
         S=delta/adVal;
     }
     else
     {
         S=delta/((2.0-adVal)+bps);
     }
     mediump float sVal=saturation;
     if (saturation>0.0)
     {
         sVal=saturation+S>=1.0?S:1.0-sVal;
         sVal=1.0/sVal-1.0;
     }
     
     lowp vec3 texRes=clamp(textureColor.rgb+(textureColor.rgb-L)*sVal,0.0,1.0);
     gl_FragColor=vec4(texRes,textureColor.a);
 }
 );

@implementation RCGPUImageSaturationOPTFilter
@synthesize saturation = _saturation;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kRCGPUImageSaturationOPTFragmentShaderString]))
    {
        return nil;
    }
    
    saturationUniform = [filterProgram uniformIndex:@"saturation"];
    self.saturation = 1.0;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setSaturation:(CGFloat)newValue;
{
    _saturation = newValue / 100.0;
    
    [self setFloat:_saturation forUniform:saturationUniform program:filterProgram];
}
@end