//
//  RCGPUImage2DRotateFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/5/11.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImage2DRotateFilter.h"

NSString *const kGPUImage2DRotateFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform highp float theta;
 uniform highp float whDe;
 uniform highp float hwDe;
 
 void main()
{
    highp vec2 rotateCoord;
    rotateCoord.x = cos(theta)*(textureCoordinate.x-0.5) + sin(theta)*(textureCoordinate.y-0.5)*hwDe;
    rotateCoord.y = cos(theta)*(textureCoordinate.y-0.5) - sin(theta)*(textureCoordinate.x-0.5)*whDe;
    rotateCoord = rotateCoord/(abs(cos(theta))+max(hwDe,whDe)*abs(sin(theta)));
    
    lowp vec4 textureColor = texture2D(inputImageTexture, rotateCoord+0.5);
    gl_FragColor = textureColor;
}
 );

//NSString *const kGPUImage2DRotateFragmentShaderString = SHADER_STRING
//(
// varying highp vec2 textureCoordinate;
// uniform sampler2D inputImageTexture;
// 
// uniform highp float theta;
// uniform highp float wDe;
// uniform highp float hDe;
// 
// void main()
//{
//    highp vec2 rotateCoord;
//    rotateCoord.x = cos(theta)*(textureCoordinate.x-0.5) - sin(theta)*(textureCoordinate.y-0.5);
//    rotateCoord.y = sin(theta)*(textureCoordinate.x-0.5) + cos(theta)*(textureCoordinate.y-0.5);
//    rotateCoord = rotateCoord/(abs(sin(theta))+abs(cos(theta)));
//    
//    lowp vec4 textureColor = texture2D(inputImageTexture, rotateCoord+0.5);
//    gl_FragColor = textureColor;
//}
// );


@implementation RCGPUImage2DRotateFilter
@synthesize theta = _theta;

//提供给GPUImgFilter调用的用来设置图片大小的回调函数
- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    CGFloat whDe,hwDe;
    whDe=filterFrameSize.width/filterFrameSize.height;
    hwDe=filterFrameSize.height/filterFrameSize.width;
    
    wDeUniform = [filterProgram uniformIndex:@"whDe"];
    hDeUniform = [filterProgram uniformIndex:@"hwDe"];
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext setActiveShaderProgram:filterProgram];
        glUniform1f(wDeUniform, whDe);
        glUniform1f(hDeUniform, hwDe);
    });
    
}

- (id)init
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImage2DRotateFragmentShaderString]))
    {
        return nil;
    }
    
    thetaUniform = [filterProgram uniformIndex:@"theta"];
    self.theta = 0.0;
    
    return self;
}

- (void)setTheta:(CGFloat)newValue;
{
    _theta = newValue;
    [self setFloat:_theta forUniform:thetaUniform program:filterProgram];
}

@end