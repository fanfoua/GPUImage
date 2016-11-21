//
//  RCGPUImageGetSkyFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/8.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageGetSkyFilter.h"

@implementation RCGPUImageGetSkyFilter
-(NSString *) fragmentShaderForGetSky;
{
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    [shaderString appendFormat:@"varying highp vec2 textureCoordinate;\n\
     uniform sampler2D inputImageTexture;\n\
     uniform mediump float avgbBrightness;\n\
     void main()\n\
     {\n\
         lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);\n\
         lowp vec4 rgba;\n\
         \n\
         if(textureColor.b>avgbBrightness&&textureColor.b>0.470588)\n\//0.470588&&textureColor.b>0.78125\n\
         {\n\
           rgba = vec4(1.0,1.0,1.0,1.0);\n\
         }\n\
         else\n\
         {\n\
           rgba = vec4(0.0,0.0,0.0,1.0);\n\
         }\n\
         gl_FragColor = rgba;\n\
     }"];
     return shaderString;
}

-(id)initAvgBrightness:(CGFloat) brightness
{
    if (!(self = [super initWithFragmentShaderFromString:[self fragmentShaderForGetSky]]))
    {
        return nil;
    }
    avgBrightness=brightness;
    
    avgBrightnessUniform = [filterProgram uniformIndex:@"avgBrightness"];
    
//    widthOffsetUniform= [filterProgram uniformIndex:@"texelWidthOffset"];
//    heightOffsetUniform= [filterProgram uniformIndex:@"texelHeightOffset"];
    
    [self setFloat:avgBrightness forUniform:avgBrightnessUniform program:filterProgram];
    
    return self;
}

@end
