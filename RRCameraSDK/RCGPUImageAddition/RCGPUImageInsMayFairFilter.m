//
//  RCGPUImageMayPairFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-4-11.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageInsMayFairFilter.h"
#import "Multi-InputFilters/RCGPUImageFiveInputFilter.h"
#import "Multi-InputFilters/RCGPUImageSixInputFilter.h"

NSString *const kRCGPUImageInsMayFairFilterShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //ins_MayPair_glowField;
 uniform sampler2D inputImageTexture3; //ins_MayPair_overlayMap100;
 uniform sampler2D inputImageTexture4; //ins_MayPair_colorOverlay
 uniform sampler2D inputImageTexture5; //ins_MayPair_colorGradient
 void main()
 {
     vec4 texel = texture2D(inputImageTexture, textureCoordinate);
     vec4 mapped=texel;
     
     mapped.r = texture2D(inputImageTexture4, vec2(mapped.r, .5)).r;
     mapped.g = texture2D(inputImageTexture4, vec2(mapped.g, .5)).g;
     mapped.b = texture2D(inputImageTexture4, vec2(mapped.b, .5)).b;
     
     mapped.r = texture2D(inputImageTexture5, vec2(mapped.r, .5)).r;
     mapped.g = texture2D(inputImageTexture5, vec2(mapped.g, .5)).g;
     mapped.b = texture2D(inputImageTexture5, vec2(mapped.b, .5)).b;
     
     
     vec3 bbTexel = texture2D(inputImageTexture2, vec2(textureCoordinate.x,1.0-textureCoordinate.y)).rgb;
     
     mapped.r = texture2D(inputImageTexture3, vec2(bbTexel.r, mapped.r)).r;
     mapped.g = texture2D(inputImageTexture3, vec2(bbTexel.g, mapped.g)).g;
     mapped.b = texture2D(inputImageTexture3, vec2(bbTexel.b, mapped.b)).b;
     mapped.a=1.0;


     gl_FragColor = mapped;
 }
 );
@implementation RCGPUImageInsMayFairFilter
- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"ins_MayPair_glowField" ofType:@"png"]];
//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"ins_MayPair_overlayMap100" ofType:@"png"]];
//    UIImage *image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"ins_MayPair_colorOverlay" ofType:@"png"]];
//    UIImage *image4 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"ins_MayPair_colorGradient" ofType:@"png"]];

    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"ins_MayPair_glowField" withExtension:@"png"]]];
    UIImage *image2 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"ins_MayPair_overlayMap100" withExtension:@"png"]]];
    UIImage *image3 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"ins_MayPair_colorOverlay" withExtension:@"png"]]];
    UIImage *image4 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"ins_MayPair_colorGradient" withExtension:@"png"]]];
    
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    ImageSource3 = [[GPUImagePicture alloc] initWithImage:image3];
    ImageSource4 = [[GPUImagePicture alloc] initWithImage:image4];
    
    GPUImageFilter *filter = [[RCGPUImageFiveInputFilter alloc] initWithFragmentShaderFromString:kRCGPUImageInsMayFairFilterShaderString];
    [self addFilter:filter];
    [ImageSource1 addTarget:filter atTextureLocation:1];
    [ImageSource2 addTarget:filter atTextureLocation:2];
    [ImageSource3 addTarget:filter atTextureLocation:3];
    [ImageSource4 addTarget:filter atTextureLocation:4];
    
    [ImageSource1 processImage];
    [ImageSource2 processImage];
    [ImageSource3 processImage];
    [ImageSource4 processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:filter,nil];
    self.terminalFilter = filter;
    
    return self;
}
@end
