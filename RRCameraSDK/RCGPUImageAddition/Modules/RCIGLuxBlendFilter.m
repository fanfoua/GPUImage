//
//  RCIGLuxBlendFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/4/22.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCIGLuxBlendFilter.h"

NSString *const kGPUImageIGLuxBlendFragmentShaderString = SHADER_STRING
(
 precision mediump float;
// uniform sampler2D s_texture;
 uniform sampler2D inputImageTexture;

 varying vec2 textureCoordinate;
// varying vec2 sourceTextureCoordinate;
 // uniform sampler2D starlight;
 // uniform sampler2D antilux;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 uniform float luxBlendAmount;
 
 void main() {
//     vec4 texel = texture2D(s_texture, sourceTextureCoordinate);
     vec4 texel = texture2D(inputImageTexture, textureCoordinate);
     vec4 inputTexel = texel;
     if (luxBlendAmount >= 0.0) {
//         texel = mix(texel, texture2D(starlight, sourceTextureCoordinate), luxBlendAmount);
         texel = mix(texel, texture2D(inputImageTexture2, textureCoordinate), luxBlendAmount);
     } else {
//         texel = mix(texel, texture2D(antilux, sourceTextureCoordinate), -luxBlendAmount);
         texel = mix(texel, texture2D(inputImageTexture3, textureCoordinate), -luxBlendAmount);
     }
     gl_FragColor = texel;
 } );

@implementation RCIGLuxBlendFilter
@synthesize luxBlendAmount = _luxBlendAmount;

- (id)init
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageIGLuxBlendFragmentShaderString]))
    {
        return nil;
    }
    
    luxBlendAmountUniform = [filterProgram uniformIndex:@"luxBlendAmount"];
    self.luxBlendAmount = 0.0;
    
    return self;
}

- (void)setLuxBlendAmount:(CGFloat)newValue
{
    _luxBlendAmount = newValue;
    [self setFloat:_luxBlendAmount forUniform:luxBlendAmountUniform program:filterProgram];
}
@end