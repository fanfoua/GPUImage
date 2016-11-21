//
//  RCGPUImageContrastMapFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/14.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageContrastMapFilter.h"

NSString *const kGPUImageRCContrastFragmentShaderString = SHADER_STRING
(
 precision lowp float;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 varying highp vec2 textureCoordinate;
 uniform lowp float contrast;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     vec3 data;
     data.r = texture2D(inputImageTexture2, vec2(textureColor.r, contrast)).r;
     data.g = texture2D(inputImageTexture2, vec2(textureColor.g, contrast)).g;
     data.b = texture2D(inputImageTexture2, vec2(textureColor.b, contrast)).b;
     
     gl_FragColor = vec4(data, 1.0);
 }
 );

@implementation RCGPUImageContrastMapFilter


- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageRCContrastFragmentShaderString]))
    {
        return nil;
    }
    
    contrastUniform = [filterProgram uniformIndex:@"contrast"];
    self.contrast = 0.0;
    
    return self;
}

- (void)setContrast:(CGFloat)newValue;
{
    _contrast = (newValue);
    [self setFloat:_contrast forUniform:contrastUniform program:filterProgram];
}
@end
