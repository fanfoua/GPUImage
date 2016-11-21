//
//  RCGPUImageRotateFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/5/11.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageRotate90Filter.h"

NSString *const kGPUImageRotate90FragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform int flag;
 
 void main()
 {
     highp vec2 rotateCoord;
     if (flag == 1)
     {
         rotateCoord.x = textureCoordinate.y;
         rotateCoord.y = 1.0 - textureCoordinate.x;
     }
     else if (flag == -1)
     {
         rotateCoord.x = 1.0 - textureCoordinate.y;
         rotateCoord.y = textureCoordinate.x;
     }
     else
     {
         rotateCoord = textureCoordinate;
     }
     
     lowp vec4 textureColor = texture2D(inputImageTexture, rotateCoord);
     gl_FragColor = textureColor;
 }
 
 );

@implementation RCGPUImageRotate90Filter
@synthesize flag = _flag;

- (id)init
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageRotate90FragmentShaderString]))
    {
        return nil;
    }
    
    flagUniform = [filterProgram uniformIndex:@"flag"];
    self.flag = 0;
    
    return self;
}

- (void)setFlag:(GLint)newValue;
{
    _flag = newValue;
    [self setInteger:_flag forUniform:flagUniform program:filterProgram];
}

@end