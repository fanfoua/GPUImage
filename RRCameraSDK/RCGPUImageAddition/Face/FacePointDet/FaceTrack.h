//
//  FaceTrack.h
//  Renren-iOS-StickerCamera
//
//  Created by 0153-00503 on 16/2/1.
//  Copyright © 2016年 renren. All rights reserved.
//

#ifndef FaceTrack_h
#define FaceTrack_h
#include <opencv2/opencv.hpp>
#include "Nativeclass.h"
using namespace std;
cv::Mat faceTracking(unsigned char *buf, unsigned char *buftmp, int index, int w, int h, int widthStep, int rotationType, vector<cv::Rect2f> &facesRe);

#endif /* FaceTrack_h */
