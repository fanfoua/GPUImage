//
//  RCGPUImageHefeFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-9-2.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageHefeFilter.h"
#import "RCGPUImageSixInputFilter.h"


NSString *const kRCGPUImageHefeFilterShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;  //edgeBurn
 uniform sampler2D inputImageTexture3;  //hefeMap
 uniform sampler2D inputImageTexture4;  //hefeGradientMap
 uniform sampler2D inputImageTexture5;  //hefeSoftLight
 uniform sampler2D inputImageTexture6;  //hefeMetal
 
 void main()
{
	vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
	vec3 edge = texture2D(inputImageTexture2, textureCoordinate).rgb;
	texel = texel * edge;
	
	texel = vec3(
                 texture2D(inputImageTexture3, vec2(texel.r, .16666)).r,
                 texture2D(inputImageTexture3, vec2(texel.g, .5)).g,
                 texture2D(inputImageTexture3, vec2(texel.b, .83333)).b);
	
	vec3 luma = vec3(.30, .59, .11);
	vec3 gradSample = texture2D(inputImageTexture4, vec2(dot(luma, texel), .5)).rgb;
	vec3 final = vec3(
                      texture2D(inputImageTexture5, vec2(gradSample.r, texel.r)).r,
                      texture2D(inputImageTexture5, vec2(gradSample.g, texel.g)).g,
                      texture2D(inputImageTexture5, vec2(gradSample.b, texel.b)).b
                      );
    
    vec3 metal = texture2D(inputImageTexture6, textureCoordinate).rgb;
    vec3 metaled = vec3(
                        texture2D(inputImageTexture5, vec2(metal.r, texel.r)).r,
                        texture2D(inputImageTexture5, vec2(metal.g, texel.g)).g,
                        texture2D(inputImageTexture5, vec2(metal.b, texel.b)).b
                        );
	
	gl_FragColor = vec4(metaled, 1.0);
}
 );

@implementation RCGPUImageHefeFilter

- (id)init;
{
    
    if (!(self = [super init]))
    {
		return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"edgeBurn" ofType:@"png"]];
//    
//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"hefeMap" ofType:@"png"]];
//    
//    UIImage *image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"hefeGradientMap" ofType:@"png"]];
//    
//    UIImage *image4 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"hefeSoftLight" ofType:@"png"]];
//    
//    UIImage *image5 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"hefeMetal" ofType:@"png"]];
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"edgeBurn" withExtension:@"png"]]];
    UIImage *image2 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"hefeMap" withExtension:@"png"]]];
    UIImage *image3 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"hefeGradientMap" withExtension:@"png"]]];
    UIImage *image4 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"hefeSoftLight" withExtension:@"png"]]];
    UIImage *image5 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"hefeMetal" withExtension:@"png"]]];
//
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    ImageSource3 = [[GPUImagePicture alloc] initWithImage:image3];
    ImageSource4 = [[GPUImagePicture alloc] initWithImage:image4];
    ImageSource5 = [[GPUImagePicture alloc] initWithImage:image5];

    GPUImageFilter *filter = [[RCGPUImageSixInputFilter alloc] initWithFragmentShaderFromString:kRCGPUImageHefeFilterShaderString];
    [self addFilter:filter];
    [ImageSource1 addTarget:filter atTextureLocation:1];
    [ImageSource2 addTarget:filter atTextureLocation:2];
    [ImageSource3 addTarget:filter atTextureLocation:3];
    [ImageSource4 addTarget:filter atTextureLocation:4];
    [ImageSource5 addTarget:filter atTextureLocation:5];
    
    [ImageSource1 processImage];
    [ImageSource2 processImage];
    [ImageSource3 processImage];
    [ImageSource4 processImage];
    [ImageSource5 processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:filter,nil];
    self.terminalFilter = filter;
    
    return self;
}

@end