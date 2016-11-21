//
//  RCGPUImageMaskFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-8-20.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageMaskFilter.h"

NSString *const kRCGPUImageMaskFilterShaderString = SHADER_STRING
(
 precision lowp float;

 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
// uniform lowp float alpha;

 void main()
 {
     vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
     vec3 mask = vec3(texture2D(inputImageTexture2, textureCoordinate).a);
     texel = texel * mask;
     
     gl_FragColor = vec4(texel, 0.6);
 }
 );

@implementation RCGPUImageMaskFilter
//@synthesize alpha = _alpha;

- (id)init
{
    if (!(self = [super initWithFragmentShaderFromString:kRCGPUImageMaskFilterShaderString])) {
        return nil;
    }
    
//    alphaUniform = [filterProgram uniformIndex:@"alpha"];
//    self.alpha = 1.0;
    return self;
}

//- (void)setAlpha:(CGFloat)newValue;
//{
//    _alpha = newValue;
//    
//    [self setFloat:_alpha forUniform:alphaUniform program:filterProgram];
//}

@end