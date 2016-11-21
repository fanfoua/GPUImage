#include "ExampleTm.h"
#include "UtilitiesTm.h"
using namespace std;
using namespace cv;

void ExampleTm::InitTm( int max_numstage, int _augnumber, Mat_<float>& meanshape ) {
	Mat_<float> shape_facedet;

	augnumber = _augnumber;
	intermediate_shapes.resize( augnumber );
	intermediate_bboxes.resize( augnumber );
	shapes_residual.resize( augnumber );
	tf2meanshape.resize( augnumber );
	meanshape2tf.resize( augnumber );

	int flag = 0;

	intermediate_shapes[0] = Reset_shape( bbox_facedet, meanshape,flag);    //调用这个函数

	UpdateTm(0, meanshape );

}

void ExampleTm::UpdateTm( int sr, Mat_<float>& meanshape) {
	Mat_<float> meanshape_resize;

	Get_box( intermediate_shapes[sr], intermediate_bboxes[sr] );
	meanshape_resize = Reset_shape( intermediate_bboxes[sr], meanshape );
	tf2meanshape[sr] = Cal_affinetrans( intermediate_shapes[sr], meanshape_resize );
	meanshape2tf[sr] = Cal_affinetrans( meanshape_resize, intermediate_shapes[sr] );
	
//	if (shape_gt.dims > 0) Cal_residual( sr );
}

void ExampleTm::Set_shape( int sr, Mat_<float> &shape, Mat_<float> &meanshape) {
	intermediate_shapes[sr] = Reset_shape( bbox_facedet, shape );
	UpdateTm( sr, meanshape );
}

