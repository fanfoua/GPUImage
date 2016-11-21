//
//  RCGPUImageRise2Filter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/8/12.
//  Copyright (c) 2015年 renren. All rights reserved.
//

#import "RCGPUImageRise2Filter.h"
#import "RCGPUImageFourInputFilter.h"
#import "Modules/RCGPUImageBrightnessFilter.h"
#import "RCDecrypt.h"

NSString *const kRCGPUImageRise2FilterShaderString = SHADER_STRING
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
@implementation RCGPUImageRise2Filter
- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"blackboard256" ofType:@"png"]];
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"blackboard256" withExtension:@"png"]]];
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    
//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"overlayMap" ofType:@"png"]];
    UIImage *image2 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"overlayMap" withExtension:@"png"]]];
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    
//    UIImage *image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"riseMap" ofType:@"png"]];
    UIImage *image3 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"riseMap" withExtension:@"png"]]];
    ImageSource3 = [[GPUImagePicture alloc] initWithImage:image3];
    
    GPUImageFilter *filter = [[RCGPUImageFourInputFilter alloc] initWithFragmentShaderFromString:kRCGPUImageRise2FilterShaderString];
    [self addFilter:filter];
    [ImageSource1 addTarget:filter atTextureLocation:1];
    [ImageSource2 addTarget:filter atTextureLocation:2];
    [ImageSource3 addTarget:filter atTextureLocation:3];
    
    [ImageSource1 processImage];
    [ImageSource2 processImage];
    [ImageSource3 processImage];
    
    RCGPUImageBrightnessFilter *BrightnessFilter = [[RCGPUImageBrightnessFilter alloc] init];
    [(RCGPUImageBrightnessFilter *)BrightnessFilter setBrightness:10];
    [self addFilter:BrightnessFilter];
    [filter addTarget:BrightnessFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:filter,nil];
    self.terminalFilter = BrightnessFilter;
    
    return self;
}

@end
