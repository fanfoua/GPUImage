//
//  RCGPUImageLomofiFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-9-2.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageLomofiFilter.h"
#import "RCGPUImageThreeInputFilter.h"

NSString *const kRCGPUImageLomofiShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 
 void main()
 {
     vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
     
     vec2 red = vec2(texel.r, 0.16666);
     vec2 green = vec2(texel.g, 0.5);
     vec2 blue = vec2(texel.b, 0.83333);
     
     texel.rgb = vec3(
                      texture2D(inputImageTexture2, red).r,
                      texture2D(inputImageTexture2, green).g,
                      texture2D(inputImageTexture2, blue).b);
     
     vec2 tc = (2.0 * textureCoordinate) - 1.0;
     float d = dot(tc, tc);
     vec2 lookup = vec2(d, texel.r);
     texel.r = texture2D(inputImageTexture3, lookup).r;
     lookup.y = texel.g;
     texel.g = texture2D(inputImageTexture3, lookup).g;
     lookup.y = texel.b;
     texel.b	= texture2D(inputImageTexture3, lookup).b;
     
     gl_FragColor = vec4(texel,1.0);
 }
 );

@implementation RCGPUImageLomofiFilter

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"lomoMap" ofType:@"png"]];
//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"vignetteMap" ofType:@"png"]];
    
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"lomoMap" withExtension:@"png"]]];
    UIImage *image2 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"vignetteMap" withExtension:@"png"]]];
   
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    GPUImageFilter *filter = [[GPUImageThreeInputFilter alloc] initWithFragmentShaderFromString:
                              kRCGPUImageLomofiShaderString];
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