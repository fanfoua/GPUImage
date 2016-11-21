//
//  RCGPUImageSymmetricFilter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/8/21.
//  Copyright (c) 2015年 renren. All rights reserved.
//
//镜像对称滤镜
#import "RCGPUImageSymmetricFilter.h"
NSString *const kRCGPUImageSymmetricFilterShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
    highp vec2 vectmp;
    if(textureCoordinate.x>0.5)
    {
        vectmp.x = textureCoordinate.x;
    }
    else
    {
        vectmp.x = 1.0 - textureCoordinate.x;
    }
    vectmp.y = textureCoordinate.y;
     
    lowp vec4 textureColor = texture2D(inputImageTexture, vectmp);
    gl_FragColor = textureColor;
 }
 );
@implementation RCGPUImageSymmetricFilter
-(id) init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    GPUImageFilter *filter = [[GPUImageFilter alloc] initWithFragmentShaderFromString:kRCGPUImageSymmetricFilterShaderString];
    
    self.initialFilters = [NSArray arrayWithObjects:filter,nil];
    self.terminalFilter = filter;
    
    return self;
}
@end
