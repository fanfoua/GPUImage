//
//  RCGPUImageBrightnessNewFilter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 16/4/26.
//  Copyright © 2016年 renren. All rights reserved.
//

#import "RCGPUImageBrightnessNewFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageBrightnessNewFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform lowp float brightness;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     //gl_FragColor = vec4((textureColor.rgb + vec3(brightness)), textureColor.w);
     
     lowp vec3 outVal;
     highp float power = 1.0 + abs(brightness);
     
     if (brightness < 0.0) {
         power = 1.0 / power;
     }
     
     // a bow function that uses a "power curve" to bow the value
     // we flip it so it does more on the high end.
     outVal.r = 1.0 - pow((1.0 - textureColor.r), power);
     outVal.g = 1.0 - pow((1.0 - textureColor.g), power);
     outVal.b = 1.0 - pow((1.0 - textureColor.b), power);
     
     gl_FragColor = vec4(outVal.rgb, textureColor.a);
 }
 );
#else
NSString *const kGPUImageBrightnessNewFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform float brightness;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = vec4((textureColor.rgb + vec3(brightness)), textureColor.w);
 }
 );
#endif

@implementation RCGPUImageBrightnessNewFilter

@synthesize brightness = _brightness;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageBrightnessNewFragmentShaderString]))
    {
        return nil;
    }
    
    brightnessUniform = [filterProgram uniformIndex:@"brightness"];
    self.brightness = 0.0;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setBrightness:(CGFloat)newValue;
{
    _brightness = newValue;
    
    [self setFloat:_brightness forUniform:brightnessUniform program:filterProgram];
}

@end
