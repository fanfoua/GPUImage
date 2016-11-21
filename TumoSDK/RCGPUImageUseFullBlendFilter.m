//
//  RCGPUImageUseFullBlendFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/12.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageUseFullBlendFilter.h"

NSString *const kGPUImageUseFullBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     mediump vec4 base = texture2D(inputImageTexture, textureCoordinate);
     mediump vec4 overlay = texture2D(inputImageTexture2, textureCoordinate2);

     gl_FragColor = vec4(overlay.rgb,1.0);//vec4(overlay.rgb*overlay.a+base.rgb*(1.0-overlay.a),1.0);
 }
 );
@implementation RCGPUImageUseFullBlendFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageUseFullBlendFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}
@end
