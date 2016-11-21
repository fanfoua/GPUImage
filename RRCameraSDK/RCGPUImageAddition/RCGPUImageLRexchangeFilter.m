//
//  RCGPUImageLRexchangeFilter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 16/5/13.
//  Copyright © 2016年 renren. All rights reserved.
//

#import "RCGPUImageLRexchangeFilter.h"

NSString *const kGPUImageLRexchangeFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, vec2(1.0-textureCoordinate.x,textureCoordinate.y));
     
     gl_FragColor = textureColor;
 }
 );

@implementation RCGPUImageLRexchangeFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageLRexchangeFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}
@end
