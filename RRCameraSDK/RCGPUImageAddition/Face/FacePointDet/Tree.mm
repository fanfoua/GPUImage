#include "Tree.h"
#include "UtilitiesTm.h"
using namespace std;
using namespace cv;



int Tree::Get_lbf( int stage, int lmID, int sr, ExampleTm &example, float max_radio_radius ) {
	int now = 0;
	Point2i a, b;
	Point2f lm;
	float pdfeat;

	while (!nodes[now].isleafnode) {
		lm = Point2f( example.intermediate_shapes[sr](lmID, 0),  example.intermediate_shapes[sr](lmID, 1));
		Get_two_pixels( a, b, nodes[now].feat[0], nodes[now].feat[1], max_radio_radius, example.intermediate_bboxes[sr],
			example.meanshape2tf[sr], lm, example.width, example.height );
		pdfeat = float( example.img_gray.at<uchar>(a.y, a.x) ) - float( example.img_gray.at<uchar>( b.y, b.x ) );
		if (pdfeat < nodes[now].thresh) now = nodes[now].lc;
		else now = nodes[now].rc;
	}

	return now;
}

void Tree::Get_two_pixels(Point2i &a, Point2i &b, Point2f anglepair, Point2f radiuspair, float max_radio_radius,
				Rect_<float> bbox,Mat_<float> &meanshape2tf,  Point2f lm,  int width, int height) {

	Point2f a_imgcoord, b_imgcoord, a_lmcoord, b_lmcoord;

	a_imgcoord.x = cos( anglepair.x )	* radiuspair.x * max_radio_radius * bbox.width;
	a_imgcoord.y = sin( anglepair.x )	* radiuspair.x * max_radio_radius * bbox.height;

	b_imgcoord.x = cos( anglepair.y )	* radiuspair.y * max_radio_radius * bbox.width;
	b_imgcoord.y = sin( anglepair.y )	* radiuspair.y * max_radio_radius * bbox.height;

	a_lmcoord = Transform_Point( meanshape2tf, a_imgcoord );
	b_lmcoord = Transform_Point( meanshape2tf, b_imgcoord );

	a.x = a_lmcoord.x + lm.x;
	a.y = a_lmcoord.y + lm.y;
	b.x = b_lmcoord.x + lm.x;
	b.y = b_lmcoord.y + lm.y;

	a.x = max( 0, min( a.x, width-1 ) );
	a.y = max( 0, min( a.y, height-1 ) );
	b.x = max( 0, min( b.x, width-1 ) );
	b.y = max( 0, min( b.y, height-1 ) );
}



void Tree::ReadTm( FILE *fin){
	int n;

	fread( &n, sizeof(int), 1, fin );
	nodes.resize( n );
	for (int i = 0;i < n;++i)
		nodes[i].ReadTm( fin );
	fread( &num_leafnodes, sizeof(int), 1, fin );
}


void TNode::ReadTm( FILE *fin){

	feat.resize( 2 );

	fread( &pnode, sizeof(int), 1, fin );
	fread( &depth, sizeof(int), 1, fin );
	fread( &lc, sizeof(int), 1, fin );
	fread( &rc, sizeof(int), 1, fin );
	fread( &isleafnode, sizeof(bool), 1, fin );
	fread( &thresh, sizeof(float), 1, fin );
	fread( &feat[0].x, sizeof(float), 1, fin );
	fread( &feat[0].y, sizeof(float), 1, fin );
	fread( &feat[1].x, sizeof(float), 1, fin );
	fread( &feat[1].y, sizeof(float), 1, fin );

}


