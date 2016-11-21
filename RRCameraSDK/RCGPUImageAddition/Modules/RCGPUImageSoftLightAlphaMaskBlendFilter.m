//
//  RCGPUImageSoftLightAlphaMaskBlendFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/8.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageSoftLightAlphaMaskBlendFilter.h"

@implementation RCGPUImageSoftLightAlphaMaskBlendFilter
-(NSString *) fragmentShaderForSoftLightAlphaMaskBlend;
{
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    [shaderString appendFormat:@"varying highp vec2 textureCoordinate;\n\
     varying highp vec2 textureCoordinate2;\n\
     varying highp vec2 textureCoordinate3;\n\
     uniform sampler2D inputImageTexture;\n\
     uniform sampler2D inputImageTexture2;\n\
     uniform sampler2D inputImageTexture3;\n\
     void main()\n\
     {\n\
     mediump vec4 base = texture2D(inputImageTexture, textureCoordinate);\n\
     mediump vec4 overlay = texture2D(inputImageTexture2, textureCoordinate2);\n\
     mediump vec4 mask = texture2D(inputImageTexture3, textureCoordinate3);\n\
     if(mask.g <0.5)\n\
     gl_FragColor =base;\n\
     else\n\
     {\n\
     gl_FragColor =vec4(mix(base.rgb, overlay.rgb, overlay.a * (base.b)*(1.0-textureCoordinate.y)), base.a);\n\
     }\n\
     }"];
    return shaderString;
}

-(id)initMixturePercent:(CGFloat) mixturePercent
{
    if (!(self = [super initWithFragmentShaderFromString:[self fragmentShaderForSoftLightAlphaMaskBlend]]))
    {
        return nil;
    }

    return self;
}

@end
