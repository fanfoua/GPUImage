//
//  RCGPUImageGradientMapFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-8-14.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageGradientMapFilter.h"

NSString *const kRCGPUImageGradientMapShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
     vec3 luma = vec3(.30, .59, .11);

     float t = dot(luma, texel);

     vec3 gradSample = texture2D(inputImageTexture2, vec2(t, .5)).rgb;
     
     gl_FragColor = vec4(gradSample, 1.0);
 }
 );

@implementation RCGPUImageGradientMapFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kRCGPUImageGradientMapShaderString]))
    {
		return nil;
    }
    
    return self;
}

@end