//
//  RCGPUImageSelectFaceColorFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/4/17.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageSelectFaceColorFilter.h"

@implementation RCGPUImageSelectFaceColorFilter

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;
{
    return self;
}

- (id)initGray:(int)graythr;
{

    NSString *currentSelectFaceColorVertexShader = [self vertexShaderForSelectFaceColor];
    NSString *currentSelectFaceColorFragmentShader = [self  fragmentShaderForSelectFaceColor:graythr];
    
    if (!(self = [super initWithVertexShaderFromString:currentSelectFaceColorVertexShader fragmentShaderFromString:currentSelectFaceColorFragmentShader]))
    {
        return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
    });
    return self;
}

#pragma mark -
#pragma mark Auto-generation of optimized Gaussian shaders


- (NSString *)vertexShaderForSelectFaceColor;
{
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    // Header
    [shaderString appendFormat:@"\
     attribute vec4 position;\n\
     attribute vec4 inputTextureCoordinate;\n\
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

- (NSString *)fragmentShaderForSelectFaceColor:(int)graythr;
{
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    
    // Header
    [shaderString appendFormat:@"\
     uniform sampler2D inputImageTexture;\n\
     uniform highp float texelWidthOffset;\n\
     uniform highp float texelHeightOffset;\n\
     \n\
     varying highp vec2 textureCoord;\n\
     \n\
     void main()\n\
     {\n\
     lowp vec4 nowdata=texture2D(inputImageTexture, textureCoord);\n\
     "];
    
    [shaderString appendFormat:@"lowp float r = nowdata.r;\n\
     lowp float g = nowdata.g;\n\
     lowp float b = nowdata.b;\n\
     lowp float maxValue = max(r, max(g, b));\n\
     lowp float minValue = min(r, min(g, b));\n\
     lowp float hue = 0.0;\n\
     if (maxValue == minValue)\n\
     {\n\
     hue = 0.0;\n\
     }\n\
     else if (maxValue == r && g >= b)\n\
     {\n\
     hue = 60.0 * (g - b) / (maxValue - minValue);\n\
     }\n\
     else if (maxValue == r && g < b)\n\
     {\n\
     hue = 60.0 * (g - b) / (maxValue - minValue) + 360.0;\n\
     }\n\
     else if (maxValue == g)\n\
     {\n\
     hue = 60.0 * (b - r) / (maxValue - minValue) + 120.0;\n\
     }\n\
     else if (maxValue == b)\n\
     {\n\
     hue = 60.0 * (r - g) / (maxValue - minValue) + 240.0;\n\
     }\n\
     if (maxValue>"];
    
    [shaderString appendFormat:@"%f&&(hue<75.0||hue>285.0))\n\
     {\n\
     gl_FragColor=vec4(1.0,1.0,1.0,1.0);\n\
     }\n\
     else\n\
     {\n\
     gl_FragColor=vec4(0.0,0.0,0.0,1.0);\n\
     }\n\
     }", graythr/255.0];
    
    
    return shaderString;
}
@end
