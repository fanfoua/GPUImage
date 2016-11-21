//
//  RCGPUImageMapFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/4/2.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageMapFilter.h"

//NSString *const kGPUImageMapFragmentShaderString = SHADER_STRING
//(
// precision highp float;
// varying vec2 textureCoordinate;
// uniform sampler2D inputImageTexture;
// uniform sampler2D inputImageTexture2;
//
// void main()
// {
//     highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
//
//     highp float r = textureColor.r;
//     highp float g = textureColor.g;
//     highp float b = textureColor.b;
//     highp float gap = 1.0/33.0;
//     //highp float fb = 1088.0/1089.0;
//     highp float ft = 31.0/33.0;
//
//     highp float temp = b/gap;
//
//     highp float index1 = min(1.0,(floor(temp))*gap + (g*ft+1.0/33.0)*gap);
//     highp float index2 = min(1.0,(floor(temp)+1.0)*gap + (g*ft+1.0/33.0)*gap);
//
//     highp float w1 = (b/gap - floor(b/gap));
//
//     highp vec4 textureColor1 = texture2D(inputImageTexture2, vec2(r,index1));
//     highp vec4 textureColor2 = texture2D(inputImageTexture2, vec2(r,index2));
//
//     gl_FragColor = vec4(mix(textureColor1,textureColor2,w1).rgb,1.0);
// }
// );

NSString *const kGPUImageMapFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 // 'size' is the number of shades per channel (e.g., 65 for a 65x(65*65) color map)\n
 highp vec4 ig_texture3D(sampler2D tex, highp vec3 texCoord, float size)
 {
     float sliceSize = 1.0 / size;
     float slicePixelSize = sliceSize / size;
     float sliceInnerSize = slicePixelSize * (size - 1.0);
     float xOffset = 0.5 * sliceSize + texCoord.x * (1.0 - sliceSize);
     float yOffset = 0.5 * slicePixelSize + texCoord.y * sliceInnerSize;
     float zOffset = texCoord.z * (size - 1.0);
     
     float zSlice0 = floor(zOffset);
     float zSlice1 = zSlice0 + 1.0;
     float s0 = yOffset + (zSlice0 * sliceSize);
     float s1 = yOffset + (zSlice1 * sliceSize);
     highp vec4 slice0Color = texture2D(tex, vec2(xOffset, s0));
     highp vec4 slice1Color = texture2D(tex, vec2(xOffset, s1));
     
     return mix(slice0Color, slice1Color, zOffset - zSlice0);
 }
 
 void main()
{
    highp vec4 texel = texture2D(inputImageTexture, textureCoordinate);
    highp vec4 inputTexel = texel;
    texel.rgb = ig_texture3D(inputImageTexture2, texel.rgb, 33.0).rgb;
    texel.rgb = mix(inputTexel.rgb, texel.rgb, 1.0);
    
    gl_FragColor = texel;
}
 );
@implementation RCGPUImageMapFilter


- (id)init
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageMapFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end