//
//  RCGPUImageNaturalSaturationOPTFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-3-5.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageNaturalSaturationOPTShaderFilter.h"
#import "GPUImageTwoInputFilter.h"

@implementation RCGPUImageNaturalSaturationOPTShaderFilter

//不同大小的饱和度s在经过自然饱和度-100%后的大小
float s_low_bound[101] = { 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3,
    4, 4, 4, 5, 5, 6, 6, 6, 7, 8, 8, 9, 9,10,10,11,12,12,12,13,
    14,14,15,16,17,18,18,19,20,20,20,21,22,23,23,24,26,26,27,28,
    28,29,29,30,31,32,33,33,34,35,35,36,36,37,37,38,39,39,40,40,
    41,41,42,42,42,43,43,44,44,45,45,45,45,46,46,46,47,47,47,47,47};
//不同大小的饱和度s在经过自然饱和度+100%后的大小
float s_up_bound[101] = { 0, 2, 4, 4, 6, 8,10,11,13,15,17,19,21,23,24,25,27,29,30,32,
    33,35,37,38,40,42,43,44,46,47,48,50,51,53,54,55,57,58,58,60,
    61,63,64,65,66,67,68,69,70,71,72,73,74,75,75,76,77,78,79,80,
    81,81,82,82,83,84,85,85,87,87,88,89,89,90,90,91,91,92,93,93,
    94,94,95,95,96,96,97,97,97,98,98,98,98,99,99,99,99,99,99,100,100};
//肤色在不同的亮度v下的调整大小
float s_refine[101] = { 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 4, 5, 5, 5, 6, 5, 6, 6, 6, 7,
    7, 8, 9, 10, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
    12, 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
    13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
    14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16 };

- (NSString *)vertexShaderForNaturalSaturationOPT;
{
//    attribute vec4 inputTextureCoordinate;
//    attribute vec4 inputTextureCoordinate2;
//    
//    varying vec2 textureCoordinate;
//    varying vec2 textureCoordinate2;
//    attribute vec4 position;
//    attribute vec4 inputTextureCoordinate;
//    attribute vec4 inputTextureCoordinate2;
        // varying vec2 textureCoord;\n
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    // Header
    [shaderString appendFormat:@"\
     attribute vec4 position;\n\
     attribute vec4 inputTextureCoordinate;\n\
     attribute vec4 inputTextureCoordinate2;\n\
     varying highp vec2 textureCoordinate;\n\
     varying highp vec2 textureCoordinate2;\n\
     \n\
     uniform float texelWidthOffset;\n\
     uniform float texelHeightOffset;\n\
     \n\
     void main()\n\
     {\n\
     gl_Position = position;\n\
     textureCoordinate = inputTextureCoordinate.xy;\n\
     textureCoordinate2 = inputTextureCoordinate2.xy;\n\
     "];
    
    // Footer
    [shaderString appendString:@"}\n"];
    
    return shaderString;
}

//- (NSString *)fragmentShaderForNaturalSaturationIratio:(int)iratio;
//{
//    NSMutableString *shaderString = [[NSMutableString alloc] init];
//    
//    // Header
//    [shaderString appendFormat:@"precision highp float;\n\
//     varying highp vec2 textureCoord;\n\
//     uniform sampler2D inputImageTexture;\n\
//     uniform float s_up_bound[101];\n\
//     uniform float s_refine[101] ;\n\
//     uniform float s_low_bound[101] ;\n\
//     int ratio=%i;\n\
//     void main()\n\
//     {\n\
//     vec4 textureColor=texture2D(inputImageTexture, textureCoord);\n\
//     float max = max(textureColor.r, max(textureColor.g, textureColor.b));\n\
//     float mint = min(textureColor.r, min(textureColor.g, textureColor.b));\n\
//     float v = max;\n\
//     float s = 0.0;\n\
//     float h = 0.0;\n\
//     if(max!=0.0) s = 1.0 - mint/max;\n\
//     if((max== mint)) h = 0.0;\n\
//     else if((max == textureColor.r) && textureColor.g >= textureColor.b)\n\
//     h = (textureColor.g - textureColor.b)/(max-mint)/6.0;\n\
//     else if((max == textureColor.r) && textureColor.g < textureColor.b)\n\
//     h = (textureColor.g - textureColor.b)/(max-mint)/6.0 +1.0;\n\
//     else if((max == textureColor.g))\n\
//     h = (textureColor.b - textureColor.r)/(max-mint)/6.0+1.0/3.0;\n\
//     else if((max == textureColor.b))\n\
//     h = (textureColor.r -textureColor.g)/(max-mint)/6.0 +2.0/3.0;\
//     \n\
//     float end_s;\n\
//     float r = (abs(float(ratio)))*0.01;\n\
//     if((ratio)==0) gl_FragColor = textureColor;\n\
//     else if(ratio > 0) end_s = 0.01 *s_up_bound[int(floor(s*100.0+0.5))];\n\
//     else end_s = 0.01 * s_low_bound[int(floor(s*100.0+0.5))];\n\
//     float delta_s = end_s - s;\n\
//     \n\
//     if(v<0.3) delta_s = delta_s*(1.5);\n\
//     else if(v<0.5) delta_s = delta_s*(2.25 - 2.5*v);\n\
//     \n\
//     float delta_v = 0.0;\n\
//     float refine_s = 0.0;\n\
//     if(ratio>0)\n\
//     {\n\
//     if(v<0.1||v>=0.95) delta_v = 0.0;\n\
//     else if(v>= 0.3&&v<0.75) delta_v = 0.02;\n\
//     else delta_v = 0.01;\n\
//     refine_s = 0.01*s_refine[int(floor(v*100.0+0.5))];\n\
//     if(s<0.25) refine_s = refine_s*(4.0*s);\n\
//     else refine_s = refine_s*(4.0*(1.0-s)/3.0);\n\
//     if(h>5.0/36.0 && h<30.0/36.0) refine_s = 0.0;\n\
//     else if(h>4.0/36.0 && h<=5.0/36.0) refine_s = refine_s * (5.0-h*36.0);\n\
//     else if(h>=30.0/36.0 && h<35.0/36.0) refine_s = refine_s *(7.2*h -6.0);\n\
//     if(h<0.152&&h>0.042) h = h +r*min(1.0/120.0,1.0/60.0 -0.15*abs(h-35.0/360.0));\n\
//     }\n\
//     else\n\
//     {\n\
//     if (v < 0.06 || v >= 0.99) delta_v = 0.0;\n\
//     else if (v < 0.16 || v >= 0.96) delta_v = -0.01;\n\
//     else if (v < 0.18 || v >= 0.94) delta_v = -0.02;\n\
//     else if (v < 0.20 || v >= 0.92) delta_v = -0.03;\n\
//     else if (v < 0.22 || v >= 0.88) delta_v = -0.04;\n\
//     else if (v < 0.24 || v >= 0.85) delta_v = -0.05;\n\
//     else if (v < 0.29 || v >= 0.81) delta_v = -0.06;\n\
//     else if (v < 0.35 || v >= 0.74) delta_v = -0.07;\n\
//     else if (v < 0.44 || v >= 0.68) delta_v = -0.08;\n\
//     else delta_v = -0.09;\n\
//     }\n\
//     if(s<0.2) delta_v = delta_v*5.0*s;\n\
//     else if(s>0.3) delta_v= delta_v*1.428*(1.0-s);\n\
//     v =v+ delta_v * r;\n\
//     s =s+ (delta_s - refine_s*0.5) * r; \n\
//     v = clamp(v,0.0,1.0);\n\
//     s = clamp(s,0.0,1.0);\n\
//     \n\
//     float f;\n\
//     float temp;\n\
//     float p, q, t, k;\n\
//     vec3 rgb;\n\
//     temp = mod(floor(h * 6.0),6.0);\n\
//     f = h * 6.0 - temp;\n\
//     p = min(1.0, v * (1.0 - s));\n\
//     q = min(1.0, v * (1.0 - f * s));\n\
//     t = min(1.0, v * (1.0 - (1.0 - f) * s));\n\
//     k = v;\n\
//     if((temp) >= 0.0&&temp<1.0) { rgb.r = k; rgb.g = t; rgb.b = p;}\n\
//     else if((temp)>=1.0&&temp<2.0){ rgb.r = q; rgb.g = k; rgb.b = p;}\n\
//     else if(temp>=2.0&&temp<3.0) {rgb.r = p; rgb.g = k; rgb.b = t;}\n\
//     else if(temp>=3.0&&temp<4.0) {rgb.r = p; rgb.g = q; rgb.b = k;}\n\
//     else if(temp>=4.0&&temp<5.0) { rgb.r = t; rgb.g = p; rgb.b = k;} \n\
//     else { rgb.r = k; rgb.g = p; rgb.b = q;} \n\
//     gl_FragColor = vec4(rgb,textureColor.a);\n\
//     if((ratio) == 0) gl_FragColor = textureColor;\n\
//     \n\
//     }\
//     ",(unsigned int)iratio];
//    
//    return shaderString;
//}

- (NSString *)fragmentShaderForNaturalSaturationIratio:(int)iratio;
{
    NSMutableString *shaderString = [[NSMutableString alloc] init];

    // Header
    [shaderString appendFormat:@"precision mediump float;\n\
        varying highp vec2 textureCoordinate;\n\
        varying highp vec2 textureCoordinate2;\n\
        uniform sampler2D inputImageTexture;\n\
        uniform sampler2D inputImageTexture2;\n\
        int ratio=%i;\n\
        vec4 lookTable(float location)\n\
        {\n\
           vec4 result;\n\
           result = texture2D(inputImageTexture2, vec2(location,0.5));\n\
           return result;\n\
        }\n\
        void main()\n\
         {\n\
            vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);\n\
            float max = max(textureColor.r, max(textureColor.g, textureColor.b));\n\
            float mint = min(textureColor.r, min(textureColor.g, textureColor.b));\n\
            float v = max;\n\
            float s = 0.0;\n\
            float h = 0.0;\n\
         if(max!=0.0) s = 1.0 - mint/max;\n\
         if(max == mint) h = 0.0;\n\
         else if(max == textureColor.r && textureColor.g >= textureColor.b)\n\
            h = (textureColor.g - textureColor.b)/(max-mint)/6.0;\n\
         else if(max == textureColor.r && textureColor.g < textureColor.b)\n\
            h = (textureColor.g - textureColor.b)/(max-mint)/6.0 +1.0;\n\
         else if(max == textureColor.g)\n\
            h = (textureColor.b - textureColor.r)/(max-mint)/6.0+1.0/3.0;\n\
         else if(max == textureColor.b)\n\
            h = (textureColor.r -textureColor.g)/(max-mint)/6.0 +2.0/3.0;\n\
     \n\
        float end_s;\n\
        float radio_abs;\n\
        if(ratio<0) radio_abs = float(-ratio);\n\
        else radio_abs = float(ratio);\n\
        float r = radio_abs*0.01;\n\
        vec4 looks = lookTable(s);\n\
        if(ratio == 0) gl_FragColor = textureColor;\n\
        else if(ratio > 0)\n\
        {\n\
            \n\
             end_s = 0.01 *255.0*looks.b;\n\
        }\n\
        else \n\
        {\n\
            end_s = 0.01 * 255.0*looks.g;\n\
        }\n\
        float delta_s = end_s - s;\n\
        \n\
        if(v<0.3) delta_s = delta_s*(1.5);\n\
        else if(v<0.5) delta_s = delta_s*(2.25 - 2.5*v);\n\
        \n\
        float delta_v = 0.0;\n\
        float refine_s = 0.0;\n\
        vec4 lookv = lookTable(v);\n\
        if(ratio>0)\n\
        {\n\
            if(v<0.1||v>=0.95) delta_v = 0.0;\n\
            else if(v>= 0.3&&v<0.75) delta_v = 0.02;\n\
            else delta_v = 0.01;\n\
     \n\
            refine_s = 0.01*255.0*lookv.r;\n\
     \n\
            if(s<0.25) refine_s = refine_s*(4.0*s);\n\
            else refine_s = refine_s*(4.0*(1.0-s)/3.0);\n\
     \n\
            if(h>5.0/36.0 && h<30.0/36.0) refine_s = 0.0;\n\
            else if(h>4.0/36.0 && h<=5.0/36.0) refine_s = refine_s * (5.0-h*36.0);\n\
            else if(h>=30.0/36.0 && h<35.0/36.0) refine_s = refine_s *(7.2*h -6.0);\n\
            if(h<0.152&&h>0.042) h = h +r*min(1.0/120.0,1.0/60.0 -0.15*abs(h-35.0/360.0));\n\
        }\n\
        else\n\
        {\n\
                if (v < 0.06 || v >= 0.99) delta_v = 0.0;\n\
                else if (v < 0.16 || v >= 0.96) delta_v = -0.01;\n\
                else if (v < 0.18 || v >= 0.94) delta_v = -0.02;\n\
                else if (v < 0.20 || v >= 0.92) delta_v = -0.03;\n\
                else if (v < 0.22 || v >= 0.88) delta_v = -0.04;\n\
                else if (v < 0.24 || v >= 0.85) delta_v = -0.05;\n\
                else if (v < 0.29 || v >= 0.81) delta_v = -0.06;\n\
                else if (v < 0.35 || v >= 0.74) delta_v = -0.07;\n\
                else if (v < 0.44 || v >= 0.68) delta_v = -0.08;\n\
                else delta_v = -0.09;\n\
         }\n\
            if(s<0.2) delta_v = delta_v*5.0*s;\n\
            else if(s>0.3) delta_v= delta_v*1.428*(1.0-s);\n\
            v =v+ delta_v * r;\n\
            s =s+ (delta_s - refine_s*0.5) * r; \n\
            v = clamp(v,0.0,1.0);\n\
            s = clamp(s,0.0,1.0);\n\
            \n\
            float f;\n\
            float temp;\n\
            float p, q, t, k;\n\
            vec3 rgb;\n\
            temp = mod(floor(h * 6.0),6.0);\n\
            f = h * 6.0 - temp;\n\
            p = min(1.0, v * (1.0 - s));\n\
            q = min(1.0, v * (1.0 - f * s));\n\
            t = min(1.0, v * (1.0 - (1.0 - f) * s));\n\
            k = v;\n\
            int tempi = int(temp); \n\
            if(tempi == 0) { rgb.r = k; rgb.g = t; rgb.b = p;}\n\
            else if(tempi == 1){ rgb.r = q; rgb.g = k; rgb.b = p;}\n\
            else if(tempi == 2) {rgb.r = p; rgb.g = k; rgb.b = t;}\n\
            else if(tempi == 3) {rgb.r = p; rgb.g = q; rgb.b = k;}\n\
            else if(tempi == 4) { rgb.r = t; rgb.g = p; rgb.b = k;} \n\
            else { rgb.r = k; rgb.g = p; rgb.b = q;} \n\
            gl_FragColor = vec4(rgb,textureColor.a);\n\
            if(ratio == 0) gl_FragColor = textureColor;\n\
          \n\
     }",(unsigned int)-iratio];
    
    return shaderString;
}

- (NSString *)fragmentShaderForNaturalSaturationIratio1:(int)iratio;
{
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    // Header
    [shaderString appendFormat:@"precision highp float;\n\
     varying highp vec2 textureCoordinate;\n\
     uniform sampler2D inputImageTexture;\n\
     uniform sampler2D inputImageTexture2;\n\
     void main()\n\
     {\n\
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);\n\
     \n\
     }"];
    
    return shaderString;
}

- (id)initIratio:(int)iratio;
{
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    NSString *currentSurfaceblurVertexShader = [self vertexShaderForNaturalSaturationOPT];
    NSString *currentSurfaceblurFragmentShader = [self  fragmentShaderForNaturalSaturationIratio:iratio];
    
    if (!(self = [super initWithFragmentShaderFromString:currentSurfaceblurFragmentShader]))
    {
        return nil;
    }
    
    return self;
}

@end