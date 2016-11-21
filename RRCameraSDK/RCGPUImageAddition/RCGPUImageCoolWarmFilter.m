//
//  RCGPUImageCoolWarmFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/8/18.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageCoolWarmFilter.h"

NSString *const kRCGPUImageCoolWarmFragmentShaderString = SHADER_STRING
(
 
 precision mediump float;
  uniform sampler2D inputImageTexture;
  varying vec2 textureCoordinate;
 
 
  float getLuma(vec3 rgbP) {
      return  (0.299 * rgbP.r) +
      (0.587 * rgbP.g) +
      (0.114 * rgbP.b);
  }
  vec3 rgbToYuv(vec3 inP) {
      vec3 outP;
      outP.r = getLuma(inP);
      outP.g = (1.0/1.772)*(inP.b - outP.r);
      outP.b = (1.0/1.402)*(inP.r - outP.r);
      return outP;
  }
 
  vec3 yuvToRgb(vec3 inP) {
      float y = inP.r;
      float u = inP.g;
      float v = inP.b;
      vec3 outP;
      outP.r = 1.402 * v + y;
      outP.g = (y - (0.299 * 1.402 / 0.587) * v -
                (0.114 * 1.772 / 0.587) * u);
      outP.b = 1.772 * u + y;
      return outP;
  }
  vec3 adjustTemperature(float tempDelta, vec3 inRgb) {
 //               // we're adjusting the temperature by shifting the chroma channels in yuv space.
      vec3 yuvVec;
 //             // XXXTODO optimization, move yuvVec to rgbSpace if we use the same curveScale per channel in yuv space.
 
      if (tempDelta > 0.0 ) {
 //              // \warm\ midtone change
          yuvVec =  vec3(0.1765, -0.1255, 0.0902);
      } else {
 //              // \cool\ midtone change
          yuvVec = -vec3(0.0588,  0.1569, -0.1255);
      }
      vec3 yuvColor = rgbToYuv(inRgb);
 
      float luma = yuvColor.r;
 
      float curveScale = sin(luma * 3.14159); // a hump
 
      yuvColor += 0.375 * tempDelta * curveScale * yuvVec;
      inRgb = yuvToRgb(yuvColor);
      return inRgb;
  }
 
  void main() {
      vec4 texel = texture2D(inputImageTexture, textureCoordinate);
      const float TOOL_ON_EPSILON = 0.01; 
      vec3 rgb1;
      vec3 rgb2;
      float temperature=2.0;//暖色
      
      if (abs(temperature)>TOOL_ON_EPSILON)//暖色
      {
          if(textureCoordinate.y<0.45)\n+
            texel.rgb=adjustTemperature(temperature,texel.rgb);
          else if(textureCoordinate.y>0.55)
            texel.rgb=adjustTemperature(-temperature,texel.rgb);
          else
          {
            rgb1 = adjustTemperature(temperature,texel.rgb);
            rgb2 = adjustTemperature(-temperature,texel.rgb);
            texel.rgb = mix(rgb1,rgb2,(textureCoordinate.y-0.45)*10.0);
          }
      }
      
      gl_FragColor=clamp(texel,0.0,1.0);
     });
@implementation RCGPUImageCoolWarmFilter
-(id) init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    GPUImageFilter *filter = [[GPUImageFilter alloc] initWithFragmentShaderFromString:kRCGPUImageCoolWarmFragmentShaderString];
    
    self.initialFilters = [NSArray arrayWithObjects:filter,nil];
    self.terminalFilter = filter;
    
    return self;
}
@end
