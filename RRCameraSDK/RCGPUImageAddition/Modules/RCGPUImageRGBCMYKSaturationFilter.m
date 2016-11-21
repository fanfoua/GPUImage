//
//  RCGPUImageRGBCMYKSaturationFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14/11/28.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageRGBCMYKSaturationFilter.h"


NSString *const kGPUImageRGBSaturationFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform lowp float redSaturation;
 uniform lowp float greenSaturation;
 uniform lowp float blueSaturation;
 
 uniform lowp float cyanSaturation;
 uniform lowp float magentaSaturation;
 uniform lowp float yellowSaturation;
 
 // Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham
 const mediump vec3 luminanceWeighting = vec3(0.3333, 0.3333, 0.3333);
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     lowp float luminance = dot(textureColor.rgb, luminanceWeighting);
     
     lowp float r = textureColor.r;
     lowp float g = textureColor.g;
     lowp float b = textureColor.b;
     
     lowp float maxValue = max(r, max(g, b));
     lowp float minValue = min(r, min(g, b));
     
     //conver rgb to cmyk
     mediump float magentaOne = 1.0 - r;
     mediump float cyanOne = 1.0 - g;
     mediump float yellowOne = 1.0 - b;
     
     mediump float key = min(cyanOne, min(magentaOne, yellowOne));
     
     mediump float magentaTwo;
     mediump float cyanTwo;
     mediump float yellowTwo;
     
     if (key == 1.0) {
         magentaTwo = 0.0;
         cyanTwo = 0.0;
         yellowTwo = 0.0;
     } else {
         magentaTwo = (magentaOne - key) / (1.0 - key);
         cyanTwo = (cyanOne - key) / (1.0 - key);
         yellowTwo = (yellowOne - key) / (1.0 - key);
     }
     
     //saturation
     lowp float luminanceCMYK = dot(vec3(magentaTwo,cyanTwo, yellowTwo), luminanceWeighting);
     mediump float magentaThree = mix(luminanceCMYK, magentaTwo, magentaSaturation);
     mediump float cyanThree = mix(luminanceCMYK, cyanTwo, cyanSaturation);
     mediump float yellowThree = mix(luminanceCMYK, yellowTwo, yellowSaturation);
     
     
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
     
     
     if ((hue > 345.0 && hue <= 360.0) || (hue > 0.0 && hue <= 15.0))
     {
         r = mix(luminance, textureColor.r, redSaturation);
     }
     else if (hue > 15.0 && hue <= 45.0)
     {
         r = mix(luminance, textureColor.r, redSaturation);
         b = 1.0 - yellowThree * (1.0 - key) - key;
     }
     else if (hue > 45.0 && hue <= 75.0)
     {
         b = 1.0 - yellowThree * (1.0 - key) - key;
     }
     else if (hue > 75.0 && hue <= 105.0)
     {
         g = mix(luminance, textureColor.g, greenSaturation);
         b = 1.0 - yellowThree * (1.0 - key) - key;
     }
     else if (hue > 105.0 && hue <= 135.0)
     {
         g = mix(luminance, textureColor.g, greenSaturation);
     }
     else if (hue > 135.0 && hue <= 165.0)
     {
         g = (mix(luminance, textureColor.g, greenSaturation) + (1.0 - cyanThree* (1.0 - key) - key)) / 2.0;
     }
     else if((hue > 165.0 && hue <= 195.0))
     {
         g = 1.0 - cyanThree* (1.0 - key) - key;
     }
     else if (hue > 195.0 && hue <= 225.0)
     {
         b = mix(luminance, textureColor.b, blueSaturation);
         g = 1.0 - cyanThree * (1.0 - key) - key;
     }
     else if (hue > 225.0 && hue <= 255.0)
     {
         b = mix(luminance, textureColor.b, blueSaturation);
     }
     else if (hue > 255.0 && hue <= 285.0)
     {
         b = mix(luminance, textureColor.b, blueSaturation);
         r = 1.0 - magentaThree * (1.0 - key) - key;
     }
     else if (hue > 285.0 && hue <= 315.0)
     {
         r = 1.0 - magentaThree * (1.0 - key) - key;
     }
     else if (hue > 315.0 && hue <= 345.0)
     {
         r = ((1.0 - magentaThree * (1.0 - key) - key) + mix(luminance, textureColor.r, redSaturation)) / 2.0;
     }
     
     gl_FragColor = vec4(r, g, b, textureColor.w);
 }
 );

@implementation RCGPUImageRGBCMYKSaturationFilter

@synthesize redSaturation = _redSaturation;
@synthesize greenSaturation = _greenSaturation;
@synthesize blueSaturation = _blueSaturation;
@synthesize cyanSaturation = _cyanSaturation;
@synthesize magentaSaturation = _magentaSaturation;
@synthesize yellowSaturation = _yellowSaturation;

- (NSString *)redSaturation:(NSUInteger)redSaturation greenSaturation:(NSUInteger)greenSaturation blueSaturation:(NSUInteger)blueSaturation cyanSaturation:(NSUInteger)cyanSaturation magentaSaturation:(NSUInteger)magentaSaturation yellowSaturation:(NSUInteger)yellowSaturation;
{
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    [shaderString appendFormat:@"\
     #define INFMAX 1.004\n\
     #define INFMIN 0.996\n\
     #define INF_MIN 0.004\n\
     varying highp vec2 textureCoordinate;\n\
     uniform sampler2D inputImageTexture;\n\
     uniform lowp float redSaturation;\n\
     uniform lowp float greenSaturation;\n\
     uniform lowp float blueSaturation;\n\
     uniform lowp float cyanSaturation;\n\
     uniform lowp float magentaSaturation;\n\
     uniform lowp float yellowSaturation;\n\
     uniform lowp int nColor;\n\
     const mediump vec3 luminanceWeighting = vec3(0.3333, 0.3333, 0.3333);\n\
     void main()\n\
     {\n\
     mediump vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);\n\
     mediump float luminance = dot(textureColor.rgb, luminanceWeighting);\n\
     mediump float r = textureColor.r;\n\
     mediump float g = textureColor.g;\n\
     mediump float b = textureColor.b;\n\
     mediump float maxValue = max(r, max(g, b));\n\
     mediump float minValue = min(r, min(g, b));\n\
     mediump float magentaOne = 1.0 - r;\n\
     mediump float cyanOne = 1.0 - g;\n\
     mediump float yellowOne = 1.0 - b;\n\
     mediump float key = min(cyanOne, min(magentaOne, yellowOne));\n\
     mediump float magentaTwo;\n\
     mediump float cyanTwo;\n\
     mediump float yellowTwo;\n\
     if (key == 1.0) {\n\
     magentaTwo = 0.0;\n\
     cyanTwo = 0.0;\n\
     yellowTwo = 0.0;\n\
     } else {\n\
     magentaTwo = (magentaOne - key) / (1.0 - key);\n\
     cyanTwo = (cyanOne - key) / (1.0 - key);\n\
     yellowTwo = (yellowOne - key) / (1.0 - key);\n\
     }\n\
     mediump float luminanceCMYK = dot(vec3(magentaTwo,cyanTwo, yellowTwo), luminanceWeighting);\n\
     mediump float fr=r;\n\
     mediump float fg=g;\n\
     mediump float fb=b;\n"
     ];
    if (redSaturation!=0)
    {
        [shaderString appendFormat:@"\n\
         if (abs(r-maxValue)<INF_MIN)\n\
         {\n\
         r += mix(luminance, textureColor.r, redSaturation)-fr;\n\
         }\n"
         ];
    }
    
    if (yellowSaturation!=0)
    {
        [shaderString appendFormat:@"\n\
         if (abs(b-minValue)<INF_MIN)\n\
         {\n\
         mediump float yellowThree = mix(luminanceCMYK, yellowTwo, yellowSaturation);\n\
         b += 1.0 - yellowThree * (1.0 - key) - key-fb;\n\
         }\n"
         ];
    }
    
    if (greenSaturation!=0)
    {
        [shaderString appendFormat:@"\n\
         if (abs(g-maxValue)<INF_MIN)\n\
         {\n\
         g += mix(luminance, textureColor.g, greenSaturation) - fg;\n\
         }\n"
         ];
    }
    
    if (cyanSaturation!=0)
    {
        [shaderString appendFormat:@"\n\
         if (abs(r-minValue)<INF_MIN)\n\
         {\n\
         mediump float cyanThree = mix(luminanceCMYK, cyanTwo, cyanSaturation);\n\
         g += 1.0 - cyanThree* (1.0 - key) - key-fg;\n\
         }\n"
         ];
    }
    
    if (blueSaturation!=0)
    {
        [shaderString appendFormat:@"\n\
         if (abs(b-maxValue)<INF_MIN)\n\
         {\n\
         b += mix(luminance, textureColor.b, blueSaturation) - fb;\n\
         }\n"
         ];
    }
    
    if (magentaSaturation!=0)
    {
        [shaderString appendFormat:@"\n\
         if (abs(g-minValue)<INF_MIN)\n\
         {\n\
         mediump float magentaThree = mix(luminanceCMYK, magentaTwo, magentaSaturation);\n\
         r += 1.0 - magentaThree * (1.0 - key) - key - fr;\n\
         }\n"
         ];
    }
    
    [shaderString appendFormat:@"\n\
     r = clamp(r,0.0,1.0);\n\
     g = clamp(g,0.0,1.0);\n\
     b = clamp(b,0.0,1.0);\n\
     \n"];
    
    [shaderString appendFormat:@"\n\
     gl_FragColor = vec4(r, g, b, textureColor.w);\n\
     }\n"];
    
    return shaderString;
}

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageRGBSaturationFragmentShaderString]))
    {
        return nil;
    }
    
    redSaturationUniform = [filterProgram uniformIndex:@"redSaturation"];
    greenSaturationUniform = [filterProgram uniformIndex:@"greenSaturation"];
    blueSaturationUniform = [filterProgram uniformIndex:@"blueSaturation"];
    
    magentaSaturationUniform = [filterProgram uniformIndex:@"magentaSaturation"];
    cyanSaturationUniform = [filterProgram uniformIndex:@"cyanSaturation"];
    yellowSaturationUniform = [filterProgram uniformIndex:@"yellowSaturation"];
    
    self.redSaturation = 1.0;
    self.greenSaturation = 1.0;
    self.blueSaturation = 1.0;
    
    self.magentaSaturation = 1.0;
    self.cyanSaturation = 1.0;
    self.yellowSaturation = 1.0;
    
    return self;
}

- (id)initRed:(NSInteger)red initGreen:(NSInteger)green initBlue:(NSInteger)blue initMagenta:(NSInteger)magenta initCyan:(NSInteger)cyan initYellow:(NSInteger)yellow;
{
    if (!(self = [super initWithFragmentShaderFromString:[self redSaturation:red greenSaturation:green blueSaturation:blue  cyanSaturation:cyan magentaSaturation:magenta yellowSaturation:yellow]]))
    {
        return nil;
    }
    
    redSaturationUniform = [filterProgram uniformIndex:@"redSaturation"];
    greenSaturationUniform = [filterProgram uniformIndex:@"greenSaturation"];
    blueSaturationUniform = [filterProgram uniformIndex:@"blueSaturation"];
    
    magentaSaturationUniform = [filterProgram uniformIndex:@"magentaSaturation"];
    cyanSaturationUniform = [filterProgram uniformIndex:@"cyanSaturation"];
    yellowSaturationUniform = [filterProgram uniformIndex:@"yellowSaturation"];
    
    self.redSaturation = (red+100.0) / 100.0;
    self.greenSaturation = (green+100.0) / 100.0;
    self.blueSaturation = (blue+100.0)/100.0;
    
    self.magentaSaturation = (magenta+100.0)/100.0;
    self.cyanSaturation = (cyan+100.0)/100.0;
    self.yellowSaturation = (yellow+100.0)/100.0;
    
    return self;
}

- (void)setRedSaturation:(CGFloat)newValue;
{
    _redSaturation = newValue;
    [self setFloat:_redSaturation forUniform:redSaturationUniform program:filterProgram];
}

- (void)setGreenSaturation:(CGFloat)newValue;
{
    _greenSaturation = newValue;
    [self setFloat:_greenSaturation forUniform:greenSaturationUniform program:filterProgram];
}

- (void)setBlueSaturation:(CGFloat)newValue;
{
    _blueSaturation = newValue;
    [self setFloat:_blueSaturation forUniform:blueSaturationUniform program:filterProgram];
}

- (void)setCyanSaturation:(CGFloat)newValue;
{
    _cyanSaturation = newValue;
    [self setFloat:_cyanSaturation forUniform:cyanSaturationUniform program:filterProgram];
}

- (void)setMagentaSaturation:(CGFloat)newValue;
{
    _magentaSaturation = newValue;
    [self setFloat:_magentaSaturation forUniform:magentaSaturationUniform program:filterProgram];
}

- (void)setYellowSaturation:(CGFloat)newValue;
{
    _yellowSaturation = newValue;
    [self setFloat:_yellowSaturation forUniform:yellowSaturationUniform program:filterProgram];
}


@end