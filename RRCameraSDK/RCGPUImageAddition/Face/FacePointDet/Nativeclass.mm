/*
 * Nativeclass.cpp
 *
 *  Created on: 2015ƒÍ7‘¬21»’
 *      Author: Administrator
 */

#include "Nativeclass.h"
#include <stdio.h>
#include <stdlib.h>
#include<iostream>
#include <opencv2/opencv.hpp>
#include "ShapeRegressor.h"
#include <assert.h>
#include <string.h>
#include <sys/types.h>
#include <opencv2/imgcodecs/ios.h>
#include "FaceTrack.h"
using namespace cv;

ShapeRegressor* RegressorMod;

/*
 * Class:     com_example_Point_demo_Nativeclass
 * Method:    init
 * Signature: ()[I
 */

ShapeRegressor* initRegressor(String configc ,String cascade, String model)
{

	ShapeRegressor *Regressor = new ShapeRegressor(configc,cascade,model);
        
	return Regressor;

}

/*
 * Class:     com_example_Point_demo_Nativeclass
 * Method:    process
 * Signature: ([I[III)[I
 */
cv::Mat* FacePointPredict(ShapeRegressor * model, UIImage * imgbuf)
{
    if (imgbuf == NULL) {
        return NULL;
    }

//    NSDate* tmpStartData = [[NSDate date] init];
//    //You code here...
    
    Mat myimg;
    UIImageToMat(imgbuf, myimg);


    
    Mat img;
    cvtColor(myimg,img,CV_BGRA2GRAY);
    
//    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
//    NSLog(@">>>>>>>>>>cost time2 = %f ms", deltaTime*1000);

    ShapeRegressor * Regressor = (ShapeRegressor*)model;
    
    Regressor->examples.clear();   //∂‘example«Âø’
    
//    NSDate* tmpStartData = [[NSDate date] init];
//    //You code here...


    Mat *outshape = Regressor->Predict(img);
    
//    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
//    NSLog(@">>>>>>>>>>cost time2 = %f ms", deltaTime*1000);


    //UIImage * result=MatToUIImage(outimg);
    
    return outshape;

}

/*
 * Class:     com_example_Point_demo_Nativeclass
 * Method:    release
 * Signature: ([I)V
 */
void releaseModel(ShapeRegressor* model)
{
	ShapeRegressor * Regressor = (ShapeRegressor*)model;
    
//    if (Regressor->buffer !=  NULL) {
//        delete[] Regressor->buffer;
//        Regressor->buffer = NULL;
//    }
    if (Regressor->cascade_pico!=NULL)
    {
        free(Regressor->cascade_pico);
        Regressor->cascade_pico = NULL;
    }
    
	Regressor->examples.clear();

	delete Regressor;

}

ShapeRegressor *initFacePoint()
{
    ShapeRegressor* Regressor;

    NSString *configc = [[NSBundle mainBundle] pathForResource:@"config_19" ofType:@"yml"];
//    NSString *cascade = [[NSBundle mainBundle] pathForResource:@"model_facedetect" ofType:@""];
//    NSString *model = [[NSBundle mainBundle] pathForResource:@"model_facealigment" ofType:@""];
    NSString *cascade = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"];
    NSString *model = [[NSBundle mainBundle] pathForResource:@"model_3043n_20_8t_5s_28p_915d_float" ofType:@""];

    Regressor = initRegressor([configc cStringUsingEncoding:NSASCIIStringEncoding],[cascade cStringUsingEncoding:NSASCIIStringEncoding],[model cStringUsingEncoding:NSASCIIStringEncoding]);
    return Regressor;
}

int FacePointInit()
{
    if (RegressorMod==NULL) {
        NSString *configc = [[NSBundle mainBundle] pathForResource:@"config_19" ofType:@"yml"];
//        NSString *cascade = [[NSBundle mainBundle] pathForResource:@"model_facedetect" ofType:@""];
//        NSString *model = [[NSBundle mainBundle] pathForResource:@"model_facealigment" ofType:@""];
        NSString *cascade = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"];
        NSString *model = [[NSBundle mainBundle] pathForResource:@"model_3043n_20_8t_5s_28p_915d_float" ofType:@""];

        RegressorMod = initRegressor([configc cStringUsingEncoding:NSASCIIStringEncoding],[cascade cStringUsingEncoding:NSASCIIStringEncoding],[model cStringUsingEncoding:NSASCIIStringEncoding]);
    }
    return 1;
}
//提供视频检测使用
cv::Mat* FacePointPredictData(ShapeRegressor * model, unsigned char * imgbuf, int w, int h, int widthStep, int rotationType)
{
    if (imgbuf == NULL) {
        return NULL;
    }
    if (rotationType==1||rotationType==3||rotationType==5||rotationType==7)
    {
        int tmp=w;
        w=h;
        h=tmp;
    }
    Mat img(w, h, CV_8U);//CV_32FC1
    //旋转90，并做镜像
    if (rotationType==0||rotationType==4)
    {
        for (int i = 0; i < h; i++)
        {
            int tmp=(h-i)*widthStep;
            for (int j = 0 ; j < w ; j++)
            {
                img.at<unsigned char>(j,i) = *(imgbuf+tmp+j);
            } 
        }
    }
    else if (rotationType==1)
    {
        for (int i = 0; i < w; i++)
        {
            int tmp=(i)*widthStep;
            for (int j = 0 ; j < h ; j++)
            {
                img.at<unsigned char>(i,j) = *(imgbuf+tmp+h-j);
            }
        }
    }
    else if (rotationType==2)
    {
        for (int i = 0; i < h; i++)
        {
            int tmp=(h-i)*widthStep;
            for (int j = 0 ; j < w ; j++)
            {
                img.at<unsigned char>(j,i) = *(imgbuf+tmp+w-j);
            }
        }
    }
    else if (rotationType==3)
    {
        for (int i = 0; i < w; i++)
        {
            int tmp=(w-i)*widthStep;
            for (int j = 0 ; j < h ; j++)
            {
                img.at<unsigned char>(i,j) = *(imgbuf+tmp+j);
            }
        }
    }
    else if (rotationType==5)
    {
        for (int i = 0; i < w; i++)
        {
            int tmp=(w-i)*widthStep;
            for (int j = 0 ; j < h ; j++)
            {
                img.at<unsigned char>(i,j) = *(imgbuf+tmp+h-j);
            }
        }
    }
    else if (rotationType==6)
    {
        for (int i = 0; i < h; i++)
        {
            int tmp=(i)*widthStep;
            for (int j = 0 ; j < w ; j++)
            {
                img.at<unsigned char>(j,i) = *(imgbuf+tmp+w-j);
            }
        }
    }
    else if (rotationType==7)
    {
        for (int i = 0; i < w; i++)
        {
            int tmp=(i)*widthStep;
            for (int j = 0 ; j < h ; j++)
            {
                img.at<unsigned char>(i,j) = *(imgbuf+tmp+j);
            }
        }
    }
//    UIImage *d= MatToUIImage(img);
    
    ShapeRegressor * Regressor = (ShapeRegressor*)model;
    
    Regressor->examples.clear();   //∂‘example«Âø’
    
    
    Mat *outshape = Regressor->Predict(img);
//    if (outshape!=NULL&&outshape[0].rows>0)
//    {
//        int ddfsf=outshape[0].at<int>(0);
//    }


//    /////Test///////给YUV数据画人脸框和关键点
//    
//    if (Regressor->examples.empty())
//    {
//        return outshape;
//    }
//    int testX=Regressor->examples[0].bbox_facedet.x+Regressor->examples[0].sx;
//    int testY=Regressor->examples[0].bbox_facedet.y+Regressor->examples[0].sy;
//    int testW=Regressor->examples[0].bbox_facedet.width;
//    int testH=Regressor->examples[0].bbox_facedet.height;
//    
//    for (int i = testY; i < testY+testH; i++)
//    {
//        
//        for (int j = testX; j < testX+testW; j++)
//        {
//            int tmp=(h-j)*widthStep;
//            if ((i>=testY&&i<=testY+testH-1&&(j==testX||j==testX+testW-1)) || (j>=testX&&j<=testX+testW-1&&(i==testY||i==testY+testH-1)))
//            {
//                *(imgbuf+tmp+i) = 255;
//            }
//        }
//    }
//    
//    int sc=3;
//    for (int i =0;i<Regressor->examples.size();i++)
//    {
//        sc = (int)max(Regressor->examples[i].bbox_facedet.width/70,1.0f);
//        for (int j=0;j<Regressor->lm_num;j++)
//        {
//            //circle(img,cv::Point(examples[i].intermediate_shapes[0](j,0)+examples[i].sx,examples[i].intermediate_shapes[0](j,1)+examples[i].sy),sc,Scalar(255,0,0),2);///////Test///////////
//            
//            int poix = ((int)(Regressor->examples[i].intermediate_shapes[0](j,0)+Regressor->examples[i].sx));
//            
//            int poiy = ((int)(Regressor->examples[i].intermediate_shapes[0](j,1)+Regressor->examples[i].sy));
//            
//            for (int u=poiy-1; u<=poiy+1; u++)
//            {
//                for (int s=poix-1; s<=poix+1; s++)
//                {
//                    if (u<0||u>=w||s<0||s>=h)
//                    {
//                        continue;
//                    }
//                    
//                    int tmp=(h-s)*widthStep;
//                    *(imgbuf+tmp+u)=255;
//                }
//            }
//
//        }
//    }
//    /////Test///////
    
//    UIImage * result=MatToUIImage(outimg);
    
    //根据不同方向转换人脸结果
    for (int i=0; i<Regressor->examples.size(); i++)
    {
        if (rotationType==1||rotationType==5)
        {
            double tmp=Regressor->examples[i].bbox_facedet.x;
            Regressor->examples[i].bbox_facedet.x=Regressor->examples[i].bbox_facedet.y;
            Regressor->examples[i].bbox_facedet.y=tmp;
            tmp=Regressor->examples[i].bbox_facedet.width;
            Regressor->examples[i].bbox_facedet.width=Regressor->examples[i].bbox_facedet.height;
            Regressor->examples[i].bbox_facedet.height=tmp;

            tmp=Regressor->examples[i].sx;
            Regressor->examples[i].sx=w-(Regressor->examples[i].sy+Regressor->examples[i].bbox_facedet.x*2+Regressor->examples[i].bbox_facedet.width);
            Regressor->examples[i].sy=h-(tmp+Regressor->examples[i].bbox_facedet.y*2+Regressor->examples[i].bbox_facedet.height);
        }
        else if (rotationType==2||rotationType==6)
        {
            //Regressor->examples[i].bbox_facedet.y=w-(Regressor->examples[i].bbox_facedet.y+Regressor->examples[i].bbox_facedet.height);
            Regressor->examples[i].sy=w-(Regressor->examples[i].sy+Regressor->examples[i].bbox_facedet.y*2+Regressor->examples[i].bbox_facedet.height);
        }
        else if (rotationType==3||rotationType==7)
        {
            double tmp=Regressor->examples[i].bbox_facedet.x;
            Regressor->examples[i].bbox_facedet.x=Regressor->examples[i].bbox_facedet.y;
            Regressor->examples[i].bbox_facedet.y=(tmp);
            tmp=Regressor->examples[i].bbox_facedet.width;
            Regressor->examples[i].bbox_facedet.width=Regressor->examples[i].bbox_facedet.height;
            Regressor->examples[i].bbox_facedet.height=tmp;
            
            tmp=Regressor->examples[i].sx;
            Regressor->examples[i].sx=Regressor->examples[i].sy;//w-(Regressor->examples[i].sy+Regressor->examples[i].bbox_facedet.x+Regressor->examples[i].bbox_facedet.width);
            Regressor->examples[i].sy=(tmp);
        }
    }
//    resultData->poiCount=RegressorMod->lm_num;
//
    int count = (int)Regressor->examples.size();
    for (int j=0; j<count; j++)
    {
        for (int i=0; i<outshape[j].rows; i+=2)
        {
            if (rotationType==1)
            {
                int tmp=w-outshape[j].at<int>(i+1);
                outshape[j].at<int>(i+1)=h-outshape[j].at<int>(i);
                outshape[j].at<int>(i)=tmp;
            }
            else if (rotationType==2)
            {
                outshape[j].at<int>(i+1)=w-outshape[j].at<int>(i+1);
                outshape[j].at<int>(i)=outshape[j].at<int>(i);
            }
            else if (rotationType==3)
            {
                int tmp=outshape[j].at<int>(i+1);
                outshape[j].at<int>(i+1)=outshape[j].at<int>(i);
                outshape[j].at<int>(i)=tmp;
            }
            else if (rotationType==5)
            {
                int tmp=outshape[j].at<int>(i+1);
                outshape[j].at<int>(i+1)=h-outshape[j].at<int>(i);
                outshape[j].at<int>(i)=tmp;
            }
            else if (rotationType==6)
            {
                outshape[j].at<int>(i+1)=w-outshape[j].at<int>(i+1);
                outshape[j].at<int>(i)=h-outshape[j].at<int>(i);
            }
            else if (rotationType==7)
            {
                int tmp=w-outshape[j].at<int>(i+1);
                outshape[j].at<int>(i+1)=outshape[j].at<int>(i);
                outshape[j].at<int>(i)=tmp;
            }
        }
    }

    
    return outshape;
    
}
//ShapeRegressor * model, Mat imgbuf, int w, int h, int widthStep, int rotationType
cv::Mat* FacePointPredictData(unsigned char *imgbuf, std::vector<cv::Rect>&facesRes, int w, int h, int widthStep, int rotationType)//(Mat & imgbuf, std::vector<cv::Rect>facesRes)
{
    
    if (imgbuf == NULL) {
        return NULL;
    }

//    Mat imgf(h, w, CV_8UC1, imgbuf, widthStep);//CV_32FC1
    unsigned char *imgtm=(unsigned char *)malloc(widthStep*h);
    memcpy(imgtm, imgbuf, h*widthStep);
//    Mat img(w, h, CV_8UC1);
    Mat img(h, w, CV_8UC1, imgtm, widthStep);
//    img=img.t();
//    cv::Mat frame(h, w, CV_8UC1, buf, widthStep);

//        UIImage *d= MatToUIImage(img);
    
    ShapeRegressor * Regressor = RegressorMod;
    
    Regressor->examples.clear();   //∂‘example«Âø’
    
#ifdef TEST_TIME
    double t = (double)cvGetTickCount();
    ////代码段
#endif

    Mat *outshape = Regressor->Predict(img);

    free(imgtm);
    img.release();
    
#ifdef TEST_TIME
    t = (double)cvGetTickCount() - t;
    printf( "人脸检测＋关键点定位内部：%gms\n", t/(cvGetTickFrequency()*1000) );
#endif

        /////Test///////给YUV数据画人脸框和关键点
    
//        if (Regressor->examples.empty())
//        {
//            return outshape;
//        }
//        int testX=Regressor->examples[0].bbox_facedet.x+Regressor->examples[0].sx;
//        int testY=Regressor->examples[0].bbox_facedet.y+Regressor->examples[0].sy;
//        int testW=Regressor->examples[0].bbox_facedet.width;
//        int testH=Regressor->examples[0].bbox_facedet.height;
//
//        for (int i = testY; i < testY+testH; i++)
//        {
//    
//            for (int j = testX; j < testX+testW; j++)
//            {
//                int tmp=(h-j)*widthStep;
//                if ((i>=testY&&i<=testY+testH-1&&(j==testX||j==testX+testW-1)) || (j>=testX&&j<=testX+testW-1&&(i==testY||i==testY+testH-1)))
//                {
//                    *(imgbuf+tmp+i) = 255;
//                }
//            }
//        }
//
//        int sc=3;
//        for (int i =0;i<Regressor->examples.size();i++)
//        {
//            sc = (int)max(Regressor->examples[i].bbox_facedet.width/70,1.0f);
//            for (int j=0;j<Regressor->lm_num;j++)
//            {
//                //circle(img,cv::Point(examples[i].intermediate_shapes[0](j,0)+examples[i].sx,examples[i].intermediate_shapes[0](j,1)+examples[i].sy),sc,Scalar(255,0,0),2);///////Test///////////
//    
//                int poix = ((int)(Regressor->examples[i].intermediate_shapes[0](j,0)+Regressor->examples[i].sx));
//    
//                int poiy = ((int)(Regressor->examples[i].intermediate_shapes[0](j,1)+Regressor->examples[i].sy));
//    
//                for (int u=poiy-1; u<=poiy+1; u++)
//                {
//                    for (int s=poix-1; s<=poix+1; s++)
//                    {
//                        if (u<0||u>=w||s<0||s>=h)
//                        {
//                            continue;
//                        }
//    
//                        int tmp=(h-s)*widthStep;
//                        *(imgbuf+tmp+u)=255;
//                    }
//                }
//
//            }
//        }
    //    /////Test///////
    
//        UIImage * result=MatToUIImage(img);
//    UIImage * resultf=MatToUIImage(imgf);
    
    
    //根据不同方向转换人脸结果
//    for (int i=0; i<Regressor->examples.size(); i++)
//    {
//        if (true||rotationType==1||rotationType==5)
//        {
//            double tmp=Regressor->examples[i].bbox_facedet.x;
//            Regressor->examples[i].bbox_facedet.x=Regressor->examples[i].bbox_facedet.y;
//            Regressor->examples[i].bbox_facedet.y=tmp;
//            tmp=Regressor->examples[i].bbox_facedet.width;
//            Regressor->examples[i].bbox_facedet.width=Regressor->examples[i].bbox_facedet.height;
//            Regressor->examples[i].bbox_facedet.height=tmp;
//            
//            tmp=Regressor->examples[i].sx;
//            Regressor->examples[i].sx=w-(Regressor->examples[i].sy+Regressor->examples[i].bbox_facedet.x*2+Regressor->examples[i].bbox_facedet.width);
//            Regressor->examples[i].sy=h-(tmp+Regressor->examples[i].bbox_facedet.y*2+Regressor->examples[i].bbox_facedet.height);
//        }
//        else if (rotationType==2||rotationType==6)
//        {
//            //Regressor->examples[i].bbox_facedet.y=w-(Regressor->examples[i].bbox_facedet.y+Regressor->examples[i].bbox_facedet.height);
//            Regressor->examples[i].sy=w-(Regressor->examples[i].sy+Regressor->examples[i].bbox_facedet.y*2+Regressor->examples[i].bbox_facedet.height);
//        }
//        else if (rotationType==3||rotationType==7)
//        {
//            double tmp=Regressor->examples[i].bbox_facedet.x;
//            Regressor->examples[i].bbox_facedet.x=Regressor->examples[i].bbox_facedet.y;
//            Regressor->examples[i].bbox_facedet.y=(tmp);
//            tmp=Regressor->examples[i].bbox_facedet.width;
//            Regressor->examples[i].bbox_facedet.width=Regressor->examples[i].bbox_facedet.height;
//            Regressor->examples[i].bbox_facedet.height=tmp;
//            
//            tmp=Regressor->examples[i].sx;
//            Regressor->examples[i].sx=Regressor->examples[i].sy;//w-(Regressor->examples[i].sy+Regressor->examples[i].bbox_facedet.x+Regressor->examples[i].bbox_facedet.width);
//            Regressor->examples[i].sy=(tmp);
//        }
//    }
    
    
    //    resultData->poiCount=RegressorMod->lm_num;
    //
    int count = (int)Regressor->examples.size();
//    for (int j=0; j<count; j++)
//    {
//        for (int i=0; i<outshape[j].rows; i+=2)
//        {
//            int tmp=outshape[j].at<int>(i+1);
//            outshape[j].at<int>(i+1)=outshape[j].at<int>(i);
//            outshape[j].at<int>(i)=tmp;
////            if (rotationType==1)
////            {
////                int tmp=w-outshape[j].at<int>(i+1);
////                outshape[j].at<int>(i+1)=h-outshape[j].at<int>(i);
////                outshape[j].at<int>(i)=tmp;
////            }
////            else if (rotationType==2)
////            {
////                outshape[j].at<int>(i+1)=w-outshape[j].at<int>(i+1);
////                outshape[j].at<int>(i)=outshape[j].at<int>(i);
////            }
////            else if (rotationType==3)
////            {
////                int tmp=outshape[j].at<int>(i+1);
////                outshape[j].at<int>(i+1)=outshape[j].at<int>(i);
////                outshape[j].at<int>(i)=tmp;
////            }
////            else if (rotationType==5)
////            {
////                int tmp=outshape[j].at<int>(i+1);
////                outshape[j].at<int>(i+1)=h-outshape[j].at<int>(i);
////                outshape[j].at<int>(i)=tmp;
////            }
////            else if (rotationType==6)
////            {
////                outshape[j].at<int>(i+1)=w-outshape[j].at<int>(i+1);
////                outshape[j].at<int>(i)=h-outshape[j].at<int>(i);
////            }
////            else if (rotationType==7)
////            {
////                int tmp=w-outshape[j].at<int>(i+1);
////                outshape[j].at<int>(i+1)=outshape[j].at<int>(i);
////                outshape[j].at<int>(i)=tmp;
////            }
//        }
//    }
    
//    for (int j=0; j<count; j++)
//    {
//        for (int i=0; i<outshape[j].rows; i+=2)
//        {
//            if (rotationType==0)
//            {
//                int tmp=outshape[j].at<int>(i+1);
//                outshape[j].at<int>(i+1)=h-outshape[j].at<int>(i);
//                outshape[j].at<int>(i)=tmp;
//            }
//        }
//    }
    
    if (count>0) {
        facesRes.resize(1);
        facesRes[0].x=Regressor->examples[0].bbox_facedet.x+Regressor->examples[0].sx;
        facesRes[0].y=Regressor->examples[0].bbox_facedet.y+Regressor->examples[0].sy;
        facesRes[0].width=Regressor->examples[0].bbox_facedet.width;
        facesRes[0].height=Regressor->examples[0].bbox_facedet.height;
    }
    else
    {
        facesRes.clear();
    }

//    facesRes.insert(facesRes.end(),   Regressor->faces.begin(),   Regressor->faces.end()   );

    return outshape;
    
//    ShapeRegressor * Regressor = RegressorMod;
//    
//    Regressor->examples.clear();   //∂‘example«Âø’
//    
//    
//    Mat *outshape = Regressor->Predict(imgbuf);
//    facesRes.clear();
//    facesRes.insert(facesRes.end(),   Regressor->faces.begin(),   Regressor->faces.end()   );
//    return outshape;
    
}



//提供图片检测使用
//cv::Mat* FacePointPredictData(ShapeRegressor * model, Mat imgbuf, int w, int h, int widthStep, int rotationType)
cv::Mat* FacePointPredictData(ShapeRegressor * model, Mat imgbuf, int w, int h, int widthStep, int rotationType)
{
    
    ShapeRegressor * Regressor = (ShapeRegressor*)model;
    
    Regressor->examples.clear();   //∂‘example«Âø’
    
    
    Mat *outshape = Regressor->Predict(imgbuf);
    //    if (outshape!=NULL&&outshape[0].rows>0)
    //    {
    //        int ddfsf=outshape[0].at<int>(0);
    //    }
    
    
    //    /////Test///////给YUV数据画人脸框和关键点
    //
    //    if (Regressor->examples.empty())
    //    {
    //        return outshape;
    //    }
    //    int testX=Regressor->examples[0].bbox_facedet.x+Regressor->examples[0].sx;
    //    int testY=Regressor->examples[0].bbox_facedet.y+Regressor->examples[0].sy;
    //    int testW=Regressor->examples[0].bbox_facedet.width;
    //    int testH=Regressor->examples[0].bbox_facedet.height;
    //
    //    for (int i = testY; i < testY+testH; i++)
    //    {
    //
    //        for (int j = testX; j < testX+testW; j++)
    //        {
    //            int tmp=(h-j)*widthStep;
    //            if ((i>=testY&&i<=testY+testH-1&&(j==testX||j==testX+testW-1)) || (j>=testX&&j<=testX+testW-1&&(i==testY||i==testY+testH-1)))
    //            {
    //                *(imgbuf+tmp+i) = 255;
    //            }
    //        }
    //    }
    //
    //    int sc=3;
    //    for (int i =0;i<Regressor->examples.size();i++)
    //    {
    //        sc = (int)max(Regressor->examples[i].bbox_facedet.width/70,1.0f);
    //        for (int j=0;j<Regressor->lm_num;j++)
    //        {
    //            //circle(img,cv::Point(examples[i].intermediate_shapes[0](j,0)+examples[i].sx,examples[i].intermediate_shapes[0](j,1)+examples[i].sy),sc,Scalar(255,0,0),2);///////Test///////////
    //
    //            int poix = ((int)(Regressor->examples[i].intermediate_shapes[0](j,0)+Regressor->examples[i].sx));
    //
    //            int poiy = ((int)(Regressor->examples[i].intermediate_shapes[0](j,1)+Regressor->examples[i].sy));
    //
    //            for (int u=poiy-1; u<=poiy+1; u++)
    //            {
    //                for (int s=poix-1; s<=poix+1; s++)
    //                {
    //                    if (u<0||u>=w||s<0||s>=h)
    //                    {
    //                        continue;
    //                    }
    //
    //                    int tmp=(h-s)*widthStep;
    //                    *(imgbuf+tmp+u)=255;
    //                }
    //            }
    //
    //        }
    //    }
    //    /////Test///////
    
    //    UIImage * result=MatToUIImage(outimg);
    
//    //根据不同方向转换人脸结果
//    for (int i=0; i<Regressor->examples.size(); i++)
//    {
//        if (rotationType==1||rotationType==5)
//        {
//            double tmp=Regressor->examples[i].bbox_facedet.x;
//            Regressor->examples[i].bbox_facedet.x=Regressor->examples[i].bbox_facedet.y;
//            Regressor->examples[i].bbox_facedet.y=tmp;
//            tmp=Regressor->examples[i].bbox_facedet.width;
//            Regressor->examples[i].bbox_facedet.width=Regressor->examples[i].bbox_facedet.height;
//            Regressor->examples[i].bbox_facedet.height=tmp;
//            
//            tmp=Regressor->examples[i].sx;
//            Regressor->examples[i].sx=w-(Regressor->examples[i].sy+Regressor->examples[i].bbox_facedet.x*2+Regressor->examples[i].bbox_facedet.width);
//            Regressor->examples[i].sy=h-(tmp+Regressor->examples[i].bbox_facedet.y*2+Regressor->examples[i].bbox_facedet.height);
//        }
//        else if (rotationType==2||rotationType==6)
//        {
//            //Regressor->examples[i].bbox_facedet.y=w-(Regressor->examples[i].bbox_facedet.y+Regressor->examples[i].bbox_facedet.height);
//            Regressor->examples[i].sy=w-(Regressor->examples[i].sy+Regressor->examples[i].bbox_facedet.y*2+Regressor->examples[i].bbox_facedet.height);
//        }
//        else if (rotationType==3||rotationType==7)
//        {
//            double tmp=Regressor->examples[i].bbox_facedet.x;
//            Regressor->examples[i].bbox_facedet.x=Regressor->examples[i].bbox_facedet.y;
//            Regressor->examples[i].bbox_facedet.y=(tmp);
//            tmp=Regressor->examples[i].bbox_facedet.width;
//            Regressor->examples[i].bbox_facedet.width=Regressor->examples[i].bbox_facedet.height;
//            Regressor->examples[i].bbox_facedet.height=tmp;
//            
//            tmp=Regressor->examples[i].sx;
//            Regressor->examples[i].sx=Regressor->examples[i].sy;//w-(Regressor->examples[i].sy+Regressor->examples[i].bbox_facedet.x+Regressor->examples[i].bbox_facedet.width);
//            Regressor->examples[i].sy=(tmp);
//        }
//    }
//    //    resultData->poiCount=RegressorMod->lm_num;
//    //
//    int count = (int)Regressor->examples.size();
//    for (int j=0; j<count; j++)
//    {
//        for (int i=0; i<outshape[j].rows; i+=2)
//        {
//            if (rotationType==1)
//            {
//                int tmp=w-outshape[j].at<int>(i+1);
//                outshape[j].at<int>(i+1)=h-outshape[j].at<int>(i);
//                outshape[j].at<int>(i)=tmp;
//            }
//            else if (rotationType==2)
//            {
//                outshape[j].at<int>(i+1)=w-outshape[j].at<int>(i+1);
//                outshape[j].at<int>(i)=outshape[j].at<int>(i);
//            }
//            else if (rotationType==3)
//            {
//                int tmp=outshape[j].at<int>(i+1);
//                outshape[j].at<int>(i+1)=outshape[j].at<int>(i);
//                outshape[j].at<int>(i)=tmp;
//            }
//            else if (rotationType==5)
//            {
//                int tmp=outshape[j].at<int>(i+1);
//                outshape[j].at<int>(i+1)=h-outshape[j].at<int>(i);
//                outshape[j].at<int>(i)=tmp;
//            }
//            else if (rotationType==6)
//            {
//                outshape[j].at<int>(i+1)=w-outshape[j].at<int>(i+1);
//                outshape[j].at<int>(i)=h-outshape[j].at<int>(i);
//            }
//            else if (rotationType==7)
//            {
//                int tmp=w-outshape[j].at<int>(i+1);
//                outshape[j].at<int>(i+1)=outshape[j].at<int>(i);
//                outshape[j].at<int>(i)=tmp;
//            }
//        }
//    }
    
    
    return outshape;
    
}
int ga_Symmetric[28]={0,4,1,3,5,10,6,9,7,8,14,20,15,19,16,18,17,21,12,13,22,24};
int facePointSymmetric(Mat mat)
{
    for (int i=0; i<=10; i++)
    {
        float ftmp = mat.at<float>(ga_Symmetric[i*2]*2);
        mat.at<float>(ga_Symmetric[i*2]*2)=mat.at<float>(ga_Symmetric[i*2+1]*2);
        mat.at<float>(ga_Symmetric[i*2+1]*2)=ftmp;
        
        ftmp = mat.at<float>(ga_Symmetric[i*2]*2+1);
        mat.at<float>(ga_Symmetric[i*2]*2+1)=mat.at<float>(ga_Symmetric[i*2+1]*2+1);
        mat.at<float>(ga_Symmetric[i*2+1]*2+1)=ftmp;
    }
    return 1;
}

//供视频检测使用--跟踪
int faceTrackMain(unsigned char *imgbuf,FacePointData *resultData,int w,int h,int widthStep,int rotationType)
{
    if (RegressorMod==NULL)
    {
        return -1;
    }
//    double t2 = (double)cvGetTickCount();
//    ////代码段
//    unsigned char *buftmp=new unsigned char[widthStep*h];
//    for (int i = 0; i < h; i++)
//    {
//        int tmp=(h-i)*widthStep;
//        for (int j = 0 ; j < w ; j++)
//        {
//            *(buftmp+j*h+i) = *(imgbuf+tmp+j);
//        }
//    }
//    t2 = (double)cvGetTickCount() - t2;
//    printf( "拷贝图像:%gms\n", t2/(cvGetTickFrequency()*1000) );
    
    static int index=0;
    vector<cv::Rect2f> facesR;
    //cv::Mat* resultMat = FacePointPredictData(RegressorMod,imgbuf,w,h,widthStep,rotationType);
#ifdef TEST_TIME
                double t = (double)cvGetTickCount();
                ////代码段
#endif
    cv::Mat resultMatmid = faceTracking(imgbuf,imgbuf,  index,w,h,widthStep,rotationType,facesR);
    //cv::Mat resultMatmid=Mat();
//    free(buftmp);
#ifdef TEST_TIME
                t = (double)cvGetTickCount() - t;
                printf( "跟踪：%gms\n", t/(cvGetTickFrequency()*1000) );
#endif
    
    if (rotationType>=4&&resultMatmid.rows>0)
    {
//        int ntmp=resultMatmid.rows/2;
//        for (int i=0; i<ntmp; i++) {
//            resultMatmid.at<float>(i*2)=h-resultMatmid.at<float>(i*2);
//        }
        
        //把后置摄像头的人脸的坐标做对称
        facePointSymmetric(resultMatmid);
    }
    

    index++;
    //    if (resultMat.size==0||RegressorMod->examples.size()==0)
    //    {
    //        releaseModel(RegressorMod);
    //        return -1;
    //    }
    Mat resultMat[1];
    resultMatmid.copyTo(resultMat[0]);
    int count=0;
    if (resultMatmid.rows>0) {
         count=1;
    }
//    int count = min((int)facesR.size(),5);
//    count=min(count,1);
    resultData->faceCount=count;
//    for (int i=0; i<count; i++)
//    {
//        resultData->rect[i].origin.x=facesR[i].x;
//        resultData->rect[i].origin.y=facesR[i].y;
//        resultData->rect[i].size.width=facesR[i].width;
//        resultData->rect[i].size.height=facesR[i].height;
//    }
    resultData->poiCount=RegressorMod->lm_num;
    
    for (int j=0; j<count; j++)
    {
        for (int i=0; i<resultMat[j].rows; i++)
        {
            int t1=i/2;
            int t2=i%2;
            resultData->poi[j][t1][t2]=resultMat[j].at<float>(i);
        }
    }
    
    //////使用关键点优化人脸框/////////
    
    for (int i=0; i<count; i++)
    {
        int left_x= resultData->poi[i][0][0],right_x = resultData->poi[i][0][0];
        int top_y = resultData->poi[i][0][1],bottom_y = resultData->poi[i][0][1];
        for (int j = 1;j < 28;++j) {
            left_x = min(left_x, resultData->poi[i][j][0]);
            right_x = max(right_x, resultData->poi[i][j][0]);
            top_y = min(top_y, resultData->poi[i][j][1]);
            bottom_y = max(bottom_y, resultData->poi[i][j][1]);
        }
        
        CGRect rect;	// 取出人脸区域
        rect.origin.x=left_x;
        rect.origin.y = top_y;
        rect.size.width=right_x-left_x;
        rect.size.height=bottom_y-top_y;
//        if (rotationType==1||rotationType==7)
//        {
//            rect.size.width=min((double)(rect.size.width+rect.size.width/8),(double)(h-rect.origin.x-1));
//        }
//        else if (rotationType==3||rotationType==5)
//        {
//            rect.origin.x=max((double)(rect.origin.x-rect.size.width/8),0.0);
//        }
//        else if (rotationType==2||rotationType==6)
//        {
//            rect.size.height=min((double)(rect.size.height+rect.size.height/8),(double)(w-rect.origin.y-1));
//        }
//        else if (rotationType==0||rotationType==4)
//        {
//            rect.origin.y=max((double)(rect.origin.y-rect.size.height/8),0.0);
//        }
        resultData->rect[i]=rect;
    }

//    for (int j=0; j<count; j++)
//    {
//        for (int i=0; i<resultMat[j].rows/2; i++)
//        {
//            float ftmp=resultData->poi[j][i][1];
//            resultData->poi[j][i][1]=h-resultData->poi[j][i][0];
//        }
//    }
//    //////////////TEST画人脸框////////////
//    for (int i=0; i<resultMatmid.rows/2; i++)
//    {
//        for (int j=-3; j<=3; j++) {
//            for (int t=-3; t<3; t++) {
//                int x = resultData->poi[0][i][0];
//                int y = resultData->poi[0][i][1];
//                if (y+j>=w||x+t>=h||x+t<0||y+j<0)
//                {
//                    continue;
//                }
//                //*(imgbuf+widthStep*(h-(x+t))+(y+j))=255;
//                
//                //*(imgbuf+widthStep*(h-(x+t))+(y+j))=255;
//                *(imgbuf+widthStep*((y+t))+(x+j))=255;
//                
////                if(i==0)
////                {
////                    *(imgbuf+widthStep*(h-(x+t))+(y+j))=0;
////                }
//                
//                
//            }
//
//        }
//    }
    return 1;
}

//供视频检测使用--实时人脸检测
int FacePointStart(unsigned char *imgbuf,FacePointData *resultData,int w,int h,int widthStep,int rotationType)
{
    if (RegressorMod==NULL)
    {
        return -1;
    }
    
    
    cv::Mat* resultMat = FacePointPredictData(RegressorMod,imgbuf,w,h,widthStep,rotationType);

//    if (resultMat.size==0||RegressorMod->examples.size()==0)
//    {
//        releaseModel(RegressorMod);
//        return -1;
//    }

    int count = min((int)RegressorMod->examples.size(),5);

    resultData->faceCount=count;
    for (int i=0; i<count; i++)
    {
        resultData->rect[i].origin.x=RegressorMod->examples[i].bbox_facedet.x+RegressorMod->examples[i].sx;
        resultData->rect[i].origin.y=RegressorMod->examples[i].bbox_facedet.y+RegressorMod->examples[i].sy;
        resultData->rect[i].size.width=RegressorMod->examples[i].bbox_facedet.width;
        resultData->rect[i].size.height=RegressorMod->examples[i].bbox_facedet.height;
    }
    resultData->poiCount=RegressorMod->lm_num;

    for (int j=0; j<count; j++)
    {
        for (int i=0; i<resultMat[j].rows; i++)
        {
            int t1=i/2;
            int t2=i%2;
            resultData->poi[j][t1][t2]=resultMat[j].at<int>(i);
        }
    }
    
    //////使用关键点优化人脸框/////////
    
    for (int i=0; i<count; i++)
    {
        int left_x= resultData->poi[i][0][0],right_x = resultData->poi[i][0][0];
        int top_y = resultData->poi[i][0][1],bottom_y = resultData->poi[i][0][1];
        for (int j = 1;j < 28;++j) {
            left_x = min(left_x, resultData->poi[i][j][0]);
            right_x = max(right_x, resultData->poi[i][j][0]);
            top_y = min(top_y, resultData->poi[i][j][1]);
            bottom_y = max(bottom_y, resultData->poi[i][j][1]);
        }
        
        CGRect rect;	// 取出人脸区域
        rect.origin.x=left_x;
        rect.origin.y = top_y;
        rect.size.width=right_x-left_x;
        rect.size.height=bottom_y-top_y;
        if (rotationType==1||rotationType==7)
        {
            rect.size.width=min((double)(rect.size.width+rect.size.width/8),(double)(h-rect.origin.x-1));
        }
        else if (rotationType==3||rotationType==5)
        {
            rect.origin.x=max((double)(rect.origin.x-rect.size.width/8),0.0);
        }
        else if (rotationType==2||rotationType==6)
        {
            rect.size.height=min((double)(rect.size.height+rect.size.height/8),(double)(w-rect.origin.y-1));
        }
        else if (rotationType==0||rotationType==4)
        {
            rect.origin.y=max((double)(rect.origin.y-rect.size.height/8),0.0);
        }
        resultData->rect[i]=rect;
    }
    
    return 1;
}

//供图片检测使用
int FacePointStartForImg(UIImage* imgbuf,FacePointData *resultData,int w,int h,int widthStep,int rotationType)
{
    if (RegressorMod==NULL)
    {
        return -1;
    }
    
    cv::Mat myimg;
    UIImageToMat(imgbuf, myimg);
    cv::Mat img;
    cvtColor(myimg,img,CV_BGRA2GRAY);
    cv::Mat* resultMat = FacePointPredictData(RegressorMod,img,w,h,widthStep,rotationType);
    
    //    if (resultMat.size==0||RegressorMod->examples.size()==0)
    //    {
    //        releaseModel(RegressorMod);
    //        return -1;
    //    }
    
    int count = min((int)RegressorMod->examples.size(),5);
    
    resultData->faceCount=count;
    for (int i=0; i<count; i++)
    {
        resultData->rect[i].origin.x=RegressorMod->examples[i].bbox_facedet.x+RegressorMod->examples[i].sx;
        resultData->rect[i].origin.y=RegressorMod->examples[i].bbox_facedet.y+RegressorMod->examples[i].sy;
        resultData->rect[i].size.width=RegressorMod->examples[i].bbox_facedet.width;
        resultData->rect[i].size.height=RegressorMod->examples[i].bbox_facedet.height;
    }
    resultData->poiCount=RegressorMod->lm_num;
    
    for (int j=0; j<count; j++)
    {
        for (int i=0; i<resultMat[j].rows; i++)
        {
            int t1=i/2;
            int t2=i%2;
            resultData->poi[j][t1][t2]=resultMat[j].at<int>(i);
        }
    }
    
    //////使用关键点优化人脸框/////////
    
    for (int i=0; i<count; i++)
    {
        int left_x= resultData->poi[i][0][0],right_x = resultData->poi[i][0][0];
        int top_y = resultData->poi[i][0][1],bottom_y = resultData->poi[i][0][1];
        for (int j = 1;j < 28;++j) {
            left_x = min(left_x, resultData->poi[i][j][0]);
            right_x = max(right_x, resultData->poi[i][j][0]);
            top_y = min(top_y, resultData->poi[i][j][1]);
            bottom_y = max(bottom_y, resultData->poi[i][j][1]);
        }
        
        CGRect rect;	// 取出人脸区域
        rect.origin.x=left_x;
        rect.origin.y = top_y;
        rect.size.width=right_x-left_x;
        rect.size.height=bottom_y-top_y;
        resultData->rect[i]=rect;
    }
    
    return 1;
}

int FacePointreleaseModel()
{
    if (RegressorMod != NULL) {
        releaseModel(RegressorMod);
        RegressorMod=NULL;
    }
    return 1;
}

int FacePointMain(UIImage *imgbuf,FacePointData *resultData)
{
    ShapeRegressor*Regressor;

    NSString *configc = [[NSBundle mainBundle] pathForResource:@"config_19" ofType:@"yml"];
    NSString *cascade = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"];
    NSString *model = [[NSBundle mainBundle] pathForResource:@"model_3043n_20_8t_5s_28p_915d_float" ofType:@""];
    
    Regressor = initRegressor([configc cStringUsingEncoding:NSASCIIStringEncoding],[cascade cStringUsingEncoding:NSASCIIStringEncoding],[model cStringUsingEncoding:NSASCIIStringEncoding]);

    cv::Mat *resultMat = FacePointPredict(Regressor,imgbuf);
    
    if (!resultMat) {
        releaseModel(Regressor);
        return -1;
    }
    if (resultMat[0].size==0||Regressor->examples.size()==0)
    {
        releaseModel(Regressor);
        return -1;
    }
    
    int count = min((int)Regressor->examples.size(),5);

    resultData->faceCount=count;
    for (int i=0; i<count; i++)
    {
//        resultData->rect[i].left=Regressor->examples[i].sx;
//        resultData->rect[i].top=Regressor->examples[i].sy;
//        resultData->rect[i].right=Regressor->examples[i].sx+Regressor->examples[i].width;
//        resultData->rect[i].bottom=Regressor->examples[i].sy+Regressor->examples[i].height;
        resultData->rect[i].origin.x=Regressor->examples[i].bbox_facedet.x+Regressor->examples[i].sx;
        resultData->rect[i].origin.y=Regressor->examples[i].bbox_facedet.y+Regressor->examples[i].sy;
        resultData->rect[i].size.width=Regressor->examples[i].bbox_facedet.width;
        resultData->rect[i].size.height=Regressor->examples[i].bbox_facedet.height;
    }
    resultData->poiCount=Regressor->lm_num;
    for (int j=0; j<count; j++)
    {
        for (int i=0; i<resultMat[j].rows; i++)
        {
            int t1=i/2;
            int t2=i%2;
            resultData->poi[j][t1][t2]=resultMat[j].at<int>(i);
            
        }
    }

    releaseModel(Regressor);
    
    return 1;
}
