//
//  RCGPUImageNaturalSaturationFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-9-25.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageNaturalSaturationFilter.h"

NSString *const kGPUImageNaturalSaturationFragmentShaderString = SHADER_STRING
(
    varying highp vec2 textureCoordinate;
 
    uniform sampler2D inputImageTexture;
    uniform lowp float vibrance;
    precision highp float;

    void main()
    {
        lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
        lowp float big = max(textureColor.r, max(textureColor.g, textureColor.b));
        lowp float avg = (textureColor.r + textureColor.g + textureColor.b) / 3.0;
        lowp float amt = ((abs(big - avg) * 2.0) * vibrance) / (100.0/255.0);
        lowp float diff;
        
        if(textureColor.r != big) {
            diff = big - textureColor.r;
            textureColor.r += diff * amt;
        }
        
        if(textureColor.g != big) {
            diff = big - textureColor.g;
            textureColor.g += diff * amt;
        }
        
        if(textureColor.b != big) {
            diff = big - textureColor.b;
            textureColor.b += diff * amt;
        }
        
        gl_FragColor = textureColor;
    }
 );

@implementation RCGPUImageNaturalSaturationFilter

@synthesize vibrance = _vibrance;

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageNaturalSaturationFragmentShaderString]))
    {
        return nil;
    }
    
    vibranceUniform = [filterProgram uniformIndex:@"vibrance"];
    self.vibrance = 1.0;
    
    return self;
}

- (void)setVibrance:(CGFloat)newValue;
{
    _vibrance = newValue;
    [self setFloat:_vibrance forUniform:vibranceUniform program:filterProgram];
}
@end
