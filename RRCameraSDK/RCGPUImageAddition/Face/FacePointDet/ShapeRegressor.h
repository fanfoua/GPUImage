#ifndef REGRESSOR_H
#define REGRESSOR_H

#include <opencv2/opencv.hpp>

#include <vector>
#include <fstream>
#include <string>
#include <stdio.h>
#include "ExampleTm.h"
#include "Tree.h"

class ShapeRegressor {
	//private:
public:
	//parameters

		int train_augnumber;
		int augnumber;
		std::vector<int> max_numfeats;
		float bagging_overlap;
		std::vector<float> max_radio_radius;
		int max_numtrees;
		int max_depth;
		int max_numstage;	
		int lm_num;            // 特征点的个数
		cv::Mat_<float> meanshape;
		std::vector<ExampleTm> examples;
		std::vector< std::vector<std::vector< Tree > > > randf;
		std::vector< cv::Mat_<float> > Ws;
		cv::CascadeClassifier face_cascade;
		bool test_mode;
        char *buffer;
        void *cascade_pico;
//        std::vector<cv::Rect_<float> > faces;//ren lian jia ce
//		cv::Rect m_face_rect;           // 上一次检测到人脸的位置
//		int camera_flag;           // 0 image, 1 camera;

	public:
		ShapeRegressor(const std::string config_file,const std::string cascade_name,const std::string model_name);
        //~ShapeRegressor();
		//cv::Mat Predict(cv::Mat & img);                     // Liu
        cv::Mat* Predict(cv::Mat & img);
//		std::vector<int> Perdict(cv::Mat &img);

		void Read_config( const cv::FileStorage& file );

		void Load_Mat( cv::Mat &img);              // Liu
		void Derive_binaryfeat( int stage, std::vector<std::vector<int> > &binfeatures );
		void Global_regression( int stage, std::vector<std::vector<int> > &binfeatures );
		void Global_predict( int stage, std::vector<std::vector<int> > &binfeatures );

		void Load_model(char * path);
		void Read(FILE * fin);


		void Face_detect( cv::CascadeClassifier &face_cascade, cv::Mat img,std::vector<cv::Rect> &faces );
    
        void Face_detect_pico(void * cascade,cv::Mat &img,std::vector<cv::Rect_<float> > &faces);
        void load_pico_model(const char *path);
//		void Face_detect( cv::CascadeClassifier &face_cascade, cv::Mat img, std::vector<cv::Rect> &faces, cv::Rect & rect);
};



#endif
