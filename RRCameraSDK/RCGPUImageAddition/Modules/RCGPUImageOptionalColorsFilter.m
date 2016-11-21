//
//  RCGPUImageOptionalColorsFilter.m
//  RRCameraSDK
//
//  Created by 孙昊 on 15-1-20.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageOptionalColorsFilter.h"

NSString *const kGPUImageOptionalColorsString = SHADER_STRING
(
#define INFMIN 0.003
#define INFMAX 0.997
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform lowp int color;
 uniform lowp int type;
 uniform lowp float fC;
 uniform lowp float fM;
 uniform lowp float fY;
 uniform lowp float fB;
 void main()
 {
     lowp vec4 srcImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 resrgb = srcImageColor;
     lowp float r=srcImageColor.r;
     lowp float g=srcImageColor.g;
     lowp float b=srcImageColor.b;
     lowp int btmp=0;
     lowp float lim;
     
      lowp float C;
      lowp float M;
      lowp float Y;
      lowp float B;
     C=fC;
     M=fM;
     Y=fY;
     B=fB;
     
     lowp float maxValue = max(r, max(g, b));
     lowp float minValue = min(r, min(g, b));
     lowp float midValue = r+g+b-maxValue-minValue;
     
     if (color==1)//red
     {
         if(abs(r-maxValue)<INFMIN)
         {
             lim=maxValue-midValue;
             btmp=1;
         }
     }
     else if (2==color)//yellow
     {
         if(abs(b-minValue)<INFMIN)
         {
             lim=midValue-minValue;
             btmp=1;
         }
     }
     else if (3==color)//green
     {
         if(abs(g-maxValue)<INFMIN)
         {
             lim=maxValue-midValue;
             btmp=1;
         }
     }
     else if (4==color)//cyan
     {
         if(abs(r-minValue)<INFMIN)
         {
             lim=midValue-minValue;
             btmp=1;
         }
     }
     else if (5==color)//blue
     {
         if(abs(b-maxValue)<INFMIN)
         {
             lim=maxValue-midValue;
             btmp=1;
         }
     }
     else if (6==color)//magenta
     {
         if(abs(g-minValue)<INFMIN)
         {
             lim=midValue-minValue;
             btmp=1;
         }
     }
     else if (color == 7)
     {
         if (r > 0.5 && g >0.5 && b > 0.5)
         {
             lim = (min(r,min(g,b))-0.5)*2.0;
             btmp=1;
         }
     }
     else if (color == 8)
     {
         if (!((r < INFMIN && g < INFMIN && b < INFMIN) || (r > INFMAX && g > INFMAX && b > INFMAX)))
         {
             lim = 1.0 - (abs(max(r ,max(g, b))- 0.5) + abs(min(r,min(g,b))-0.5));
             btmp=1;
         }
     }
     else if (color == 9)
     {
         if (r < 0.5 && g < 0.5 && b < 0.5)
         {
             lim = (0.5-max(r, max(g, b)))*2.0;
             btmp=1;
         }
     }
     
     if (lim < INFMIN && lim > -INFMIN)
     {
         btmp=0;
     }
     
     if (btmp == 0)
     {
     }
     else
     {
         
     lowp float r_dec = lim * r;
     lowp float r_inc = lim * (1.0 - r);
     lowp float g_dec = lim * g;
     lowp float g_inc = lim * (1.0 - g);
     lowp float b_dec = lim * b;
     lowp float b_inc = lim * (1.0 - b);
     
     if (B > INFMIN || B < -INFMIN)
     {
         C += B;
         M += B;
         Y += B;
     }
     
     if (type == 1)
     {
         r = clamp(r - lim * C, r - r_dec, r + r_inc);

         g = clamp(g - lim * M, g - g_dec, g + g_inc);

         b = clamp(b - lim * Y, b - b_dec, b + b_inc);
//         if (B > INFMIN || B < -INFMIN)
//         {
//             C = B;
//             M = B;
//             Y = B;
//             
//             r = clamp(r - lim * C, r - r_dec, r + r_inc);
//             
//             g = clamp(g - lim * M, g - g_dec, g + g_inc);
//             
//             b = clamp(b - lim * Y, b - b_dec, b + b_inc);
//         }
     }
     else
     {
         if (r > 0.5)
         {
             r = r - r_inc * C;
         }
         else
         {
             r = r - min(r_inc * C, r_dec);
         }
         if (g > 0.5)
         {
             g = g - g_inc * M;
         }
         else
         {
             g = g - min(g_inc * M, g_dec);
         }
         if (b > 0.5)
         {
             b = b - b_inc * Y;
         }
         else
         {
             b = b - min(b_inc * Y, b_dec);
         }
         
//         if (B > INFMIN || B < -INFMIN)
//         {
//             C = B;
//             M = B;
//             Y = B;
//             
//             if (r > 0.5)
//             {
//                 r = r - r_inc * C;
//             }
//             else
//             {
//                 r = r - min(r_inc * C, r_dec);
//             }
//             if (g > 0.5)
//             {
//                 g = g - g_inc * M;
//             }
//             else
//             {
//                 g = g - min(g_inc * M, g_dec);
//             }
//             if (b > 0.5)
//             {
//                 b = b - b_inc * Y;
//             }
//             else
//             {
//                 b = b - min(b_inc * Y, b_dec);
//             }
//         }
     }
     }
     
     resrgb.r=r;
     resrgb.g=g;
     resrgb.b=b;
     gl_FragColor = resrgb;
 
   }
);

@implementation RCGPUImageOptionalColorsFilter
@synthesize iColor = _iColor;
@synthesize iType = _iType;
@synthesize fC = _fC;
@synthesize fM = _fM;
@synthesize fY = _fY;
@synthesize fB = _fB;

- (NSString *)color:(NSUInteger)color type:(NSUInteger)type C:(NSUInteger)iC M:(NSUInteger)iM Y:(NSUInteger)iY B:(NSUInteger)iB;
{
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    [shaderString appendFormat:@"\n\
     #define INFMIN 0.003\n\
     #define INFMAX 0.997\n\
     varying highp vec2 textureCoordinate;\n\
     uniform sampler2D inputImageTexture;\n\
     uniform lowp int color;\n\
     uniform lowp int type;\n\
     uniform lowp float fC;\n\
     uniform lowp float fM;\n\
     uniform lowp float fY;\n\
     uniform lowp float fB;\n\
     void main()\n\
     {\n\
         lowp vec4 srcImageColor = texture2D(inputImageTexture, textureCoordinate);\n\
         lowp vec4 resrgb = srcImageColor;\n\
         lowp float r=srcImageColor.r;\n\
         lowp float g=srcImageColor.g;\n\
         lowp float b=srcImageColor.b;\n\
         lowp int btmp=0;\n\
         lowp float lim;\n\
         lowp float C;\n\
         lowp float M;\n\
         lowp float Y;\n\
         lowp float B;\n\
         C=fC;\n\
         M=fM;\n\
         Y=fY;\n\
         B=fB;\n\
         lowp float maxValue = max(r, max(g, b));\n\
         lowp float minValue = min(r, min(g, b));\n\
         lowp float midValue = r+g+b-maxValue-minValue;\n"
     ];
    if (color==1)
    {
        [shaderString appendFormat:@"\n\
         if(abs(r-maxValue)<INFMIN)\n\
         {\n\
             lim=maxValue-midValue;\n\
             btmp=1;\n\
         }\n"
         ];
    }
    
    if (color==2)
    {
        [shaderString appendFormat:@"\n\
         if(abs(b-minValue)<INFMIN)\n\
         {\n\
             lim=midValue-minValue;\n\
             btmp=1;\n\
         }\n"
         ];
    }
    
    if (color==3)
    {
        [shaderString appendFormat:@"\n\
         if(abs(g-maxValue)<INFMIN)\n\
         {\n\
             lim=maxValue-midValue;\n\
             btmp=1;\n\
         }\n"
         ];
    }
    
    if (color==4)
    {
        [shaderString appendFormat:@"\n\
         if(abs(r-minValue)<INFMIN)\n\
         {\n\
             lim=midValue-minValue;\n\
             btmp=1;\n\
         }\n"
         ];
    }
    
    if (color==5)
    {
        [shaderString appendFormat:@"\n\
         if(abs(b-maxValue)<INFMIN)\n\
         {\n\
             lim=maxValue-midValue;\n\
             btmp=1;\n\
         }\n"
         ];
    }
    
    if (color==6)
    {
        [shaderString appendFormat:@"\n\
         if(abs(g-minValue)<INFMIN)\n\
         {\n\
             lim=midValue-minValue;\n\
             btmp=1;\n\
         }\n"
         ];
    }
    
    if (color==7)
    {
        [shaderString appendFormat:@"\n\
        if (r > 0.5 && g >0.5 && b > 0.5)\n\
        {\n\
            lim = (min(r,min(g,b))-0.5)*2.0;\n\
            btmp=1;\n\
        }\n"
        ];
    }
    
    if (color==8)
    {
        [shaderString appendFormat:@"\n\
         if (!((r < INFMIN && g < INFMIN && b < INFMIN) || (r > INFMAX && g > INFMAX && b > INFMAX)))\n\
         {\n\
             lim = 1.0 - (abs(max(r ,max(g, b))- 0.5) + abs(min(r,min(g,b))-0.5));\n\
             btmp=1;\n\
         }\n"
         ];
    }
    
    if (color==9)
    {
        [shaderString appendFormat:@"\n\
        if (r < 0.5 && g < 0.5 && b < 0.5)\n\
        {\n\
            lim = (0.5-max(r, max(g, b)))*2.0;\n\
            btmp=1;\n\
        }\n"
        ];
    }
    [shaderString appendFormat:@"\n\
    if (lim < INFMIN && lim > -INFMIN)\n\
    {\n\
        btmp=0;\n\
    }\n"
    ];
    
    [shaderString appendFormat:@"\n\
    if (btmp == 1)\n\
    {\n\
        lowp float r_dec = lim * r;\n\
        lowp float r_inc = lim * (1.0 - r);\n\
        lowp float g_dec = lim * g;\n\
        lowp float g_inc = lim * (1.0 - g);\n\
        lowp float b_dec = lim * b;\n\
        lowp float b_inc = lim * (1.0 - b);\n"
     ];
    
    if (iB!=0) {
        [shaderString appendFormat:@"\n\
         C += B;\n\
         M += B;\n\
         Y += B;\n"
         ];
    }

    
    if (type==1)
    {
        if (iC!=0)
        {
            [shaderString appendFormat:@"\n\
             r = clamp(r - lim * C, r - r_dec, r + r_inc);\n"
             ];
        }
        if (iM!=0)
        {
            [shaderString appendFormat:@"\n\
             g = clamp(g - lim * M, g - g_dec, g + g_inc);\n"
             ];
        }
        if (iY!=0)
        {
            [shaderString appendFormat:@"\n\
             b = clamp(b - lim * Y, b - b_dec, b + b_inc);\n"
             ];
        }
        
//        if (iB!=0)
//        {
//            [shaderString appendFormat:@"\n\
//             C = B;\n\
//             M = B;\n\
//             Y = B;\n"
//             ];
//            [shaderString appendFormat:@"\n\
//             r = clamp(r - lim * C, r - r_dec, r + r_inc);\n"
//             ];
//            [shaderString appendFormat:@"\n\
//             g = clamp(g - lim * M, g - g_dec, g + g_inc);\n"
//             ];
//            [shaderString appendFormat:@"\n\
//             b = clamp(b - lim * Y, b - b_dec, b + b_inc);\n"
//             ];
//        }
    }
    else
    {
        if (iC!=0)
        {
            [shaderString appendFormat:@"\n\
            if (r > 0.5)\n\
            {\n\
                r = r - r_inc * C;\n\
            }\n\
            else\n\
            {\n\
                r = r - min(r_inc * C, r_dec);\n\
            }\n"
            ];
        }
        if (iM!=0)
        {
            [shaderString appendFormat:@"\n\
             if (g > 0.5)\n\
             {\n\
             g = g - g_inc * M;\n\
             }\n\
             else\n\
             {\n\
             g = g - min(g_inc * M, g_dec);\n\
             }\n"
             ];
        }
        if (iY!=0)
        {
            [shaderString appendFormat:@"\n\
             if (b > 0.5)\n\
             {\n\
             b = b - b_inc * Y;\n\
             }\n\
             else\n\
             {\n\
             b = b - min(b_inc * Y, b_dec);\n\
             }\n"
            ];
        }
        
//        if (iB!=0)
//        {
//            [shaderString appendFormat:@"\n\
//             C = B;\n\
//             M = B;\n\
//             Y = B;\n"
//             ];
//            
//            [shaderString appendFormat:@"\n\
//             if (r > 0.5)\n\
//             {\n\
//             r = r - r_inc * C;\n\
//             }\n\
//             else\n\
//             {\n\
//             r = r - min(r_inc * C, r_dec);\n\
//             }\n"
//             ];
//            
//            [shaderString appendFormat:@"\n\
//             if (g > 0.5)\n\
//             {\n\
//             g = g - g_inc * M;\n\
//             }\n\
//             else\n\
//             {\n\
//             g = g - min(g_inc * M, g_dec);\n\
//             }\n"
//             ];
//            
//            [shaderString appendFormat:@"\n\
//             if (b > 0.5)\n\
//             {\n\
//             b = b - b_inc * Y;\n\
//             }\n\
//             else\n\
//             {\n\
//             b = b - min(b_inc * Y, b_dec);\n\
//             }\n"
//             ];
//        }
    }
    [shaderString appendFormat:@"\n\
     }\n\
     resrgb.r=r;\n\
     resrgb.g=g;\n\
     resrgb.b=b;\n\
     gl_FragColor = resrgb;\n\
     }\n"
    ];
    
    return shaderString;
}


- (id)initColor:(GLint)color initType:(GLint)type initC:(NSInteger)iC initM:(NSInteger)iM initY:(NSInteger)iY initB:(NSInteger)iB;
{
    if (!(self = [super initWithFragmentShaderFromString:[self color:color type:type C:iC M:iM Y:iY B:iB]]))
    {
        return nil;
    }

//    if (!(self = [super initWithFragmentShaderFromString:kGPUImageOptionalColorsString]))
//    {
//        return nil;
//    }
    colorUniform = [filterProgram uniformIndex:@"color"];
    typeUniform = [filterProgram uniformIndex:@"type"];
    fCUniform = [filterProgram uniformIndex:@"fC"];
    fMUniform = [filterProgram uniformIndex:@"fM"];
    fYUniform = [filterProgram uniformIndex:@"fY"];
    fBUniform = [filterProgram uniformIndex:@"fB"];
    
    
    CGFloat C=iC/100.0;
    CGFloat M=iM/100.0;
    CGFloat Y=iY/100.0;
    CGFloat B=iB/100.0;
    self.iColor=color;
    self.iType=type;
    self.fC=C;
    self.fM=M;
    self.fY=Y;
    self.fB=B;
    return self;
}

- (void)setIColor:(GLint)newValue;
{
    _iColor = newValue;
    
    [self setInteger:_iColor forUniform:colorUniform program:filterProgram];
}

- (void)setIType:(GLint)newValue;
{
    _iType = newValue;
    
    [self setInteger:_iType forUniform:typeUniform program:filterProgram];
}

- (void)setFC:(CGFloat)newValue;
{
    _fC = newValue;
    
    [self setFloat:_fC forUniform:fCUniform program:filterProgram];
}

- (void)setFM:(CGFloat)newValue;
{
    _fM = newValue;
    
    [self setFloat:_fM forUniform:fMUniform program:filterProgram];
}

- (void)setFY:(CGFloat)newValue;
{
    _fY = newValue;
    
    [self setFloat:_fY forUniform:fYUniform program:filterProgram];
}

- (void)setFB:(CGFloat)newValue;
{
    _fB = newValue;
    
    [self setFloat:_fB forUniform:fBUniform program:filterProgram];
}
@end
