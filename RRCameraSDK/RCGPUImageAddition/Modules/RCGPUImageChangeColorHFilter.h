//
//  RCGPUImageChangeColorHFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/6/29.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageChangeColorHFilter : GPUImageFilter
{
    GLint allImgHUniform;
    
    GLint redHUniform;
    GLint greenHUniform;
    GLint blueHUniform;
    
    GLint magentaHUniform;
    GLint cyanHUniform;
    GLint yellowHUniform;
}
@property(readwrite, nonatomic) CGFloat allImgH;

@property(readwrite, nonatomic) CGFloat redH;
@property(readwrite, nonatomic) CGFloat greenH;
@property(readwrite, nonatomic) CGFloat blueH;

@property(readwrite, nonatomic) CGFloat magentaH;
@property(readwrite, nonatomic) CGFloat cyanH;
@property(readwrite, nonatomic) CGFloat yellowH;

- (id)initAllImgH:(NSInteger)allImgH RedH:(NSInteger)redH GreenH:(NSInteger)greenH BlueH:(NSInteger)blueH CyanH:(NSInteger)cyanH MagentaH:(NSInteger)magentaH YellowH:(NSInteger)yellowH;
@end
