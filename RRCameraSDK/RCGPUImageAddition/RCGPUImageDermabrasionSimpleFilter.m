//
//  RCGPUImageDermabrasionSimpleFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/8/5.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageDermabrasionSimpleFilter.h"

@implementation RCGPUImageDermabrasionSimpleFilter
#define MIN_RADIUS 2
#define MAX_RADIUS 4
- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;
{
    return self;
}

- (id)initRadius:(int)radius initThreshold:(GLfloat)thr;
{
    
    [self setStep:1 setThreshold:thr];//步长设置为1
    iRadius=MIN(MIN(MAX((radius+1)/3, MIN_RADIUS),radius),MAX_RADIUS);
    iRadius=2;//固定滤波器半径
    fStep=(1.0*radius)/iRadius;
    NSString *currentSurfaceblurVertexShader = [self vertexShaderForSurfaceblur];
    NSString *currentSurfaceblurFragmentShader = [self  fragmentShaderForSurfaceblur];
    
    
    if (!(self = [super initWithVertexShaderFromString:currentSurfaceblurVertexShader fragmentShaderFromString:currentSurfaceblurFragmentShader]))
    {
        return nil;
    }
    //    CGRect rectTmp;
    //    rectTmp.origin.x=0.0;
    //    rectTmp.origin.y=0.0;
    //    rectTmp.size.width=1.0;
    //    rectTmp.size.height=1.0;
    [self setGray:0.25];
    
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
     uniform highp float texelWidthOffset;\n\
     uniform highp float texelHeightOffset;\n\
     uniform highp float grayThr;\n\
     \n\
     varying highp vec2 textureCoord;\n\
     \n\
     void main()\n\
     {\n\
     highp vec4 sum = vec4(0.0);\n\
     lowp vec4 nowdata = texture2D(inputImageTexture, textureCoord);\n\
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
    
    [shaderString appendFormat:@"highp vec4 nowdata3 = texture2D(inputImageTexture2, vec2(max(max(nowdata.r,nowdata.g),nowdata.b), 0.5));\n\
     highp float tddd = 2.5*255.0*nowdata3.r/2048.0+0.00001;\n\
     highp vec4 tt = vec4(1.0);\n\
     if (nowdata.r+nowdata.g>grayThr*2.0)\n\
     {"];
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
     }\n\
     else\n\
     {\n\
     sum=nowdata;\n\
     }\n\
     gl_FragColor = vec4(sum.rgb,1.0);\n\
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

//- (void) setFaceRect:(CGRect)faceRect
//{
//    [self setFloat:faceRect.origin.x forUniformName:@"faceRectLeft"];
//    [self setFloat:faceRect.origin.x+faceRect.size.width forUniformName:@"faceRectRight"];
//    [self setFloat:faceRect.origin.y forUniformName:@"faceRectTop"];
//    [self setFloat:faceRect.origin.y+faceRect.size.height forUniformName:@"faceRectBottom"];
//}

- (void) setGray:(CGFloat)faceGray
{
    [self setFloat:faceGray forUniformName:@"grayThr"];
}
-(void) changeRect:(CGRect)faceRect
{
    int Radius,faceWidth;
    
    faceWidth=faceRect.size.width;
    if (faceWidth<100)
    {
        Radius=3;
    }
    if (faceWidth<140)
    {
        Radius=5;
    }
    else if (faceWidth<180)
    {
        Radius=6;
    }
    else if (faceWidth<250)
    {
        Radius=8;
    }
    else if(faceWidth<300)
    {
        Radius=10;
    }
    else
    {
        Radius=12;
    }
    
    if (faceWidth==0)
    {
        Radius=4;
    }
}
@end
