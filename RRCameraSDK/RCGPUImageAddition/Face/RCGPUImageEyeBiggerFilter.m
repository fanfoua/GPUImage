//
//  RCGPUImageBeautyEyeFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/6/4.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageEyeBiggerFilter.h"
#import "RCFaceHistStatisticsFilter.h"
@implementation RCGPUImageEyeBiggerFilter

NSString *const kGPUImageEyeBiggerFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 uniform highp float x1;
 uniform highp float x2;
 uniform highp float y1;
 uniform highp float y2;
 uniform highp float rw;
 uniform highp float rh;
 uniform highp float opacity;
 
 void main()
 {
     mediump vec4 textureColor;
     highp float x;
     highp float y;
     highp float xdst;
     highp float ydst;
     
     if ((abs(textureCoordinate.x-x1)<rw&&abs(textureCoordinate.y-y1)<rh)||(abs(textureCoordinate.x-x2)<rw&&abs(textureCoordinate.y-y2)<rh))
     {
         if ((abs(textureCoordinate.x-x1)<rw&&abs(textureCoordinate.y-y1)<rh))
         {
             x=x1;
             y=y1;
         }
         else if((abs(textureCoordinate.x-x2)<rw&&abs(textureCoordinate.y-y2)<rh))
         {
             x=x2;
             y=y2;
         }
         
         highp vec4 textureColorx;
         
         highp vec2 td=(vec2(rw,rh)-abs(textureCoordinate-vec2(x,y)))/vec2(rw,rh);;//(r-abs(textureCoordinate-vec2(x,y)))/r;
         highp vec2 dt=vec2(td.y,td.x);
         if(textureCoordinate.x<x)
         {
             highp float tmpx=(textureCoordinate.x - x+rw)/rw;
             textureColorx = texture2D(inputImageTexture3, vec2(tmpx,opacity));
             xdst=textureColorx.r*rw+x-rw;
         }
         else
         {
             highp float tmpx=(textureCoordinate.x - x)/rw;
             textureColorx = texture2D(inputImageTexture2, vec2(tmpx,opacity));
             xdst=textureColorx.r*rw+x;
         }
         
         highp vec4 textureColory;
         if(textureCoordinate.y<y)
         {
             highp float tmpy=(textureCoordinate.y - y+rh)/rh;
             textureColory = texture2D(inputImageTexture3, vec2(tmpy,opacity));
             ydst=textureColory.r*rh+y-rh;
         }
         else
         {
             highp float tmpy=(textureCoordinate.y - y)/rh;
             textureColory = texture2D(inputImageTexture2, vec2(tmpy,opacity));
             ydst=textureColory.r*rh+y;
         }
         highp vec2 us=vec2(textureCoordinate*(1.0-dt)+vec2(xdst,ydst)*dt);
         textureColor=texture2D(inputImageTexture, us);
     }
     else
     {
         textureColor=texture2D(inputImageTexture, textureCoordinate);
     }
     
     gl_FragColor = vec4(textureColor.rgb,1.0);
 }
 );


NSString *const kGPUImageEyeBiggerOnePoiFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 uniform highp float x1;
 uniform highp float y1;
 uniform highp float rw;
 uniform highp float rh;
 uniform highp float opacity;
 
 void main()
 {
     mediump vec4 textureColor;
     highp float x;
     highp float y;
     highp float xdst;
     highp float ydst;
     
     if (abs(textureCoordinate.x-x1)<rw&&abs(textureCoordinate.y-y1)<rh)
     {
         if ((abs(textureCoordinate.x-x1)<rw&&abs(textureCoordinate.y-y1)<rh))
         {
             x=x1;
             y=y1;
         }
         
         highp vec4 textureColorx;
         
         highp vec2 td=(vec2(rw,rh)-abs(textureCoordinate-vec2(x,y)))/vec2(rw,rh);;//(r-abs(textureCoordinate-vec2(x,y)))/r;
         highp vec2 dt=vec2(td.y,td.x);
         if(textureCoordinate.x<x)
         {
             highp float tmpx=(textureCoordinate.x - x+rw)/rw;
             textureColorx = texture2D(inputImageTexture3, vec2(tmpx,opacity));
             xdst=textureColorx.r*rw+x-rw;
         }
         else
         {
             highp float tmpx=(textureCoordinate.x - x)/rw;
             textureColorx = texture2D(inputImageTexture2, vec2(tmpx,opacity));
             xdst=textureColorx.r*rw+x;
         }
         
         highp vec4 textureColory;
         if(textureCoordinate.y<y)
         {
             highp float tmpy=(textureCoordinate.y - y+rh)/rh;
             textureColory = texture2D(inputImageTexture3, vec2(tmpy,opacity));
             ydst=textureColory.r*rh+y-rh;
         }
         else
         {
             highp float tmpy=(textureCoordinate.y - y)/rh;
             textureColory = texture2D(inputImageTexture2, vec2(tmpy,opacity));
             ydst=textureColory.r*rh+y;
         }
         highp vec2 us=vec2(textureCoordinate*(1.0-dt)+vec2(xdst,ydst)*dt);
         textureColor=texture2D(inputImageTexture, us);
     }
     else
     {
         textureColor=texture2D(inputImageTexture, textureCoordinate);
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
    
    int faceWidth=faceRect->face_w;
    RCGPUImageThreeInputFilter *EyeBiggerFragmentFilter;
    if (opacity<0.0)
    {
        EyeBiggerFragmentFilter=[[RCGPUImageThreeInputFilter alloc] initWithFragmentShaderFromString:kGPUImageEyeBiggerOnePoiFragmentShaderString];
        
        float x1;
        float y1;
        float rw,rh;
        
        x1=(1.0*faceRect->eyeleft_x)/sizeReal->width;
        y1=(1.0*faceRect->eyeleft_y)/sizeReal->height;
        
        rw=fabs(opacity)*0.12;
        rh=rw*w/h;
        [EyeBiggerFragmentFilter setFloat:x1 forUniformName:@"x1"];
        [EyeBiggerFragmentFilter setFloat:y1 forUniformName:@"y1"];
        [EyeBiggerFragmentFilter setFloat:rw forUniformName:@"rw"];
        [EyeBiggerFragmentFilter setFloat:rh forUniformName:@"rh"];
        [EyeBiggerFragmentFilter setFloat:0.375*0.5 forUniformName:@"opacity"];
    }
    else
    {
        EyeBiggerFragmentFilter=[[RCGPUImageThreeInputFilter alloc] initWithFragmentShaderFromString:kGPUImageEyeBiggerFragmentShaderString];
        
        float x1;
        float y1;
        float x2;
        float y2;
        float rw,rh;
        
        x1=(1.0*faceRect->eyeleft_x)/sizeReal->width;
        y1=(1.0*faceRect->eyeleft_y)/sizeReal->height;
        x2=(1.0*faceRect->eyeright_x)/sizeReal->width;
        y2=(1.0*faceRect->eyeright_y)/sizeReal->height;
        
        rw=sqrtf((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))*0.5;
        rh=rw*w/h;
        [EyeBiggerFragmentFilter setFloat:x1 forUniformName:@"x1"];
        [EyeBiggerFragmentFilter setFloat:x2 forUniformName:@"x2"];
        [EyeBiggerFragmentFilter setFloat:y1 forUniformName:@"y1"];
        [EyeBiggerFragmentFilter setFloat:y2 forUniformName:@"y2"];
        [EyeBiggerFragmentFilter setFloat:rw forUniformName:@"rw"];
        [EyeBiggerFragmentFilter setFloat:rh forUniformName:@"rh"];
        [EyeBiggerFragmentFilter setFloat:opacity*0.5 forUniformName:@"opacity"];
    }
    
    
    
    
    
    UIImage *image4 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"FaceLiftMap1" withExtension:@"png"]]];
    
    NSAssert(image4,
             @"To use RCGPUImageInsCremaFilter you need to add FaceLiftMap1.png to your application bundle.");
    ImageSource4 = [[GPUImagePicture alloc] initWithImage:image4];
    
    //        UIImage *image5 = [[UIImage alloc] initWithContentsOfFile:[resBundle
    //                                                                   pathForResource:@"FaceLiftMap2" ofType:@"png"]];
    
    UIImage *image5 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"FaceLiftMap2" withExtension:@"png"]]];
    
    NSAssert(image5,
             @"To use RCGPUImageInsCremaFilter you need to add FaceLiftMap2.png to your application bundle.");
    ImageSource5 = [[GPUImagePicture alloc] initWithImage:image5];
    
    [self addFilter:EyeBiggerFragmentFilter];
    [ImageSource4 addTarget:EyeBiggerFragmentFilter atTextureLocation:1];
    [ImageSource5 addTarget:EyeBiggerFragmentFilter atTextureLocation:2];
    [ImageSource4 processImage];
    [ImageSource5 processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:EyeBiggerFragmentFilter,nil];
    self.terminalFilter = EyeBiggerFragmentFilter;
    return self;
}
@end
