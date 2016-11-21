//
//  main.cpp
//  TestProject
//
//  Created by 0153-00503 on 15/12/21.
//  Copyright © 2015年 0153-00503. All rights reserved.
//

//#include <iostream>
//
//int main(int argc, const char * argv[]) {
//    // insert code here...
//    std::cout << "Hello, World!\n";
//    return 0;
//}
/************************************************************************
 * Copyright(c) 2011  Yang Xian
 * All rights reserved.
 *
 * File:	opticalFlow.cpp
 * Brief: lk光流法做运动目标检测
 * Version: 1.0
 * Author: Yang Xian
 * Email: xyang2011@sinano.ac.cn
 * Date:	2011/11/18
 * History:
 ************************************************************************/
#include <opencv2/video.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/core.hpp>
#include <opencv2/opencv.hpp>
#include "Nativeclass.h"
#include <iostream>
#include <cstdio>
#include "FaceTrack.h"
#include <opencv2/imgcodecs/ios.h>

using namespace std;
using namespace cv;
cv::Mat* FacePointPredictData(unsigned char *imgbuf, std::vector<cv::Rect>&facesRes, int w, int h, int widthStep, int rotationType);

char window_name[50] = "optical flow tracking";
Mat gray;	// 当前图片
Mat gray_prev;	// 预测图片
vector<Point2f> pointsT[2];	// point0为特征点的原来位置，point1为特征点的新位置
vector<Point2f> pointsFir;	// point0为特征点的原来位置，point1为特征点的新位置
vector<Point2f> pointsFirStl;
vector<Point2f> pointsRes;
//int maxCount = 500;	// 检测的最大特征数
//double qLevel = 0.01;	// 特征检测的等级
//double minDist = 10.0;	// 两特征点之间的最小距离
vector<uchar> status;	// 跟踪特征的状态，特征的流发现为1，否则为0
vector<float> err;
Rect2f ret[2];
int g_Index=0;
CascadeClassifier face_cascadeTmp;
bool ga_pointIsUse[80];

//int main(int argc, const char * argv[])
//{
//    cv::Mat frame;
//    cv::Mat result;
//    
//    // 	CvCapture* capture = cvCaptureFromCAM( -1 );	// 摄像头读取文件开关
//    VideoCapture capture(0);//("D:\\code\\OpticalFlow\\Debug\\bike.avi");
//    
//    
//    string face_cascade_name = "/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt.xml";
//    if( !face_cascadeTmp.load( face_cascade_name) ){ printf("--(!)Error loading face_cascade\n");  };
//    
//    FacePointInit();
//    if(capture.isOpened()/*capture*/)	// 摄像头读取文件开关
//    {
//        capture.set(CV_CAP_PROP_FRAME_WIDTH, 640);
//        capture.set(CV_CAP_PROP_FRAME_HEIGHT, 480);
//        
//        int index=0;
//        while(true)
//        {
//            // 			frame = cvQueryFrame( capture );	// 摄像头读取文件开关
//            capture >> frame;
//            
//            if(!frame.empty())
//            {
////                double t = (double)cvGetTickCount();
//                ////代码段
//
//                tracking(frame, result, index);
//                
////                t = (double)cvGetTickCount() - t;
////                printf( "exec time = %gms\n", t/(cvGetTickFrequency()*1000) );
//                
//                index++;
//                //imshow("test", frame);
//            }
//            else
//            {
//                printf(" --(!) No captured frame -- Break!");
//                break;
//            }
//            
////            //int c = waitKey(100);
////            if( (char)c == 27 )
////            {
////                break;
////            }
//        }
//    }
//    return 0;
//}

Mat_<float> My_estimateNonflecTransformTmp( vector<Point2f> &APoints, vector<Point2f> &BPoints ){
    Mat_<float> D, tmp, alpha, Y, affine;
    
    D.create( APoints.size()*2, 4 );
    Y.create( APoints.size()*2, 1 );
    for (int i = 0;i < APoints.size();++i) {
        D(i*2, 0) = APoints[i].x; D(i*2, 1) = APoints[i].y; D(i*2, 2) = 1; D(i*2, 3) = 0;
        D(i*2+1, 0) = APoints[i].y; D(i*2+1, 1) = -APoints[i].x; D(i*2+1, 2) = 0; D(i*2+1, 3) = 1;
        Y(i*2, 0) = BPoints[i].x;
        Y(i*2+1, 0) = BPoints[i].y;
    }
    tmp = D.t()*D;
    alpha = tmp.inv()*D.t()*Y;
    
    affine.create( 2, 3 );
    affine(0, 0) = alpha(0, 0); affine(0,1) = alpha(1, 0); affine(0, 2) = alpha(2, 0);
    affine(1, 0) = -alpha(1, 0); affine(1, 1) = alpha(0,0); affine(1, 2) = alpha(3, 0);
    
    return affine;
    
}

Mat_<float> Transform_PointsTmp( Mat_<float> &affine, vector<Point2f> &a ) {
    Mat_<float> tmp, result;
    
    //	show_mat( affine, "affine");
    //	show_mat( a, "a");
    tmp.create(3, a.size());
    for (int i = 0;i < a.size();++i){
        tmp(0, i) = a[i].x;
        tmp(1, i) = a[i].y;
        tmp(2, i) = 1;
    }
    result = affine * tmp;
    return result.t();
}

void MatToPointVector(Mat_<float>  mat, vector<Point2f>& pointVector)
{
    Point2f point2f;
    pointVector.clear();
    for (int i=0; i<mat.rows; i++) {
        point2f.x=mat(i,0);
        point2f.y=mat(i,1);
        pointVector.push_back(point2f);
    }
    
}

//////////////////////////////////////////////////////////////////////////
// function: tracking
// brief: 跟踪
// parameter: frame	输入的视频帧
//			  output 有跟踪结果的视频帧
// return: void
//////////////////////////////////////////////////////////////////////////

void DetFacePoint(unsigned char* buf, vector<cv::Rect2f>& facesf, vector<Point2f>& pointF, int w, int h, int widthStep, int rotationType)
{
    memset(ret, 0, sizeof(ret));
    vector<cv::Rect> faces;
//    face_cascadeTmp.detectMultiScale(frame, faces, 1.4, 2, 0,  cv::Size(30, 30)  );
//    if (faces.size()<=0) {
//        return;
//    }

//    if (faces.size()>0)
    {
        

        faces.clear();
        Mat *re= FacePointPredictData(buf,faces,w,h,widthStep,rotationType);
        if (faces.size()<=0) {
            return;
        }
        Rect2f roi=cv::Rect(faces[0].x, faces[0].y, faces[0].width, faces[0].height);
        ret[0]=roi;
        facesf.clear();
        facesf.insert(facesf.end(),   faces.begin(),   faces.end()   );
        
        pointsFirStl.clear();
        
        int counthalf=re[0].rows/2;
        for (int i=0; i<counthalf; i++)
        {
//            int ntmp=re[0].at<int>(i*2);
//            re[0].at<int>(i*2)=re[0].at<int>(i*2+1);
//            re[0].at<int>(i*2+1)=ntmp;
            
            Point2f poit;
            poit.x=(float)re[0].at<int>(i*2);
            poit.y=(float)re[0].at<int>(i*2+1);
            pointsFirStl.push_back(poit);
        }

        if (re[0].rows>0)
        {
            //干掉周围的关键点
            for (int df=42;df<re[0].rows-2;df++)//21
            {
                re[0].at<int>(df)=re[0].at<int>(df+2);
            }
            
            for (int df=40;df<re[0].rows-2;df++)//20
            {
                re[0].at<int>(df)=re[0].at<int>(df+2);
            }
            
            for (int df=34;df<re[0].rows-2;df++)//17
            {
                re[0].at<int>(df)=re[0].at<int>(df+2);
            }
            
            for (int df=28;df<re[0].rows-2;df++)//14
            {
                re[0].at<int>(df)=re[0].at<int>(df+2);
            }
            
            for (int df=20;df<re[0].rows-2;df++)//10
            {
                re[0].at<int>(df)=re[0].at<int>(df+2);
            }
            
            for (int df=10;df<re[0].rows-2;df++)//5
            {
                re[0].at<int>(df)=re[0].at<int>(df+2);
            }
            
            for (int df=0;df<re[0].rows-10;df++)//0、1、2、3、4
            {
                re[0].at<int>(df)=re[0].at<int>(df+10);
            }
            re[0].pop_back(24);
            pointF.clear();
            for(int df=0;df<re[0].rows;df+=2)
            {
                Point2f tesf;
                tesf.x=re[0].at<int>(df);
                tesf.y=re[0].at<int>(df+1);
                pointF.push_back(tesf);
            }
            
        }
    }
}

cv::Mat faceTracking(unsigned char *buf, unsigned char *buftmp, int index, int w, int h, int widthStep, int rotationType, vector<cv::Rect2f> &facesRe)
{
    unsigned char *bufus=(unsigned char *)malloc(widthStep*h);
    memcpy(bufus, buf, widthStep*h);
    cv::Mat frame(h, w, CV_8UC1, bufus);
    //cv::Mat frame(h,w,CV_8UC1,)
    bool isevennum=true;//索引是否为偶数
    if (index%2==0)
    {
        isevennum=true;
    }
    else
    {
        isevennum=false;
    }
    
    if (isevennum) {
        //frame.copyTo(gray);
        delete[] gray.data;
        gray.release();
        gray=frame;
    }
    else
    {
        delete[] gray_prev.data;
        gray_prev.release();
        gray_prev=frame;
        //frame.copyTo(gray_prev);
    }
    
    
    if (g_Index>=50)//20
    {
        g_Index=0;
    }
    static vector<cv::Rect2f> faces;
    if (g_Index==0)
    {

        vector<cv::Rect2f> facesMid;
#ifdef TEST_TIME
        double t = (double)cvGetTickCount();
        ////代码段
#endif
        DetFacePoint(bufus, facesMid, pointsT[0],w,h,widthStep,rotationType);
#ifdef TEST_TIME
        t = (double)cvGetTickCount() - t;
        printf( "人脸检测＋关键点定位1：%gms\n", t/(cvGetTickFrequency()*1000) );
#endif
        if (facesMid.size()>0) {
            faces.clear();
            faces.insert(faces.end(), facesMid.begin(),facesMid.end());
            
//            cv::Rect facetmp;
//            facetmp.x=faces[0].x+faces[0].width*0.2;
//            facetmp.y=faces[0].y+faces[0].height*0.2;
//            facetmp.width=faces[0].width*0.6;
//            facetmp.height=faces[0].height*0.6;
//            std::vector<cv::Point2f> poi;
//            facetmp=facetmp&cv::Rect(0,0,frame.cols,frame.rows);
//            cv::goodFeaturesToTrack(frame(facetmp), poi, 15, 0.02, 15);
//            for (int i=0; i<poi.size(); i++) {
//                poi[i].x+=facetmp.x;
//                poi[i].y+=facetmp.y;
//                pointsT[0].push_back(poi[i]);
//            }
        }
        
        if(facesMid.size()>0)
        {
            for (int i=0; i<80; i++)
            {
                if ((i>=0&&i<=5)||i==10||i==14||i==17||i==20||i==21)
                {
                    ga_pointIsUse[i]=false;
                }
                else
                {
                    ga_pointIsUse[i]=true;
                }
            }
            //if (pointsFir.size()==0)
            {
                pointsFir.clear();
                pointsFir.insert(pointsFir.end(),   pointsT[0].begin(),   pointsT[0].end()   );
                
                pointsT[1].clear();
                pointsT[1].insert(pointsT[1].end(),   pointsT[0].begin(),   pointsT[0].end()   );
            }

            //pointsFirStl.clear();
//            if (pointsFirStl.size()==0) {
//                pointsFirStl.insert(pointsFirStl.end(), pointsFir.begin(),pointsFir.end());
//            }
            
        }
        else
        {
//            pointsT[0].clear();
//            pointsT[1].clear();
        }
    }
        
        
        if (faces.size()>0&&pointsT[0].size()>0&&g_Index!=0)
        {
            if (gray_prev.empty())
            {
                delete [] gray_prev.data;
                gray_prev.release();
                gray_prev=frame;
                //frame.copyTo(gray_prev);
                //cv::cvtColor(frame, gray_prev, CV_BGR2GRAY);
            }
            
            if (gray.empty())
            {
                delete [] gray.data;
                gray.release();
                gray=frame;
                //frame.copyTo(gray);
                //cv::cvtColor(frame, gray, CV_BGR2GRAY);
            }
            
            cv::Size winSize = cv::Size(21,21);
            int maxLevel=3;
            if (!(g_Index==0&&faces.size()>0))
            {
#ifdef TEST_TIME
                double t = (double)cvGetTickCount();
                ////代码段
#endif
                if (isevennum) {
                    calcOpticalFlowPyrLK(gray_prev, gray, pointsT[0], pointsT[1], status, err, winSize,maxLevel);
                }
                else
                {
                    calcOpticalFlowPyrLK(gray, gray_prev, pointsT[0], pointsT[1], status, err, winSize,maxLevel);
                }
#ifdef TEST_TIME
                t = (double)cvGetTickCount() - t;
                printf( "光流：%gms\n", t/(cvGetTickFrequency()*1000) );
#endif
            }
            
            Mat_<float> transMatrix=My_estimateNonflecTransformTmp(pointsFir,pointsT[1]);
            Mat_<float> transRes = Transform_PointsTmp(transMatrix,pointsFir);
            
//            Mat_<float> transResStl = Transform_PointsTmp(transMatrix,pointsFirStl);
            
            vector<Point2f>::iterator it = pointsT[1].begin();
            vector<Point2f>::iterator itFir = pointsFir.begin();
            int counttmp=(int)pointsT[0].size();
            int j=0;
            for (int i=0; i<counttmp; i++)
            {
                float tmpx= transRes(i,0)-pointsT[1][j].x;
                float tmpy= transRes(i,1)-pointsT[1][j].y;
                float len=sqrt(tmpx*tmpx+tmpy*tmpy);
                if (len>faces[0].width*0.1)
                {
                    //ga_pointIsUse[i]=false;
                    pointsT[1].erase(it);
                    pointsFir.erase(itFir);
                    j--;
                    
                    int tmpcount=0;
                    for (int j=0; j<80; j++) {
                        if (ga_pointIsUse[i]==true) {
//                            if ((i>=0&&i<=5)||i==10||i==14||i==17||i==20||i==21) {
//                                ga_pointIsUse[i]=false;
//                                continue;
//                            }
                            if (tmpcount==i) {
                                ga_pointIsUse[i]=false;
                                break;
                            }
                            tmpcount++;
                            
                        }
                        
                    }
                }
                else
                {
                    it++;
                    itFir++;
                }
                
                j++;
            }
            
            Mat_<float> transMatrix2=My_estimateNonflecTransformTmp(pointsFir,pointsT[1]);
//            Mat_<float> transRes = Transform_PointsTmp(transMatrix,pointsFir);
            
            Mat_<float> transResStl = Transform_PointsTmp(transMatrix2,pointsFirStl);
            MatToPointVector(transResStl,pointsRes);
        }
    
    if ((pointsT[1].size()<10||faces.size()<=0)&&g_Index!=0) {
//        pointsT[0].clear();
//        pointsT[1].clear();
        faces.clear();
#ifdef TEST_TIME
        double t = (double)cvGetTickCount();
        ////代码段
#endif
        DetFacePoint(buf, faces, pointsT[1],w,h,widthStep,rotationType);
#ifdef TEST_TIME
        t = (double)cvGetTickCount() - t;
        printf( "人脸检测＋关键点定位2：%gms\n", t/(cvGetTickFrequency()*1000) );
#endif

        if (pointsT[1].size()<=0)
        {
            faces.clear();
        }
        if (faces.size()<=0) {
            pointsT[0].clear();
            pointsT[1].clear();
            pointsRes.clear();
            pointsFir.clear();
//            pointsFir.clear();
//            pointsFirStl.clear();
        }
        else
        {
//            cv::Rect facetmp;
//            facetmp.x=faces[0].x+faces[0].width*0.2;
//            facetmp.y=faces[0].y+faces[0].height*0.2;
//            facetmp.width=faces[0].width*0.6;
//            facetmp.height=faces[0].height*0.6;
//            std::vector<cv::Point2f> poi;
//            facetmp=facetmp&cv::Rect(0,0,frame.cols,frame.rows);
//            
//            cv::goodFeaturesToTrack(frame(facetmp), poi, 15, 0.02, 15);
//            for (int i=0; i<poi.size(); i++)
//            {
//                poi[i].x+=facetmp.x;
//                poi[i].y+=facetmp.y;
//                pointsT[1].push_back(poi[i]);
//            }
            
            for (int i=0; i<80; i++)
            {
                if ((i>=0&&i<=5)||i==10||i==14||i==17||i==20||i==21)
                {
                    ga_pointIsUse[i]=false;
                }
                else
                {
                    ga_pointIsUse[i]=true;
                }
            }
            pointsFir.clear();
            pointsFir.insert(pointsFir.end(),   pointsT[1].begin(),   pointsT[1].end()   );
            
//            if (pointsFirStl.size()==0) {
//                pointsFirStl.insert(pointsFirStl.end(), pointsFir.begin(),pointsFir.end());
//            }
        }
        g_Index=-1;
    }
    
    
//    if (pointsT[1].size()>0)
//    {
//        for (int i=0; i<pointsT[1].size(); i++)
//        {
//            int tmpcount=0;
//            for (int j=0; j<pointsRes.size(); j++)
//            {
//                if (ga_pointIsUse[i]==true)
//                {
//                    if (i==tmpcount)
//                    {
//                        pointsRes[i]=pointsT[1][tmpcount];
//                    }
//                    tmpcount++;
//                }
//            }
//        }
//    }
    
//    if (isevennum) {
//        frame.copyTo(gray_prev);
//        //gray_prev=frame;
//        //cv::cvtColor(frame, gray_prev, CV_BGR2GRAY);
//    }
//    else
//    {
//        frame.copyTo(gray);
//        //gray=frame;
//        //cv::cvtColor(frame, gray, CV_BGR2GRAY);
//    }
    
//    Mat output;
//    frame.copyTo(output);
//    
//    for (size_t i=0; i<pointsRes.size(); i++)
//    {
//        //line(output, initial[i], pointsT[1][i], Scalar(0, 0, 255));
//        circle(output, pointsRes[i], 1, Scalar(255), -1);
//        
//        //circle(output, pointsFirStl[i], 3, Scalar(255, 255, 0), -1);
//        //rectangle(output,ret[0],Scalar(255, 0, 0));
//    }
//    
////    for (size_t i=0; i<pointsT[1].size(); i++)
////    {
////        //line(output, initial[i], pointsT[1][i], Scalar(0, 0, 255));
////        circle(output, pointsT[1][i], 1, Scalar(255), -1);
////        
////        //circle(output, pointsFirStl[i], 3, Scalar(255, 255, 0), -1);
////        //rectangle(output,ret[0],Scalar(255, 0, 0));
////    }
////    
////    for (size_t i=0; i<pointsFir.size(); i++)
////    {
////        //line(output, initial[i], pointsT[1][i], Scalar(0, 0, 255));
////        circle(output, pointsFir[i], 1, Scalar(255), -1);
////        
////        //circle(output, pointsFirStl[i], 3, Scalar(255, 255, 0), -1);
////        //rectangle(output,ret[0],Scalar(255, 0, 0));
////    }
//    UIImage *imgshow=MatToUIImage(output);
    
    swap(pointsT[1], pointsT[0]);
    pointsT[1].resize(pointsT[0].size());
    
    
//    imshow(window_name, output);
    g_Index++;
    cv::Mat mt((int)pointsRes.size()*2,1,CV_32FC1);
    
    //注意：横纵左边替换
    for (int i=0; i<pointsRes.size(); i++) {
        mt.at<float>(i*2)=pointsRes[i].x;//h-pointsRes[i].y;//pointsRes[i].x;
        mt.at<float>(i*2+1)=pointsRes[i].y;;//pointsRes[i].x;//pointsRes[i].y;
        
    }
    facesRe=faces;
    
//    //////////////TEST画人脸框////////////
//    for (int i=0; i<pointsT[0].size(); i++)
//    {
//        for (int j=-5; j<=5; j++) {
//            for (int t=-5; t<5; t++) {
//            int x = pointsT[0][i].x;
//            int y = pointsT[0][i].y;
//            if (y+j>=w||x+t>=h||x+t<0||y+j<0)
//            {
//                continue;
//            }
//            *(buftmp+widthStep*(h-(x+t))+(y+j))=0;
//            }
//        }
//
//    }
//    UIImage *showImg=MatToUIImage(frame);
    
    return mt;
}
