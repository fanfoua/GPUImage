//
//  RCGPUImageSutroFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-9-2.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageSutroFilter.h"
#import "Multi-InputFilters/RCGPUImageSixInputFilter.h"

NSString *const kRCGPUImageSutroShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //sutroMap;
 uniform sampler2D inputImageTexture3; //sutroMetal;
 uniform sampler2D inputImageTexture4; //softLight
 uniform sampler2D inputImageTexture5; //sutroEdgeburn
 uniform sampler2D inputImageTexture6; //sutroCurves
 
 void main()
 {
     vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
     
     vec2 tc = (2.0 * textureCoordinate) - 1.0;
     float d = dot(tc, tc);
     vec2 lookup = vec2(d, texel.r);
     texel.r = texture2D(inputImageTexture2, lookup).r;
     lookup.y = texel.g;
     texel.g = texture2D(inputImageTexture2, lookup).g;
     lookup.y = texel.b;
     texel.b	= texture2D(inputImageTexture2, lookup).b;
     
     vec3 rgbPrime = vec3(0.1019, 0.0, 0.0);
     float m = dot(vec3(.3, .59, .11), texel.rgb) - 0.03058;
     texel = mix(texel, rgbPrime + m, 0.32);
     
     vec3 metal = texture2D(inputImageTexture3, textureCoordinate).rgb;
     texel.r = texture2D(inputImageTexture4, vec2(metal.r, texel.r)).r;
     texel.g = texture2D(inputImageTexture4, vec2(metal.g, texel.g)).g;
     texel.b = texture2D(inputImageTexture4, vec2(metal.b, texel.b)).b;
     
     texel = texel * texture2D(inputImageTexture5, textureCoordinate).rgb;
     
     texel.r = texture2D(inputImageTexture6, vec2(texel.r, .16666)).r;
     texel.g = texture2D(inputImageTexture6, vec2(texel.g, .5)).g;
     texel.b = texture2D(inputImageTexture6, vec2(texel.b, .83333)).b;
     
     
     gl_FragColor = vec4(texel, 1.0);
 }
 );

@implementation RCGPUImageSutroFilter

- (id)init;
{
    
    if (!(self = [super init]))
    {
		return nil;
    }
    

    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"vignetteMap" ofType:@"png"]];
//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"sutroMetal" ofType:@"png"]];
//    UIImage *image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"softLight" ofType:@"png"]];
//    UIImage *image4 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"sutroEdgeBurn" ofType:@"png"]];
//    UIImage *image5 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"sutroCurves" ofType:@"png"]];
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"vignetteMap" withExtension:@"png"]]];
    UIImage *image2 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"sutroMetal" withExtension:@"png"]]];
    UIImage *image3 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"softLight" withExtension:@"png"]]];
    UIImage *image4 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"sutroEdgeBurn" withExtension:@"png"]]];
    UIImage *image5 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"sutroCurves" withExtension:@"png"]]];
    
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    ImageSource3 = [[GPUImagePicture alloc] initWithImage:image3];
    ImageSource4 = [[GPUImagePicture alloc] initWithImage:image4];
    ImageSource5 = [[GPUImagePicture alloc] initWithImage:image5];
    
    GPUImageFilter *filter = [[RCGPUImageSixInputFilter alloc] initWithFragmentShaderFromString:kRCGPUImageSutroShaderString];
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