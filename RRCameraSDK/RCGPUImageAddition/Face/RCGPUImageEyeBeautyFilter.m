//
//  RCGPUImageEyeBeautyFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/6/5.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageEyeBeautyFilter.h"
#import "RCFaceHistStatisticsFilter.h"
@implementation RCGPUImageEyeBeautyFilter

@synthesize iThreshold = _iThreshold;
@synthesize fProportion = _fProportion;
NSString *const kGPUImageEyeBeautyShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform lowp float iThreshold;
 uniform lowp float fProportion;
 uniform highp vec2 poi1;
 uniform highp vec2 poi2;
 uniform highp float r;
 void main()
 {
     lowp vec4 srcImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 gaussImageColor = texture2D(inputImageTexture2, textureCoordinate2);
     lowp vec4 resrgb = srcImageColor;
     lowp vec4 vtmp = srcImageColor-gaussImageColor;
     
     highp float lin1;
     highp float lin2;
     highp float dx;
     dx=(vtmp.r+vtmp.g+vtmp.b)/3.0;
     lin1=distance(textureCoordinate,poi1);
     lin2=distance(textureCoordinate,poi2);
     if (lin1<r||lin2<r)
     {

         if (abs(abs(vtmp.r)+abs(vtmp.g)+abs(vtmp.b)) > 3.0*iThreshold)
         {
             resrgb.rgb = clamp(dx*fProportion+srcImageColor.rgb, 0.0, 1.0);
         }
//         if (abs(vtmp.r) > iThreshold)
//         {
//             resrgb.r = clamp(vtmp.r*fProportion+srcImageColor.r, 0.0, 1.0);
//         }
//     
//         if (abs(vtmp.g) > iThreshold)
//         {
//             resrgb.g = clamp(vtmp.g*fProportion+srcImageColor.g, 0.0, 1.0);
//         }
//     
//         if (abs(vtmp.b) > iThreshold)
//         {
//             resrgb.b = clamp(vtmp.b*fProportion+srcImageColor.b, 0.0, 1.0);
//         }
     }
     gl_FragColor =  resrgb;
 }
 );

NSString *const kGPUImageEyeBeautyOnePointShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform lowp float iThreshold;
 uniform lowp float fProportion;
 uniform highp vec2 poi1;
 uniform highp float r;
 void main()
 {
     lowp vec4 srcImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 gaussImageColor = texture2D(inputImageTexture2, textureCoordinate2);
     lowp vec4 resrgb = srcImageColor;
     lowp vec4 vtmp = srcImageColor-gaussImageColor;
     
     highp float lin1;
     highp float dx;
     dx=(vtmp.r+vtmp.g+vtmp.b)/3.0;
     lin1=distance(textureCoordinate,poi1);
     if (lin1<r)
     {
         
         if (abs(abs(vtmp.r)+abs(vtmp.g)+abs(vtmp.b)) > 3.0*iThreshold)
         {
             resrgb.rgb = clamp(dx*fProportion+srcImageColor.rgb, 0.0, 1.0);
         }
         //         if (abs(vtmp.r) > iThreshold)
         //         {
         //             resrgb.r = clamp(vtmp.r*fProportion+srcImageColor.r, 0.0, 1.0);
         //         }
         //
         //         if (abs(vtmp.g) > iThreshold)
         //         {
         //             resrgb.g = clamp(vtmp.g*fProportion+srcImageColor.g, 0.0, 1.0);
         //         }
         //
         //         if (abs(vtmp.b) > iThreshold)
         //         {
         //             resrgb.b = clamp(vtmp.b*fProportion+srcImageColor.b, 0.0, 1.0);
         //         }
     }
     gl_FragColor =  resrgb;
 }
 );

- (id)initFaceRect:(struct FACERECT*)faceRect initImageSize:(CGSize)size initCount:(CGFloat)fProportion initRadius:(NSUInteger)iRadius initThreshold:(NSUInteger)iThreshold;
{
    CGFloat fSigma = ((CGFloat)iRadius)/2.0;
    
    if (!(self = [super init])) {
        return nil;
    }
    
    float x1;
    float y1;
    float x2;
    float y2;
    float r;
    
    x1=(1.0*faceRect->eyeleft_x)/size.width;
    y1=(1.0*faceRect->eyeleft_y)/size.height;
    x2=(1.0*faceRect->eyeright_x)/size.width;
    y2=(1.0*faceRect->eyeright_y)/size.height;
    
    r=sqrtf((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))*0.5;
    
    CGPoint poi1,poi2;
    poi1.x=x1;
    poi1.y=y1;
    poi2.x=x2;
    poi2.y=y2;
    
    // 高斯
    blurFilter = [[RCGPUImageGaussianBlurPassParamFilter alloc] initRadius:iRadius initSigma:(CGFloat)fSigma];
    [self addFilter:blurFilter];
    
    if (fProportion<0.0)
    {
        r=fabs(fProportion);
        fProportion=0.3;
        
        // 锐化
        sharpeningFilter = [[GPUImageTwoInputFilter alloc]
                            initWithFragmentShaderFromString:kGPUImageEyeBeautyOnePointShaderString];
        
        [self addFilter:sharpeningFilter];
        
        [blurFilter addTarget:sharpeningFilter atTextureLocation:1];
    }
    else
    {
        // 锐化
        sharpeningFilter = [[GPUImageTwoInputFilter alloc]
                            initWithFragmentShaderFromString:kGPUImageEyeBeautyShaderString];
        
        [self addFilter:sharpeningFilter];
        
        [blurFilter addTarget:sharpeningFilter atTextureLocation:1];

        [sharpeningFilter setPoint:poi2 forUniformName:@"poi2"];
    }
    
    [sharpeningFilter setPoint:poi1 forUniformName:@"poi1"];
    [sharpeningFilter setFloat:r forUniformName:@"r"];
    self.fProportion = fProportion;
    self.iThreshold = (CGFloat)(iThreshold/255.0);
    
    self.initialFilters = [NSArray arrayWithObjects:blurFilter, sharpeningFilter, nil];
    self.terminalFilter = sharpeningFilter;

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
