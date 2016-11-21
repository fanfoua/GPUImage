//
//  RCGPUImageCartoonFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/6.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageCartoonFilter.h"

@implementation RCGPUImageCartoonFilter


-(NSString *) fragmentShaderForCartoon;
{
    int iRadius = 2;
    double sobelKernel[] = {-1,-1, 0, 1, 1};
    
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    [shaderString appendFormat:@"varying highp vec2 textureCoordinate;\n\
     uniform sampler2D inputImageTexture;\n\
     uniform mediump float texelWidthOffset;\n\
     uniform mediump float texelHeightOffset;\n\
     uniform mediump float threshold;\n\
     uniform mediump float amounts;\n\
     const mediump vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);\n\
         void main()\n\
         {\n\
         mediump vec4 sumX = vec4(0.0);\n\
         mediump vec4 dataX;\n\
         mediump vec4 temp = vec4(0.0);\n\
         mediump float step = 2.0;\n"];
    
    
    for (int i = -iRadius; i <= iRadius; i++) {
    [shaderString appendFormat:@"dataX = texture2D(inputImageTexture, textureCoordinate-vec2(%.2f*texelWidthOffset,0.0));\n\
            temp += dataX*(%f);\n", i * 1.0f, sobelKernel[i + iRadius]];
    }
    
    [shaderString appendFormat:@"sumX += abs(temp*amounts);\n\
    temp = vec4(0.0);\n"];
    for (int i = -iRadius; i <= iRadius; i++) {
    [shaderString appendFormat:@"dataX = texture2D(inputImageTexture, textureCoordinate-vec2(0.0,%.2f*texelHeightOffset));\n\
        temp += dataX*(%f);\n", i * 1.0f, sobelKernel[i + iRadius]];
    }
    [shaderString appendFormat:@"sumX += abs(temp*amounts);\n\
    if(sumX.r<threshold) sumX.r = 0.0;\n\
    if(sumX.g<threshold) sumX.g = 0.0;\n\
    if(sumX.b<threshold) sumX.b = 0.0;\n\
    sumX = 1.0-clamp(sumX/8.0,0.0,1.0);\n\
    sumX.rgb = vec3(dot(sumX.rgb, luminanceWeighting));\n\
    gl_FragColor=vec4(sumX.rgb,1.0);}"];
    return shaderString;
}

-(id)initThreshold:(CGFloat)threshold Amounts:(CGFloat)amounts
{
    if (!(self = [super initWithFragmentShaderFromString:[self fragmentShaderForCartoon]]))
    {
        return nil;
    }
//    threshold=0.001;
//    amounts=10.0;
    
    widthOffsetUniform = [filterProgram uniformIndex:@"texelWidthOffset"];
    heightOffsetUniform = [filterProgram uniformIndex:@"texelHeightOffset"];
    
    thresholdUniform = [filterProgram uniformIndex:@"threshold"];
    amountsUniform = [filterProgram uniformIndex:@"amounts"];
    
    [self setFloat:threshold forUniform:thresholdUniform program:filterProgram];
    [self setFloat:amounts forUniform:amountsUniform program:filterProgram];
    return self;
}

//提供给GPUImgFilter调用的用来设置图片大小的回调函数
- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    widthOffset = 1.0 / filterFrameSize.width;
    heightOffset = 1.0 / filterFrameSize.height;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext setActiveShaderProgram:filterProgram];
        glUniform1f(widthOffsetUniform, widthOffset);
        glUniform1f(heightOffsetUniform, heightOffset);
    });
    
}

@end
