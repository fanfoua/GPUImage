//
//  RCGPUImageDressupFilter.m
//  Renren-iOS-StickerCamera
//
//  Created by 0153-00503 on 15/12/8.
//  Copyright © 2015年 renren. All rights reserved.
//动态实时贴纸

#import "RCGPUImageDressupFilter.h"
#import "FacePointDet/Nativeclass.h"
#import "RCFaceHistStatisticsFilter.h"
RCGPUImageDressupFilter *DressupFilter;
CGSize backImageSize;
int devModel=4;
@implementation RCGPUImageDressupFilter
- (NSString *)vertexShaderForDressup;
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

- (NSString *)fragmentShaderForDressup;
{
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    
    // Header
    [shaderString appendFormat:@"\
     varying highp vec2 textureCoord;\n\
     uniform sampler2D inputImageTexture;\n\
     uniform sampler2D inputImageTexture2;\n\
     uniform highp float midX;\n\
     uniform highp float midY;\n\
     uniform highp float midW;\n\
     uniform highp float midH;\n\
     void main()\n\
     {\n\
     lowp vec4 base = texture2D(inputImageTexture, textureCoord);\n\
     if (textureCoord.x>midX&&textureCoord.x<midX+midW&&textureCoord.y>midY&&textureCoord.y<midY+midH)\n\
     {\n\
     highp vec2 po=max(vec2((textureCoord.x-midX)/midW,(textureCoord.y-midY)/midH),0.0);\n\
     lowp vec4 background = texture2D(inputImageTexture2, po);\n\
     gl_FragColor = vec4(background.rgb+(1.0-background.a)*base.rgb, base.a);\n\
     }\n\
     else\n\
     {\n\
     gl_FragColor = base;\n\
     }\n\
     }"];
    
    return shaderString;
}

- (NSString *)fragmentShaderForDressupAngle;
{
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    
    // Header
    [shaderString appendFormat:@"\
     varying highp vec2 textureCoord;\n\
     uniform sampler2D inputImageTexture;\n\
     uniform sampler2D inputImageTexture2;\n\
     uniform highp float midX;\n\
     uniform highp float midY;\n\
     uniform highp float midW;\n\
     uniform highp float midH;\n\
     uniform highp float backX;\n\
     uniform highp float backY;\n\
     uniform highp float imageW;\n\
     uniform highp float imageH;\n\
     uniform highp float sinang;\n\
     uniform highp float cosang;\n\
     void main()\n\
     {\n\
     lowp vec4 base = texture2D(inputImageTexture, textureCoord);\n\
     highp vec2 lontmp=(textureCoord*vec2(imageW,imageH)-vec2(midX,midY));\n\
     highp vec2 lon;\n\
     lon.x = cosang*(lontmp.x)-sinang*(lontmp.y);\n\
     lon.y = sinang*(lontmp.x)+cosang*(lontmp.y);\n\
     if (midW>=0.0&&lon.x>-midW*backX&&lon.x<midW*(1.0-backX)&&lon.y>-midH*backY&&lon.y<midH*(1.0-backY))\n\
     {\n\
     highp vec2 po=min(max(vec2((lon.x)/midW+backX,(lon.y)/midH+backY),0.0),1.0);\n\
     lowp vec4 background = texture2D(inputImageTexture2, po);\n\
     gl_FragColor = vec4(background.rgb+(1.0-background.a)*base.rgb, base.a);\n\
     }\n\
     else\n\
     {\n\
        gl_FragColor = base;\n\
     }\n\
     }"];
    
    return shaderString;
}
CGFloat backprop1,backprop2;
-(void)setBackImageDevicePosition:(int)model faceStickerInf:(FaceStickerInf*)faceStickerInf;
{
    devModel=model;
    CGFloat midX,midY,midW,midH;
    
    if (devModel==-1)
    {
        [TwoInputFilter setFloat:0.0 forUniformName:@"midX"];
        [TwoInputFilter setFloat:0.0 forUniformName:@"midY"];
        [TwoInputFilter setFloat:-1.0 forUniformName:@"midW"];
        [TwoInputFilter setFloat:-1.0 forUniformName:@"midH"];
        [TwoInputFilter setFloat:0.5 forUniformName:@"backX"];
        [TwoInputFilter setFloat:0.5 forUniformName:@"backY"];
        
        [TwoInputFilter setFloat:100 forUniformName:@"imageW"];
        [TwoInputFilter setFloat:100 forUniformName:@"imageH"];
        [TwoInputFilter setFloat:sinf(0.0) forUniformName:@"sinang"];
        [TwoInputFilter setFloat:cosf(0.0) forUniformName:@"cosang"];
        return ;
    }

    
    float angle1 = (float)(faceData.poi[0][20][1]-faceData.poi[0][14][1])/(float)(faceData.poi[0][20][0]-faceData.poi[0][14][0]);
    float angle2 = (float)(faceData.poi[0][24][1]-faceData.poi[0][22][1])/(float)(faceData.poi[0][24][0]-faceData.poi[0][22][0]);
    float angle3 = (float)(faceData.poi[0][9][1]-faceData.poi[0][6][1])/(float)(faceData.poi[0][9][0]-faceData.poi[0][6][0]);
    
    float angle=(angle1+angle2+angle3)/3.0;
    
    float ftmpt=faceData.rect[0].size.width*backImageSize.height/backImageSize.width/2.0;
    float x = (faceData.poi[0][6][0]+faceData.poi[0][9][0])/2.0+ftmpt*sinf(angle);//faceData.foreheadRect[0].origin.x+faceData.foreheadRect[0].size.width/2.0;//(faceData.poi[0][17][0]+faceData.poi[0][19][0])/2.0;
    float y = ((faceData.poi[0][6][1]+faceData.poi[0][9][1])/2.0)-ftmpt*cosf(angle);//faceData.foreheadRect[0].origin.y+faceData.foreheadRect[0].size.height/2.0;//(faceData.poi[0][17][1]+faceData.poi[0][19][1])/2.0;
    float w = faceData.rect[0].size.width;//sqrt(ftmp1*ftmp1+ftmp2*ftmp2);
    float h = w*backImageSize.height/backImageSize.width;
    float backx=0.5;
    float backy=0.5;
    if (faceStickerInf->positionType==1)//脸、鼻子 3个点
    {
        CGPoint point1,point2;
        point1.x=(faceData.poi[0][14][0]+faceData.poi[0][16][0])/2.0;
        point1.y=(faceData.poi[0][15][1]+faceData.poi[0][17][1])/2.0;
        point2.x=(faceData.poi[0][18][0]+faceData.poi[0][20][0])/2.0;
        point2.y=(faceData.poi[0][19][1]+faceData.poi[0][21][1])/2.0;
        float ro = faceSticker.faceStickerInf[0].point[1].x-faceSticker.faceStickerInf[0].point[0].x;
        float tmpx = point2.x-point1.x;
        float tmpy = point2.y-point1.y;
        if (devModel>=4)
        {
            tmpy=-tmpy;
        }
        if (fabs(tmpx)>0.0)
        {
            angle=atan(tmpy/tmpx);
        }
        float ro2 = sqrt(tmpx*tmpx+tmpy*tmpy);
        x=faceData.poi[0][11][0];
        y=faceData.poi[0][11][1];
        w=ro2/ro;
        h = w*backImageSize.height/backImageSize.width;
        backx=faceSticker.faceStickerInf[0].point[2].x;
        backy=faceSticker.faceStickerInf[0].point[2].y;
    }
    else if (faceStickerInf->positionType==2)//眉毛 2个点
    {
        float ro = faceSticker.faceStickerInf[0].point[1].x-faceSticker.faceStickerInf[0].point[0].x;
        float tmpx = faceData.poi[0][9][0]-faceData.poi[0][6][0];
        float tmpy = faceData.poi[0][9][1]-faceData.poi[0][6][1];
        if (devModel>=4)
        {
            tmpy=-tmpy;
        }
        if (fabs(tmpx)>0.0)
        {
            angle=atan(tmpy/tmpx);
        }
        float ro2 = sqrt(tmpx*tmpx+tmpy*tmpy);
        x=(faceData.poi[0][9][0]+faceData.poi[0][6][0])/2.0;
        y=(faceData.poi[0][9][1]+faceData.poi[0][6][1])/2.0;
        w=ro2/ro;
        h = w*backImageSize.height/backImageSize.width;
        backx=(faceSticker.faceStickerInf[0].point[0].x+faceSticker.faceStickerInf[0].point[1].x)/2.0;
        backy=(faceSticker.faceStickerInf[0].point[0].y+faceSticker.faceStickerInf[0].point[1].y)/2.0;
    }
    else if (faceStickerInf->positionType==3)//眼睛 2个点
    {
        CGPoint point1,point2;
        point1.x=(faceData.poi[0][14][0]+faceData.poi[0][16][0])/2.0;
        point1.y=(faceData.poi[0][15][1]+faceData.poi[0][17][1])/2.0;
        point2.x=(faceData.poi[0][18][0]+faceData.poi[0][20][0])/2.0;
        point2.y=(faceData.poi[0][19][1]+faceData.poi[0][21][1])/2.0;
        float ro = faceSticker.faceStickerInf[0].point[1].x-faceSticker.faceStickerInf[0].point[0].x;
        float tmpx = point2.x-point1.x;
        float tmpy = point2.y-point1.y;
        if (devModel>=4)
        {
            tmpy=-tmpy;
        }
        if (fabs(tmpx)>0.0)
        {
            angle=atan(tmpy/tmpx);
        }
        float ro2 = sqrt(tmpx*tmpx+tmpy*tmpy);
        x=(point2.x+point1.x)/2.0;
        y=(point2.y+point1.y)/2.0;
        w=ro2/ro;
        h = w*backImageSize.height/backImageSize.width;
        backx=(faceSticker.faceStickerInf[0].point[0].x+faceSticker.faceStickerInf[0].point[1].x)/2.0;
        backy=(faceSticker.faceStickerInf[0].point[0].y+faceSticker.faceStickerInf[0].point[1].y)/2.0;
    }
    else if (faceStickerInf->positionType==4)//耳朵 2个点
    {
        CGPoint point1,point2;
        point1.x=faceData.poi[0][0][0];
        point1.y=faceData.poi[0][0][1];
        point2.x=faceData.poi[0][4][0];
        point2.y=faceData.poi[0][4][1];
        float ro = faceSticker.faceStickerInf[0].point[1].x-faceSticker.faceStickerInf[0].point[0].x;
        float tmpx = point2.x-point1.x;
        float tmpy = point2.y-point1.y;
        if (devModel>=4)
        {
            tmpy=-tmpy;
        }
        if (fabs(tmpx)>0.0)
        {
            angle=atan(tmpy/tmpx);
        }
        float ro2 = sqrt(tmpx*tmpx+tmpy*tmpy);
        x=(point2.x+point1.x)/2.0;
        y=(point2.y+point1.y)/2.0;
        w=ro2/ro;
        h = w*backImageSize.height/backImageSize.width;
        backx=(faceSticker.faceStickerInf[0].point[0].x+faceSticker.faceStickerInf[0].point[1].x)/2.0;
        backy=(faceSticker.faceStickerInf[0].point[0].y+faceSticker.faceStickerInf[0].point[1].y)/2.0;
    }
    else if (faceStickerInf->positionType==5)//脸蛋 2个点
    {
        CGPoint point1,point2;
        point1.x=(faceData.poi[0][14][0]+faceData.poi[0][16][0])/2.0;
        point1.y=(faceData.poi[0][15][1]+faceData.poi[0][17][1])/2.0;
        point2.x=(faceData.poi[0][18][0]+faceData.poi[0][20][0])/2.0;
        point2.y=(faceData.poi[0][19][1]+faceData.poi[0][21][1])/2.0;
        float ro = faceSticker.faceStickerInf[0].point[1].x-faceSticker.faceStickerInf[0].point[0].x;
        float tmpx = point2.x-point1.x;
        float tmpy = point2.y-point1.y;
        if (devModel>=4)
        {
            tmpy=-tmpy;
        }
        if (fabs(tmpx)>0.0)
        {
            angle=atan(tmpy/tmpx);
        }
        float ro2 = sqrt(tmpx*tmpx+tmpy*tmpy);
        x=(point2.x+point1.x)/2.0;
        y=(point2.y+point1.y)/2.0;
        w=ro2/ro;
        h = w*backImageSize.height/backImageSize.width;
        backx=(faceSticker.faceStickerInf[0].point[0].x+faceSticker.faceStickerInf[0].point[1].x)/2.0;
        backy=(faceSticker.faceStickerInf[0].point[0].y+faceSticker.faceStickerInf[0].point[1].y)/2.0;
    }
    else if (faceStickerInf->positionType==6)//嘴 2个点
    {
        CGPoint point1,point2;
        point1.x=faceData.poi[0][22][0];
        point1.y=faceData.poi[0][22][1];
        point2.x=faceData.poi[0][24][0];
        point2.y=faceData.poi[0][24][1];
        float ro = faceSticker.faceStickerInf[0].point[1].x-faceSticker.faceStickerInf[0].point[0].x;
        float tmpx = point2.x-point1.x;
        float tmpy = point2.y-point1.y;
        if (devModel>=4)
        {
            tmpy=-tmpy;
        }
        if (fabs(tmpx)>0.0)
        {
            angle=atan(tmpy/tmpx);
        }
        float ro2 = sqrt(tmpx*tmpx+tmpy*tmpy);
        x=(point2.x+point1.x)/2.0;
        y=(point2.y+point1.y)/2.0;
        w=ro2/ro;
        h = w*backImageSize.height/backImageSize.width;
        backx=(faceSticker.faceStickerInf[0].point[0].x+faceSticker.faceStickerInf[0].point[1].x)/2.0;
        backy=(faceSticker.faceStickerInf[0].point[0].y+faceSticker.faceStickerInf[0].point[1].y)/2.0;
    }
    else if (faceStickerInf->positionType==7)//下巴 3个点
    {
        CGPoint point1,point2;
        point1.x=(faceData.poi[0][14][0]+faceData.poi[0][16][0])/2.0;
        point1.y=(faceData.poi[0][15][1]+faceData.poi[0][17][1])/2.0;
        point2.x=(faceData.poi[0][18][0]+faceData.poi[0][20][0])/2.0;
        point2.y=(faceData.poi[0][19][1]+faceData.poi[0][21][1])/2.0;
        float ro = faceSticker.faceStickerInf[0].point[1].x-faceSticker.faceStickerInf[0].point[0].x;
        float tmpx = point2.x-point1.x;
        float tmpy = point2.y-point1.y;
        if (devModel>=4)
        {
            tmpy=-tmpy;
        }
        if (fabs(tmpx)>0.0)
        {
            angle=atan(tmpy/tmpx);
        }
        float ro2 = sqrt(tmpx*tmpx+tmpy*tmpy);
        x=faceData.poi[0][2][0];
        y=faceData.poi[0][2][1];
        w=ro2/ro;
        h = w*backImageSize.height/backImageSize.width;
        backx=faceSticker.faceStickerInf[0].point[2].x;
        backy=faceSticker.faceStickerInf[0].point[2].y;
    }
    else if (faceStickerInf->positionType==8)//额头及头发 2个点
    {
        float ro = faceSticker.faceStickerInf[0].point[1].x-faceSticker.faceStickerInf[0].point[0].x;
        float tmpx = faceData.poi[0][9][0]-faceData.poi[0][6][0];
        float tmpy = faceData.poi[0][9][1]-faceData.poi[0][6][1];
        if (devModel>=4)
        {
            tmpy=-tmpy;
        }
        if (fabs(tmpx)>0.0)
        {
            angle=atan(tmpy/tmpx);
        }
        float ro2 = sqrt(tmpx*tmpx+tmpy*tmpy);
        x=(faceData.poi[0][9][0]+faceData.poi[0][6][0])/2.0;
        y=(faceData.poi[0][9][1]+faceData.poi[0][6][1])/2.0;
        w=ro2/ro;
        h = w*backImageSize.height/backImageSize.width;
        backx=(faceSticker.faceStickerInf[0].point[0].x+faceSticker.faceStickerInf[0].point[1].x)/2.0;
        backy=(faceSticker.faceStickerInf[0].point[0].y+faceSticker.faceStickerInf[0].point[1].y)/2.0;
    }
    else if (faceStickerInf->positionType==9)//头上 2个点
    {
        float ro = faceSticker.faceStickerInf[0].point[1].x-faceSticker.faceStickerInf[0].point[0].x;
        float tmpx = faceData.poi[0][9][0]-faceData.poi[0][6][0];
        float tmpy = faceData.poi[0][9][1]-faceData.poi[0][6][1];
        if (devModel>=4)
        {
            tmpy=-tmpy;
        }
        if (fabs(tmpx)>0.0)
        {
            angle=atan(tmpy/tmpx);
        }
        float ro2 = sqrt(tmpx*tmpx+tmpy*tmpy);
        x=(faceData.poi[0][9][0]+faceData.poi[0][6][0])/2.0;
        y=(faceData.poi[0][9][1]+faceData.poi[0][6][1])/2.0;
        w=ro2/ro;
        h = w*backImageSize.height/backImageSize.width;
        backx=(faceSticker.faceStickerInf[0].point[0].x+faceSticker.faceStickerInf[0].point[1].x)/2.0;
        backy=(faceSticker.faceStickerInf[0].point[0].y+faceSticker.faceStickerInf[0].point[1].y)/2.0;
    }
    else if (faceStickerInf->positionType==10)//下巴及以下 3个点
    {
        CGPoint point1,point2;
        point1.x=(faceData.poi[0][14][0]+faceData.poi[0][16][0])/2.0;
        point1.y=(faceData.poi[0][15][1]+faceData.poi[0][17][1])/2.0;
        point2.x=(faceData.poi[0][18][0]+faceData.poi[0][20][0])/2.0;
        point2.y=(faceData.poi[0][19][1]+faceData.poi[0][21][1])/2.0;
        float ro = faceSticker.faceStickerInf[0].point[1].x-faceSticker.faceStickerInf[0].point[0].x;
        float tmpx = point2.x-point1.x;
        float tmpy = point2.y-point1.y;
        if (devModel>=4)
        {
            tmpy=-tmpy;
        }
        if (fabs(tmpx)>0.0)
        {
            angle=atan(tmpy/tmpx);
        }
        float ro2 = sqrt(tmpx*tmpx+tmpy*tmpy);
        x=faceData.poi[0][2][0];
        y=faceData.poi[0][2][1];
        w=ro2/ro;
        h = w*backImageSize.height/backImageSize.width;
        backx=faceSticker.faceStickerInf[0].point[2].x;
        backy=faceSticker.faceStickerInf[0].point[2].y;
    }
    else if (faceStickerInf->positionType==11)//脸左边 3个点
    {
        CGPoint point1,point2;
        point1.x=(faceData.poi[0][14][0]+faceData.poi[0][16][0])/2.0;
        point1.y=(faceData.poi[0][15][1]+faceData.poi[0][17][1])/2.0;
        point2.x=(faceData.poi[0][18][0]+faceData.poi[0][20][0])/2.0;
        point2.y=(faceData.poi[0][19][1]+faceData.poi[0][21][1])/2.0;
        float ro = faceSticker.faceStickerInf[0].point[1].x-faceSticker.faceStickerInf[0].point[0].x;
        float tmpx = point2.x-point1.x;
        float tmpy = point2.y-point1.y;
        if (devModel>=4)
        {
            tmpy=-tmpy;
        }
        if (fabs(tmpx)>0.0)
        {
            angle=atan(tmpy/tmpx);
        }
        float ro2 = sqrt(tmpx*tmpx+tmpy*tmpy);
        x=faceData.poi[0][11][0];
        y=faceData.poi[0][11][1];
        w=ro2/ro;
        h = w*backImageSize.height/backImageSize.width;
        backx=faceSticker.faceStickerInf[0].point[2].x;
        backy=faceSticker.faceStickerInf[0].point[2].y;
    }
    else if (faceStickerInf->positionType==12)//脸右边 3个点
    {
        CGPoint point1,point2;
        point1.x=(faceData.poi[0][14][0]+faceData.poi[0][16][0])/2.0;
        point1.y=(faceData.poi[0][15][1]+faceData.poi[0][17][1])/2.0;
        point2.x=(faceData.poi[0][18][0]+faceData.poi[0][20][0])/2.0;
        point2.y=(faceData.poi[0][19][1]+faceData.poi[0][21][1])/2.0;
        float ro = faceSticker.faceStickerInf[0].point[1].x-faceSticker.faceStickerInf[0].point[0].x;
        float tmpx = point2.x-point1.x;
        float tmpy = point2.y-point1.y;
        if (devModel>=4)
        {
            tmpy=-tmpy;
        }
        if (fabs(tmpx)>0.0)
        {
            angle=atan(tmpy/tmpx);
        }
        float ro2 = sqrt(tmpx*tmpx+tmpy*tmpy);
        x=faceData.poi[0][11][0];
        y=faceData.poi[0][11][1];
        w=ro2/ro;
        h = w*backImageSize.height/backImageSize.width;
        backx=faceSticker.faceStickerInf[0].point[2].x;
        backy=faceSticker.faceStickerInf[0].point[2].y;
    }
    
    if (devModel<4)
    {
        x=faceData.originWidth-x;
    }

    if (faceData.faceCount<=0)//||(model!=0&&model!=4))
    {
        x=0.5*faceData.originWidth;//0.3*faceData.originWidth*faceSticker.cutRect.size.width+faceSticker.cutRect.origin.x*faceData.originWidth;
        y=0.5*faceData.originHeight;//0.3*faceData.originHeight*faceSticker.cutRect.size.height+faceSticker.cutRect.origin.y*faceData.originHeight;
        w=0.5*faceData.originWidth;
        h=w*backImageSize.height/backImageSize.width;
		angle=0.0;
    }
    x=max(x,0.0);
    y=max(y,0.0);

    CGSize cameraSize;
    cameraSize.width=faceData.originWidth;
    cameraSize.height=faceData.originHeight;
    float width =320.0;
    float height = 568.0;

    CGRect cropRegion = CGRectMake((cameraSize.width - width) * .5 / cameraSize.width, (cameraSize.height - height) * .5 / cameraSize.height, width / cameraSize.width, height / cameraSize.height);
    
    faceSticker.cutRect=cropRegion;
    
    x=max(x-faceSticker.cutRect.origin.x*faceData.originWidth,0.0);
    y=max(y-faceSticker.cutRect.origin.y*faceData.originHeight,0.0);
//    backx=max(backx-faceSticker.cutRect.origin.x,0.0);
//    backy=max(backy-faceSticker.cutRect.origin.y,0.0);

    int imageW=faceData.originWidth*faceSticker.cutRect.size.width;
    int imageH=faceData.originHeight*faceSticker.cutRect.size.height;
    
    [TwoInputFilter setFloat:x forUniformName:@"midX"];
    [TwoInputFilter setFloat:y forUniformName:@"midY"];
    [TwoInputFilter setFloat:w forUniformName:@"midW"];
    [TwoInputFilter setFloat:h forUniformName:@"midH"];
    [TwoInputFilter setFloat:backx forUniformName:@"backX"];
    [TwoInputFilter setFloat:backy forUniformName:@"backY"];
    
    [TwoInputFilter setFloat:imageW forUniformName:@"imageW"];
    [TwoInputFilter setFloat:imageH forUniformName:@"imageH"];
    [TwoInputFilter setFloat:sinf(angle) forUniformName:@"sinang"];
    [TwoInputFilter setFloat:cosf(angle) forUniformName:@"cosang"];
}

-(void)setBackImageFilter:(GPUImageTwoInputFilter*)InputFilter X:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w H:(CGFloat)h;
{
    
    [InputFilter setFloat:x forUniformName:@"midX"];
    [InputFilter setFloat:y forUniformName:@"midY"];
    [InputFilter setFloat:w forUniformName:@"midW"];
    [InputFilter setFloat:h forUniformName:@"midH"];
}

-(void)setBackImageProp:(CGFloat)prop Model:(int)model
{
    GPUImageTwoInputFilter* InputFilter;
    CGFloat midX,midY,midW,midH;
    CGFloat backprop;
    if (model==1||model==3)
    {
        backprop=backprop1;
        InputFilter=TwoInputFilter2;
    }
    else
    {
        backprop=backprop2;
        InputFilter=TwoInputFilter3;
    }
    
    midW=1.0;
    midH=prop/backprop;
    if (model==1)//上面的背景图
    {
        midX=0.0;
        midY=0.0;
    }
    else if(model==2)//下面的背景图
    {
        midX=0.0;
        midY=1.0-midH;
    }
    else if (model==3)//实时滤镜上面的背景图
    {
        midX=0.0;
        midY=0.125;
    }
    else if(model==4)//实时滤镜上面的背景图
    {
        midX=0.0;
        midY=0.875-midH;
    }
    
    [self setBackImageFilter:InputFilter X:midX Y:midY W:midW H:midH];
}

-(void)setBackImageProp2:(CGFloat)prop Rect:(CGRect)rect Filter:(GPUImageTwoInputFilter *)InputFilter
{
    CGFloat midX,midY,midW,midH;
//    CGFloat backprop;
//    backprop=backprop1;
    midX=rect.origin.x;
    midY=rect.origin.y;
    if (rect.size.width==0.0)
    {
        midW=1.0;
    }
    else
    {
        midW=rect.size.width;
    }
    
    if (rect.size.height==0.0)
    {
        midH=prop;
    }
    else
    {
        midH=prop*rect.size.height;
    }
    
    
    
    [self setBackImageFilter:InputFilter X:midX Y:midY W:midW H:midH];
}

-(void)setBackImagerotationType: (int)rotationType Indx:(int)indxt// previewRatio: (int)previewModel;
{
//    ///////////TEST///////////
//    CGPoint poi;
//    poi.x=0.0;
//    poi.y=0.5;
//    faceSticker.stickerCount=1;
//    faceSticker.faceStickerInf[0].count=60;
//    faceSticker.faceStickerInf[0].point[0]=poi;
//    poi.x=0.5;
//    poi.y=0.5;
//    faceSticker.faceStickerInf[0].point[1]=poi;
//    poi.x=1.0;
//    poi.y=0.5;
//    faceSticker.faceStickerInf[0].point[2]=poi;
////    faceSticker.faceStickerInf[0].sizeRatio=2.0;
//    faceSticker.faceStickerInf[0].positionType=11;
//    faceSticker.faceStickerInf[0].imageName = [NSString stringWithFormat:@"RedEnvelope"];
//    
//    faceSticker.stickerBackCount=1;
//    faceSticker.faceStickerBackInf[0].imageName = [NSString stringWithFormat:@"RedEnvelope"];
//    faceSticker.faceStickerBackInf[0].count=1;
//    faceSticker.faceStickerBackInf[0].rect.origin.x=0.0;
//    faceSticker.faceStickerBackInf[0].rect.origin.y=0.0;
//    faceSticker.faceStickerBackInf[0].rect.size.width=0.0;
//    faceSticker.faceStickerBackInf[0].rect.size.height=0.0;
//    ///////////TEST///////////
    
    int indxC=indxt;
    
    if (rotationType==-1)
    {
        [self setBackImageDevicePosition:rotationType faceStickerInf:nil];
        return;
    }
    
    if (faceSticker.stickerCount>0&&TwoInputFilter!=nil&&faceSticker.faceStickerInf[0].imageName!=nil)
    {
        int inxUse=(indxC%(faceSticker.faceStickerInf[0].count));///(4.0/3.0);
        if (inxUse==0) {
            inxUse=faceSticker.faceStickerInf[0].count;
        }
        if (inxUse>faceSticker.faceStickerInf[0].count)
        {
            inxUse=faceSticker.faceStickerInf[0].count;
        }
#ifdef TEST_TIME
        NSDate* tmpStartData = [[NSDate date] init];
        //You code here...
#endif
        NSString *str;
        if (inxUse<10) {
            str = [NSString stringWithFormat:@"%s0%d.png",faceSticker.faceStickerInf[0].imageName,inxUse];
        }
        else
        {
            str = [NSString stringWithFormat:@"%s%d.png",faceSticker.faceStickerInf[0].imageName,inxUse];
        }

//        ///////////TEST///////////
//        NSString *strtmp = [NSString stringWithFormat:@"%@/%d",faceSticker.faceStickerInf[0].imageName,inx];
//
//        NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
//        str = [resBundle pathForResource:strtmp ofType:@"png"];
//        ///////////TEST///////////
        
        UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:str];
        ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
        [ImageSource1 addTarget:TwoInputFilter atTextureLocation:1];
        [ImageSource1 processImage];
        

        
        backImageSize=image1.size;
        [self setBackImageDevicePosition:rotationType faceStickerInf:&faceSticker.faceStickerInf[0]];
#ifdef TEST_TIME
        double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
        NSLog(@">>>>>>>>>>cost time = %f ms", deltaTime*1000);
#endif
//        inx++;
//        if (inx>=faceSticker.faceStickerInf[0].count)
//        {
//            inx=2;
//        }
    }
    
    if (faceSticker.stickerBackCount>0&&TwoInputFilter2!=nil&&faceSticker.faceStickerBackInf[0].imageName!=nil)
    {
        int inxBackUse=(indxC%(faceSticker.faceStickerBackInf[0].count));
        if (inxBackUse==0) {
            inxBackUse=faceSticker.faceStickerBackInf[0].count;
        }
        if (inxBackUse>faceSticker.faceStickerBackInf[0].count)
        {
            inxBackUse=faceSticker.faceStickerBackInf[0].count;
        }
        NSString *str;
        if (inxBackUse<10) {
            str = [NSString stringWithFormat:@"%s0%d.png",faceSticker.faceStickerBackInf[0].imageName,inxBackUse];
        }
        else
        {
            str = [NSString stringWithFormat:@"%s%d.png",faceSticker.faceStickerBackInf[0].imageName,inxBackUse];
        }


//        ///////////TEST///////////
//        NSString *strtmp = [NSString stringWithFormat:@"%@/%d",faceSticker.faceStickerBackInf[0].imageName,inxBack];
//        
//        NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
//        str = [resBundle pathForResource:strtmp ofType:@"png"];
//        ///////////TEST///////////
        
        UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:str];
        ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
        [ImageSource2 addTarget:TwoInputFilter2 atTextureLocation:1];
        [ImageSource2 processImage];

        backprop1=image2.size.width/image2.size.height;
        CGFloat ftm=faceData.originWidth/faceData.originHeight*faceSticker.cutRect.size.width/faceSticker.cutRect.size.height;
        [self setBackImageProp2:ftm/backprop1 Rect:faceSticker.faceStickerBackInf[0].rect Filter:TwoInputFilter2];
        
    }
}

- (id)initIndex:(int)indx
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    
    
    //    ///////////TEST///////////
    //    CGPoint poi;
    //    poi.x=0.2;
    //    poi.y=0.5;
    //    faceSticker.stickerCount=1;
    //    faceSticker.faceStickerInf[0].count=60;
    //    faceSticker.faceStickerInf[0].point[0]=poi;
    //    poi.x=0.5;
    //    poi.y=0.1;
    //    faceSticker.faceStickerInf[0].point[1]=poi;
    //    poi.x=0.8;
    //    poi.y=0.5;
    //    faceSticker.faceStickerInf[0].point[2]=poi;
    //    //    faceSticker.faceStickerInf[0].sizeRatio=2.0;
    //    faceSticker.faceStickerInf[0].positionType=2;
    //    faceSticker.faceStickerInf[0].imageName = [NSString stringWithFormat:@"RedEnvelope"];
    //
    //    faceSticker.stickerBackCount=1;
    //    faceSticker.faceStickerBackInf[0].imageName = [NSString stringWithFormat:@"RedEnvelope"];
    //    ///////////TEST///////////
    
    if (faceSticker.stickerCount==0&&faceSticker.stickerBackCount==0)
    {
        
        NSString *currentSurfaceblurVertexShader = [self vertexShaderForDressup];
        NSString *currentSurfaceblurFragmentShader = [self  fragmentShaderForDressup];
        NSString *currentDressupAngleFragmentShader = [self  fragmentShaderForDressupAngle];
        
        NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
            UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                 pathForResource:@"Slimming1" ofType:@"png"]];

            ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
            
            TwoInputFilter = [[GPUImageTwoInputFilter alloc]initWithVertexShaderFromString:currentSurfaceblurVertexShader fragmentShaderFromString:currentDressupAngleFragmentShader];
            [ImageSource1 addTarget:TwoInputFilter atTextureLocation:1];
            [ImageSource1 processImage];
            
            backImageSize=image1.size;
            [self setBackImageDevicePosition:-1 faceStickerInf:nil];

        self.initialFilters = [NSArray arrayWithObjects:TwoInputFilter,nil];
        self.terminalFilter = TwoInputFilter;
        
        return self;
    }
    
    NSString *currentSurfaceblurVertexShader = [self vertexShaderForDressup];
    NSString *currentSurfaceblurFragmentShader = [self  fragmentShaderForDressup];
    NSString *currentDressupAngleFragmentShader = [self  fragmentShaderForDressupAngle];
    if (faceSticker.stickerCount>0)
    {
        int inxUse=(indx%(faceSticker.faceStickerInf[0].count));///(4.0/3.0);
        if (inxUse==0) {
            inxUse=faceSticker.faceStickerInf[0].count;
        }
        if (inxUse>faceSticker.faceStickerInf[0].count)
        {
            inxUse=faceSticker.faceStickerInf[0].count;
        }
        
        NSString *str;
        if (inxUse<10) {
            str = [NSString stringWithFormat:@"%s0%d.png",faceSticker.faceStickerInf[0].imageName,inxUse];
        }
        else
        {
            str = [NSString stringWithFormat:@"%s%d.png",faceSticker.faceStickerInf[0].imageName,inxUse];
        }
        
        UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:str];
        ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
        
        
        TwoInputFilter = [[GPUImageTwoInputFilter alloc]initWithVertexShaderFromString:currentSurfaceblurVertexShader fragmentShaderFromString:currentDressupAngleFragmentShader];
        [ImageSource1 addTarget:TwoInputFilter atTextureLocation:1];
        [ImageSource1 processImage];
        
        backImageSize=image1.size;
        [self setBackImageDevicePosition:devModel faceStickerInf:&faceSticker.faceStickerInf[0]];
    }
    
    if (faceSticker.stickerBackCount>0)
    {
        int inxBackUse=(indx%(faceSticker.faceStickerBackInf[0].count));
        if (inxBackUse==0) {
            inxBackUse=faceSticker.faceStickerBackInf[0].count;
        }
        if (inxBackUse>faceSticker.faceStickerBackInf[0].count)
        {
            inxBackUse=faceSticker.faceStickerBackInf[0].count;
        }
        NSString *str;
        if (inxBackUse<10) {
            str = [NSString stringWithFormat:@"%s0%d.png",faceSticker.faceStickerBackInf[0].imageName,inxBackUse];
        }
        else
        {
            str = [NSString stringWithFormat:@"%s%d.png",faceSticker.faceStickerBackInf[0].imageName,inxBackUse];
        }
        
        //        ///////////TEST///////////
        //        NSString *strtmp2 = [NSString stringWithFormat:@"%@/%d",faceSticker.faceStickerBackInf[0].imageName,100];
        //
        //        NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
        //        str = [resBundle pathForResource:strtmp2 ofType:@"png"];
        //        ///////////TEST///////////
        
        UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:str];
        TwoInputFilter2 = [[GPUImageTwoInputFilter alloc]initWithVertexShaderFromString:currentSurfaceblurVertexShader fragmentShaderFromString:currentSurfaceblurFragmentShader];
        //[TwoInputFilter addTarget:TwoInputFilter2];
        backprop1=image2.size.width/image2.size.height;
        ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
        [TwoInputFilter addTarget:TwoInputFilter2 atTextureLocation:0];
        [ImageSource2 addTarget:TwoInputFilter2 atTextureLocation:1];
        [ImageSource2 processImage];
        CGFloat ftm=faceData.originWidth/faceData.originHeight*faceSticker.cutRect.size.width/faceSticker.cutRect.size.height;
        [self setBackImageProp2:ftm/backprop1 Rect:faceSticker.faceStickerBackInf[0].rect Filter:TwoInputFilter2];
    }

    
    if (faceSticker.stickerCount>0)
    {
        self.initialFilters = [NSArray arrayWithObjects:TwoInputFilter,nil];
        if (faceSticker.stickerBackCount>0) {
            self.terminalFilter = TwoInputFilter2;
        }
        else
        {
            self.terminalFilter = TwoInputFilter;
        }
    }
    else if (faceSticker.stickerBackCount>0)
    {
        self.initialFilters = [NSArray arrayWithObjects:TwoInputFilter2,nil];
        self.terminalFilter = TwoInputFilter2;
    }
    else
    {
        nil;
    }
    
    
    
    return self;
}

- (id)initIndexTmp:(int)indx;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    int ind1=indx%2;
    int ind2=indx%3;
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    UIImage *image1;
    if (ind1==0)
    {
        image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                                   pathForResource:@"Christmashat1" ofType:@"png"]];
    }
    else if (ind1==1)
    {
        image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                          pathForResource:@"Christmashat2" ofType:@"png"]];
    }

    NSAssert(image1,
             @"To use RCGPUImageTimeMachineFilter you need to add test2.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    NSString *currentSurfaceblurVertexShader = [self vertexShaderForDressup];
    NSString *currentSurfaceblurFragmentShader = [self  fragmentShaderForDressup];
    NSString *currentDressupAngleFragmentShader = [self  fragmentShaderForDressupAngle];
    TwoInputFilter = [[GPUImageTwoInputFilter alloc]initWithVertexShaderFromString:currentSurfaceblurVertexShader fragmentShaderFromString:currentDressupAngleFragmentShader];
    [ImageSource1 addTarget:TwoInputFilter atTextureLocation:1];
    [ImageSource1 processImage];
    
    
    UIImage *image2;
    
    if (ind2==0)
    {
        image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                          pathForResource:@"ChristmasBackground1" ofType:@"png"]];
    }
    else if (ind2==1)
    {
        image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                          pathForResource:@"ChristmasBackground2" ofType:@"png"]];
    }
    else if (ind2==2)
    {
        image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                          pathForResource:@"ChristmasBackground3" ofType:@"png"]];
    }
    NSAssert(image2,
             @"To use RCGPUImageTimeMachineFilter you need to add test2.png to your application bundle.");
    
     TwoInputFilter2 = [[GPUImageTwoInputFilter alloc]initWithVertexShaderFromString:currentSurfaceblurVertexShader fragmentShaderFromString:currentSurfaceblurFragmentShader];
    
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    [TwoInputFilter addTarget:TwoInputFilter2 atTextureLocation:0];
    [ImageSource2 addTarget:TwoInputFilter2 atTextureLocation:1];
    [ImageSource2 processImage];
    
    
    UIImage *image3;
    
    if (ind2==0)
    {
        image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                          pathForResource:@"ChristmasBackground4" ofType:@"png"]];
    }
    else if (ind2==1)
    {
        image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                          pathForResource:@"ChristmasBackground5" ofType:@"png"]];
    }
    else if (ind2==2)
    {
        image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                          pathForResource:@"ChristmasBackground6" ofType:@"png"]];
    }
    NSAssert(image3,
             @"To use RCGPUImageTimeMachineFilter you need to add test2.png to your application bundle.");
    
     TwoInputFilter3 = [[GPUImageTwoInputFilter alloc]initWithVertexShaderFromString:currentSurfaceblurVertexShader fragmentShaderFromString:currentSurfaceblurFragmentShader];
    
    ImageSource3 = [[GPUImagePicture alloc] initWithImage:image3];
    [TwoInputFilter2 addTarget:TwoInputFilter3 atTextureLocation:0];
    [ImageSource3 addTarget:TwoInputFilter3 atTextureLocation:1];
    [ImageSource3 processImage];

    backprop1=image2.size.width/image2.size.height;
    backprop2=image3.size.width/image3.size.height;
    [self setBackImageProp:faceData.originWidth/faceData.originHeight Model:1];
    [self setBackImageProp:faceData.originWidth/faceData.originHeight Model:2];
    
    backImageSize=image1.size;
    [self setBackImageDevicePosition:devModel faceStickerInf:&faceSticker.faceStickerInf[0]];

    self.initialFilters = [NSArray arrayWithObjects:TwoInputFilter,nil];
    self.terminalFilter = TwoInputFilter3;
    return self;
}
@end
