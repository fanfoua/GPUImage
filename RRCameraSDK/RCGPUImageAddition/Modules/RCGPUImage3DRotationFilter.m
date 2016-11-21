//
//  RCGPUImage3DRotationFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/4/9.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImage3DRotationFilter.h"

NSString *const kRCGPUImage3DRotationFilterShaderString = SHADER_STRING
( 
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform highp float a11;
 uniform highp float a12;
 uniform highp float a13;
 uniform highp float a21;
 uniform highp float a22;
 uniform highp float a23;
 uniform highp float a31;
 uniform highp float a32;
 
 void main()
 {
     highp vec2 pCoordinate;
     
     highp float den = (a11*a22 - a12*a21 - a13*a22*(textureCoordinate.x-0.5) - a22*a23*(textureCoordinate.x-0.5) + a13*a21*(textureCoordinate.y-0.5) + a21*a23*(textureCoordinate.y-0.5));
     pCoordinate.x = (a21*a32 - a22*a31 + a22*(textureCoordinate.x-0.5) - a21*(textureCoordinate.y-0.5))/den;
     pCoordinate.y = -(a11*a32 - a12*a31 + a12*(textureCoordinate.x-0.5) - a11*(textureCoordinate.y-0.5) - a13*a32*(textureCoordinate.x-0.5) - a23*a32*(textureCoordinate.x-0.5) + a13*a31*(textureCoordinate.y-0.5) + a23*a31*(textureCoordinate.y-0.5))/den;
    
//     pCoordinate = clamp(pCoordinate+0.5,0.0,1.0);
     pCoordinate = pCoordinate + 0.5;
     lowp vec4 textureColor = texture2D(inputImageTexture, pCoordinate);
    
     gl_FragColor = textureColor;
 }
 );

@implementation RCGPUImage3DRotationFilter
@synthesize a11 = _a11;
@synthesize a12 = _a12;
@synthesize a13 = _a13;
@synthesize a21 = _a21;
@synthesize a22 = _a22;
@synthesize a23 = _a23;
@synthesize a31 = _a31;
@synthesize a32 = _a32;


struct PointCoodinate {
    GLfloat x;
    GLfloat y;
} PointCoodinate[4];
//typedef struct PointCoodinate PointCoodinate;

-(void)computePara:(int) flag theta:(float)theta
{
    
//    PointCoodinate[0].x = 0;
//    PointCoodinate[0].y = 0;
//    
//    PointCoodinate[1].x = 1.0;
//    PointCoodinate[1].y = 0;
//
//    PointCoodinate[2].x = 1.0;
//    PointCoodinate[2].y = 1.0;
//    
//    PointCoodinate[3].x = 0;
//    PointCoodinate[3].y = 1.0;
    
    if (flag == 1 && theta >= 1.0) {  //right button, left sliding, theta >= 1.0
        PointCoodinate[0].x = 0;
        PointCoodinate[0].y = 0;
        
//        PointCoodinate[1].x = 1.0;
//        PointCoodinate[1].y = 0;
        PointCoodinate[1].x = theta;
        PointCoodinate[1].y = 1.0f - theta;
        
//        PointCoodinate[2].x = 1.0;
//        PointCoodinate[2].y = 1.0;
        PointCoodinate[2].x = theta;
        PointCoodinate[2].y = theta;
        
        PointCoodinate[3].x = 0;
        PointCoodinate[3].y = 1.0;
    }
    else if (flag == 1 && theta < 1.0) {  //right button, right sliding, theta < 1.0
//        PointCoodinate[0].x = 0;
//        PointCoodinate[0].y = 0;
        PointCoodinate[0].x = theta - 1.0f;
        PointCoodinate[0].y = theta - 1.0f;
        
        PointCoodinate[1].x = 1.0f;
        PointCoodinate[1].y = 0.0f;
        
        PointCoodinate[2].x = 1.0f;
        PointCoodinate[2].y = 1.0f;
        
//        PointCoodinate[3].x = 0;
//        PointCoodinate[3].y = 1.0;
        PointCoodinate[3].x = theta - 1.0f;
        PointCoodinate[3].y = 2.0f - theta;
    }
    else if (flag == -1 && theta >= 1.0) {  // left button, left sliding, theta >= 1.0
        
        PointCoodinate[0].x = 0.0f;
        PointCoodinate[0].y = 0.0f;
        
        PointCoodinate[1].x = theta;
        PointCoodinate[1].y = 1.0f - theta;
        
        PointCoodinate[2].x = theta;
        PointCoodinate[2].y = theta;
        
        PointCoodinate[3].x = 0.0f;
        PointCoodinate[3].y = 1.0f;
        
    }
    else if (flag == -1 && theta < 1.0) {  // left button, right sliding, theta < 1.0
        PointCoodinate[0].x = theta - 1.0f;
        PointCoodinate[0].y = theta - 1.0f;
        
        PointCoodinate[1].x = 1.0f;
        PointCoodinate[1].y = 0.0f;
        
        PointCoodinate[2].x = 1.0f;
        PointCoodinate[2].y = 1.0f;
        
        PointCoodinate[3].x = theta - 1.0f;
        PointCoodinate[3].y = 2.0 - theta;
    }
    else{
        return;
    }
    
    float u0 = PointCoodinate[0].x - 0.5f;
    float u1 = PointCoodinate[1].x - 0.5f;
    float u2 = PointCoodinate[2].x - 0.5f;
    float u3 = PointCoodinate[3].x - 0.5f;
    
    float v0 = PointCoodinate[0].y - 0.5f;
    float v1 = PointCoodinate[1].y - 0.5f;
    float v2 = PointCoodinate[2].y - 0.5f;
    float v3 = PointCoodinate[3].y - 0.5f;
    
    float den =  (u0*v1 - u1*v0 - u0*v3 + u1*v2 - u2*v1 + u3*v0 + u2*v3 - u3*v2);
    
    self.a11 = (2*u0*u2*v1 - 2*u1*u2*v0 - 2*u0*u3*v1 + 2*u1*u3*v0 - 2*u0*u2*v3 + 2*u0*u3*v2 +
                2*u1*u2*v3 - 2*u1*u3*v2)/den;
    self.a21 = -(2*u0*u1*v2 - 2*u0*u2*v1 - 2*u0*u1*v3 + 2*u1*u3*v0 + 2*u0*u2*v3 - 2*u2*u3*v0 -
                 2*u1*u3*v2 + 2*u2*u3*v1)/den;
    self.a31 = (u0*u1*v2 - u1*u2*v0 - u0*u1*v3 + u0*u3*v1 - u0*u3*v2 + u2*u3*v0 +
                u1*u2*v3 - u2*u3*v1)/den;
    self.a12 = (2*u0*v1*v2 - 2*u1*v0*v2 - 2*u0*v1*v3 + 2*u1*v0*v3 - 2*u2*v0*v3 + 2*u3*v0*v2 +
                2*u2*v1*v3 - 2*u3*v1*v2)/den;
    self.a22 = -(2*u1*v0*v2 - 2*u2*v0*v1 - 2*u0*v1*v3 + 2*u3*v0*v1 + 2*u0*v2*v3 - 2*u3*v0*v2 -
                 2*u1*v2*v3 + 2*u2*v1*v3)/den;
    self.a32 = (u0*v1*v2 - u2*v0*v1 - u1*v0*v3 + u3*v0*v1 - u0*v2*v3 + u2*v0*v3 + u1*v2*v3 - u3*v1*v2)/den;
    self.a13 = (2*u0*v2 - 2*u2*v0 - 2*u0*v3 - 2*u1*v2 + 2*u2*v1 + 2*u3*v0 + 2*u1*v3 - 2*u3*v1)/den;
    self.a23 = (2*u0*v1 - 2*u1*v0 - 2*u0*v2 + 2*u2*v0 + 2*u1*v3 - 2*u3*v1 - 2*u2*v3 + 2*u3*v2)/den;
}

- (id)initPara:(int)flag theta:(float)theta
{
    if (!(self = [super initWithFragmentShaderFromString:kRCGPUImage3DRotationFilterShaderString]))
    {
        return nil;
    }
    
    a11Uniform = [filterProgram uniformIndex:@"a11"];
    a12Uniform = [filterProgram uniformIndex:@"a12"];
    a13Uniform = [filterProgram uniformIndex:@"a13"];
    
    a21Uniform = [filterProgram uniformIndex:@"a21"];
    a22Uniform = [filterProgram uniformIndex:@"a22"];
    a23Uniform = [filterProgram uniformIndex:@"a23"];
    
    a31Uniform = [filterProgram uniformIndex:@"a31"];
    a32Uniform = [filterProgram uniformIndex:@"a32"];

    [self computePara:flag theta:theta];
    
    return self;
}

- (void)setA11:(GLfloat)newValue;
{
    _a11 = newValue;
    [self setFloat:_a11 forUniform:a11Uniform program:filterProgram];
}

- (void)setA12:(GLfloat)newValue;
{
    _a12 = newValue;
    [self setFloat:_a12 forUniform:a12Uniform program:filterProgram];
}

- (void)setA13:(GLfloat)newValue;
{
    _a13 = newValue;
    [self setFloat:_a13 forUniform:a13Uniform program:filterProgram];
}

- (void)setA21:(GLfloat)newValue;
{
    _a21 = newValue;
    [self setFloat:_a21 forUniform:a21Uniform program:filterProgram];
}

- (void)setA22:(GLfloat)newValue;
{
    _a22 = newValue;
    [self setFloat:_a22 forUniform:a22Uniform program:filterProgram];
}

- (void)setA23:(GLfloat)newValue;
{
    _a23 = newValue;
    [self setFloat:_a23 forUniform:a23Uniform program:filterProgram];
}

- (void)setA31:(GLfloat)newValue;
{
    _a31 = newValue;
    [self setFloat:_a31 forUniform:a31Uniform program:filterProgram];
}

- (void)setA32:(GLfloat)newValue;
{
    _a32 = newValue;
    [self setFloat:_a32 forUniform:a32Uniform program:filterProgram];
}

@end