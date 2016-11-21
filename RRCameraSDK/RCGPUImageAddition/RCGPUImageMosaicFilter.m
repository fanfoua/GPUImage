//
//  RCGPUImageMosaicFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/29.
//  Copyright (c) 2015年 renn. All rights reserved.
//
//官客 马赛克
#import "RCGPUImageMosaicFilter.h"

NSString *const kRCGPUImageMosaicFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform highp float hw;
 void main()
 {
     highp vec2 vectmp = vec2(floor(textureCoordinate.x*80.0)/80.0,floor(textureCoordinate.y*(hw*80.0))/(80.0*hw));
     mediump vec4 textureColor = texture2D(inputImageTexture, vectmp);
     gl_FragColor = textureColor;
 }
 );

@implementation RCGPUImageMosaicFilter
-(id) initSize:(CGSize)size;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    int w = size.width;
    int h = size.height;
    
    GPUImageFilter *filter = [[GPUImageFilter alloc] initWithFragmentShaderFromString:kRCGPUImageMosaicFragmentShaderString];
    [filter setFloat:h*1.0/w forUniformName:@"hw"];
    
    self.initialFilters = [NSArray arrayWithObjects:filter,nil];
    self.terminalFilter = filter;
    
    return self;
}
@end
