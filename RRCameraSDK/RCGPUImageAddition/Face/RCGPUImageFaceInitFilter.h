//
//  RCGPUImageFaceInitFilter.h
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/8/18.
//  Copyright (c) 2015年 renren. All rights reserved.
//

#import "GPUImageFilterGroup.h"


@interface RCGPUImageFaceInitFilter : GPUImageFilterGroup
{
    
}
- (id)initImg:(UIImage *)image Graythr:(int*)p_pgraythr FaceWidth:(int *)p_pfaceWidth GrayAve:(int *)grayAve FaceRect:(struct FACERECT*)faceRectForLift FaceParameter:(FaceParameters *)faceParameters;
@end
