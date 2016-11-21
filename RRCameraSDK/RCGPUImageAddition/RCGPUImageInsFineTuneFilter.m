//
//  RCGPUImageInsFineTuneFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/5/10.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageInsFineTuneFilter.h"

NSString *const kGPUImageInsFineTuneFragmentShaderString = SHADER_STRING
(
 precision highp float;
 uniform sampler2D inputImageTexture;
 varying vec2 textureCoordinate;
// varying vec2 sourceTextureCoordinate;
 uniform sampler2D blurred;
 uniform sampler2D sharpenBlur;
 uniform sampler2D splines;
 const float splines_shadows_offset = 0.250000;
 const float splines_shadowsNeg_offset = 0.750000;
 uniform float brightness;//亮度
 uniform float contrast;//对比度
 uniform float saturation;//饱和度
 uniform float temperature;//暖色？
 uniform float vignette;
 uniform float fade;
 uniform float highlights;
 uniform float shadows;
 uniform float sharpen;
 uniform float sharpenDisabled;
 uniform float tintShadowsIntensity;
 uniform float tintHighlightsIntensity;
 uniform vec3 tintShadowsColor;
 uniform vec3 tintHighlightsColor;

 // magnitude can be around the range ~ -1.0 -> 1.0
 vec3 bowRgbChannels(vec3 inVal, float mag) {

     vec3 outVal;
     float power = 1.0 + abs(mag);

     if (mag < 0.0) {
         power = 1.0 / power;
     }

     // a bow function that uses a "power curve" to bow the value
     // we flip it so it does more on the high end.
     outVal.r = 1.0 - pow((1.0 - inVal.r), power);
     outVal.g = 1.0 - pow((1.0 - inVal.g), power);
     outVal.b = 1.0 - pow((1.0 - inVal.b), power);

     return outVal;
 }

 // power bow. at 0 returns a linear curve on the inval.
 // at + mag returns an inceasingly "bowed up" curve,
 // at - mag returns the symmetrical function across the (y = x) line.
 // it's reflected so it's heavier at the bottom.
 float powerBow(float inVal, float mag) {
     float outVal;
     float power = 1.0 + abs(mag);

     if (mag > 0.0) {
         // flip power, and use abs so it magnitude negative values
         // have curves that are symmetric to positive.
         power = 1.0 / power;
     }
     inVal = 1.0 - inVal;
     outVal = pow((1.0 - inVal), power);

     return outVal;
 }

 vec3 rgb_to_hsv(vec3 c) {
     vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
     vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
     vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);

     float d = q.x - min(q.w, q.y);
     float e = 1.0e-10;
     return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
 }

 vec3 hsv_to_rgb(vec3 c) {
     vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
     vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
     return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
 }

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
     // we're adjusting the temperature by shifting the chroma channels in yuv space.
     vec3 yuvVec;
     // XXX TODO: optimization, move yuvVec to rgbSpace if we use the same curveScale per channel in yuv space.

     if (tempDelta > 0.0 ) {
         // "warm" midtone change
         yuvVec =  vec3(0.1765, -0.1255, 0.0902);
     } else {
         // "cool" midtone change
         yuvVec = -vec3(0.0588,  0.1569, -0.1255);
     }
     vec3 yuvColor = rgbToYuv(inRgb);

     float luma = yuvColor.r;

     float curveScale = sin(luma * 3.14159); // a hump

     yuvColor += 0.375 * tempDelta * curveScale * yuvVec;
     inRgb = yuvToRgb(yuvColor);
     return inRgb;
 }

 float linearRamp(float minVal, float maxVal, float value) {
     return clamp((value - minVal)/(maxVal - minVal), 0.0, 1.0);
 }

 // Acceptable ranges for strength are (-1, 1)
 // Sample output for strength = 0.4: https://www.latest.facebook.com/pxlcld/l743
 // When approaching the 1/-1 value the curve approaches a step function
 // A negative strength produces an easeOutIn curve.
 float easeInOutSigmoid(float value, float strength) {
     float t = 1.0 / (1.0 - strength);
     if (value > 0.5) {
         return 1.0 - pow(2.0 - 2.0 * value, t) * 0.5;
     } else {
         return pow(2.0 * value, t) * 0.5;
     }
 }

 vec3 softOverlayBlend(vec3 a, float mag) {
     return pow(a, vec3(1.0 / (1.0 - mag)));
 }

 // shadowsAdjust
 // for a passed in luminance curve adjust it by the "shadows area" strong bow or
 // the "non shadows area" by the gentle bow function.
 // the blurred luminance value is used to determing if we're in a "shadows area"
 // or "non shadows area"
 // the curves used are here: https://www.facebook.com/pxlcld/l7Dh
 float shadowsAdjust(float inLum, float inBlurredLum, float shadowsAmount) {
     
     float darkVal;
     float brightVal;
     if (shadowsAmount > 0.0) {
         darkVal = texture2D(splines, vec2(inLum, splines_shadows_offset)).r;
         brightVal = powerBow(inLum, 0.1);
     } else {
         darkVal = texture2D(splines, vec2(inLum, splines_shadowsNeg_offset)).r;
         brightVal = powerBow(inLum, -0.1);
     }
     float mixVal = clamp((inBlurredLum - 0.00)/0.4, 0.0, 1.0);
     float mixedVal = mix(darkVal, brightVal, inBlurredLum);

     return mix(inLum, mixedVal, abs(shadowsAmount));
 }

 // highlightsAdjust
 // for a passed in luminance curve adjust it by the "highlights area" strong bow or
 // the "non highlights area" by the gentle bow function.
 // this mirrors the shadowsAdjust implmentation, by mirroring the curves used.
 // the curves used are here: https://www.facebook.com/pxlcld/l7Dh
 float highlightsAdjust(float inLum, float inBlurredLum, float highlightsAmount) {
     float darkVal;
     float brightVal;
     if (highlightsAmount < 0.0) {
         brightVal = 1.0 - texture2D(splines, vec2(1.0 - inLum, splines_shadows_offset)).r;
         darkVal = 1.0 - powerBow(1.0 - inLum, 0.1);
     } else {
         brightVal = 1.0 - texture2D(splines, vec2(1.0 - inLum, splines_shadowsNeg_offset)).r;
         darkVal = 1.0 - powerBow(1.0 - inLum, -0.1);
     }
     float mixVal = clamp((inBlurredLum - 0.6)/0.4, 0.0, 1.0);
     float mixedVal = mix(darkVal, brightVal, inBlurredLum);

     return mix(inLum, mixedVal, abs(highlightsAmount));
 }

 vec3 fadeRaisedSFunction(vec3 color) {
     // Coefficients for the fading function
     vec3 co1 = vec3(-0.9772);
     vec3 co2 = vec3(1.708);
     vec3 co3 = vec3(-0.1603);
     vec3 co4 = vec3(0.2878);

     // Components of the polynomial
     vec3 comp1 = co1 * pow(vec3(color), vec3(3.0));
     vec3 comp2 = co2 * pow(vec3(color), vec3(2.0));
     vec3 comp3 = co3 * vec3(color);
     vec3 comp4 = co4;

     vec3 finalComponent = comp1 + comp2 + comp3 + comp4;
     vec3 difference = finalComponent - color;
     vec3 scalingValue = vec3(0.9);

     return color + (difference * scalingValue);
 }

 // This curve raises the darker colors, to lift shadows.
 vec3 tintRaiseShadowsCurve(vec3 color) {
     // This curve tints only shadows or highlights
     vec3 co1 = vec3(-0.003671);
     vec3 co2 = vec3(0.3842);
     vec3 co3 = vec3(0.3764);
     vec3 co4 = vec3(0.2515);

     // Components of the polynomial
     vec3 comp1 = co1 * pow(color, vec3(3.0));
     vec3 comp2 = co2 * pow(color, vec3(2.0));
     vec3 comp3 = co3 * color;
     vec3 comp4 = co4;

     return comp1 + comp2 + comp3 + comp4;
 }

 // fadeAdjust
 // For a passed in float, fade the image between a light gray source and the input image.
 vec3 fadeAdjust(vec3 texel, float fadeVal) {
     vec3 faded = fadeRaisedSFunction(texel);
     return (texel * (1.0 - fadeVal)) + (faded * fadeVal);
 }

 // tintShadows
 vec3 tintShadows(vec3 texel, vec3 tintColor, float tintAmount) {
     vec3 raisedShadows = tintRaiseShadowsCurve(texel);

     // Blend in raised shadows on the channels affected by the tintColor
     vec3 tintedShadows = mix(texel, raisedShadows, tintColor);
     vec3 tintedShadowsWithAmount = mix(texel, tintedShadows, tintAmount);

     // Clamping avoids pixel overflow when both tint shadows and highlights are applied
     return clamp(tintedShadowsWithAmount, 0.0, 1.0);
 }

 // tintHighlights
 vec3 tintHighlights(vec3 texel, vec3 tintColor, float tintAmount) {
     // Apply the inverse of the tint curve to affect highlights
     vec3 loweredHighlights = vec3(1.0) - tintRaiseShadowsCurve(vec3(1.0) - texel);

     // Blend in lowered highlights on the channels not effected by the tint colors
     vec3 tintedHighlights = mix(texel, loweredHighlights, (vec3(1.0) - tintColor));
     vec3 tintedHighlightsWithAmount = mix(texel, tintedHighlights, tintAmount);

     // Clamping avoids pixel overflow when both tint shadows and highlights are applied
     return clamp(tintedHighlightsWithAmount, 0.0, 1.0);
 }
 void main() {
     vec4 texel = texture2D(inputImageTexture, textureCoordinate);
     vec4 inputTexel = texel;
     const float TOOL_ON_EPSILON = 0.01;

     // sharpen 锐化
     if (abs(sharpenDisabled) < TOOL_ON_EPSILON) {
         // A zero value actually does something, a default sharpening, so don't put in a TOOL_ON_EPSILON check here
         vec3 blurredTexel = texture2D(sharpenBlur, textureCoordinate).rgb;
         vec3 diff = texel.rgb - blurredTexel;
         // sharpen magnitude has a default value of 0.35 at input 0, and a maximum of 2.5 at input 1.0.
         float mag = mix(0.35, 2.5, sharpen);
         texel.rgb = clamp(texel.rgb + diff * mag, 0.0, 1.0);
     }

     // highlights and shadows both use a blurred texture
     float blurredLum;
     if ((abs(highlights) > TOOL_ON_EPSILON) ||
         (abs(shadows) > TOOL_ON_EPSILON)) {
         texel=clamp(texel,0.0,1.0);
         vec3 blurredTexel = texture2D(blurred, textureCoordinate).rgb;
         blurredLum = rgb_to_hsv(blurredTexel).z;
     }

     // highlights  高光
     if ((abs(highlights) > TOOL_ON_EPSILON)) {
         texel=clamp(texel,0.0,1.0);
         // highlights tend to look better adjusted in RGB space.
         //                         texel.rgb = hsv_to_rgb(hsv);
         texel.r = highlightsAdjust(texel.r, blurredLum, highlights);
         texel.g = highlightsAdjust(texel.g, blurredLum, highlights);
         texel.b = highlightsAdjust(texel.b, blurredLum, highlights);
     }

     //  shadows  阴影
     if (abs(shadows) > TOOL_ON_EPSILON) {
         texel=clamp(texel,0.0,1.0);
         texel.r = shadowsAdjust(texel.r, blurredLum, shadows);
         texel.g = shadowsAdjust(texel.g, blurredLum, shadows);
         texel.b = shadowsAdjust(texel.b, blurredLum, shadows);
     }

     // fade   褪色ok
     if (abs(fade) > TOOL_ON_EPSILON ) {
         texel=clamp(texel,0.0,1.0);
         texel.rgb = fadeAdjust(texel.rgb, fade);
     }

     // tint shadows   色彩阴影强度
     if (abs(tintShadowsIntensity) > TOOL_ON_EPSILON) {
         texel=clamp(texel,0.0,1.0);
         texel.rgb = tintShadows(texel.rgb, tintShadowsColor, tintShadowsIntensity * 2.0);
     }

     // tint highlights   色彩高光强度
     if (abs(tintHighlightsIntensity) > TOOL_ON_EPSILON) {
         texel=clamp(texel,0.0,1.0);
         texel.rgb = tintHighlights(texel.rgb, tintHighlightsColor, tintHighlightsIntensity * 2.0);
     }

     // we're in HSV space for the next bunch of operations
     

     // saturation, scale from -1->1 to 50% max adjustment   饱和度ok
     if (abs(saturation) > TOOL_ON_EPSILON) {
         vec3 hsv = rgb_to_hsv(texel.rgb);
         texel=clamp(texel,0.0,1.0);
         float saturationFactor = 1.0 + saturation;
         hsv.y = hsv.y * saturationFactor;
         hsv.y = clamp(hsv.y, 0.0, 1.0);
         texel.rgb = hsv_to_rgb(hsv);
     }

     

     // contrast   对比度ok
     if (abs(contrast) > TOOL_ON_EPSILON) {
         texel=clamp(texel,0.0,1.0);
         float strength = contrast * 0.5; // adjust range to useful values

         vec3 yuv = rgbToYuv(texel.rgb);
         yuv.x = easeInOutSigmoid(yuv.x, strength);
         yuv.y = easeInOutSigmoid(yuv.y + 0.5, strength * 0.65) - 0.5;
         yuv.z = easeInOutSigmoid(yuv.z + 0.5, strength * 0.65) - 0.5;
         texel.rgb = yuvToRgb(yuv);
     }
     
     if (abs(temperature)>TOOL_ON_EPSILON)//暖色
     {
         texel=clamp(texel,0.0,1.0);
         texel.rgb=adjustTemperature(temperature,texel.rgb);
     }
     
     if (abs(brightness)>TOOL_ON_EPSILON)//亮度
     {
         texel=clamp(texel,0.0,1.0);
         texel.rgb=bowRgbChannels(texel.rgb,brightness);
     }
     
     if (abs(vignette)>TOOL_ON_EPSILON)//叠加效果
     {
         texel=clamp(texel,0.0,1.0);
         texel.rgb=softOverlayBlend(texel.rgb,vignette);
     }
     gl_FragColor=clamp(texel,0.0,1.0);
    }
);

NSString *const kGPUImageInsFineTuneVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

@implementation RCGPUImageInsFineTuneFilter

- (id)initStruct:(InsFineTune *)insFineTune
{

    if (!(self = [self initWithVertexShaderFromString:kGPUImageInsFineTuneVertexShaderString fragmentShaderFromString:kGPUImageInsFineTuneFragmentShaderString]))
    {
        return nil;
    }
    
    ga_Data[0][0]=1.0;
    ga_Data[0][1]=1.0;
    ga_Data[0][2]=0.0;
    
    ga_Data[1][0]=1.0;
    ga_Data[1][1]=0.5;
    ga_Data[1][2]=0.0;
    
    ga_Data[2][0]=1.0;
    ga_Data[2][1]=0.0;
    ga_Data[2][2]=0.0;
    
    ga_Data[3][0]=1.0;
    ga_Data[3][1]=0.0;
    ga_Data[3][2]=1.0;
    
    ga_Data[4][0]=0.5;
    ga_Data[4][1]=0.0;
    ga_Data[4][2]=1.0;
    
    ga_Data[5][0]=0.0;
    ga_Data[5][1]=0.0;
    ga_Data[5][2]=1.0;
    
    ga_Data[6][0]=0.0;
    ga_Data[6][1]=1.0;
    ga_Data[6][2]=1.0;
    
    ga_Data[7][0]=0.0;
    ga_Data[7][1]=1.0;
    ga_Data[7][2]=0.0;
    
    brightnessUniform = [filterProgram uniformIndex:@"brightness"];
    contrastUniform = [filterProgram uniformIndex:@"contrast"];
    saturationUniform = [filterProgram uniformIndex:@"saturation"];
    temperatureUniform = [filterProgram uniformIndex:@"temperature"];
    vignetteUniform = [filterProgram uniformIndex:@"vignette"];
    fadeUniform = [filterProgram uniformIndex:@"fade"];
    highlightsUniform = [filterProgram uniformIndex:@"highlights"];
    shadowsUniform = [filterProgram uniformIndex:@"shadows"];
    sharpenUniform = [filterProgram uniformIndex:@"sharpen"];
    sharpenDisabledUniform = [filterProgram uniformIndex:@"sharpenDisabled"];
    tintShadowsIntensityUniform = [filterProgram uniformIndex:@"tintShadowsIntensity"];
    tintHighlightsIntensityUniform = [filterProgram uniformIndex:@"tintHighlightsIntensity"];
    tintShadowsColorUniform = [filterProgram uniformIndex:@"tintShadowsColor"];
    tintHighlightsColorUniform = [filterProgram uniformIndex:@"tintHighlightsColor"];
    
    //[self setInteger:_iColor forUniform:brightnessUniform program:filterProgram];
    [self setFloat:insFineTune->brightness forUniform:brightnessUniform program:filterProgram];
    [self setFloat:insFineTune->contrast forUniform:contrastUniform program:filterProgram];
    [self setFloat:insFineTune->saturation forUniform:saturationUniform program:filterProgram];
    [self setFloat:insFineTune->temperature forUniform:temperatureUniform program:filterProgram];
    [self setFloat:insFineTune->vignette forUniform:vignetteUniform program:filterProgram];
    [self setFloat:insFineTune->fade forUniform:fadeUniform program:filterProgram];
    [self setFloat:insFineTune->highlights forUniform:highlightsUniform program:filterProgram];
    [self setFloat:insFineTune->shadows forUniform:shadowsUniform program:filterProgram];
    [self setFloat:insFineTune->sharpen forUniform:sharpenUniform program:filterProgram];
    [self setFloat:insFineTune->sharpenDisabled forUniform:sharpenDisabledUniform program:filterProgram];
    [self setFloat:insFineTune->tintShadowsIntensity forUniform:tintShadowsIntensityUniform program:filterProgram];
    [self setFloat:insFineTune->tintHighlightsIntensity forUniform:tintHighlightsIntensityUniform program:filterProgram];
    
    
    [self setVec3:insFineTune->tintShadowsColor forUniform:tintShadowsColorUniform program:filterProgram];
    [self setVec3:insFineTune->tintHighlightsColor forUniform:tintHighlightsColorUniform program:filterProgram];
    return self;
}
@end
