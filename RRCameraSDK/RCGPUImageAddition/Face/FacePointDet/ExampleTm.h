#ifndef ExampleTm_H
#define ExampleTm_H

#include <opencv2/opencv.hpp>

class ExampleTm {
	public:
		int width_orig;
		int height_orig;
		int width;
		int height;
		int sx, sy;
		int augnumber;
		int id;
		cv::Mat_<float> shape_gt;
		cv::Rect_<float> bbox_gt;
		cv::Rect_<float> bbox_facedet;
		cv::Mat img_gray;
		std::vector<cv::Mat_<float> > intermediate_shapes;
		std::vector<cv::Rect_<float> > intermediate_bboxes;
		std::vector<cv::Mat_<float> > shapes_residual;
		std::vector<cv::Mat_<float> > meanshape2tf, tf2meanshape;

		ExampleTm(){}
		void InitTm( int max_numstage, int _augnumber, cv::Mat_<float>& meanshape );
		void UpdateTm( int sr, cv::Mat_<float>& meanshape);
		void Set_shape( int sr, cv::Mat_<float> &shape, cv::Mat_<float> &meanshape);
		void Cal_residual( int sr );
		void Save_shape( std::string filename );
		void Show_shape( std::string filename );
		float Error( int sr );
		
};

#endif
