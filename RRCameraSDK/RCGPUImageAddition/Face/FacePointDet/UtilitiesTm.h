#ifndef UtilitiesTm_H
#define UtilitiesTm_H

#include <opencv2/opencv.hpp>
#include <string>
#include <ctime>
#include <math.h>
#include "ExampleTm.h"
//#include "liblinear/linear.h"
#include "Tree.h"

# define M_PI         (3.14159265358979323846) /* pi */
# define M_eps        (1e-5) 
//# define LM_NUM       (19)

# define FACE_SIZE     (70)   //minimum detect face size 


void Get_box( cv::Mat_<float> &shape_gt, cv::Rect_<float> &bbox_gt);
cv::Rect_<float> Enlarging_box( cv::Rect_<float> &bbox_gt, float scale, float width, float height );
cv::Mat_<float> Reset_shape( cv::Rect_<float> &bbox, cv::Mat_<float> &shape_union );
cv::Mat_<float> Reset_shape( cv::Rect_<float> &bbox, cv::Mat_<float> &shape_union,int flag);  // add by liu


cv::Mat_<float> Cal_affinetrans( cv::Mat_<float> &A, cv::Mat_<float> &B );
cv::Point2f Transform_Point( cv::Mat_<float> &affine, cv::Point2f a );
cv::Mat_<float> Transform_Points( cv::Mat_<float> &affine, cv::Mat_<float> &a );
cv::Mat_<float> My_estimateNonflecTransform( std::vector<cv::Point2f> &APoints, std::vector<cv::Point2f> &BPoints );
void Getproposal( int numfeats, std::vector< cv::Point2f > &radiuspairs, std::vector< cv::Point2f > &anglepairs );
void Rand_Perm( int num, std::vector<int> &P );


float Euc_dis( float x, float y );



#endif
