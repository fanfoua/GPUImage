//
//  RCGPUImageBrightnessFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/3/27.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageBrightnessFilter.h"
#import "RCDecrypt.h"
#import "RCGPUImageBrightnessMapFilter.h"

////打表，不同的强度分别经过+150、-150的亮度调整后的值
//int b_up_bound[256] = { 0, 3, 5, 8, 10, 13, 15, 18, 21, 23, 26, 28, 31, 33, 36, 39, 41, 44, 46, 49, 51, 54, 57, 59, 62, 64, 67, 69, 72, 75, 77, 80, 82,
//    85, 87, 90, 93, 95, 98, 100, 103, 106, 108, 111, 113, 116, 118, 121, 124, 126, 129, 131, 134, 136, 139, 141, 144, 146, 148, 151, 153, 155, 158, 160, 162,
//    164, 167, 169, 171, 173, 175, 177, 179, 181, 183, 184, 186, 188, 190, 191, 193, 195, 196, 198, 199, 201, 202, 203, 205, 206, 207, 209, 210, 211, 212, 213, 214,
//    216, 217, 218, 219, 220, 221, 222, 222, 223, 224, 225, 226, 227, 227, 228, 229, 230, 230, 231, 232, 232, 233, 234, 234, 235, 235, 236, 237, 237, 238, 238, 239,
//    239, 240, 240, 240, 241, 241, 242, 242, 242, 243, 243, 244, 244, 244, 244, 245, 245, 245, 246, 246, 246, 247, 247, 247, 247, 247, 248, 248, 248, 248, 249, 249,
//    249, 249, 249, 250, 250, 250, 250, 250, 250, 250, 251, 251, 251, 251, 251, 251, 251, 251, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 253, 253, 253, 253,
//    253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254,
//    254, 254, 254, 254, 254, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255};
//
//int b_low_bound[256] = { 0, 0, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 7, 7, 7, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 12, 12, 12,
//    13, 13, 14, 14, 14, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 19, 19, 19, 20, 20, 21, 21, 21, 22, 22, 23, 23, 23, 24, 24, 24, 25,
//    25, 26, 26, 26, 27, 27, 28, 28, 28, 29, 29, 30, 30, 30, 31, 31, 31, 32, 32, 33, 33, 33, 34, 34, 35, 35, 35, 36, 36, 37, 37, 37,
//    38, 38, 38, 39, 39, 40, 40, 40, 41, 41, 42, 42, 42, 43, 43, 44, 44, 44, 45, 45, 45, 46, 46, 47, 47, 47, 48, 48, 49, 49, 49, 50,
//    50, 51, 51, 51, 52, 52, 53, 53, 53, 54, 54, 55, 55, 55, 56, 56, 57, 57, 57, 58, 58, 59, 59, 60, 60, 60, 61, 61, 62, 62, 63, 63,
//    63, 64, 64, 65, 65, 66, 66, 67, 67, 68, 68, 69, 69, 70, 70, 71, 71, 72, 72, 73, 73, 74, 74, 75, 75, 76, 76, 77, 78, 78, 79, 79,
//    80, 81, 81, 82, 83, 83, 84, 85, 85, 86, 87, 87, 88, 89, 90, 90, 91, 92, 93, 94, 95, 96, 96, 97, 98, 99, 100, 101, 102, 103, 105, 106,
//    107, 108, 109, 111, 112, 113, 115, 116, 118, 120, 121, 123, 125, 127, 129, 131, 133, 136, 139, 141, 145, 148, 152, 156, 161, 167, 174, 183, 195, 214, 242};
//
//float b_use[256];
//- (NSString *)vertexShaderForBrightness;
//{
//    NSMutableString *shaderString = [[NSMutableString alloc] init];
//    // Header
//    [shaderString appendFormat:@"\
//     attribute vec4 position;\n\
//     attribute vec4 inputTextureCoordinate;\n\
//     \n\
//     uniform float texelWidthOffset;\n\
//     uniform float texelHeightOffset;\n\
//     varying vec2 textureCoord;\n\
//     \n\
//     void main()\n\
//     {\n\
//     gl_Position = position;\n\
//     textureCoord = inputTextureCoordinate.xy;\n\
//     "];
//
//    // Footer
//    [shaderString appendString:@"}\n"];
//
//    return shaderString;
//}
//
//- (NSString *)fragmentShaderForBrightness:(int)brightness;
//{
//    if (brightness < -150 || brightness > 150) {
//        brightness = MIN(150, MAX(-150, brightness));
//    }
//
//    float fbright;
//    if (brightness!=0)
//    {
//        fbright = abs(brightness)/150.0;
//        fbright=0.4*fbright+0.6*(1.0-(1.0-fbright)*(1.0-fbright));
//        if (brightness>0)
//        {
//            for (int i=0; i<256; i++)
//            {
//                b_use[i]=MIN(1.0, MAX(0.0,(i+(b_up_bound[i]-i)*fbright)/255.0));
//            }
//        }
//        else
//        {
//            for (int i=0; i<256; i++)
//            {
//                b_use[i]=MIN(1.0, MAX(0.0,(i+(b_low_bound[i]-i)*fbright)/255.0));
//            }
//        }
//    }
//
//
//    NSMutableString *shaderString = [[NSMutableString alloc] init];
//
//    // Header
//    [shaderString appendFormat:@"\
//     uniform sampler2D inputImageTexture;\n\
//     varying highp vec2 textureCoord;\n\
//     uniform lowp float b_use[256];\n\
//     uniform lowp float c_use[256];\n\
//     \n\
//     void main()\n\
//     {\n\
//     lowp vec4 nowdata=texture2D(inputImageTexture, textureCoord);\n\
//     lowp vec3 datatmp=nowdata.rgb;\n\
//     "];
//
//    if (brightness!=0)
//    {
//        [shaderString appendFormat:@"datatmp = vec3(b_use[int(floor(255.0*datatmp.r))],b_use[int(floor(255.0*datatmp.g))],b_use[int(floor(255.0*datatmp.b))]);\n"];
//    }
//
//
//    [shaderString appendFormat:@"gl_FragColor=vec4(datatmp.rgb,nowdata.a);}"];
//
//    return shaderString;
//}
//
//- (id)initBrightness:(int)brightness;
//{
//    NSString *currentBrightnessVertexShader = [self vertexShaderForBrightness];
//    NSString *currentBrightnessFragmentShader = [self  fragmentShaderForBrightness:brightness];
//
//    if (!(self = [super initWithVertexShaderFromString:currentBrightnessVertexShader fragmentShaderFromString:currentBrightnessFragmentShader]))
//    {
//        return nil;
//    }
//
//    runSynchronouslyOnVideoProcessingQueue(^{
//        [GPUImageContext useImageProcessingContext];
//
//        brightnessUniform = [filterProgram uniformIndex:@"b_use"];
//
//    });
//    return self;
//}
//
////提供给GPUImgFilter调用的用来设置图片大小的回调函数
//- (void)setupFilterForSize:(CGSize)filterFrameSize;
//{
//    runSynchronouslyOnVideoProcessingQueue(^{
//        [GPUImageContext setActiveShaderProgram:filterProgram];
//        glUniform1fv(brightnessUniform, 256, b_use);
//    });
//}
//@end

//NSString *const kGPUImageRCBrightnessFragmentShaderString = SHADER_STRING
//(
// precision lowp float;
//
// uniform sampler2D inputImageTexture;
// uniform sampler2D inputImageTexture2;
// varying highp vec2 textureCoordinate;
// uniform lowp float brightness;
//
// void main()
// {
//     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
//
//     vec3 data;
//     data.r = texture2D(inputImageTexture2, vec2(textureColor.r, brightness)).r;
//     data.g = texture2D(inputImageTexture2, vec2(textureColor.g, brightness)).g;
//     data.b = texture2D(inputImageTexture2, vec2(textureColor.b, brightness)).b;
//
//     gl_FragColor = vec4(data, 1.0);
// }
// );

@implementation RCGPUImageBrightnessFilter

@synthesize brightness = _brightness;

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    
    BrightnessMapFilter = [[RCGPUImageBrightnessMapFilter alloc]init];
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"bright_mapfix" withExtension:@"png"]]];
    
    NSAssert(image1,
             @"To use RCGPUImageBrightnessFilter you need to add bright_mapfix.png to your application bundle.");
    
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    [ImageSource1 addTarget:BrightnessMapFilter atTextureLocation:1];
    [ImageSource1 processImage];
    
    self.brightness = 0.0;
    
    self.initialFilters = [NSArray arrayWithObjects:BrightnessMapFilter, nil];
    self.terminalFilter = BrightnessMapFilter;
    return self;
}

- (void)setBrightness:(CGFloat)newValue;
{
    _brightness = ((newValue+150.0)/300.0);
    BrightnessMapFilter.brightness=_brightness;
}
@end