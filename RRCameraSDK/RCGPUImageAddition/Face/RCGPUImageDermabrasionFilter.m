//
//  RCGPUImageDermabrasionFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/4/17.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageDermabrasionFilter.h"

float paraArray[256];

@implementation RCGPUImageDermabrasionFilter
#define MIN_RADIUS 2
#define MAX_RADIUS 4
- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;
{
    return self;
}

- (id)initRadius:(int)radius initThreshold:(GLfloat)thr;
{
    [self setStep:1 setThreshold:thr];//步长设置为1
    iRadius=MIN(MIN(MAX((radius+1)/2, MIN_RADIUS),radius),MAX_RADIUS);
    fStep=(1.0*radius)/iRadius;
    NSString *currentSurfaceblurVertexShader = [self vertexShaderForSurfaceblur];
    NSString *currentSurfaceblurFragmentShader = [self  fragmentShaderForSurfaceblur];
    
    if (!(self = [super initWithVertexShaderFromString:currentSurfaceblurVertexShader fragmentShaderFromString:currentSurfaceblurFragmentShader]))
    {
        return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        surfaceblurWidthOffsetUniform = [filterProgram uniformIndex:@"texelWidthOffset"];
        surfaceblurHeightOffsetUniform = [filterProgram uniformIndex:@"texelHeightOffset"];
        
    });
    
    
    

    return self;
}

#pragma mark -
#pragma mark Auto-generation of optimized Gaussian shaders

- (void)setStep: (int)step setThreshold: (GLfloat)threshold
{
    glstepforsurfaceblur=1;
    fThreshold=threshold;
}

- (NSString *)vertexShaderForSurfaceblur;
{
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    // Header
    [shaderString appendFormat:@"\
     attribute vec4 position;\n\
     attribute vec4 inputTextureCoordinate;\n\
     attribute vec4 inputTextureCoordinate2;\n\
     attribute vec4 inputTextureCoordinate3;\n\
     \n\
     uniform float texelWidthOffset;\n\
     uniform float texelHeightOffset;\n\
     varying vec2 textureCoord;\n\
     \n\
     void main()\n\
     {\n\
     gl_Position = position;\n\
     textureCoord = inputTextureCoordinate.xy;\n\
     "];
    
    // Footer
    [shaderString appendString:@"}\n"];
    
    return shaderString;
}

- (NSString *)fragmentShaderForSurfaceblur;
{
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    
    // Header
    [shaderString appendFormat:@"\
     uniform sampler2D inputImageTexture;\n\
     uniform sampler2D inputImageTexture2;\n\
     uniform sampler2D inputImageTexture3;\n\
     uniform highp float texelWidthOffset;\n\
     uniform highp float texelHeightOffset;\n\
     \n\
     varying highp vec2 textureCoord;\n\
     \n\
     void main()\n\
     {\n\
     highp vec4 sum = vec4(0.0);\n\
     lowp vec4 nowdata = texture2D(inputImageTexture, textureCoord);\n\
     lowp vec4 nowdata2 = texture2D(inputImageTexture2, textureCoord);\n\
     lowp vec4 datatmp;\n\
     highp vec4 weight = vec4(1.0);\n\
     highp vec4 k;\n\
     "];
    
    // Inner texture loop
    [shaderString appendFormat:@"sum += nowdata;\n"];
    
   // int tdm = int(max(max(nowdata.r,nowdata.g),nowdata.b)*255.0);\n\
    //highp float temp = (paraArray[int(nowdata3.r/2048.0)]+0.00001);\n\
    
    
    //highp float tddd = 2.5*255.0*nowdata3.r/2048.0;\n\
    //highp float tddd = 2.5*paraArray[int(max(max(nowdata.r,nowdata.g),nowdata.b)*255.0)];\n\
    //vec2(max(max(nowdata.r,nowdata.g),nowdata.b), 0.5));\n\
    
    [shaderString appendFormat:@"highp vec4 nowdata3 = texture2D(inputImageTexture3, vec2(max(max(nowdata.r,nowdata.g),nowdata.b), 0.5));\n\
     highp float tddd = 2.5*255.0*nowdata3.r/2048.0+0.00001;\n\
     highp vec4 tt = vec4(1.0);"];
    //线性
    for (int i = -iRadius; i <= iRadius; i++)
    {
        for (int j = -iRadius; j<= iRadius; j++)
        {
            [shaderString appendFormat:@"datatmp = texture2D(inputImageTexture, textureCoord-vec2(%f*texelWidthOffset,%f*texelHeightOffset));\n\
             k = clamp(tt - abs(datatmp-nowdata)/tddd,0.0,1.0);\n\
             weight += k;\n\
             sum += k*datatmp;\n", i*fStep,j*fStep];
        }
    }
    
    //不加提亮
    [shaderString appendFormat:@"sum = clamp(sum/(weight+0.0001),0.0,1.0);\n\
     if (nowdata2.r > 0.5)\n\
     {\n\
        gl_FragColor = vec4(sum.rgb,1.0);\n\
     }\n\
     else\n\
     {\n\
        gl_FragColor = nowdata;\n\
     }\n\
     }"];
    
    return shaderString;
}


//提供给GPUImgFilter调用的用来设置图片大小的回调函数
- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    surfaceblurWidthOffset = glstepforsurfaceblur / filterFrameSize.width;
    surfaceblurHeightOffset = glstepforsurfaceblur / filterFrameSize.height;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext setActiveShaderProgram:filterProgram];
        glUniform1f(surfaceblurWidthOffsetUniform, surfaceblurWidthOffset);
        glUniform1f(surfaceblurHeightOffsetUniform, surfaceblurHeightOffset);
        
    
    });
}

@end
