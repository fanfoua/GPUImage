//
//  RCGPUImageParaBlendFilter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/9/29.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageParaBlendFilter.h"

NSString *const kGPUImageParaBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform highp float para;
 void main()
 {
     lowp vec4 c1 = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 c2 = texture2D(inputImageTexture2, textureCoordinate);
     
     lowp vec4 outputColor;
     outputColor.rgb=mix(c1.rgb,c2.rgb,para);
//     if (c2.rgb==c1.rgb)
//     {
//         outputColor.rgb=vec3(1.0,0.0,0.0);
//     }
     //mix(c1.rgb,c2.rgb,0.5);
     outputColor.a=1.0;
     
     gl_FragColor = outputColor;
 }
 );

@implementation RCGPUImageParaBlendFilter

- (id)initPara:(CGFloat)para;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageParaBlendFragmentShaderString]))
    {
        return nil;
    }
    
    [self setFloat:para forUniformName:@"para"];
    
    return self;
}
@end
