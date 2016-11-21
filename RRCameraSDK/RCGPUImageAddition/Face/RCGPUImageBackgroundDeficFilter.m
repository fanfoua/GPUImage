//
//  RCGPUImageBackgroundDeficFilter.m
//  Renren-iOS-StickerCamera
//
//  Created by 0153-00503 on 15/12/7.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageBackgroundDeficFilter.h"
#import "RCGPUImageGaussianBlurPassParamFilter.h"
RCGPUImageBackgroundDeficFilter *BackgroundDeficFilter=NULL;
@implementation RCGPUImageBackgroundDeficFilter
- (NSString *)vertexShaderForSBackgroundDefic;
{
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    // Header
    [shaderString appendFormat:@"\
     attribute vec4 position;\n\
     attribute vec4 inputTextureCoordinate;\n\
     attribute vec4 inputTextureCoordinate2;\n\
     \n\
     varying vec2 textureCoord;\n\
     \n\
     void main()\n\
     {\n\
     gl_Position = position;\n\
     textureCoord = inputTextureCoordinate.xy;\n\
     "];
    
    // Footer
    [shaderString appendString:@"}\n"];
    
    return shaderString;
}

- (NSString *)fragmentShaderForBackgroundDefic;
{
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    
    // Header
    [shaderString appendFormat:@"\
      varying highp vec2 textureCoord;\n\
      uniform sampler2D inputImageTexture;\n\
      uniform sampler2D inputImageTexture2;\n\
      uniform highp float midX;\n\
     uniform highp float midY;\n\
      uniform highp float r;\n\
      void main()\n\
      {\n\
          lowp vec4 base = texture2D(inputImageTexture, textureCoord);\n\
          lowp vec4 background = texture2D(inputImageTexture2, textureCoord);\n\
          highp vec2 centerPts=vec2(midX,midY);\n\
          highp float dist =distance(textureCoord,centerPts);\n\
          highp float alpha;\n\
          if(dist>r) \n\
     alpha = min(abs((dist-r)/(1.0-r)),1.0);\n\
          else\n\
     alpha = 0.0;\n\
          gl_FragColor = vec4(mix(base.rgb, background.rgb, background.a * alpha), base.a);\n\
     }"];
    
    return shaderString;
}

-(void)setFaceRect:(FacePointData *)faceData Model: (int)viModel;
{
    CGPoint facePoint;
    CGFloat r;
    if (faceData->faceCount<=0)
    {
        facePoint.x=0.5;
        facePoint.y=0.5;
        r=0.3;
    }
    else
    {
        if (viModel==2)
        {
            facePoint.x=((faceData->originWidth-faceData->rect[0].origin.x-faceData->rect[0].size.width)+faceData->rect[0].size.width/2.0)/faceData->originWidth;
        }
        else
        {
            facePoint.x=(faceData->rect[0].origin.x+faceData->rect[0].size.width/2.0)/faceData->originWidth;
        }

        facePoint.y=(faceData->rect[0].origin.y+faceData->rect[0].size.height/2.0)/faceData->originHeight;
        r=MIN(MAX(faceData->rect[0].size.width/faceData->originWidth/3.0, 0.0),1.0);
    }
    
    [TwoInputFilter setFloat:r forUniformName:@"r"];
    [TwoInputFilter setFloat:facePoint.x forUniformName:@"midX"];
    [TwoInputFilter setFloat:facePoint.y forUniformName:@"midY"];
}

- (id)initFaceStruct:(FacePointData *)faceData;
{
    RCGPUImageGaussianBlurPassParamFilter *gaussianBlurFilter=[[RCGPUImageGaussianBlurPassParamFilter alloc]initRadius:5 initSigma:10.0];
    
    
    NSString *currentSurfaceblurVertexShader = [self vertexShaderForSBackgroundDefic];
    NSString *currentSurfaceblurFragmentShader = [self  fragmentShaderForBackgroundDefic];
    TwoInputFilter = [[GPUImageTwoInputFilter alloc]initWithVertexShaderFromString:currentSurfaceblurVertexShader fragmentShaderFromString:currentSurfaceblurFragmentShader];
    [gaussianBlurFilter addTarget:TwoInputFilter atTextureLocation:1];
    [self setFaceRect:faceData Model:2];

    self.initialFilters = [NSArray arrayWithObjects:gaussianBlurFilter,TwoInputFilter,nil];
    self.terminalFilter = TwoInputFilter;
    return self;
}
@end
