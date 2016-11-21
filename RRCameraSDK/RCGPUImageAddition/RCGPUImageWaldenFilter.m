//
//  RCGPUImageWaldenFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-9-2.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageWaldenFilter.h"
#import "RCGPUImageThreeInputFilter.h"

NSString *const kRCGPUImageWaldenFilterShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //map
 uniform sampler2D inputImageTexture3; //vigMap
 
 void main()
 {
     vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
     
     texel = vec3(
                  texture2D(inputImageTexture2, vec2(texel.r, .16666)).r,
                  texture2D(inputImageTexture2, vec2(texel.g, .5)).g,
                  texture2D(inputImageTexture2, vec2(texel.b, .83333)).b);
     
     vec2 tc = (2.0 * textureCoordinate) - 1.0;
     float d = dot(tc, tc);  //向量点积
     vec2 lookup = vec2(d, texel.r);
     texel.r = texture2D(inputImageTexture3, lookup).r;
     lookup.y = texel.g;
     texel.g = texture2D(inputImageTexture3, lookup).g;
     lookup.y = texel.b;
     texel.b = texture2D(inputImageTexture3, lookup).b;
     
     gl_FragColor = vec4(texel, 1.0);
 }
 );

@implementation RCGPUImageWaldenFilter

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
//    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"waldenMap" withExtension:@"png"]]];
    UIImage *image2 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"vignetteMap" withExtension:@"png"]]];
    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"waldenMap" ofType:@"png"]];
//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"vignetteMap" ofType:@"png"]];
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    
    
    GPUImageFilter *filter = [[RCGPUImageThreeInputFilter alloc] initWithFragmentShaderFromString:kRCGPUImageWaldenFilterShaderString];
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
