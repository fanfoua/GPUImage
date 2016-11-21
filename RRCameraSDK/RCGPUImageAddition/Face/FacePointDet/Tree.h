#ifndef TREE_H
#define TREE_H

#include <opencv2/opencv.hpp>
#include "ExampleTm.h"
#include <fstream>

class TNode {
	public:
		TNode() {};
		int pnode;
		int depth;
		int lc, rc;
		bool isleafnode;
		std::vector< cv::Point2f > feat;
		std::vector< int > ind_samples;
		float thresh;

		void Set( int _p, int _depth, int _lc, int _rc, bool _isleaf){
			pnode = _p;
			depth = _depth;
			lc = _lc; rc = _rc;
			isleafnode = _isleaf;
		}

		void ReadTm( std::FILE *fin );
};

class Tree {
	public:
		std::vector< TNode > nodes;
		int num_leafnodes;
		Tree() {};

		int Get_lbf( int stage, int lmID, int sr, ExampleTm &example, float max_radio_radius );
		void Get_two_pixels(cv::Point2i &a, cv::Point2i &b, cv::Point2f anglepair, cv::Point2f radiuspair, float max_radio_radius,
				cv::Rect_<float> bbox,  cv::Mat_<float> & meanshape2tf, cv::Point2f lm, int width, int height);
		void ReadTm(std::FILE *fin);
};

#endif
