//
//  RCGPUImageChangeColorHFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/6/29.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageChangeColorHFilter.h"

NSString *const kRCGPUImageChangeColorHFragmentShaderString = SHADER_STRING
(
  precision highp float;
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform float allImgH;
 uniform float redH;
 uniform float greenH;
 uniform float blueH;
 
 uniform float cyanH;
 uniform float magentaH;
 uniform float yellowH;
 
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
 
 void main()
 {
     highp vec4 textureColorsrc = texture2D(inputImageTexture, textureCoordinate);

      vec3 hsv = rgb_to_hsv(textureColorsrc.rgb);
     vec3 rgbtmp;
     
     //convert to hue
     highp float hue;
     hue = hsv.r*360.0;
     
     highp float addH;
     addH=0.0;

     highp float Bili;
     highp float BiliRes;
     if ((hue > 345.0 && hue <= 360.0) || (hue >= 0.0 && hue <= 15.0))
     {
         addH=redH;
     }
     else if (hue > 15.0 && hue <= 45.0)
     {
         Bili=1.0-(hue-15.0)/30.0;
         addH=redH*Bili+yellowH*(1.0-Bili);
     }
     else if (hue > 45.0 && hue <= 75.0)
     {
         addH=yellowH;
     }
     else if (hue > 75.0 && hue <= 105.0)
     {
         Bili=1.0-(hue-75.0)/30.0;
         addH=yellowH*Bili+greenH*(1.0-Bili);
     }
     else if (hue > 105.0 && hue <= 135.0)
     {
         addH=greenH;
     }
     else if (hue > 135.0 && hue <= 165.0)
     {
         
         Bili=1.0-(hue-135.0)/30.0;
         addH=greenH*Bili+cyanH*(1.0-Bili);
     }
     else if((hue > 165.0 && hue <= 195.0))
     {
         addH=cyanH;
     }
     else if (hue > 195.0 && hue <= 225.0)
     {
         Bili=1.0-(hue-195.0)/30.0;
         addH=cyanH*Bili+blueH*(1.0-Bili);
     }
     else if (hue > 225.0 && hue <= 255.0)
     {
         addH=blueH;
     }
     else if (hue > 255.0 && hue <= 285.0)
     {
         Bili=1.0-(hue-255.0)/30.0;
         addH=blueH*Bili+magentaH*(1.0-Bili);
     }
     else if (hue > 285.0 && hue <= 315.0)
     {
         addH=magentaH;
     }
     else if (hue > 315.0 && hue <= 345.0)
     {
         Bili=1.0-(hue-315.0)/30.0;
         addH=magentaH*Bili+redH*(1.0-Bili);
     }
     if (allImgH!=0.0)
     {
         addH=addH+allImgH;
     }
     
     hue=hue+addH;
     if(hue>=360.0)
     {
         hue=mod(hue,360.0);
     }
      vec3 hsvtmp;
     hsvtmp.r=hue/360.0;
     hsvtmp.g=hsv.g;
     hsvtmp.b=hsv.b;

     rgbtmp=hsv_to_rgb(hsvtmp);

     gl_FragColor = vec4(clamp(rgbtmp,0.0,1.0),1.0);
 }
 );

@implementation RCGPUImageChangeColorHFilter
@synthesize allImgH = _allImgH;
@synthesize redH = _redH;
@synthesize greenH = _greenH;
@synthesize blueH = _blueH;
@synthesize cyanH = _cyanH;
@synthesize magentaH = _magentaH;
@synthesize yellowH = _yellowH;

- (id)initAllImgH:(NSInteger)allImgH RedH:(NSInteger)redH GreenH:(NSInteger)greenH BlueH:(NSInteger)blueH CyanH:(NSInteger)cyanH MagentaH:(NSInteger)magentaH YellowH:(NSInteger)yellowH;
{
    if (!(self = [super initWithFragmentShaderFromString:kRCGPUImageChangeColorHFragmentShaderString]))
    {
        return nil;
    }
    allImgHUniform = [filterProgram uniformIndex:@"allImgH"];
    redHUniform = [filterProgram uniformIndex:@"redH"];
    greenHUniform = [filterProgram uniformIndex:@"greenH"];
    blueHUniform = [filterProgram uniformIndex:@"blueH"];
    
    magentaHUniform = [filterProgram uniformIndex:@"magentaH"];
    cyanHUniform = [filterProgram uniformIndex:@"cyanH"];
    yellowHUniform = [filterProgram uniformIndex:@"yellowH"];
    
    self.allImgH = (allImgH) *1.0;
    self.redH = (redH) *1.0;
    self.greenH = (greenH) *1.0;
    self.blueH = (blueH)*1.0;
    
    self.magentaH = (magentaH)*1.0;
    self.cyanH = (cyanH)*1.0;
    self.yellowH = (yellowH)*1.0;
    
    return self;
}

- (void)setAllImgH:(CGFloat)newValue;
{
    _allImgH = newValue;
    [self setFloat:_allImgH forUniform:allImgHUniform program:filterProgram];
}

- (void)setRedH:(CGFloat)newValue;
{
    _redH = newValue;
    [self setFloat:_redH forUniform:redHUniform program:filterProgram];
}

- (void)setGreenH:(CGFloat)newValue;
{
    _greenH = newValue;
    [self setFloat:_greenH forUniform:greenHUniform program:filterProgram];
}

- (void)setBlueH:(CGFloat)newValue;
{
    _blueH = newValue;
    [self setFloat:_blueH forUniform:blueHUniform program:filterProgram];
}

- (void)setCyanH:(CGFloat)newValue;
{
    _cyanH = newValue;
    [self setFloat:_cyanH forUniform:cyanHUniform program:filterProgram];
}

- (void)setMagentaH:(CGFloat)newValue;
{
    _magentaH = newValue;
    [self setFloat:_magentaH forUniform:magentaHUniform program:filterProgram];
}

- (void)setYellowH:(CGFloat)newValue;
{
    _yellowH = newValue;
    [self setFloat:_yellowH forUniform:yellowHUniform program:filterProgram];
}
@end
