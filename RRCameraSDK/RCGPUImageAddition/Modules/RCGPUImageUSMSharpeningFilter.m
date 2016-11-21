//
//  RCGPUImageUSMSharpeningFilter.m
//  RRCameraSDK
//
//  Created by 孙昊 on 15-1-19.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageUSMSharpeningFilter.h"

@implementation RCGPUImageUSMSharpeningFilter

@synthesize iThreshold = _iThreshold;
@synthesize fProportion = _fProportion;
NSString *const kGPUImageUSMSharpeningShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform lowp float iThreshold;
 uniform lowp float fProportion;
 
 void main()
 {
     lowp vec4 srcImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 gaussImageColor = texture2D(inputImageTexture2, textureCoordinate2);
     lowp vec4 resrgb = srcImageColor;
     lowp vec4 vtmp = srcImageColor-gaussImageColor;
     if (abs(vtmp.r) > iThreshold)
     {
         resrgb.r = clamp(vtmp.r*fProportion+srcImageColor.r, 0.0, 1.0);
     }
     
     if (abs(vtmp.g) > iThreshold)
     {
         resrgb.g = clamp(vtmp.g*fProportion+srcImageColor.g, 0.0, 1.0);
     }
     
     if (abs(vtmp.b) > iThreshold)
     {
         resrgb.b = clamp(vtmp.b*fProportion+srcImageColor.b, 0.0, 1.0);
     }
     gl_FragColor =  resrgb;
 }
 );

- (id)initCount:(CGFloat)fProportion initRadius:(NSUInteger)iRadius initThreshold:(NSUInteger)iThreshold;
{
    CGFloat fSigma = ((CGFloat)iRadius)/2.0;
    
    if (!(self = [super init])) {
        return nil;
    }
    
    // 高斯
    blurFilter = [[RCGPUImageGaussianBlurPassParamFilter alloc] initRadius:iRadius initSigma:(CGFloat)fSigma];
    [self addFilter:blurFilter];
    
    // 锐化
    sharpeningFilter = [[GPUImageTwoInputFilter alloc]
                        initWithFragmentShaderFromString:kGPUImageUSMSharpeningShaderString];
    [self addFilter:sharpeningFilter];
    
    [blurFilter addTarget:sharpeningFilter atTextureLocation:1];
    
    self.initialFilters = [NSArray arrayWithObjects:blurFilter, sharpeningFilter, nil];
    self.terminalFilter = sharpeningFilter;
    self.iThreshold = (CGFloat)(iThreshold/255.0);
    self.fProportion = fProportion;
    return self;
}

- (void)setIThreshold:(CGFloat)newValue;
{
    _iThreshold = newValue;
    [sharpeningFilter setFloat:newValue forUniformName:@"iThreshold"];
}

- (void)setFProportion:(CGFloat)newValue;
{
    _fProportion = newValue;
    [sharpeningFilter setFloat:newValue forUniformName:@"fProportion"];
}
@end