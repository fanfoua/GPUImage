//
//  RCGPUImageFaceAcneFilter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/9/15.
//  Copyright (c) 2015年 renren. All rights reserved.
//

#import "RCGPUImageFaceAcneFilter.h"
#include <opencv2/opencv.hpp>
#include <opencv2/imgcodecs/ios.h>

using namespace std;
using namespace cv;

const float aaa[] = {300,293.89,287.81,281.76,275.75,269.76,263.82,257.92,252.05,246.24,240.47,234.76,229.1,223.49,217.95,212.46,207.04,201.69,196.41,191.2,186.06,181,176.03,171.13,166.32,161.6,156.97,152.43,147.99,143.65,139.41,135.28,131.25,127.33,123.52,119.83,116.25,112.8,109.46,106.25,103.18,100.23,97.41,94.731,92.189,89.789,87.533,85.423,83.463,81.654,80,78.429,76.871,75.324,73.791,72.273,70.769,69.281,67.81,66.356,64.921,63.505,62.108,60.733,59.379,58.048,56.739,55.455,54.196,52.963,51.756,50.577,49.425,48.303,47.211,46.149,45.119,44.121,43.157,42.226,41.331,40.471,39.647,38.861,38.112,37.403,36.734,36.105,35.517,34.972,34.47,34.012,33.599,33.231,32.909,32.635,32.408,32.231,32.103,32.026,32};

cv::Mat getFacialMaskAuto(cv::Mat & img, vector<cv::Point>&shapes)     //得到五官的模型
{
    
    vector<cv::Point> leftEyebrow(shapes.begin(),shapes.begin()+2);
    vector<cv::Point> rightEyebrow(shapes.begin()+2,shapes.begin()+4);
    
    
    vector<cv::Point> nose(shapes.begin()+4,shapes.begin()+8);
    
    vector<cv::Point> leftEye(shapes.begin()+8,shapes.begin()+12);
    vector<cv::Point> rightEye(shapes.begin()+12,shapes.begin()+16);
    
    vector<cv::Point> month(shapes.begin()+16,shapes.begin()+20);
    
    
    vector<vector<cv::Point> > contours;
    
    contours.push_back(leftEyebrow);
    contours.push_back(rightEyebrow);
    contours.push_back(nose);
    contours.push_back(leftEye);
    contours.push_back(rightEye);
    contours.push_back(month);
    
    cv::Mat result = cv::Mat::zeros(img.size(),CV_8UC1);
    
    
    drawContours(result,contours,-1,Scalar(255),CV_FILLED);
    
    
    // 自适应扩大人脸
    int sc =(rightEye[0].x+rightEye[1].x+rightEye[2].x+rightEye[3].x)/4 - (leftEye[0].x+leftEye[1].x+leftEye[2].x+leftEye[3].x)/4;
    
    sc = max(sc/12,11);
    
    dilate(result,result,cv::Mat::ones(sc,sc,CV_8UC1));
    return result;
    
};

cv::Mat getMaskAuto(cv::Mat & org)
{
    
    cv::Mat gray,mask,ycrcb;
    
    cvtColor(org,ycrcb,CV_BGR2YCrCb);
    cvtColor(org,gray,CV_BGR2GRAY);
    
    
    cv::Mat sp1[3];
    split(ycrcb,sp1);
    
    cv::Mat maskSkin(org.size(),CV_8UC1);
    
    for (int i=0;i<org.rows;i++)
    {
        uchar * ptcr = sp1[1].ptr<uchar>(i);
        uchar * ptcb = sp1[2].ptr<uchar>(i);
        uchar * ptshin = maskSkin.ptr<uchar>(i);
        for (int j=0;j<org.cols;j++)
        {
            if (ptcr[j]>=133&&ptcr[j]<=173&&ptcb[j]>=77&&ptcb[j]<=127)
            {
                ptshin[j] = 255;
            }
            else
                ptshin[j] =0;
        }
    }
    
    morphologyEx(maskSkin,maskSkin,MORPH_CLOSE,cv::Mat::ones(5,5,CV_8UC1));
    erode(maskSkin,maskSkin,cv::Mat::ones(5,5,CV_8UC1));
    
    cv::Mat gauss5;
    cv::Mat gauss7;
    
    //GaussianBlur(org,gauss5,Size(5,5),2);
    //GaussianBlur(org,gauss7,Size(7,7),2);
    
    GaussianBlur(org,gauss5,cv::Size(5,5),2);
    GaussianBlur(org,gauss7,cv::Size(7,7),2);
    
    cv::Mat map = abs(org-gauss5)+abs(org-gauss7);
    
    
    
    // test for mean light
    cv::Mat sp[3];
    split(map,sp);
    
    Scalar avg,std;
    
    meanStdDev(map,avg,std,maskSkin);
    
    threshold(sp[0],sp[0],avg[0]+3*std[0],255,CV_THRESH_BINARY);
    threshold(sp[1],sp[1],avg[1]+3*std[1],255,CV_THRESH_BINARY);
    threshold(sp[2],sp[2],avg[2]+3*std[2],255,CV_THRESH_BINARY);
    
    mask = max(max(sp[0],sp[1]),sp[2]);
    
    return mask;
};

cv::Mat getSkinRegion(cv::Mat org,float area)
{
    cv::Mat dst = cv::Mat::zeros(org.size(),CV_8UC1);
    cv::Mat re =  cv::Mat::zeros(org.size(),CV_8UC1);
    
    
    uchar R,G,B;
    for(int i = 0;i<org.rows;i++){
        uchar* prgb = org.ptr<uchar>(i);
        uchar* pdst = dst.ptr<uchar>(i);
        for(int j=0;j<org.cols;j++){
            R = prgb[3*j+2];
            G = prgb[3*j+1];
            B = prgb[3*j];
            
            if((R>95 && G>40 && B>20 && R-B>15 && R-G>15)||(R>200 && G>210 && B>170 && abs(R-B)<=15 && R>B && G>B))
                pdst[j] = 0;
            else
                pdst[j] = 255;
            
        }
    }
    
    vector<vector<cv::Point> > contours;
    findContours(dst,contours,CV_RETR_CCOMP,CV_CHAIN_APPROX_NONE);
    
    vector<vector<cv::Point> >::iterator itc= contours.begin();
    
    while (itc!=contours.end())
    {
        if (contourArea(*itc)<area)
        {
            itc = contours.erase(itc);
            continue;
        }
        else
            itc++;
        
    }
    
    drawContours(re,contours,-1,Scalar(255),CV_FILLED);
    
    dilate(re,re,cv::Mat::ones(5,5,CV_8UC1));
    
    return 255-re;
    //	return Mat(re.size(),CV_8UC1,Scalar(255))-re;
}

//cv::Mat removeLargeComp(cv::Mat &mask,float area)
//{
//    if(countNonZero(mask)<=0)
//        return mask;
//    
//    vector<vector<cv::Point> > contours;
//    vector<vector<cv::Point> > contour_small;
//    vector<Vec4i> hierarchy;
//    
//    findContours(mask,contours,hierarchy,CV_RETR_EXTERNAL|CV_RETR_CCOMP,CV_CHAIN_APPROX_NONE);
//    
//    
//    int idx =0;
//    for( ; idx >= 0; idx = hierarchy[idx][0] ) //herarchy[idx][0]当前轮廓的下一个外部轮廓
//    {
//        const vector<cv::Point>& c = contours[idx];
//        RotatedRect rect = minAreaRect(c);
//        float s = (float)rect.size.height/rect.size.width;
//        
//        double iarea = fabs(contourArea(cv::Mat(c)));
//        
//        if( iarea < area && (s<2.5 && s >0.4))
//        {
//            contour_small.push_back(c);
//        }
//    }
//    
//    cv::Mat re = cv::Mat::zeros(mask.size(),mask.type());
//    
//    drawContours(re,contour_small,-1,Scalar(255),CV_FILLED);
//    
//    return re;
//    
//}

Mat getFacialMaskAuto(Mat & img, vector<cv::Point>&shapes,cv::Rect &rect)     // 由shape 获取人脸轮廓
{
    int scale = max((shapes[18].x+shapes[20].x)/2-(shapes[14].x+shapes[16].x)/2,10);  //两眼的距离
    
    Mat result = Mat::zeros(img.size(),CV_8UC1);
    
    
    vector<cv::Point> ext(shapes.begin(),shapes.begin()+5); // 1 5 9 13 17
    
    cv::Point x1(shapes[14].x,max(shapes[14].y - (int)(0.8*scale),0)); //左上延
    cv::Point x2(shapes[20].x,max(shapes[20].y - (int)(0.8*scale),0));  //右上延
    
    ext.push_back(x2);
    ext.push_back(x1);
    
    rect = boundingRect(ext);  //轮廓的外接矩形
    
    vector<cv::Point> leftEyebrow(shapes.begin()+5,shapes.begin()+8); // 18，20，22
    vector<cv::Point> rightEyebrow(shapes.begin()+8,shapes.begin()+11); //23 25 27
    
    
    vector<cv::Point> nose(shapes.begin()+11,shapes.begin()+14);  // 31 32 36
    
    
    vector<cv::Point> leftEye(shapes.begin()+14,shapes.begin()+18);  //37 39 40 42
    vector<cv::Point> rightEye(shapes.begin()+19,shapes.begin()+22);  // 43 44 46 47
    rightEye[0].x -= scale/8;                                 //修正右眼左边容易去除  9/22

    vector<cv::Point> month(shapes.begin()+22,shapes.begin()+26);         // 49 52 55 58
    
    // 先画外围轮廓
    vector<vector<cv::Point> > contours;
    contours.push_back(ext);
    drawContours(result,contours,-1,Scalar(255),CV_FILLED);
    contours.clear();
    
    // 膨胀一圈
    int sc = max(scale/12,11);
    dilate(result,result,Mat::ones(sc,sc,CV_8UC1));
    
    contours.push_back(leftEyebrow);
    contours.push_back(rightEyebrow);
    contours.push_back(nose);
    contours.push_back(leftEye);
    contours.push_back(rightEye);
    contours.push_back(month);
    
    drawContours(result,contours,-1,Scalar(0),CV_FILLED);
    
    // 为眼睛换一个椭圆
    RotatedRect leftRect = minAreaRect(leftEye);
    RotatedRect rightRect = minAreaRect(rightEye);
    //	RotatedRect mouseRect = minAreaRect(month);
    ellipse(result,leftRect,Scalar(0),scale/8,-1);
    ellipse(result,rightRect,Scalar(0),scale/8,-1);
    //	ellipse(result,mouseRect,Scalar(0),5,-1);
    
    sc = max(scale/12,11);
    
    erode(result,result,Mat::ones(sc,sc,CV_8UC1));      // 黑色区域扩大一圈
    
    return result;
};



Mat removeLargeComp(Mat &mask,float area)
{
    if(countNonZero(mask)<=0)
        return mask;
    
    vector<vector<cv::Point> > contours;
    vector<vector<cv::Point> > contour_small;
    vector<Vec4i> hierarchy;
    
    findContours(mask,contours,hierarchy,CV_RETR_EXTERNAL|CV_RETR_CCOMP,CV_CHAIN_APPROX_NONE);
    
    
    int idx =0;
    for( ; idx >= 0; idx = hierarchy[idx][0] ) //herarchy[idx][0]��ǰ��������һ���ⲿ����
    {
        const vector<cv::Point>& c = contours[idx];
        RotatedRect rect = minAreaRect(c);
        float s = (float)rect.size.height/rect.size.width;
        
        double iarea = fabs(contourArea(Mat(c)));
        
        if( iarea < area && (s<2.5 && s >0.4))
        {
            contour_small.push_back(c);
        }
    }
    
    Mat re = Mat::zeros(mask.size(),mask.type());
    
    drawContours(re,contour_small,-1,Scalar(255),CV_FILLED);
    
    return re;
    
}

UIImage* AutomaticAcne(UIImage *uiimg,FacePointData *facedtm,float param)
{
    int len=facedtm->poiCount*2;
    
    cv::Mat img;
    UIImageToMat(uiimg, img);
    
    cvtColor(img,img,CV_RGBA2BGR);

    vector<cv::Point> shapes;
    for(int i=0;i<len/2;i++)
        shapes.push_back(cv::Point(facedtm->poi[0][i][0],facedtm->poi[0][i][1]));
    
//    cv::Mat facialMask = getFacialMaskAuto(img,shapes);
//    
//    cv::Rect rect(shapes[0].x,shapes[0].y,shapes[3].x - shapes[0].x,shapes[19].y - shapes[0].y);
//    
//    rect.x = max(rect.x - rect.width/3,1);
//    rect.y = max(rect.y - rect.height/2,1);
//    rect.width = min((int)(rect.width*5/3),img.cols - rect.x-1);
//    rect.height=min((int)(rect.height*7/4),img.rows - rect.y -1);
//    
//    float area = (rect.width/40.0)*(rect.height/40.0);
//
//    cv::Mat faceSkinMask  = getSkinRegion(img(rect),area*1.5);
//
//    cv::Mat imgskin = cv::Mat::zeros(img.size(),CV_8UC1);
//    faceSkinMask.copyTo(imgskin(rect));
//    imgskin = max(imgskin - facialMask,0);
//
//    cv::Mat org =img(rect);
//    
//    cv::Mat gauss3,gauss7, gauss9;
//    GaussianBlur(org,gauss3,cv::Size(3,3),2);
//    GaussianBlur(org,gauss7,cv::Size(7,7),2);
//    GaussianBlur(org,gauss9,cv::Size(9,9),2);
//    
//    cv::Mat map = abs(gauss3-gauss9)+abs(gauss3-gauss7);
//    
//    cv::Mat sp[3];
//    split(map,sp);
//    
//    cv::Scalar avg,std;
//    
//    meanStdDev(map,avg,std,faceSkinMask);
//    
//    threshold(sp[0],sp[0],avg[0]+2.5*std[0],255,CV_THRESH_BINARY);
//    threshold(sp[1],sp[1],avg[1]+2.5*std[1],255,CV_THRESH_BINARY);
//    threshold(sp[2],sp[2],avg[2]+2.5*std[2],255,CV_THRESH_BINARY);
//    
//    cv::Mat faceDouMask = max(max(sp[0],sp[1]),sp[2]);
//    
//    medianBlur(faceDouMask,faceDouMask,3);        // 中值滤波
//
//    cv::Mat imgDou = cv::Mat::zeros(img.size(),CV_8UC1);
//    
//    faceDouMask.copyTo(imgDou(rect));
//    
//    imgDou = imgskin.mul(imgDou);
//    
//    cv::Mat douMaskFinal  = removeLargeComp(imgDou,area);
//    
//    dilate(douMaskFinal,douMaskFinal,cv::Mat::ones(5,5,CV_8UC1));
//
//    cv::Mat outImg;
//    inpaint(img,douMaskFinal,outImg,5,INPAINT_TELEA);
    
    cv::Rect rect;
    Mat facialMask = getFacialMaskAuto(img,shapes,rect);
    
    rect = rect & cv::Rect(1,1,img.cols-1,img.rows-1);
    
    Mat org =img(rect);

    Mat gauss7;
    GaussianBlur(org,gauss7,cv::Size(7,7),2);
    
    
    //		Mat map = abs(gauss3-gauss9)+abs(gauss3-gauss7);
    Mat map = abs(org - gauss7);
    
    
    Mat sp[3];
    split(map,sp);
    
    Scalar avg,std;
    
    meanStdDev(map,avg,std,facialMask(rect));
    
    threshold(sp[0],sp[0],avg[0]+2.5*std[0],255,CV_THRESH_BINARY);
    threshold(sp[1],sp[1],avg[1]+2.5*std[1],255,CV_THRESH_BINARY);
    threshold(sp[2],sp[2],avg[2]+2.5*std[2],255,CV_THRESH_BINARY);
    
    Mat faceDouMask = max(max(sp[0],sp[1]),sp[2]);
    
    medianBlur(faceDouMask,faceDouMask,3);        // 中值滤波 去除孤立点
    
    
    faceDouMask = faceDouMask.mul(facialMask(rect));
    
    //		imwrite("/storage/sdcard0/model/faceDouMask.jpg",faceDouMask);
    
    //float range = 300-260*param;//60-40*param;
    float range = aaa[(int)(param/0.01)];
    float area = (rect.width/range)*(rect.height/range);
    
    Mat douMaskFinal  = removeLargeComp(faceDouMask,area);
    dilate(douMaskFinal,douMaskFinal,Mat::ones(5,5,CV_8UC1));
    
    inpaint(org,douMaskFinal,org,5,INPAINT_TELEA);
    org.copyTo(img(rect));
    
    cvtColor(img,img,CV_BGR2RGBA);
    
    UIImage *resultimg;
    resultimg=MatToUIImage(img);

    return resultimg;
}

UIImage* ManualAcne(UIImage *uiimg,int x, int y, float radius)
{
    
    CGImageRef imgRef=[uiimg CGImage];
    CGSize sizeReal = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    int w = sizeReal.width;
    int h = sizeReal.height;
    
    float rtmp=radius*0.025*w;
    cv::Mat img;
    UIImageToMat(uiimg, img);
    
    cvtColor(img,img,CV_RGBA2BGR);
    

    cv::Mat mask = cv::Mat::zeros(h,w,CV_8UC1);
    circle(mask,cv::Point(x,y),rtmp+1,Scalar(255),-1);
    
    cv::Mat outImg;
    
    int sc = min(w,h)/100;
    sc = min(5,sc);
    
    cv::inpaint(img,mask,outImg,sc,INPAINT_TELEA);
    
    cvtColor(outImg,outImg,CV_BGR2RGBA);
    
    UIImage *resultimg;
    resultimg=MatToUIImage(outImg);
    
    return resultimg;
}
