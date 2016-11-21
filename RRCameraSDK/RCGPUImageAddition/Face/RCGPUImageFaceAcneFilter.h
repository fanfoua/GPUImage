//
//  RCGPUImageFaceAcneFilter.h
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/9/15.
//  Copyright (c) 2015年 renren. All rights reserved.
//

//#import <GPUImage/GPUImage.h>
//#import "RCFaceHistStatisticsFilter.h"
#import "Nativeclass.h"

UIImage* AutomaticAcne(UIImage *uiimg,FacePointData *facedtm,float param);

UIImage* ManualAcne(UIImage *uiimg,int x, int y, float radius);