//
//  RCGPUImageFaceLiftFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/5/30.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageFaceLiftFilter.h"
#import "RCFaceHistStatisticsFilter.h"
@implementation RCGPUImageFaceLiftFilter

NSString *const kGPUImageFaceLiftFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;
 varying highp vec2 textureCoordinate4;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 uniform sampler2D inputImageTexture4;
 uniform highp float x1;
 uniform highp float w;
 uniform highp float y1;
 uniform highp float h;
 uniform highp float opacity;
 void main()
 {
     mediump vec4 textureColor;
     if (textureCoordinate.x>x1&&textureCoordinate.x<x1+w
         &&textureCoordinate.y>y1&&textureCoordinate.y<y1+h)
     {
         highp float tmp;
         highp float tmpx;
         highp float tmpy;
         tmpx= 3.0*(textureCoordinate.x - x1)/w;
         tmpy = (textureCoordinate.y-y1)/h;
         highp vec4 textureColor4 = texture2D(inputImageTexture4, vec2(tmpy,0.5))*opacity;//1.2调瘦脸程度(inputImageTexture4资源内部最大值是0.3 放大后不能超过1.0)
         if(tmpx<1.0)
         {
             tmp = tmpx;
             mediump vec4 textureColor2 = texture2D(inputImageTexture2, vec2(tmp,textureColor4.r));
             tmp = textureColor2.r;
         }
         else if (tmpx<2.0)
         {
             tmp = tmpx;
         }
         else
         {
             tmp = tmpx-2.0;
             mediump vec4 textureColor3 = texture2D(inputImageTexture3, vec2(tmp,textureColor4.r));
             tmp = textureColor3.r+2.0;
         }
         
         highp float tmp3 = tmp*w/3.0+x1;
         textureColor = texture2D(inputImageTexture, vec2(tmp3,textureCoordinate.y));
     }
     else
     {
         textureColor = texture2D(inputImageTexture, textureCoordinate);
     }
     
     gl_FragColor = vec4(textureColor.rgb,1.0);
 }
 );
- (id)initFaceRect:(struct FACERECT*)faceRect ImgSize:(CGSize *)sizeReal Opacity:(CGFloat)opacity
//- (id)initFaceRect:(struct FACERECT*)faceRect initImageSize:(CGSize)size
{
    
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //    CGImageRef img=[image CGImage];
    //    CGSize sizeReal = CGSizeMake(CGImageGetWidth(img), CGImageGetHeight(img));
    int w = sizeReal->width;
    int h = sizeReal->height;
    
    //瘦脸 大眼
    int faceWidth=faceRect->face_w;
    //    if (faceWidth>0&&faceRect->face_x-faceRect->face_w/4.0>0
    //        &&faceRect->face_x+faceRect->face_w*5.0/4.0<w-1)
    {
        //        UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
        //                                                                   pathForResource:@"FaceLiftMap1" ofType:@"png"]];
        
        UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                                  [resBundle URLForResource:@"FaceLiftMap1" withExtension:@"png"]]];
        
        NSAssert(image1,
                 @"To use RCGPUImageInsCremaFilter you need to add FaceLiftMap1.png to your application bundle.");
        ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
        
        //        UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle
        //                                                                   pathForResource:@"FaceLiftMap2" ofType:@"png"]];
        
        UIImage *image2 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                                  [resBundle URLForResource:@"FaceLiftMap2" withExtension:@"png"]]];
        
        NSAssert(image2,
                 @"To use RCGPUImageInsCremaFilter you need to add FaceLiftMap2.png to your application bundle.");
        ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
        
        //        UIImage *image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle
        //                                                                   pathForResource:@"FaceLiftMap3" ofType:@"png"]];
        
        UIImage *image3 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                                  [resBundle URLForResource:@"FaceLiftMap3" withExtension:@"png"]]];
        
        NSAssert(image3,
                 @"To use RCGPUImageInsCremaFilter you need to add FaceLiftMap3.png to your application bundle.");
        ImageSource3 = [[GPUImagePicture alloc] initWithImage:image3];
        
        RCGPUImageFourInputFilter *FaceLiftFragmentFilter=[[RCGPUImageFourInputFilter alloc]initWithFragmentShaderFromString:kGPUImageFaceLiftFragmentShaderString];
        
        
        float x1, w, y1, h;
        x1=(faceRect->face_x-faceRect->face_w/4.0)/sizeReal->width;
        w=(1.5*faceRect->face_w)/sizeReal->width;
        y1=faceRect->face_y/sizeReal->height;
        h=faceRect->face_h*4.0/3.0/sizeReal->height;
        
        [FaceLiftFragmentFilter setFloat:x1 forUniformName:@"x1"];
        [FaceLiftFragmentFilter setFloat:w forUniformName:@"w"];
        [FaceLiftFragmentFilter setFloat:y1 forUniformName:@"y1"];
        [FaceLiftFragmentFilter setFloat:h forUniformName:@"h"];
        [FaceLiftFragmentFilter setFloat:opacity*3.3 forUniformName:@"opacity"];
        
        [self addFilter:FaceLiftFragmentFilter];
        [ImageSource1 addTarget:FaceLiftFragmentFilter atTextureLocation:1];
        [ImageSource2 addTarget:FaceLiftFragmentFilter atTextureLocation:2];
        [ImageSource3 addTarget:FaceLiftFragmentFilter atTextureLocation:3];
        [ImageSource1 processImage];
        [ImageSource2 processImage];
        [ImageSource3 processImage];
        
        self.initialFilters = [NSArray arrayWithObjects:FaceLiftFragmentFilter,nil];
        self.terminalFilter = FaceLiftFragmentFilter;
        return self;
    }
    //    return nil;
}
@end
