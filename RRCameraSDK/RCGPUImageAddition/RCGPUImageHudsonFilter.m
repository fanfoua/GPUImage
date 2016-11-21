//
//  RCGPUImageHudsonFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-9-2.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageHudsonFilter.h"
#import "RCGPUImageFourInputFilter.h"

NSString *const kRCGPUImageHudsonFilterShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //blowout;
 uniform sampler2D inputImageTexture3; //overlay;
 uniform sampler2D inputImageTexture4; //map
 
 void main()
 {
     vec4 texel = texture2D(inputImageTexture, textureCoordinate);
     vec3 bbTexel = texture2D(inputImageTexture2, textureCoordinate).rgb;
     
     texel.r = texture2D(inputImageTexture3, vec2(bbTexel.r, texel.r)).r;
     texel.g = texture2D(inputImageTexture3, vec2(bbTexel.g, texel.g)).g;
     texel.b = texture2D(inputImageTexture3, vec2(bbTexel.b, texel.b)).b;
     
     vec4 mapped;
     mapped.r = texture2D(inputImageTexture4, vec2(texel.r, .16666)).r;
     mapped.g = texture2D(inputImageTexture4, vec2(texel.g, .5)).g;
     mapped.b = texture2D(inputImageTexture4, vec2(texel.b, .83333)).b;
     mapped.a = 1.0;
     gl_FragColor = mapped;
 }
 );

@implementation RCGPUImageHudsonFilter

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }

    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"hudsonBackground" ofType:@"png"]];
//    
//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"overlayMap" ofType:@"png"]];
//    
//    UIImage *image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"hudsonMap" ofType:@"png"]];
    
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"hudsonBackground" withExtension:@"png"]]];
    UIImage *image2 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"overlayMap" withExtension:@"png"]]];
    UIImage *image3 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"hudsonMap" withExtension:@"png"]]];
    
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    ImageSource3 = [[GPUImagePicture alloc] initWithImage:image3];
    
    GPUImageFilter *filter = [[RCGPUImageFourInputFilter alloc] initWithFragmentShaderFromString:kRCGPUImageHudsonFilterShaderString];
    [self addFilter:filter];
    [ImageSource1 addTarget:filter atTextureLocation:1];
    [ImageSource2 addTarget:filter atTextureLocation:2];
    [ImageSource3 addTarget:filter atTextureLocation:3];
    
    [ImageSource1 processImage];
    [ImageSource2 processImage];
    [ImageSource3 processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:filter,nil];
    self.terminalFilter = filter;
    
    return self;
}

@end