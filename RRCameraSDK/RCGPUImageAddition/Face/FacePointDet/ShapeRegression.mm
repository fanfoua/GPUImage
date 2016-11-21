#include "ShapeRegressor.h"
#include "UtilitiesTm.h"
#include "opencv2/objdetect/objdetect.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <opencv2/imgcodecs/ios.h>
#include "picornt.h"
#include "Nativeclass.h"
#define QUICK_FACE_DET 1
#define OPENCV_FACE_DET 2
#define FACE_DET_CHOICE OPENCV_FACE_DET //QUICK_FACE_DET //OPENCV_FACE_DET //
using namespace std;
using namespace cv;
#define POINTER_OFFSET(pointer,value,type) \
memcpy(&(value), pointer, sizeof(type));\
pointer+=sizeof(type);

int readInt(char* &p){
    int * pint = (int*)p;
    int re = pint[0];
    pint++;
    p = (char*)pint;
    return re;
}
float readDoubletest(char* &p){
    float * pint = (float*)p;
    float re = pint[0];
    p+=8;
    return re;
}
double readDouble(char* &p){
    double * pint = (double*)p;
    double re = pint[0];
    pint++;
    p = (char*)pint;
    return re;
}

void readTree(char* &buff,Tree & tree)
{
    //int n = readInt(buff);
    int n;
    POINTER_OFFSET(buff,n,int);
    tree.nodes.resize(n);
    
    for (int i=0; i<n; i++) {
        tree.nodes[i].feat.resize(2);
        POINTER_OFFSET(buff,tree.nodes[i].pnode,int);
        POINTER_OFFSET(buff,tree.nodes[i].depth,int);
        POINTER_OFFSET(buff,tree.nodes[i].lc,int);
        POINTER_OFFSET(buff,tree.nodes[i].rc,int);
        POINTER_OFFSET(buff,tree.nodes[i].isleafnode,bool);
        POINTER_OFFSET(buff,tree.nodes[i].thresh,float);
        POINTER_OFFSET(buff,tree.nodes[i].feat[0].x,float);
        POINTER_OFFSET(buff,tree.nodes[i].feat[0].y,float);
        POINTER_OFFSET(buff,tree.nodes[i].feat[1].x,float);
        POINTER_OFFSET(buff,tree.nodes[i].feat[1].y,float);
        /*
        tree.nodes[i].pnode = readInt(buff);
        tree.nodes[i].depth = readInt(buff);
        tree.nodes[i].lc = readInt(buff);
        tree.nodes[i].rc = readInt(buff);
        tree.nodes[i].isleafnode = buff[0]; buff++;
        //tree.nodes[i].thresh = readDouble(buff);

//        tree.nodes[i].feat[0].x = (float)readDouble(buff);
        double t1 =readDoubletest(buff);
        
        tree.nodes[i].feat[0].x = (float)t1;
        tree.nodes[i].feat[0].y = (float)readDoubletest(buff);
        tree.nodes[i].feat[1].x = (float)readDoubletest(buff);
        tree.nodes[i].feat[1].y = (float)readDoubletest(buff);*/
        
    }
    
    //tree.num_leafnodes = readInt(buff);
    POINTER_OFFSET(buff,tree.num_leafnodes,int);
}

void ShapeRegressor::load_pico_model(const char *path){
    int size;
    FILE* file;
    //
    file = fopen(path,"rb");
    
    if(!file){
        return;
    }
    
    fseek(file, 0L, SEEK_END);
    size = ftell(file);
    fseek(file, 0L, SEEK_SET);
    
    cascade_pico = malloc(size);
    
    if(!cascade_pico)
        return;
    
    if (size!=fread(cascade_pico, 1, size, file)){
        free(cascade_pico);
        cascade_pico = NULL;
        return;
    }
    
    fclose(file);
}


void ShapeRegressor::Face_detect_pico(void * cascade, cv::Mat &img,std::vector<cv::Rect_<float> > &faces)
{
    
    if(img.channels()!=1){
    }
    
    faces.clear();
    
    IplImage iplimg(img);
    int minsize = 150;
    int maxsize = 1028;
    float angle = 0;
    float scalefactor = 1.3;
    float stridefactor = 0.1;
    float qthreshold = 5.0;
    
    float qs[100], rs[100], cs[100], ss[100];
    
    int num = find_objects(rs, cs, ss, qs, 100, cascade_pico, 0, (void*)iplimg.imageData, iplimg.height, iplimg.width, iplimg.widthStep, scalefactor, stridefactor, minsize, min(iplimg.height,iplimg.width));
    num = cluster_detections(rs, cs, ss, qs, num);
    
    int k=0;
    for(int i=0; i<num&&i<3; ++i){
        if (qs[i]>qthreshold)
        {
            Rect_<float> rect = Rect_<float>(cs[i]-ss[i]/2,rs[i]-ss[i]/2,ss[i],ss[i])&Rect_<float>(0,0,img.cols,img.rows);
            faces.push_back(rect);
            //			LOGE("face Rect %d [%f,%f,%f,%f]",i,rect.x,rect.y,rect.width,rect.height);
        }
    }

    return;
}


ShapeRegressor::ShapeRegressor(const string config_file,const string face_cascade_name,const string model_path) {
    
    buffer = NULL;
    cascade_pico = NULL;

	srand( unsigned( time(0) ) );
	FileStorage fs;
	fs.open(config_file, FileStorage::READ);

	if(!fs.isOpened())
		cout<<"error file load"<<endl;

	Read_config( fs );
	fs.release();

#if FACE_DET_CHOICE==QUICK_FACE_DET
	load_pico_model(face_cascade_name.c_str());
#elif FACE_DET_CHOICE==OPENCV_FACE_DET
    if( !face_cascade.load( face_cascade_name ) ){ printf("--(!)Error loading face_cascade\n");  };
#endif

	Load_model(const_cast<char*>(model_path.c_str()));

    //load_pico_model(face_cascade_name.c_str());
//    m_face_rect = cv::Rect(0,0,300,300);

	test_mode = false;
}



void ShapeRegressor::Read_config( const FileStorage& file ) {
	file["train_augnumber"] >> train_augnumber;
	file["max_numfeats"] >> max_numfeats;
	file["bagging_overlap"] >> bagging_overlap;
	file["max_radio_radius"] >> max_radio_radius;
	file["max_numtrees"] >> max_numtrees;
	file["max_depth"] >> max_depth;
	file["max_numstage"] >> max_numstage;	
	file["LM_NUM"] >> lm_num;
}


//Derive binary features for each sample given learned random forest
void ShapeRegressor::Derive_binaryfeat( int stage, vector<vector<int> > &binfeatures ) {
	int leafid, idx, sr;
	int m, now;

	m = examples.size()*augnumber;
	
	binfeatures.resize( m );
	for (int i = 0;i < m;++i) {
		idx = i / augnumber;
		sr = i % augnumber;

		binfeatures[i].clear();
		now = 0;
		for (int j = 0;j < lm_num;++j) 
			for (int t = 0;t < max_numtrees;++t) {
				leafid = randf[stage][j][t].Get_lbf( stage, j, sr, examples[idx], max_radio_radius[stage] );
				binfeatures[i].push_back( now + leafid - (1 << (max_depth-1)) + 1 );
				now += randf[stage][j][t].num_leafnodes;
			}
	}
}



void ShapeRegressor::Global_predict( int stage, vector<vector<int> > &binfeatures ){
	Mat_<float> row, deltashape, deltashape_lm, pred_shape;
	int m = examples.size()*augnumber;
	int idx, sr;

	deltashape.create( lm_num, 2);
	for (int i = 0;i < m;++i) {
		idx = i / augnumber;
		sr = i % augnumber;
		row = Mat::zeros( 1, lm_num*2, CV_64F);
		for (int j = 0;j < binfeatures[i].size();++j){
			row += Ws[stage].row( binfeatures[i][j] );
		}

		for (int j = 0;j < lm_num;++j)
			for (int k = 0;k < 2;++k)
				deltashape(j,k) = row(0, j*2+k);

		deltashape_lm = Transform_Points( examples[idx].meanshape2tf[sr], deltashape );

		for (int j = 0;j < lm_num;++j) {
			deltashape_lm(j, 0) *= examples[idx].intermediate_bboxes[sr].width;
			deltashape_lm(j, 1) *= examples[idx].intermediate_bboxes[sr].height;
		}

		examples[idx].intermediate_shapes[sr] += deltashape_lm;
		//pred_shape.copyTo(examples[i].intermediate_shapes[stage+1]);                 //mat need deep copy!

		examples[idx].UpdateTm( sr, meanshape );
	}
}



void ShapeRegressor::Load_model(char * path) {
    printf("Loading model...\n");
	FILE *fin = fopen(path, "rb");
	if (fin == NULL) {
		printf("Load model failed\n");
		return;
	}
	this->Read( fin );
//	fclose( fin );
	printf("Loading model over\n");
}


/************************************************************************/
/* ÃÌº”¥¶¿Ì“ª∏ˆÕºœÒµƒ∫Ø ˝£¨∑µªÿ±Íº«µ„µƒΩ·π˚                                                                     */
/************************************************************************/

Mat* ShapeRegressor::Predict(Mat & img)
{
	vector<vector<int> > binfeatures;

	if (img.empty())
	{
		return NULL;
	}
    augnumber = 1;
    
//    double t0 = (double)cvGetTickCount();
    Load_Mat( img );
//    t0 = (double)cvGetTickCount() - t0;
//    printf( "人脸检测：%gms\n", t0/(cvGetTickFrequency()*1000) );
//    UIImage * result=MatToUIImage(img);///////Test///////////
    if(examples.empty())
    {
        
        return NULL;
    }
    
    printf("load samples over\n");
    
    for (int i = 0;i < examples.size();++i){
        examples[i].InitTm( max_numstage, 1, meanshape );
    }

//	start = clock();
    
	for (int i = 0;i < max_numstage;++i) {
        
        double t = (double)cvGetTickCount();
		Derive_binaryfeat( i, binfeatures );
        t = (double)cvGetTickCount() - t;
        printf( "关键点随机树：%gms\n", t/(cvGetTickFrequency()*1000) );
//		printf("binfeatures over\n");
        
        double t2 = (double)cvGetTickCount();
		Global_predict( i,  binfeatures );
        t2 = (double)cvGetTickCount() - t2;
        printf( "矩阵：%gms\n", t2/(cvGetTickFrequency()*1000) );
//		printf("regression over\n");
	}
    
//	end = clock();
//	LOGE("lbf: %fms",(double)(end-start)/CLOCKS_PER_SEC*1000);

    
	static Mat shape[10];
    for (int i=0; i<10; i++)
    {
        shape[i].create(lm_num*2, 1, CV_32S);//int
    }
    int maxFaceCount=10;
    int faceCount = examples.size();
    faceCount = min(maxFaceCount,faceCount);
	int sc=3;
	for (int i =0;i<faceCount;i++)
	{
		sc = (int)max(examples[i].bbox_facedet.width/70,1.0f);
		for (int j=0;j<lm_num;j++)
		{
            //circle(img,cv::Point(examples[i].intermediate_shapes[0](j,0)+examples[i].sx,examples[i].intermediate_shapes[0](j,1)+examples[i].sy),sc,Scalar(255,0,0),2);///////Test///////////

            shape[i].at<int>(j*2)=examples[i].intermediate_shapes[0](j,0)+examples[i].sx;
            shape[i].at<int>(j*2+1)=examples[i].intermediate_shapes[0](j,1)+examples[i].sy;
			//shape[i].push_back((int)(examples[i].intermediate_shapes[0](j,0)+examples[i].sx));
			//shape[i].push_back((int)(examples[i].intermediate_shapes[0](j,1)+examples[i].sy));
		}
	}
//UIImage * result=MatToUIImage(img);///////Test///////////
//	if(camera_flag ==1)
//		return img;

	return &shape[0];
}

void ShapeRegressor::Load_Mat( Mat &img)
{

	int n = 0, id = -1;

	Mat img_region;
	Rect_<float> region;
    vector<cv::Rect> faces;
#if FACE_DET_CHOICE==QUICK_FACE_DET
    Face_detect_pico(cascade_pico,img,faces);
#elif FACE_DET_CHOICE==OPENCV_FACE_DET
    Face_detect( face_cascade, img, faces);
#endif
	
//    CV_EXPORTS_W void rectangle(InputOutputArray img, Point pt1, Point pt2,
//                                const Scalar& color, int thickness = 1,
//                                int lineType = LINE_8, int shift = 0);
    int maxW=0;
    int maxInd=0;
    for (int j=0; j<faces.size(); j++)
    {
        if (faces[j].width>maxW)
        {
            maxW=faces[j].width;
            maxInd=j;
        }
    }
	for (int i = 0;i < faces.size();++i)
	{
        if(i!=maxInd)
        {
            continue;
        }
        //rectangle(img,cv::Point(faces[i].x,faces[i].y),cv::Point(faces[i].x+faces[i].width,faces[i].y+faces[i].height),Scalar(255,0,0));///////Test///////////
		examples.push_back( ExampleTm() );

		examples[n].width_orig = img.cols;
		examples[n].height_orig = img.rows;
		examples[n].bbox_facedet = faces[i];

		region = Enlarging_box( examples[n].bbox_facedet, 1.5, examples[n].width_orig, examples[n].height_orig );
		img_region = Mat(img, region );

		examples[n].bbox_facedet.x -=  region.x;
		examples[n].bbox_facedet.y -=  region.y;

		if (img_region.channels() == 1)
			img_region.copyTo( examples[n].img_gray );
		else {
			cvtColor(img_region, examples[n].img_gray, CV_BGR2GRAY);
		}

		examples[n].width = img_region.cols;
		examples[n].height = img_region.rows;
		examples[n].sx = region.x; examples[n].sy = region.y;
		examples[n].id = id;
		n++;
	}
}



/*
void ShapeRegressor::Read(FILE * fin) {
    
//    fseek(fin, 0 , SEEK_END);
//    long size = ftell(fin);
//    rewind(fin);
//    
//    char *buffer = new char[size];
//    
//    fread(buffer, sizeof(char),size , fin);
//    fclose(fin);
    
    
    
	int rows, cols;
    int i,j,k;
    randf.resize( max_numstage );
    
	for (i = 0;i < max_numstage;++i) {
		randf[i].resize( lm_num );
		for (j = 0;j < lm_num;++j) {
			randf[i][j].resize( max_numtrees );
			for (k = 0;k < max_numtrees;++k) {
				//randf[i][j][k] = Tree();
				randf[i][j][k].ReadTm( fin );
 //               cout<<"randf: "<<i<<j<<k<<endl;
			}
		}
	}
    
	Ws.resize( max_numstage );
	for (i = 0;i < max_numstage;++i){
		fread( &rows, sizeof(int), 1, fin);
		fread( &cols, sizeof(int), 1, fin);
		Ws[i].create( rows, cols );
        
        fread(Ws[i].ptr<double>(0),sizeof(double),rows*cols,fin);
    }
    
//	for (j = 0;j < rows;++j)
//            for (k = 0;k < cols;++k){
//                fread( &Ws[i](j,k), sizeof(double), 1, fin );
//                cout<<"ws: "<<i<<j<<k<<endl;
//            }
        
//    }
    
	meanshape.create( lm_num, 2 );
//	for (i = 0;i < lm_num;++i)
//        for (j = 0;j < 2;++j){
//            fread( &meanshape(i,j), sizeof(double), 1, fin );
//            cout<<"meanshape: "<<i<<j<<endl;
//        }
    fread(meanshape.ptr<double>(0),sizeof(double),lm_num*2,fin);
    
  //  fclose(fin);
}
*/





// for images
void ShapeRegressor::Face_detect( CascadeClassifier &face_cascade, Mat img, vector<cv::Rect> &faces ) {
	Mat img_gray;
    int FaceSize = max(img.rows,img.cols)/6;
    
	//equalizeHist( img_gray, img_gray );

//	 //-- Detect faces CV_HAAR_SCALE_IMAGE|
//    face_cascade.detectMultiScale(img_gray, faces, 1.4, 0, 0|CV_HAAR_FIND_BIGGEST_OBJECT,  cv::Size(FACE_SIZE, FACE_SIZE)  );
    //-- Detect faces CV_HAAR_SCALE_IMAGE|
#ifdef TEST_TIME
    double t = (double)cvGetTickCount();
    ////代码段
#endif
    face_cascade.detectMultiScale(img, faces, 1.4, 3, 0,  cv::Size(FaceSize, FaceSize)  );
#ifdef TEST_TIME
    t = (double)cvGetTickCount() - t;
    printf( "人脸检测：%gms\n", t/(cvGetTickFrequency()*1000) );
#endif
}

void ShapeRegressor::Read(FILE * fin) {
    
        fseek(fin, 0 , SEEK_END);
        long size = ftell(fin);
        rewind(fin);
    
        buffer = new char[size];
    
    //buffer = (char *)malloc(10);
        fread(buffer, sizeof(char),size , fin);
        fclose(fin);
    
    char * pp=buffer;
    
    int rows, cols;
    int i,j,k;
    randf.resize( max_numstage );
    
    for (i = 0;i < max_numstage;++i) {
        randf[i].resize( lm_num );
        for (j = 0;j < lm_num;++j) {
            randf[i][j].resize( max_numtrees );
            for (k = 0;k < max_numtrees;++k) {
                
                readTree(pp,randf[i][j][k]);
            }
        }
    }
    
    Ws.resize( max_numstage );
    for (i = 0;i < max_numstage;++i){
//        fread( &rows, sizeof(int), 1, fin);
//        fread( &cols, sizeof(int), 1, fin);
        POINTER_OFFSET(pp,rows,int);
        POINTER_OFFSET(pp,cols,int);
        //rows = readInt(pp);
        //cols = readInt(pp);
        Ws[i].create(rows,cols);
        memcpy(Ws[i].data, pp, sizeof(float)*rows*cols);
        //Ws[i]=Mat(rows,cols,CV_64FC1,(float*)pp);
        pp +=rows*cols*sizeof(float)/sizeof(char);
 //       fread(Ws[i].ptr<double>(0),sizeof(double),rows*cols,fin);
    }
    
    //	for (j = 0;j < rows;++j)
    //            for (k = 0;k < cols;++k){
    //                fread( &Ws[i](j,k), sizeof(double), 1, fin );
    //                cout<<"ws: "<<i<<j<<k<<endl;
    //            }
    
    //    }
    
    meanshape.create(lm_num, 2);
    memcpy(meanshape.data, pp, sizeof(float)*lm_num*2);
   //meanshape = Mat(lm_num,2,CV_64FC1,(double*)pp);
    
    if (buffer !=  NULL) {
        delete[] buffer;
        buffer = NULL;
    }
    
 //   meanshape.create( lm_num, 2 );
    //	for (i = 0;i < lm_num;++i)
    //        for (j = 0;j < 2;++j){
    //            fread( &meanshape(i,j), sizeof(double), 1, fin );
    //            cout<<"meanshape: "<<i<<j<<endl;
    //        }
 //   fread(meanshape.ptr<double>(0),sizeof(double),lm_num*2,fin);
    
    //  fclose(fin);
}




