//
//  RCGPUImageContrastFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/3/27.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageContrastFilter.h"
#import "RCDecrypt.h"
#import "RCGPUImageContrastMapFilter.h"

////打表，不同的强度分别经过+100、-50的对比度调整后的值
//int c_up_bound[256] = { 0, 0, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 13, 13, 14,
//    14, 15, 16, 16, 17, 18, 18, 19, 20, 21, 21, 22, 23, 24, 24, 25, 26, 27, 28, 29, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
//    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 52, 53, 54, 55, 56, 57, 59, 60, 61, 62, 63, 65, 66, 67, 69, 70, 71, 73, 74, 75, 77, 78,
//    79, 81, 82, 84, 85, 86, 88, 89, 91, 92, 94, 95, 97, 99, 100, 102, 103, 105, 106, 108, 110, 111, 113, 115, 116, 118, 120, 121, 123, 125, 127, 128,
//    130, 132, 134, 135, 137, 139, 140, 142, 144, 145, 147, 149, 150, 152, 153, 155, 156, 158, 160, 161, 163, 164, 166, 167, 169, 170, 171, 173, 174, 176, 177, 178,
//    180, 181, 182, 184, 185, 186, 188, 189, 190, 192, 193, 194, 195, 196, 198, 199, 200, 201, 202, 203, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216,
//    217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 226, 227, 228, 229, 230, 231, 231, 232, 233, 234, 234, 235, 236, 237, 237, 238, 239, 239, 240, 241, 241, 242,
//    242, 243, 244, 244, 245, 245, 246, 246, 247, 247, 248, 248, 249, 249, 250, 250, 250, 251, 251, 252, 252, 252, 253, 253, 253, 254, 254, 254, 254, 255, 255};
//
//int c_low_bound[256] = { 0, 1, 3, 4, 5, 7, 8, 10, 11, 12, 14, 15, 16, 17, 19, 20, 21, 23, 24, 25, 26, 28, 29, 30, 31, 33, 34, 35, 36, 38, 39, 40, 41,
//    42, 43, 45, 46, 47, 48, 49, 50, 52, 53, 54, 55, 56, 57, 58, 59, 60, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76,
//    77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 90, 91, 92, 93, 94, 95, 96, 97, 98, 98, 99, 100, 101, 102, 103, 103, 104, 105,
//    106, 107, 107, 108, 109, 110, 111, 111, 112, 113, 114, 114, 115, 116, 116, 117, 118, 119, 119, 120, 121, 121, 122, 123, 123, 124, 125, 125, 126, 127, 127, 128,
//    128, 129, 130, 130, 131, 132, 132, 133, 134, 134, 135, 136, 136, 137, 138, 139, 139, 140, 141, 141, 142, 143, 144, 144, 145, 146, 147, 148, 148, 149, 150, 151,
//    152, 152, 153, 154, 155, 156, 157, 157, 158, 159, 160, 161, 162, 163, 164, 165, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180,
//    181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 195, 196, 197, 198, 199, 200, 201, 202, 203, 205, 206, 207, 208, 209, 210, 212, 213, 214, 215,
//    216, 217, 219, 220, 221, 222, 224, 225, 226, 227, 229, 230, 231, 232, 234, 235, 236, 238, 239, 240, 241, 243, 244, 245, 247, 248, 250, 251, 252, 254, 255};


//float c_use[256];
//- (NSString *)vertexShaderForContrastAndBrightness;
//{
//
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
//- (NSString *)fragmentShaderForContrast:(int)contrast;
//{
//    if (contrast < -50 || contrast > 100) {
//        contrast = MIN(100, MAX(-50, contrast));
//    }
//
//    float fcontrast;
//
//    if (contrast!=0)
//    {
//        if (contrast>0)
//        {
//            fcontrast= contrast /100.0;
//        }
//        else
//        {
//
//            fcontrast= -contrast/50.0;
//        }
//        fcontrast=0.4*fcontrast+0.6*(1.0-(1.0-fcontrast)*(1.0-fcontrast));
//        if (contrast>0)
//        {
//            for (int i=0; i<256; i++)
//            {
//                c_use[i]=(i+(c_up_bound[i]-i)*fcontrast)/255.0;
//            }
//        }
//        else
//        {
//            for (int i=0; i<256; i++)
//            {
//                c_use[i]=(i+(c_low_bound[i]-i)*fcontrast)/255.0;
//            }
//        }
//    }
//
//    NSMutableString *shaderString = [[NSMutableString alloc] init];
//
//    // Header
//    [shaderString appendFormat:@"\
//     uniform sampler2D inputImageTexture;\n\
//     varying highp vec2 textureCoord;\n\
//     uniform lowp float c_use[256];\n\
//     \n\
//     void main()\n\
//     {\n\
//     lowp vec4 nowdata=texture2D(inputImageTexture, textureCoord);\n\
//     lowp vec3 datatmp=nowdata.rgb;\n\
//     "];
//
//    if (contrast!=0)
//    {
//        [shaderString appendFormat:@"datatmp = vec3(c_use[int(floor(datatmp.r*255.0))],c_use[int(floor(datatmp.g*255.0))],c_use[int(floor(255.0*datatmp.b))]);\n"];
//    }
//
//    [shaderString appendFormat:@"gl_FragColor=vec4(datatmp.rgb,nowdata.a);}"];
//
//    return shaderString;
//}
//
//- (id)initContrast:(int)contrast;
//{
//    NSString *currentContrastVertexShader = [self vertexShaderForContrastAndBrightness];
//    NSString *currentContrastFragmentShader = [self  fragmentShaderForContrast:contrast];
//
//    if (!(self = [super initWithVertexShaderFromString:currentContrastVertexShader fragmentShaderFromString:currentContrastFragmentShader]))
//    {
//        return nil;
//    }
//
//    runSynchronouslyOnVideoProcessingQueue(^{
//        [GPUImageContext useImageProcessingContext];
//
//        contrastUniform = [filterProgram uniformIndex:@"c_use"];
//    });
//    return self;
//}
//
////提供给GPUImgFilter调用的用来设置图片大小的回调函数
//- (void)setupFilterForSize:(CGSize)filterFrameSize;
//{
//    runSynchronouslyOnVideoProcessingQueue(^{
//        [GPUImageContext setActiveShaderProgram:filterProgram];
//        glUniform1fv(contrastUniform, 256, c_use);
//    });
//}

//NSString *const kGPUImageRCContrastFragmentShaderString = SHADER_STRING
//(
// precision lowp float;
//
// uniform sampler2D inputImageTexture;
// uniform sampler2D inputImageTexture2;
// varying highp vec2 textureCoordinate;
// uniform lowp float contrast;
//
// void main()
// {
//     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
//
//     vec3 data;
//     data.r = texture2D(inputImageTexture2, vec2(textureColor.r, contrast)).r;
//     data.g = texture2D(inputImageTexture2, vec2(textureColor.g, contrast)).g;
//     data.b = texture2D(inputImageTexture2, vec2(textureColor.b, contrast)).b;
//
//     gl_FragColor = vec4(data, 1.0);
// }
// );

@implementation RCGPUImageContrastFilter

@synthesize contrast = _contrast;

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    ContrastMapFilter=[[RCGPUImageContrastMapFilter alloc] init];
    
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"contrast_map" withExtension:@"png"]]];
    
    NSAssert(image1,
             @"To use RCGPUImageContrastFilter you need to add contrast_map.png to your application bundle.");
    
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    [ImageSource1 addTarget:ContrastMapFilter atTextureLocation:1];
    [ImageSource1 processImage];
    
    self.contrast = 0.0;
    
    
    self.initialFilters = [NSArray arrayWithObjects:ContrastMapFilter, nil];
    self.terminalFilter = ContrastMapFilter;
    
    return self;
}

- (void)setContrast:(CGFloat)newValue;
{
    _contrast = ((newValue+100.0)/200.0);
    ContrastMapFilter.contrast=_contrast;
}

@end