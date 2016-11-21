//
//  RCGPUImageBrightnessMapFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/14.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageBrightnessMapFilter.h"

NSString *const kGPUImageRCBrightnessFragmentShaderString = SHADER_STRING
(
 precision lowp float;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 varying highp vec2 textureCoordinate;
 uniform lowp float brightness;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     vec3 data;
     data.r = texture2D(inputImageTexture2, vec2(textureColor.r, brightness)).r;
     data.g = texture2D(inputImageTexture2, vec2(textureColor.g, brightness)).g;
     data.b = texture2D(inputImageTexture2, vec2(textureColor.b, brightness)).b;
     
     gl_FragColor = vec4(data, 1.0);
 }
 );
@implementation RCGPUImageBrightnessMapFilter
@synthesize brightness = _brightness;

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageRCBrightnessFragmentShaderString]))
    {
        return nil;
    }

    brightnessUniform = [filterProgram uniformIndex:@"brightness"];
    self.brightness = 0.0;
    
    return self;
}

- (void)setBrightness:(CGFloat)newValue;
{
    _brightness = newValue;
    [self setFloat:_brightness forUniform:brightnessUniform program:filterProgram];
}
@end
