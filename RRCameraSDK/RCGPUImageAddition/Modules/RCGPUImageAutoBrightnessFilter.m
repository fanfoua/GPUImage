//
//  RCGPUImageAutoBrightnessFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-8-25.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageAutoBrightnessFilter.h"

NSString *const kGPUImageAutoBrightnessFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform lowp float brightness;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     textureColor.r += textureColor.r*brightness;
     textureColor.b += textureColor.b*brightness;
     textureColor.g += textureColor.g*brightness;
     
     gl_FragColor = vec4(textureColor.rgb, textureColor.w);
 }
 );

@implementation RCGPUImageAutoBrightnessFilter

@synthesize brightness = _brightness;

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageAutoBrightnessFragmentShaderString]))
    {
		return nil;
    }
    
    brightnessUniform = [filterProgram uniformIndex:@"brightness"];
    self.brightness = 1.0;
    
    return self;
}

- (void)setBrightness:(CGFloat)newValue;
{
    _brightness = newValue;
    
    [self setFloat:_brightness forUniform:brightnessUniform program:filterProgram];
}

@end