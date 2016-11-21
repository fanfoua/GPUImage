//
//  RCIGBoxBlurFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/4/22.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCIGBoxBlurFilter.h"

NSString *const kGPUImageIGBoxBlurFragmentShaderString = SHADER_STRING
(
 precision mediump float;
// uniform sampler2D s_texture;
 uniform sampler2D inputImageTexture;
 varying vec2 textureCoordinate;
// varying vec2 sourceTextureCoordinate;
 uniform float kernelSize;
 uniform vec2 blurVector;
 
 void main() {
     vec4 texel = texture2D(inputImageTexture, textureCoordinate);
     
     vec4 inputTexel = texel;
     vec4 avgValue = vec4(0.0);
     float coefficientSum = 0.0;
     
     // ceter pixel
     avgValue += texel;
     coefficientSum += 1.0;
     // Go through the remaining 8 vertical samples (4 on each side of the center)
     for (float i = 1.0; i < kernelSize + 1.0; i++) {
         avgValue += texture2D(inputImageTexture, textureCoordinate - i * blurVector);
         avgValue += texture2D(inputImageTexture, textureCoordinate + i * blurVector);
         coefficientSum += 2.0;
     }
     
     texel = avgValue / coefficientSum;
     gl_FragColor = texel;
 }
 );

@implementation RCIGBoxBlurFilter
@synthesize kernelSize = _kernelSize;
@synthesize blurVector = _blurVector;

- (id)init
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageIGBoxBlurFragmentShaderString]))
    {
        return nil;
    }
    
    kernelSizeUniform = [filterProgram uniformIndex:@"kernelSize"];
    blurVectorUniform = [filterProgram uniformIndex:@"blurVector"];
    self.kernelSize = 4.0;
    CGPoint p; p.x = 0.0; p.y = 1.0/1000.0;
    self.blurVector = p;
    
    return self;
}

- (void)setKernelSize:(CGFloat)newValue;
{
    _kernelSize = newValue;
    [self setFloat:_kernelSize forUniform:kernelSizeUniform program:filterProgram];
}

- (void)setBlurVector:(CGPoint)newValue
{
    _blurVector = newValue;
    [self setPoint:_blurVector forUniform:blurVectorUniform program:filterProgram];
}

@end