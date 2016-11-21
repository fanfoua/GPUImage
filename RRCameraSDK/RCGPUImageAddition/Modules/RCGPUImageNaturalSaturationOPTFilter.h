//
//  RCGPUImageNaturalSaturationOPTMainFilter.h
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/10/19.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageNaturalSaturationOPTFilter : GPUImageFilterGroup
{
    GPUImagePicture *ImageSource1;
}
- (id)initIratio:(int)iratio;
@end
