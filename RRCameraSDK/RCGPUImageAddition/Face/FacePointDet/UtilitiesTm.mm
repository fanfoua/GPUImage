#include "UtilitiesTm.h"
#include <algorithm>
using namespace cv;
using namespace std;


void Get_box( Mat_<float> &shape_gt, Rect_<float> &bbox_gt) {
	float left_x, right_x, top_y, bottom_y;

	left_x = right_x = shape_gt(0, 0);
	top_y = bottom_y = shape_gt(0, 1);

	for (int i = 1;i < shape_gt.rows;++i) {
		left_x = min(left_x, shape_gt(i, 0));
		right_x = max(right_x, shape_gt(i, 0));
		top_y = min(top_y, shape_gt(i, 1));
		bottom_y = max(bottom_y, shape_gt(i, 1));
	}
	bbox_gt = Rect_<float>(left_x, top_y, right_x - left_x, bottom_y - top_y);
}

Rect_<float> Enlarging_box( Rect_<float> &bbox_gt, float scale, float width, float height ) {
	Rect_<float> bbox;

	bbox.x = max(floor( bbox_gt.x - (scale-1)/2*bbox_gt.width ), 1.0f);
	bbox.y = max(floor( bbox_gt.y - (scale-1)/2*bbox_gt.height ), 1.0f);

	bbox.width = min(floor( scale * bbox_gt.width ), width-bbox.x);
	bbox.height = min(floor( scale * bbox_gt.height ), height-bbox.y);

	return bbox;
}

//reset the initial shape according to the groundtruth shape and union shape for all faces
Mat_<float> Reset_shape( Rect_<float> &bbox, Mat_<float> &shape_union ) {
	Rect_<float> bbox_union;
	Mat_<float> shape_initial;

	shape_initial.create(shape_union.rows, 2);
	Get_box( shape_union, bbox_union );
	for (int i = 0;i < shape_union.rows;++i) {
		shape_initial(i, 0) = (shape_union(i, 0)-bbox_union.x) * bbox.width / bbox_union.width + bbox.x;
		shape_initial(i, 1) = (shape_union(i, 1)-bbox_union.y) * bbox.height / bbox_union.height + bbox.y;
	//	printf("%lf %lf\n", shape_initial(i, 0), shape_initial(i, 1));
	}

	return shape_initial;
}

// add by liu
Mat_<float> Reset_shape( Rect_<float> &bbox, Mat_<float> &shape_union,int flag) {
	Rect_<float> bbox_union;
	Mat_<float> shape_initial;

	shape_initial.create(shape_union.rows, 2);
	Get_box( shape_union, bbox_union );
	for (int i = 0;i < shape_union.rows;++i) {
		//shape_initial(i, 0) = (shape_union(i, 0)-bbox_union.x) * bbox.width / bbox_union.width + bbox.x;
		//shape_initial(i, 1) = (shape_union(i, 1)-bbox_union.y) * bbox.height / bbox_union.height + bbox.y;
		shape_initial(i, 0) = (shape_union(i, 0)) * bbox.width  + bbox.x;
		shape_initial(i, 1) = (shape_union(i, 1)) * bbox.height + bbox.y;
		//	printf("%lf %lf\n", shape_initial(i, 0), shape_initial(i, 1));
	}

	return shape_initial;

}





//calculate affine transformation 
Mat_<float> Cal_affinetrans( Mat_<float> &A, Mat_<float> &B ) {
	float A_xm, A_ym, B_xm, B_ym;
	vector<Point2f> APoints, BPoints;

	A_xm = A_ym = B_xm = B_ym = 0;
	for (int i = 0;i < A.rows; ++i) {
		A_xm += A(i, 0); A_ym += A(i, 1);
		B_xm += B(i, 0); B_ym += B(i, 1);
	}
	A_xm /= A.rows; A_ym /= A.rows;
	B_xm /= B.rows; B_ym /= B.rows;
	for (int i = 0;i < A.rows;++i) {
		APoints.push_back(Point2f(A(i, 0) - A_xm, A(i, 1) - A_ym));
		BPoints.push_back(Point2f(B(i, 0) - B_xm, B(i, 1) - B_ym));
	}
	Mat_<float> a;

	a.create(2, 3);
	a(0, 0) = 1; a(0, 1) = 0; a(0, 2) = 0;
	a(1, 0) = 0; a(1, 1) = 1; a(1, 2) = 0;
	
	return  My_estimateNonflecTransform( APoints, BPoints );
}


Mat_<float> My_estimateNonflecTransform( vector<Point2f> &APoints, vector<Point2f> &BPoints ){
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

Point2f Transform_Point( Mat_<float> &affine, Point2f a ) {

	return Point2f( affine(0,0) * a.x + affine(0,1) * a.y + affine(0,2), affine(1,0) * a.x + affine(1,1) * a.y + affine(1,2) );
}

Mat_<float> Transform_Points( Mat_<float> &affine, Mat_<float> &a ) {
	Mat_<float> tmp, result;

//	show_mat( affine, "affine");
//	show_mat( a, "a");
	tmp.create(3, a.rows);
	for (int i = 0;i < a.rows;++i){
		tmp(0, i) = a(i, 0);
		tmp(1, i) = a(i, 1);
		tmp(2, i) = 1;
	}
	result = affine * tmp;
	return result.t();
}

//get random features
void Getproposal( int numfeats, vector< Point2f > &radiuspairs, vector< Point2f > &anglepairs ) {
	int num_radius = 31;
	int num_angles = 37;
	int n = 0, radius_a, angle_a, radius_b, angle_b;

	vector<int> P_a, P_b;
	Rand_Perm( num_radius*num_angles, P_a );
	Rand_Perm( num_radius*num_angles, P_b );
//	for (int i = 0;i < num_radius*num_angles;++i)
//		P_b[i] ++;
//	P_b[num_radius*num_angles-1] = 0;

	radiuspairs.clear(); anglepairs.clear();
	for (int i = 0;i < num_radius*num_angles;++i) {
		if (n++ == numfeats) break;
		if (P_a[i] == P_b[i]) continue;
		radius_a = P_a[i] / num_angles; angle_a = P_a[i] % num_angles;
		radius_b = P_b[i] / num_angles; angle_b = P_b[i] % num_angles;

		radiuspairs.push_back( Point2f(1.0*radius_a/(num_radius-1), 1.0*radius_b/(num_radius-1)) );
		anglepairs.push_back( Point2f( 2*M_PI*angle_a/(num_angles-1), 2*M_PI*angle_b/(num_angles-1) ) );
	}
}

void Rand_Perm( int num, vector<int> &P ) {
	P.resize( num );
	for (int i = 0;i < num;++i) 
		P[i] = i;
	random_shuffle( P.begin(), P.end() );
}


float Euc_dis( float x, float y ) {
	return sqrt( x*x+y*y );
}


