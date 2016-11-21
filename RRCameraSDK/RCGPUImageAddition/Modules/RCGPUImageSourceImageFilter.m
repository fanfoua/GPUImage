//
//  RCGPUImageSourceImageFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/3/18.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageSourceImageFilter.h"

NSString *const kGPUImageSourceImageFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     gl_FragColor = textureColor;
 }
 );

@implementation RCGPUImageSourceImageFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageSourceImageFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end