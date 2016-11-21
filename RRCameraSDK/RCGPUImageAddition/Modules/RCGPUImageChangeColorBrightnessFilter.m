//
//  RCGPUImageChangeColorBrightnessFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/6/29.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageChangeColorBrightnessFilter.h"

//全图调亮度
NSString *const kRCGPUImageAllImgBrightnessFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform float brightness;
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     mediump vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     gl_FragColor = vec4(textureColor.rgb+(vec3(1.0)-textureColor.rgb)*brightness, textureColor.a);
 }
 );

NSString *const kRCGPUImageChangeColorBrightnessFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;

 uniform lowp float allImgBrightness;
 uniform lowp float redBrightness;
 uniform lowp float greenBrightness;
 uniform lowp float blueBrightness;
 
 uniform lowp float cyanBrightness;
 uniform lowp float magentaBrightness;
 uniform lowp float yellowBrightness;

 void main()
 {
     lowp vec4 textureColorsrc = texture2D(inputImageTexture, textureCoordinate);
     lowp float r = textureColorsrc.r;
     lowp float g = textureColorsrc.g;
     lowp float b = textureColorsrc.b;
     
     lowp float maxValue = max(r, max(g, b));
     lowp float minValue = min(r, min(g, b));
     
     //convert to hue
     lowp float hue = 0.0;
     if (maxValue == minValue)
     {
         hue = 0.0;
     }
     else if (maxValue == r && g >= b)
     {
         hue = 60.0 * (g - b) / (maxValue - minValue);
     }
     else if (maxValue == r && g < b)
     {
         hue = 60.0 * (g - b) / (maxValue - minValue) + 360.0;
     }
     else if (maxValue == g)
     {
         hue = 60.0 * (b - r) / (maxValue - minValue) + 120.0;
     }
     else if (maxValue == b)
     {
         hue = 60.0 * (r - g) / (maxValue - minValue) + 240.0;
     }
     
     highp vec4 textureColor;
     textureColor=textureColorsrc;
     highp vec3 textureColorTmp;
     textureColorTmp=textureColor.rgb;
     highp vec3 textureColorTmp2;
     textureColorTmp2=textureColor.rgb;
     
     highp float Bili;
     highp float BiliRes;
     if ((hue > 345.0 && hue <= 360.0) || (hue >= 0.0 && hue <= 15.0))
     {
         if(redBrightness>0.0)
         {
            textureColor.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*redBrightness;
         }
         else if(redBrightness<0.0)
         {
            textureColor.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*redBrightness;
         }

     }
     else if (hue > 15.0 && hue <= 45.0)
     {
         Bili=1.0-(hue-15.0)/30.0;
         
         BiliRes=redBrightness*Bili+yellowBrightness*(1.0-Bili);
         if(Bili>(1.0-Bili))
         {
             if(BiliRes>0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*(BiliRes);
             }
             else if(BiliRes<0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*(BiliRes);
             }
         }
         else
         {
             if(BiliRes>0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*(BiliRes);
             }
             else if(BiliRes<0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*(BiliRes);
             }
         }
         
        
         textureColor.rgb=textureColorTmp.rgb;
     }
     else if (hue > 45.0 && hue <= 75.0)
     {
         if(yellowBrightness>0.0)
         {
             textureColor.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*yellowBrightness;
         }
         else if(yellowBrightness<0.0)
         {
             textureColor.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*yellowBrightness;
         }
     }
     else if (hue > 75.0 && hue <= 105.0)
     {
         Bili=1.0-(hue-75.0)/30.0;
         BiliRes=yellowBrightness*Bili+greenBrightness*(1.0-Bili);
         if(Bili>(1.0-Bili))
         {
             if(BiliRes>0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*(BiliRes);
             }
             else if(BiliRes<0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*(BiliRes);
             }
         }
         else
         {
             if(BiliRes>0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*(BiliRes);
             }
             else if(BiliRes<0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*(BiliRes);
             }
         }
         
         textureColor.rgb=textureColorTmp.rgb;
     }
     else if (hue > 105.0 && hue <= 135.0)
     {
         if(greenBrightness>0.0)
         {
             textureColor.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*greenBrightness;
         }
         else if(greenBrightness<0.0)
         {
             textureColor.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*greenBrightness;
         }
     }
     else if (hue > 135.0 && hue <= 165.0)
     {
         
         Bili=1.0-(hue-135.0)/30.0;
         BiliRes=greenBrightness*Bili+cyanBrightness*(1.0-Bili);
         if(Bili>(1.0-Bili))
         {
             if(BiliRes>0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*BiliRes;
             }
             else if(BiliRes<0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*BiliRes;
             }
         }
        else
        {
            if(BiliRes>0.0)
            {
                textureColorTmp.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*BiliRes;
            }
            else if(BiliRes<0.0)
            {
                textureColorTmp.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*BiliRes;
            }
        }
         

         textureColor.rgb=textureColorTmp.rgb;
     }
     else if((hue > 165.0 && hue <= 195.0))
     {
         if(cyanBrightness>0.0)
         {
             textureColor.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*cyanBrightness;
         }
         else if(cyanBrightness<0.0)
         {
             textureColor.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*cyanBrightness;
         }
     }
     else if (hue > 195.0 && hue <= 225.0)
     {
         Bili=1.0-(hue-195.0)/30.0;
         BiliRes=cyanBrightness*Bili+blueBrightness*(1.0-Bili);
         if(Bili>(1.0-Bili))
         {
             if (BiliRes>0.0)
             {
                 textureColorTmp.rgb = textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*(BiliRes);
             }
             else if(BiliRes<0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*(BiliRes);
             }
         }
         else
         {
             if(BiliRes>0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*(BiliRes);
             }
             else if(BiliRes<0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*(BiliRes);
             }
         }

         textureColor.rgb=textureColorTmp.rgb;
     }
     else if (hue > 225.0 && hue <= 255.0)
     {
         if(blueBrightness>0.0)
         {
             textureColor.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*blueBrightness;
         }
         else if(blueBrightness<0.0)
         {
             textureColor.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*blueBrightness;
         }
     }
     else if (hue > 255.0 && hue <= 285.0)
     {
         Bili=1.0-(hue-255.0)/30.0;
         BiliRes=blueBrightness*Bili+magentaBrightness*(1.0-Bili);
         if(Bili>(1.0-Bili))
         {
             if(BiliRes>0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*(BiliRes);
             }
             else if(BiliRes<0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*(BiliRes);
             }
         }
         else
         {
             if(BiliRes>0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*(BiliRes);
             }
             else if(BiliRes<0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*(BiliRes);
             }
         }
         
         textureColor.rgb=textureColorTmp.rgb;
     }
     else if (hue > 285.0 && hue <= 315.0)
     {
         if(magentaBrightness>0.0)
         {
             textureColor.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*magentaBrightness;
         }
         else if(magentaBrightness<0.0)
         {
             textureColor.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*magentaBrightness;
         }
     }
     else if (hue > 315.0 && hue <= 345.0)
     {
         Bili=1.0-(hue-315.0)/30.0;
         BiliRes=magentaBrightness*Bili+redBrightness*(1.0-Bili);
         if(Bili>(1.0-Bili))
         {
             if(BiliRes>0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*(BiliRes);
             }
             else if(BiliRes<0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*(BiliRes);
             }
         }
         else
         {
             if(BiliRes>0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(vec3(maxValue)-textureColor.rgb)*(BiliRes);
             }
             else if(BiliRes<0.0)
             {
                 textureColorTmp.rgb=textureColor.rgb+(textureColor.rgb-vec3(minValue))*(BiliRes);
             }
         }
         
         textureColor.rgb=textureColorTmp.rgb;
     }
     if (allImgBrightness!=0.0)
     {
         textureColor.rgb = vec3(textureColor.rgb+(vec3(1.0)-textureColor.rgb)*allImgBrightness);
     }
     
     gl_FragColor = vec4(clamp( textureColor.rgb,vec3(0.0),vec3(1.0)),1.0);
 }
 );

@implementation RCGPUImageChangeColorBrightnessFilter

@synthesize allImgBrightness = _allImgBrightness;
@synthesize redBrightness = _redBrightness;
@synthesize greenBrightness = _greenBrightness;
@synthesize blueBrightness = _blueBrightness;
@synthesize cyanBrightness = _cyanBrightness;
@synthesize magentaBrightness = _magentaBrightness;
@synthesize yellowBrightness = _yellowBrightness;

- (id)initAllImgBrightness:(NSInteger)allImgBrightness RedBrightness:(NSInteger)redBrightness GreenBrightness:(NSInteger)greenBrightness BlueBrightness:(NSInteger)blueBrightness CyanBrightness:(NSInteger)cyanBrightness MagentaBrightness:(NSInteger)magentaBrightness YellowBrightness:(NSInteger)yellowBrightness;
{
    if (!(self = [super initWithFragmentShaderFromString:kRCGPUImageChangeColorBrightnessFragmentShaderString]))
    {
        return nil;
    }
    allImgBrightnessUniform = [filterProgram uniformIndex:@"allImgBrightness"];
    redBrightnessUniform = [filterProgram uniformIndex:@"redBrightness"];
    greenBrightnessUniform = [filterProgram uniformIndex:@"greenBrightness"];
    blueBrightnessUniform = [filterProgram uniformIndex:@"blueBrightness"];
    
    magentaBrightnessUniform = [filterProgram uniformIndex:@"magentaBrightness"];
    cyanBrightnessUniform = [filterProgram uniformIndex:@"cyanBrightness"];
    yellowBrightnessUniform = [filterProgram uniformIndex:@"yellowBrightness"];
    
    self.allImgBrightness = (allImgBrightness) / 100.0;
    self.redBrightness = (redBrightness) / 100.0;
    self.greenBrightness = (greenBrightness) / 100.0;
    self.blueBrightness = (blueBrightness)/100.0;
    
    self.magentaBrightness = (magentaBrightness)/100.0;
    self.cyanBrightness = (cyanBrightness)/100.0;
    self.yellowBrightness = (yellowBrightness)/100.0;
    
    return self;
}

- (void)setAllImgBrightness:(CGFloat)newValue;
{
    _allImgBrightness = newValue;
    [self setFloat:_allImgBrightness forUniform:allImgBrightnessUniform program:filterProgram];
}

- (void)setRedBrightness:(CGFloat)newValue;
{
    _redBrightness = newValue;
    [self setFloat:_redBrightness forUniform:redBrightnessUniform program:filterProgram];
}

- (void)setGreenBrightness:(CGFloat)newValue;
{
    _greenBrightness = newValue;
    [self setFloat:_greenBrightness forUniform:greenBrightnessUniform program:filterProgram];
}

- (void)setBlueBrightness:(CGFloat)newValue;
{
    _blueBrightness = newValue;
    [self setFloat:_blueBrightness forUniform:blueBrightnessUniform program:filterProgram];
}

- (void)setCyanBrightness:(CGFloat)newValue;
{
    _cyanBrightness = newValue;
    [self setFloat:_cyanBrightness forUniform:cyanBrightnessUniform program:filterProgram];
}

- (void)setMagentaBrightness:(CGFloat)newValue;
{
    _magentaBrightness = newValue;
    [self setFloat:_magentaBrightness forUniform:magentaBrightnessUniform program:filterProgram];
}

- (void)setYellowBrightness:(CGFloat)newValue;
{
    _yellowBrightness = newValue;
    [self setFloat:_yellowBrightness forUniform:yellowBrightnessUniform program:filterProgram];
}
@end
