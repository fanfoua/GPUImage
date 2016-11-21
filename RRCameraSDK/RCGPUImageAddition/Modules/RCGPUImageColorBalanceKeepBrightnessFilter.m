//
//  RCGPUImageColorBalanceKeepBrightnessFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/1.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageColorBalanceKeepBrightnessFilter.h"

NSString *const kRCGPUImageColorBalanceKeepBrightnessVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 inputTextureCoordinate2;
 attribute vec4 inputTextureCoordinate3;
 attribute vec4 inputTextureCoordinate4;
 
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 varying vec2 textureCoordinate3;
 varying vec2 textureCoordinate4;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     textureCoordinate2 = inputTextureCoordinate2.xy;
     textureCoordinate3 = inputTextureCoordinate3.xy;
     textureCoordinate4 = inputTextureCoordinate4.xy;
 }
 );

NSString *const kRCGPUImageColorBalanceKeepBrightnessFragmentShaderString = SHADER_STRING
(
precision highp float;

 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;
 varying highp vec2 textureCoordinate4;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 uniform sampler2D inputImageTexture4;

 uniform float shadowShiftR;
 uniform float shadowShiftG;
 uniform float shadowShiftB;
 uniform float midShiftR;
 uniform float midShiftG;
 uniform float midShiftB;
 uniform float highlightShiftR;
 uniform float highlightShiftG;
 uniform float highlightShiftB;

float adjust(sampler2D map, float val, float shift)
{
   highp vec2 mapIdx = vec2(val,shift);
   mediump vec4 value = texture2D(map, mapIdx);
   return value.r;
}
 
 float pixel_cb(float val,float sshift,float mshift,float hshift)
 {
     highp float shadow;
     highp float midtone;
     highp float highlight;
     highp float value;
     shadow = adjust(inputImageTexture2,val,sshift);
     midtone = adjust(inputImageTexture3,val,mshift);
     highlight = adjust(inputImageTexture4,val,hshift);
     value = -2.0*val +shadow + midtone +highlight;
     value = clamp(value,0.0,1.0);
     return value;
 }
 
 void main()
 {
    mediump vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    highp float r = textureColor.r;
    highp float g = textureColor.g;
    highp float b = textureColor.b;

    highp float shadowRIndex = (shadowShiftR);
    shadowRIndex = (shadowRIndex+100.0)/200.0;
    highp float mintoneRIndex = (midShiftR);
    mintoneRIndex = (mintoneRIndex+100.0)/200.0;
    highp float highlightRIndex= (highlightShiftR);
    highlightRIndex = (highlightRIndex+100.0)/200.0;

    highp float shadowGIndex= (shadowShiftG);
    shadowGIndex = (shadowGIndex+100.0)/200.0;

    highp float mintoneGIndex= (midShiftG);
    mintoneGIndex = (mintoneGIndex+100.0)/200.0;

    highp float highlightGIndex= (highlightShiftG);
    highlightGIndex = (highlightGIndex+100.0)/200.0;

    highp float shadowBIndex= (shadowShiftB);
    shadowBIndex = (shadowBIndex+100.0)/200.0;

    highp float mintoneBIndex= (midShiftB);
    mintoneBIndex = (mintoneBIndex+100.0)/200.0;

    highp float highlightBIndex= (highlightShiftB);
    highlightBIndex = (highlightBIndex+100.0)/200.0;

    float outR = pixel_cb(r,shadowRIndex,mintoneRIndex,highlightRIndex);
    float outG = pixel_cb(g,shadowGIndex,mintoneGIndex,highlightGIndex);
    float outB = pixel_cb(b,shadowBIndex,mintoneBIndex,highlightBIndex);

    gl_FragColor = vec4(outR,outG,outB,1.0);
    // mediump vec4 value = texture2D(inputImageTexture4, textureCoordinate);
     //gl_FragColor = vec4(vec4(value.rgb,1.0));
 });

@implementation RCGPUImageColorBalanceKeepBrightnessFilter

- (int)setColorBalanceParamshadowShiftR:(float) shadowShiftR shadowShiftG:(float) shadowShiftG  shadowShiftB: (float) shadowShiftB midShiftR: (float) midShiftR midShiftG:(float) midShiftG midShiftB:(float) midShiftB highlightShiftR:(float) highlightShiftR highlightShiftG:(float) highlightShiftG highlightShiftB:(float) highlightShiftB;
{
    int maxvalue, maxindex, minvalue, minindex, midvalue, midindex;
    minvalue = MIN(MIN(midShiftR, midShiftG), midShiftB);
    midShiftR +=(-minvalue);
    midShiftG +=(-minvalue);
    midShiftB +=(-minvalue);

    if (midShiftR > midShiftG) {
        maxvalue = midShiftR; maxindex = 0;
        minvalue = midShiftG; minindex = 1;
    }
    else {
        maxvalue = midShiftG; maxindex = 1;
        minvalue = midShiftR; minindex = 0;
    }
    if (maxvalue < midShiftB){
        maxvalue = midShiftB; maxindex = 2;
    }
    if (minvalue > midShiftB){
        minvalue = midShiftB; minindex = 2;
    }
    midindex = 3 - maxindex - minindex;
    midvalue = midShiftR + midShiftB + midShiftG - maxvalue - minvalue;
    
    if(minindex == 0) midShiftR = (-maxvalue);
    else if(minindex == 1) midShiftG = (-maxvalue);
    else if(minindex == 2) midShiftB = (-maxvalue);
    
    if(midindex == 0) midShiftR = 2 * midvalue - maxvalue;
    else if(midindex == 1) midShiftG = 2 * midvalue - maxvalue;
    else if(midindex == 2) midShiftB = 2 * midvalue - maxvalue;
    
    
    maxvalue = MAX(MAX(shadowShiftR, shadowShiftG), shadowShiftB);
    
    shadowShiftR +=(-maxvalue);
    shadowShiftG +=(-maxvalue);
    shadowShiftB +=(-maxvalue);
    
    minvalue = MIN(MIN(highlightShiftR, highlightShiftG), highlightShiftB);
    
    highlightShiftR +=(-minvalue);
    highlightShiftG +=(-minvalue);
    highlightShiftB +=(-minvalue);
    
    mshadowShiftR = shadowShiftR;
    mshadowShiftG = shadowShiftG;
    mshadowShiftB = shadowShiftB;
    mmidShiftR = midShiftR;
    mmidShiftG = midShiftG;
    mmidShiftB = midShiftB;
    mhighlightShiftR = highlightShiftR;
    mhighlightShiftG = highlightShiftG;
    mhighlightShiftB = highlightShiftB;
    
//    setInteger(mshadowShiftRLocation,mshadowShiftR);
//    setInteger(mshadowShiftGLocation,mshadowShiftG);
//    setInteger(mshadowShiftBLocation,mshadowShiftB);
//    
//    setInteger(mmidShiftRLocation,mmidShiftR);
//    setInteger(mmidShiftGLocation,mmidShiftG);
//    setInteger(mmidShiftBLocation,mmidShiftB);
//    
//    setInteger(mhighlightShiftRLocation,mhighlightShiftR);
//    setInteger(mhighlightShiftGLocation,mhighlightShiftG);
//    setInteger(mhighlightShiftBLocation,mhighlightShiftB);
    
    [self setFloat:shadowShiftR forUniform:mshadowShiftRUniform program:filterProgram];
    [self setFloat:shadowShiftG forUniform:mshadowShiftGUniform program:filterProgram];
    [self setFloat:shadowShiftB forUniform:mshadowShiftBUniform program:filterProgram];
    
    [self setFloat:midShiftR forUniform:mmidShiftRUniform program:filterProgram];
    [self setFloat:midShiftG forUniform:mmidShiftGUniform program:filterProgram];
    [self setFloat:midShiftB forUniform:mmidShiftBUniform program:filterProgram];
    
    [self setFloat:highlightShiftR forUniform:mhighlightShiftRUniform program:filterProgram];
    [self setFloat:highlightShiftG forUniform:mhighlightShiftGUniform program:filterProgram];
    [self setFloat:highlightShiftB forUniform:mhighlightShiftBUniform program:filterProgram];
    return 1;
}

//public void onInit() {
//    super.onInit();
//    //GLES20.glUseProgram(getProgram());
//    mshadowShiftRLocation = GLES20.glGetUniformLocation(getProgram(), "shadowShiftR");
//    mshadowShiftGLocation = GLES20.glGetUniformLocation(getProgram(), "shadowShiftG");
//    mshadowShiftBLocation = GLES20.glGetUniformLocation(getProgram(), "shadowShiftB");
//    
//    mmidShiftRLocation = GLES20.glGetUniformLocation(getProgram(), "midShiftR");
//    mmidShiftGLocation = GLES20.glGetUniformLocation(getProgram(), "midShiftG");
//    mmidShiftBLocation = GLES20.glGetUniformLocation(getProgram(), "midShiftB");
//    
//    mhighlightShiftRLocation = GLES20.glGetUniformLocation(getProgram(), "highlightShiftR");
//    mhighlightShiftGLocation = GLES20.glGetUniformLocation(getProgram(), "highlightShiftG");
//    mhighlightShiftBLocation = GLES20.glGetUniformLocation(getProgram(), "highlightShiftB");
//    
//}
- (id)initShadowShiftR:(NSInteger) shadowShiftR shadowShiftG:(NSInteger) shadowShiftG  shadowShiftB: (NSInteger) shadowShiftB midShiftR: (NSInteger) midShiftR midShiftG:(NSInteger) midShiftG midShiftB:(NSInteger) midShiftB highlightShiftR:(NSInteger) highlightShiftR highlightShiftG:(NSInteger) highlightShiftG highlightShiftB:(NSInteger) highlightShiftB;
{
    if (!(self = [super initWithFragmentShaderFromString:kRCGPUImageColorBalanceKeepBrightnessFragmentShaderString]))
    {
        return nil;
    }
    


    
    mshadowShiftR = 0;
    mshadowShiftG = 0;
    mshadowShiftB = 0;
    mmidShiftR = 0;
    mmidShiftG = 0;
    mmidShiftB = 0;
    mhighlightShiftR = 0;
    mhighlightShiftG = 0;
    mhighlightShiftB = 0;
    
    mshadowShiftRUniform = [filterProgram uniformIndex:@"shadowShiftR"];
    mshadowShiftGUniform = [filterProgram uniformIndex:@"shadowShiftG"];
    mshadowShiftBUniform = [filterProgram uniformIndex:@"shadowShiftB"];
    
    mmidShiftRUniform = [filterProgram uniformIndex:@"midShiftR"];
    mmidShiftGUniform = [filterProgram uniformIndex:@"midShiftG"];
    mmidShiftBUniform = [filterProgram uniformIndex:@"midShiftB"];
    
    mhighlightShiftRUniform = [filterProgram uniformIndex:@"highlightShiftR"];
    mhighlightShiftGUniform = [filterProgram uniformIndex:@"highlightShiftG"];
    mhighlightShiftBUniform = [filterProgram uniformIndex:@"highlightShiftB"];
    
    
[self setColorBalanceParamshadowShiftR:shadowShiftR shadowShiftG: shadowShiftG  shadowShiftB:  shadowShiftB
midShiftR: midShiftR midShiftG: midShiftG midShiftB: midShiftB highlightShiftR: highlightShiftR
highlightShiftG: highlightShiftG highlightShiftB: highlightShiftB];
    
    
    return self;
}


@end
