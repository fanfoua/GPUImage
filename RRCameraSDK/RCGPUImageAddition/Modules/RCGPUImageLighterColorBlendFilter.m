//
//  RCGPUImageLightColorBlendFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-1-15.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCGPUImageLighterColorBlendFilter.h"
NSString *const kGPUImageLighterColorFillFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform lowp float mixturePercent;
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     lowp float sumColor = textureColor2.r+textureColor2.g+textureColor2.b;
     lowp float delta = (textureColor.r+textureColor.g+textureColor.b) * mixturePercent - (sumColor);
     if(delta >= 0.0)
     {
         gl_FragColor = textureColor;
     }
     else
     {
         gl_FragColor = textureColor2;
     }
 });

@implementation RCGPUImageLighterColorBlendFilter

//浅色叠加系数，输入叠加不透明度即可
- (id)initMixturePercent: (CGFloat)mixturePercent;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageLighterColorFillFragmentShaderString]))
    {
        return nil;
    }
    mixUniform = [filterProgram uniformIndex:@"mixturePercent"];
    self.mix = mixturePercent;
    return self;
}

- (void)setMix:(CGFloat)newValue;
{
    _mix = newValue;
    
    [self setFloat:_mix forUniform:mixUniform program:filterProgram];
}

@end
