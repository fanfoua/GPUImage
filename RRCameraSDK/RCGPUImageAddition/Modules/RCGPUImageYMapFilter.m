//
//  RCGPUImageYMapFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-4-11.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageYMapFilter.h"

NSString *const kGPUImageYMapFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 textureColor2;
     textureColor2.r = texture2D(inputImageTexture2, vec2(textureCoordinate.y,textureColor.r)).r;
     textureColor2.g = texture2D(inputImageTexture2, vec2(textureCoordinate.y,textureColor.g)).g;
     textureColor2.b = texture2D(inputImageTexture2, vec2(textureCoordinate.y,textureColor.b)).b;
     gl_FragColor = vec4(textureColor2.rgb,1.0);
 }
 );

@implementation RCGPUImageYMapFilter
- (id)init
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageYMapFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end

