//
//  RCGPUImageSlimmingFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/8/7.
//  Copyright (c) 2015年 renn. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "RCGPUImageSlimmingFilter.h"

NSString *const kRCGPUImageSlimmingShaderFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform highp float x;
 uniform highp float y;
 uniform highp float px;
 uniform highp float py;
 uniform highp float w;
 
 void main()
 {
    mediump vec4 textureColor;
    highp vec2 xy=vec2(x,y);
    xy=clamp((textureCoordinate.xy-xy)/w+0.5,0.0,1.0);
     
    if (abs(textureCoordinate.x-x)<w/2.0&&
    abs(textureCoordinate.y-y)<w/2.0)
    {
        mediump vec4 mapX=texture2D(inputImageTexture2,vec2(xy.x,abs(px)*(1.0-abs(xy.y-0.5)*2.0)));
        mediump vec4 mapY=texture2D(inputImageTexture2,vec2(xy.y,abs(py)*(1.0-abs(xy.x-0.5)*2.0)));
        if (px<0.0)
        {
            mapX.r=xy.x*2.0-mapX.r;
        }
        if(py<0.0)
        {
            mapY.r=xy.y*2.0-mapY.r;
        }
        highp vec2 loc=clamp(vec2(mapX.r*w+x-w/2.0,mapY.r*w+y-w/2.0),0.0,1.0);
        textureColor = texture2D(inputImageTexture,loc);
    }
    else
    {
        textureColor = texture2D(inputImageTexture,textureCoordinate);
    }
     gl_FragColor = textureColor;
 }
);

@implementation RCGPUImageSlimmingFilter
//brushW是移动画面占整个图像的比例
- (id)initPointOld:(CGPoint)pointOld PointNew:(CGPoint)pointNew Img:(UIImage*)image BrushW:(CGFloat)brushW
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    CGImageRef img=[image CGImage];
    CGSize sizeReal = CGSizeMake(CGImageGetWidth(img), CGImageGetHeight(img));
    int w = sizeReal.width;
    int h = sizeReal.height;
    CGFloat minF=0.01;//手滑动最小有效位移
    CGFloat maxF=0.3;//手滑动最大有效位移
    CGFloat len=fabs(pointOld.x-pointNew.x)/w;
    CGFloat vectorX=MIN(MAX(len,minF),maxF);
    
    vectorX=(vectorX-minF)/(maxF-minF)*0.20+0.01;//画面移动最小和最大值是0.01-0.25
    if (pointOld.x-pointNew.x<0.0)
    {
        vectorX=-vectorX;
    }
    len=fabs(pointOld.y-pointNew.y)/h;
    CGFloat vectorY=MIN(MAX(len,minF),maxF);
    
    vectorY=(vectorY-minF)/(maxF-minF)*0.20+0.01;
    if (pointOld.y-pointNew.y<0.0)
    {
        vectorY=-vectorY;
    }
    GPUImageFilter* filter=[[GPUImageTwoInputFilter alloc]initWithFragmentShaderFromString:kRCGPUImageSlimmingShaderFragmentShaderString];
    
    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                              pathForResource:@"Slimming1" ofType:@"png"]];
    NSAssert(image1,
             @"To use RCGPUImageFaceDermabrasionFilter you need to add paraImg.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    [ImageSource1 addTarget:filter atTextureLocation:2];
    [ImageSource1 processImage];
    
    [filter setFloat:vectorX forUniformName:@"px"];
    
    [filter setFloat:vectorY forUniformName:@"py"];
    
    [filter setFloat:1.0*pointOld.x/w forUniformName:@"x"];
    
    [filter setFloat:1.0*pointOld.y/h forUniformName:@"y"];
    
    [filter setFloat:brushW*0.5 forUniformName:@"w"];
    
    self.initialFilters = [NSArray arrayWithObjects:filter,nil];
    self.terminalFilter = filter;
    return self;
}
@end
