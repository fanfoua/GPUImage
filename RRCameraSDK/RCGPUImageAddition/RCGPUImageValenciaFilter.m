//
//  RCGPUImageValenciaFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-9-2.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageValenciaFilter.h"
#import "RCGPUImageThreeInputFilter.h"

NSString *const kRCGPUImageValenciaShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //map
 uniform sampler2D inputImageTexture3; //gradMap
 
 mat3 saturateMatrix = mat3(
                            1.1402,
                            -0.0598,
                            -0.061,
                            -0.1174,
                            1.0826,
                            -0.1186,
                            -0.0228,
                            -0.0228,
                            1.1772);
 
 vec3 lumaCoeffs = vec3(.3, .59, .11);
 
 void main()
 {
     vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
     
     texel = vec3(
                  texture2D(inputImageTexture2, vec2(texel.r, .1666666)).r,
                  texture2D(inputImageTexture2, vec2(texel.g, .5)).g,
                  texture2D(inputImageTexture2, vec2(texel.b, .8333333)).b
                  );
     
     texel = saturateMatrix * texel;
     float luma = dot(lumaCoeffs, texel);
     texel = vec3(
                  texture2D(inputImageTexture3, vec2(luma, texel.r)).r,
                  texture2D(inputImageTexture3, vec2(luma, texel.g)).g,
                  texture2D(inputImageTexture3, vec2(luma, texel.b)).b);
     
     gl_FragColor = vec4(texel, 1.0);
 }
 );

@implementation RCGPUImageValenciaFilter
- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    

    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"valenciaMap" ofType:@"png"]];
//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"valenciaGradientMap" ofType:@"png"]];

    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"valenciaMap" withExtension:@"png"]]];
    UIImage *image2 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"valenciaGradientMap" withExtension:@"png"]]];

    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];

    GPUImageFilter *filter = [[GPUImageThreeInputFilter alloc] initWithFragmentShaderFromString:kRCGPUImageValenciaShaderString];
    [self addFilter:filter];
    [ImageSource1 addTarget:filter atTextureLocation:1];
    [ImageSource2 addTarget:filter atTextureLocation:2];
    [ImageSource1 processImage];
    [ImageSource2 processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:filter,nil];
    self.terminalFilter = filter;
    
    return self;
}

@end