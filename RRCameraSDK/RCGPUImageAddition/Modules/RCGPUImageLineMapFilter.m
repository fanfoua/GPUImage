//
//  RCGPUImageLineMapFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-4-9.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageLineMapFilter.h"

NSString *const kGPUImageLineMapFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 
 void main()
 {
     highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 textureColor2;
     textureColor2 = texture2D(inputImageTexture2, vec2(0.5,textureCoordinate.y));
     highp vec4 textureColor3;
     textureColor3.a=textureColor.a;
     textureColor3.r = texture2D(inputImageTexture3, vec2(1.0-textureColor2.r,textureColor.r)).r;
     textureColor3.g = texture2D(inputImageTexture3, vec2(1.0-textureColor2.g,textureColor.g)).g;
     textureColor3.b = texture2D(inputImageTexture3, vec2(1.0-textureColor2.b,textureColor.b)).b;
     
     gl_FragColor = vec4(textureColor3.rgb,1.0);
 }
 );

@implementation RCGPUImageLineMapFilter
- (id)init
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageLineMapFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end
