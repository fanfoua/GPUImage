//
//  RRPhotoFilter.m
//  RROpenCV
//
//  Created by lych on 10/23/12.
//  Copyright (c) 2012 lych. All rights reserved.
//
#import <math.h>
#import "RRPhotoFilter.h"
#include "RRFilterTool.h"

float _neutralPointSh = 20.0;
float _neutralCPoint = 110;
float _colorMaskWeight = 0.4;
int _colCurvePoints[4] = {10,40,70,97};

int  _brgCrvPoints[4] = {2,35,60,95};
float _brgCrv[6] = {10,22,72,128,195,245};
float _brgCrvWeight = 0.5;
float _br_limits[3] = {40,1.1,30};

float _colCurve_max[6] = {0.0,0.2,0.25,0.33,0.60,500};
float _colCurve_min[6] = {0.0,0.1,0.14,0.28,0.46,500};
float _colCurveWeight =  0.55;
float _sat_limits[3] = {0,1.6,0.5};

float _sharpCurve[5] = {0.0,0.18, 0.50, 1.30 ,50};
float _sharpCurveWeight = 0.55;
float _sharp_limits[3]={0,1.65,0.2};



enum BrightnessWarning BrightnessDetection(void *inImage, uint width, uint height)
{
    if (inImage == NULL) {
        return kNoWarning;
    }
    
    unsigned char *imgPixel = (unsigned char *)inImage;
    
    uint h = height, w = width;
    
    int subSampleWidth=0;
    int subSampleHeight=0;
    
    
    
    if (h*w >= 640*480) {
        
        subSampleWidth=3;
        subSampleHeight=3;
        
    }
    else if(h*w >= 352 *288)
    {
        subSampleWidth=2;
        subSampleHeight=2;
    
    }
    else if(h*w >= 176*144)
    {
        subSampleWidth=1;
        subSampleHeight=1;
        
    }
    else
    {
        subSampleWidth=0;
        subSampleHeight=0;
    }
    
    int imageHist[256]={0};
    int sum=0;
    int tr = 0, tg = 0, tb = 0;
    
    int numPixels=0;
    int mean=0;
    
    for (int i=0; i< h; i+= (1 << subSampleHeight)) {
       
        for (int j=0; j<w*4; j+= ((1 << subSampleWidth))*4) {
           
            tr = imgPixel[4*i*w + j];
            tg = imgPixel[4*i*w + j + 1];
            tb = imgPixel[4*i*w + j + 2];
            
            // Y = 0.299 * R + 0.587 * G + 0.114 * B;
            int Y=0.299*tr+0.587*tg+0.114*tb;
            Y=pixelRange(Y);
            imageHist[Y]++;
            sum+=Y;
        }
    }
    
    numPixels=(w*h)/((1<< subSampleWidth)*(1<<subSampleHeight));
    mean=sum/numPixels;
    
    int frameCntAlarm=2;
    int _frameCntBright = 0;
    int  _frameCntDark = 0;

    
    // Get proportion in lowest bins
    int lowTh=20;
    float propLow=0;
    
    for (int i=0; i < lowTh; i++) {
        propLow+=imageHist[i];
    }
    
    propLow/=numPixels;
    
    // Get proportion in highest bins 
    int highTh=230;
    float propHigh=0;
    for (int i=highTh; i< 256; i++) {
        propHigh+=imageHist[i];
    }
    propHigh/=numPixels;
    
    if (propHigh < 0.4) {
        if (mean < 90 || mean > 170) {
            
            float stdY=0;
            //--------------------
            for (int i=0; i< h; i+= (1 << subSampleHeight)) {
              //  int row=h*w;
                
                for (int j=0; j<w*4; j+= ((1 << subSampleWidth))*4) {
                    
                    tr = imgPixel[4*i*w + j];
                    tg = imgPixel[4*i*w + j + 1];
                    tb = imgPixel[4*i*w + j + 2];
                    
                    // Y = 0.299 * R + 0.587 * G + 0.114 * B;
                    int Y=0.299*tr+0.587*tg+0.114*tb;
                    Y=pixelRange(Y);
                    
                    stdY+=(Y-mean)*(Y-mean);
                }
            }

            //--------------------------for
            stdY=sqrt(stdY/numPixels);
            
            int sums=0;
            int medianY=140;
            int perc05=0;
            int perc95=255;
            
            float posPerc05 = numPixels * 0.05f;
            float posMedian = numPixels * 0.5f;
            float posPerc95 = numPixels * 0.95f;
            
            //-----------
            for (int i=0; i < 256; i++) {
                sums+=imageHist[i];
                
                if (sums < posPerc05) {
                    perc05=i;
                }
                if (sums < posMedian) {
                    medianY=i;
                }
                if (sums <posPerc95) {
                    posPerc95=i;
                }
                else
                {
                    break;
                }
            }
            //----------------
             // Check if image is too dark
            if ((stdY < 55) && (perc05 < 50))
            {
                if (medianY < 60 || mean < 80 ||  perc95 < 130 ||
                    propLow > 0.20)
                {
                    _frameCntDark++;
                }
                else
                {
                    _frameCntDark = 0;
                }
            }
            else
            {
                _frameCntDark = 0;
            }

            // Check if image is too bright
            if ((stdY < 52) && (perc95 > 200) && (medianY > 160))
            {
                if (medianY > 185 || mean > 185 || perc05 > 140 ||
                    propHigh > 0.25)
                {
                    _frameCntBright++;
                }
                else
                {
                    _frameCntBright = 0;
                }
            }
            else
            {
                _frameCntBright = 0;
            }
           
            

        }
        else
        {
            _frameCntDark = 0;
            _frameCntBright = 0;
        }

               
      
    }else
    {
        _frameCntBright++;
        _frameCntDark = 0;
        NSLog(@"kBrightWarning");
    }
    
    
    if (_frameCntDark > frameCntAlarm)
    {
        NSLog(@" dark waring");
        return kDarkWarning;
        
    }
    else if (_frameCntBright > frameCntAlarm)
    {
        NSLog(@"kBrightWarning");

        return kBrightWarning;
    }
    else
    {
        NSLog(@"kNoWarning");

        return kNoWarning;
    }
    
}

void ImageWhitenFilter(void *inImage, uint width, uint height, uint repeat)
{
    if (inImage == NULL) {
        return ;
    }
    
    unsigned char *imgPixel = (unsigned char *)inImage;
    
    uint h = height, w = width;
    int tr = 0, tg = 0, tb = 0;
    double coeff = 0.0;
    
    int ttb,ttg,ttr;
    for (int j = 0; j < h; j++) {
        for (int i = 0; i < 4*w; i=i+4) {
            tb = imgPixel[4*j*w + i];
            tg = imgPixel[4*j*w + i + 1];
            tr = imgPixel[4*j*w + i + 2];
                     
            // (tb+tg+tr)/255.0/3.0
            
            // first time
            coeff=((tb+tg+tr)/765.0)*0.8;
            
            ttb = tb*coeff;
            ttg = tg*coeff;
            ttr = tr*coeff;
            
            tb=255-((255-ttb)*(255-tb))/255;
            tg=255-((255-ttg)*(255-tg))/255;
            tr=255-((255-ttr)*(255-tr))/255;
            
            // second time
            coeff=((tb+tg+tr)/765.0)*0.8;
            
            ttb = tb*coeff;
            ttg = tg*coeff;
            ttr = tr*coeff;
            
            tb = 255-((255-ttb)*(255-tb))/255;
            tg = 255-((255-ttg)*(255-tg))/255;
            tr = 255-((255-ttr)*(255-tr))/255;
            
            // third time
            coeff=((tb+tg+tr)/765.0)*0.7;
            
            ttb=tb*coeff;
            ttg=tg*coeff;
            ttr=tr*coeff;
            
            tb=255-((255-ttb)*(255-tb))/255;
            tg=255-((255-ttg)*(255-tg))/255;
            tr=255-((255-ttr)*(255-tr))/255;
                       
            
//            RGB rgb={static_cast<double>(tr),static_cast<double>(tg),static_cast<double>(tb)};
            RGB rgb = {tr,tg,tb};
            HSI hsi=RGBTOHSI(rgb);

            hsi.s=hsi.s*1.1;
            
//             hsi.i=(hsi.i-Imin)/(Imax-Imin);
//            hsi.i=(hsi.i-Imin)/(Imax-Imin);
//            hsi.i=(hsi.i-Imin)/(Imax-Imin);

            rgb=HSITORGB(hsi);
            
            tr=rgb.r;
            tb=rgb.b;
            tg=rgb.g;
                                  
            imgPixel[4*j*w + i] = pixelRange(tb);
            imgPixel[4*j*w + i + 1] = pixelRange(tg);
            imgPixel[4*j*w + i + 2] = pixelRange(tr);
        }
    }
}


void ImageWhitenFilterTest(void *inImage, uint width, uint height, uint repeat)
{
    if (inImage == NULL) {
        return ;
    }
    
    unsigned char *imgPixel = (unsigned char *)inImage;
    
    uint h = height, w = width;
    int tr = 0, tg = 0, tb = 0;
    double coeff = 0.0;
    
    int ttb,ttg,ttr;
    for (int j = 0; j < h; j++) {
        for (int i = 0; i < 4*w; i=i+4) {
            tb = imgPixel[4*j*w + i];
            tg = imgPixel[4*j*w + i + 1];
            tr = imgPixel[4*j*w + i + 2];
          
            // (tb+tg+tr)/255.0/3.0
            
            // first time
            coeff=((tb+tg+tr)/765.0)*0.3;
            
            ttb = tb*coeff;
            ttg = tg*coeff;
            ttr = tr*coeff;
            
            tb=255-((255-ttb)*(255-tb))/255;
            tg=255-((255-ttg)*(255-tg))/255;
            tr=255-((255-ttr)*(255-tr))/255;
            
//            // second time
//            coeff=((tb+tg+tr)/765.0)*0.1;
//            
//            ttb = tb*coeff;
//            ttg = tg*coeff;
//            ttr = tr*coeff;
//            
//            tb=255-((255-ttb)*(255-tb))/255;
//            tg=255-((255-ttg)*(255-tg))/255;
//            tr=255-((255-ttr)*(255-tr))/255;
            
                       
                       
            //             hsi.i=(hsi.i-Imin)/(Imax-Imin);
            //            hsi.i=(hsi.i-Imin)/(Imax-Imin);
            //            hsi.i=(hsi.i-Imin)/(Imax-Imin);
//            RGB rgb={static_cast<double>(tr),static_cast<double>(tg),static_cast<double>(tb)};
            RGB rgb = {tr,tg,tb};
            HSI hsi=RGBTOHSI(rgb);
            
            
            hsi.s=hsi.s*1.1;
            rgb=HSITORGB(hsi);
            
            tr=rgb.r;
            tb=rgb.b;
            tg=rgb.g;
            

            
            imgPixel[4*j*w + i] = pixelRange(tb);
            imgPixel[4*j*w + i + 1] = pixelRange(tg);
            imgPixel[4*j*w + i + 2] = pixelRange(tr);
        }
    }

}

void ImageHueFilter(void *inImage, uint width, uint height, uint repeat)
{
    
    if (inImage == NULL) {
        return ;
    }

    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    
    int m1,m2,m3,n1,n2,n3;
    int r,g,b;
   
    
    for (int y=1; y<h-1; y++) {
        for (int x=1; x<w-1; x++) {
            
            m1 = w*(y-1)<<2;
            m2 = w*y<<2;
            m3 = w*(y+1)<<2;
            
            n1 = (x-1)<<2;
            n2 = x<<2;
            n3 = (x+1)<<2;
            
            r = imgPixel[m2+n2];
            g = imgPixel[m2+n2+1];
            b = imgPixel[m2+n2+2];
            
//            RGB rgb={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
            RGB rgb = {r,g,b};
            HSI hsi=RGBTOHSI(rgb);
            hsi.s=hsi.s*1.5;
            
//            hsi.i=(hsi.i-Imin)/(Imax-Imin);
//            hsi.i=(hsi.i-Imin)/(Imax-Imin);
//            hsi.i=(hsi.i-Imin)/(Imax-Imin);

            rgb=HSITORGB(hsi);
        
            r=rgb.r;
            b=rgb.b;
            g=rgb.g;
            imgPixel[m2 + n2] = pixelRange(r);
            imgPixel[m2 + n2 + 1] = pixelRange(g);
            imgPixel[m2 + n2 + 2] = pixelRange(b);
        }
    }
}


void ImageSaturationFilter(void *inImage, uint width, uint height, uint repeat)
{
   
    if (inImage == NULL) {
        return ;
    }

    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    int r,g,b,m2,n2;

    double sValue=190;
    for (int y=0; y<h; y++) {
        for (int x=0; x<w; x++) {
            
            m2 = w*y<<2;
            n2 = x<<2;
            
            r = imgPixel[m2+n2];
            g = imgPixel[m2+n2+1];
            b = imgPixel[m2+n2+2];
            
            double S;
            
            int max=MAX(MAX(r, g), b);
            int min=MIN(MIN(r, g), b);
            
            double delta=(double)(max-min);
            double value=(double)(max+min);
            
            double L=value/2;
            
            if (L < 128) {
                S=delta/value;
            }
            else{
                S=delta/(255-value);
            }
            
            if (sValue > 0) {
                sValue=(sValue+S>=255)? S : (255-sValue);
                sValue=255/sValue-1;
            }
            
            r=r+(r-L)*sValue;
            g=g+(g-L)*sValue;
            b=b+(r-L)*sValue;
            
            r=r+(r-L)*sValue;
            g=g+(g-L)*sValue;
            b=b+(r-L)*sValue;
                        
            imgPixel[m2 + n2] = pixelRange(r);
            imgPixel[m2 + n2 + 1] = pixelRange(g);
            imgPixel[m2 + n2 + 2] = pixelRange(b);
        }
    }
    
}

#pragma mark-- 递推双边滤波 梯度域
void domain_bilateral_filter(void *inImage,uint width, uint height, double sigma_spatial, double sigma_range) {

    
    if (inImage == NULL) {
        return ;
    }

    
    unsigned char *imgPixel = (unsigned char *) inImage;
    int w=width;
    int h=height;
    
    unsigned char***texture=qx_allocu_3(h,w,3);//allocate memory
	double***image=qx_allocd_3(h,w,3);
	double***image_filtered=qx_allocd_3(h,w,3);
	double***temp=qx_allocd_3(h,w,3);
	double***temp_2=qx_allocd_3(2,w,3);
    
    int m2,n2;
    int r=0,g=0,b=0;
    for (int y=0; y< h; y++) {
        for (int x=0; x<w;x++) {
            
            m2 = w*y<<2;
            n2 = x<<2;
            
            r = imgPixel[m2+n2];
            g = imgPixel[m2+n2+1];
            b = imgPixel[m2+n2+2];
            
            image[y][x][0]=r;
            texture[y][x][0]=r;
            image[y][x][1]=g;
            texture[y][x][1]=g;
            image[y][x][2]=b;
            texture[y][x][2]=b;
   
        }
    }
    
    
//    int nr_iteration=1;
//	for(int i=0;i<nr_iteration;i++)
    
    qx_gradient_domain_recursive_bilateral_filter(image_filtered,image,texture,sigma_spatial,sigma_range,h,w,temp,temp_2);

//   for(int y=0;y<h;y++) for(int x=0;x<w;x++) for(int c=0;c<3;c++) texture[y][x][c]=image_filtered[y][x][c];
    
//    qx_gradient_domain_recursive_bilateral_filter(image_filtered,image,texture,sigma_spatial,sigma_range,h,w,temp,temp_2);//filtering
//    
//	for(int y=0;y<h;y++) for(int x=0;x<w;x++) for(int c=0;c<3;c++) //detail enhancement
//	{
//		texture[y][x][c]=(unsigned char)MIN(255.0,MAX(0.0,image_filtered[y][x][c]+2*(image[y][x][c]-image_filtered[y][x][c])));
//	}
    
    for (int y=0; y< h; y++) {
        for (int x=0; x<w;x++) {
            
            m2 = w*y<<2;
            n2 = x<<2;
            
            imgPixel[m2+n2]=image_filtered[y][x][0];
            imgPixel[m2+n2+1]=image_filtered[y][x][1];
            imgPixel[m2+n2+2]=image_filtered[y][x][2];
            
        }
    }
  
    qx_freeu_3(texture);
    qx_freed_3(image);
    qx_freed_3(image_filtered);
    qx_freed_3(temp);
    qx_freed_3(temp_2);
}

void domain_fuck_bilateral_filter(void *inImage,uint width, uint height, double sigma_spatial, double sigma_range)
{
    if (inImage == NULL) {
        return ;
    }
    
    unsigned char *imgPixel = (unsigned char *) inImage;
    uint w = width;
    uint h = height;
    uint m2,n2;
    
	double***image_filtered = qx_allocd_3(h,w,3);
	double***temp = qx_allocd_3(h,w,3);
	double***temp_2 = qx_allocd_3(2,w,3);
    
    
    qx_fuck_bilateral_filter(image_filtered,imgPixel,sigma_spatial,sigma_range,h,w,temp,temp_2);
    
    for (int y=0; y< h; y++) {
        for (int x=0; x<w;x++) {
            
            m2 = w*y<<2;
            n2 = x<<2;
            imgPixel[m2+n2] = image_filtered[y][x][0];
            imgPixel[m2+n2+1] = image_filtered[y][x][1];
            imgPixel[m2+n2+2] = image_filtered[y][x][2];
        }
    }
    
    qx_freed_3(image_filtered);
    qx_freed_3(temp);
    qx_freed_3(temp_2);
}

void bilateral_filter(void *inImage,uint width, uint height, int ds, int rs) {
    
    if (inImage == NULL) {
        return ;
    }

    double factor = -0.5;
    
    
    int radius=3;
    int size = 2 * radius + 1;
    
    double c_weight_table[size][size];
    double s_weight_table[256];
    
    unsigned char *imgPixel = (unsigned char *) inImage;
    
    double delta,deltaDelta;
    for (int i = -radius; i <= radius; i++) {
        for (int j = -radius; j <= radius; j++) {
            delta = sqrt(i * i + j * j) / ds;
            deltaDelta = delta * delta;
            c_weight_table[i + radius][j + radius] = exp(deltaDelta * factor);
        }
    }
    
    for (int i = 0; i < 256; i++) {
        delta = sqrt(i * i) / rs;
        deltaDelta = delta * delta;
        s_weight_table[i] = exp(deltaDelta * factor);
    }
    
    double red_sum = 0, green_sum = 0, blue_sum = 0;
    double red_weight = 0, green_weight = 0, blue_weight = 0;
    double red_weight_sum = 0, green_weight_sum = 0, blue_weight_sum = 0;
    int  tr = 0, tg = 0, tb = 0;

    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            
            int index = ((row*width)<<2) + (col<<2);
            
            tr = imgPixel[index];
            tg = imgPixel[index+1];
            tb = imgPixel[index+2];
            
//           RGB rgb={tr,tg,tb};
//        YCBCR ycrcb = RGBTOYCBCR(rgb,2);
//        if (ycrcb.Cr > 137 && ycrcb.Cr < 177 && ycrcb.Cb>77 && ycrcb.Cb < 127 && (ycrcb.Cb+ycrcb.Cr) > 190 && (ycrcb.Cb+ycrcb.Cr) <215)
            if ((tr >95 && tg >40 && tb >20 &&
                          tr - tb >15 && tr - tg >1 ) ||
                          (tr >200 && tg >210 && tb >170 &&
                          abs(tr - tb)<=15 && tr >tb && tg >tb))
            {
                
                int row_offset = 0, col_offset = 0;
                unsigned char tr2 = 0, tg2 = 0, tb2 = 0;
                int  index2;
                for (int semirow = -radius; semirow <= radius; semirow++) {
                    for (int semicol = -radius; semicol <= radius; semicol++) {
                        
                        if((row + semirow) >= 0 && (row + semirow) < height) {
                            row_offset = row + semirow;
                        } else {
                            row_offset = 0;
                        }
                        
                        if((semicol + col) >= 0 && (semicol + col) < width) {
                            col_offset = col + semicol;
                        } else {
                            col_offset = 0;
                        }
                        
                        index2 = ((row_offset*width) << 2)+(col_offset<<2);
                        
                        tr2 = imgPixel[index2];
                        tg2 = imgPixel[index2+1];
                        tb2 = imgPixel[index2+2];
                        
                        red_weight = c_weight_table[semirow + radius][semicol + radius] * s_weight_table[abs(tr2 - tr)];
                        green_weight = c_weight_table[semirow + radius][semicol + radius] * s_weight_table[abs(tg2 - tg)];
                        blue_weight = c_weight_table[semirow + radius][semicol + radius] * s_weight_table[abs(tb2 - tb)];
                        
                        red_weight_sum += red_weight;
                        green_weight_sum += green_weight;
                        blue_weight_sum += blue_weight;
                        
                        red_sum += red_weight * tr2;
                        green_sum += green_weight * tg2;
                        blue_sum += blue_weight * tb2;
                    }
                }
                
                tr = (int) floor(red_sum / red_weight_sum);
                tg = (int) floor(green_sum / green_weight_sum);
                tb = (int) floor(blue_sum / blue_weight_sum);
                
                imgPixel[index] = tr;
                imgPixel[index+1] = tg;
                imgPixel[index+2] = tb;
                
                
                red_sum = green_sum = blue_sum = 0;
                red_weight = green_weight = blue_weight = 0;
                red_weight_sum = green_weight_sum = blue_weight_sum = 0;
                
            }
        }
    }
}


void ImageBilateralFilter(void *inImage,uint width, uint height, int ds, int rs)
{
    
    if (inImage == NULL) {
        return ;
    }
    
    double factor = -0.5;
    
    
    int radius=6;
    int size = 2 * radius + 1;
    
    double c_weight_table[size][size];
    double s_weight_table[256];
    
    unsigned char *imgPixel = (unsigned char *) inImage;
    unsigned char *tmpPixel=(unsigned char *)inImage;
    
    
    for (int i = -radius; i <= radius; i++) {
        for (int j = -radius; j <= radius; j++) {
            double delta = sqrt(i * i + j * j) / ds;
            double deltaDelta = delta * delta;
            c_weight_table[i + radius][j + radius] = exp(deltaDelta * factor);
        }
    }
    
    for (int i = 0; i < 256; i++) {
        double delta = sqrt(i * i) / rs;
        double deltaDelta = delta * delta;
        s_weight_table[i] = exp(deltaDelta * factor);
    }
    
    double red_sum = 0, green_sum = 0, blue_sum = 0;
    double red_weight = 0, green_weight = 0, blue_weight = 0;
    double red_weight_sum = 0, green_weight_sum = 0, blue_weight_sum = 0;
     
//    Boolean doOrNot=true;
    
    //横向
    
    for (int row = 0; row < height; row++) {
        int  tr = 0, tg = 0, tb = 0;
        for (int col = 0; col < width; col++) {
            
            int index=row*width*4+col*4;
            
            tr = imgPixel[index];
            tg = imgPixel[index+1];
            tb = imgPixel[index+2];
                
            
            int  col_offset = 0;
            unsigned char tr2 = 0, tg2 = 0, tb2 = 0;
            
    
            if ((tr >95 && tg >40 && tb >20 &&
                 tr - tb >15 && tr - tg >1 ) ||
                (tr >200 && tg >210 && tb >170 &&
                 abs(tr - tb)<=15 && tr >tb && tg >tb))
            {
            
           for (int semicol = -radius; semicol <= radius; semicol++) {
                
                if((semicol + col) >= 0 && (semicol + col) < width) {
                    col_offset = col + semicol;
                } else {
                    col_offset = 0;
                }
                
                
                int  index2=row*width*4+col_offset*4;
                
                tr2=imgPixel[index2];
                tg2=imgPixel[index2+1];
                tb2=imgPixel[index2+2];
                
                red_weight = c_weight_table[radius/2][semicol + radius] * s_weight_table[abs(tr2 - tr)];
                green_weight = c_weight_table[radius/2][semicol + radius] * s_weight_table[abs(tg2 - tg)];
                blue_weight = c_weight_table[radius/2][semicol + radius] * s_weight_table[abs(tb2 - tb)];
                
                red_weight_sum += red_weight;
                green_weight_sum += green_weight;
                blue_weight_sum += blue_weight;
                
                red_sum += (red_weight * (double)tr2);
                green_sum += (green_weight * (double)tg2);
                blue_sum += (blue_weight *(double)tb2);
                
            }
            
            tr = (int) floor(red_sum / red_weight_sum);
            tg = (int) floor(green_sum / green_weight_sum);
            tb = (int) floor(blue_sum / blue_weight_sum);
            
            
            }
            
            tmpPixel[index]=tr;
            tmpPixel[index+1]=tg;
            tmpPixel[index+2]=tb;
            
            
            red_sum = green_sum = blue_sum = 0;
            red_weight = green_weight = blue_weight = 0;
            red_weight_sum = green_weight_sum = blue_weight_sum = 0;
            
                
            }        
    }
    
    
    //纵向
    for (int row = 0; row < height; row++) {
        int  tr = 0, tg = 0, tb = 0;
        for (int col = 0; col < width; col++) {
            
            int index=row*width*4+col*4;
            
            tr = imgPixel[index];
            tg = imgPixel[index+1];
            tb = imgPixel[index+2];
            
            int row_offset = 0;
            unsigned char tr2 = 0, tg2 = 0, tb2 = 0;
            
            
           
            if ((tr >95 && tg >40 && tb >20 &&
                 tr - tb >15 && tr - tg >1 ) ||
                (tr >200 && tg >210 && tb >170 &&
                 abs(tr - tb)<=15 && tr >tb && tg >tb))
            {
            
            
            for (int semirow = -radius; semirow <= radius; semirow++) {
                
                if((row + semirow) >= 0 && (row + semirow) < height) {
                    row_offset = row + semirow;
                } else {
                    row_offset = 0;
                }
                
                
                int  index2=row_offset*width*4+col*4;
                
                tr2=tmpPixel[index2];
                tg2=tmpPixel[index2+1];
                tb2=tmpPixel[index2+2];
                
                red_weight = c_weight_table[semirow + radius][radius/2] * s_weight_table[abs(tr2 - tr)];
                green_weight = c_weight_table[semirow + radius][radius/2] * s_weight_table[abs(tg2 - tg)];
                blue_weight = c_weight_table[semirow + radius][radius/2] * s_weight_table[abs(tb2 - tb)];
                
                red_weight_sum += red_weight;
                green_weight_sum += green_weight;
                blue_weight_sum += blue_weight;
                
                red_sum += (red_weight * (double)tr2);
                green_sum += (green_weight * (double)tg2);
                blue_sum += (blue_weight *(double)tb2);
                
            }
            
            
            tr = (int) floor(red_sum / red_weight_sum);
            tg = (int) floor(green_sum / green_weight_sum);
            tb = (int) floor(blue_sum / blue_weight_sum);
            
            
            }
            
            
            imgPixel[index]=tr;
            imgPixel[index+1]=tg;
            imgPixel[index+2]=tb;
            
            
            
            red_sum = green_sum = blue_sum = 0;
            red_weight = green_weight = blue_weight = 0;
            red_weight_sum = green_weight_sum = blue_weight_sum = 0;
            
          
        }
        
    }
}


void ImageCMYKToRed(void *inImage, uint width, uint height, uint repeat)
{
    
    if (inImage == NULL) {
        return ;
    }
    
    unsigned char *imgPixel = (unsigned char *) inImage;
    
    int r = 0,g = 0,b = 0;
    int m1,m2,m3,n1,n2,n3;
    int w = width,h = height;
    double lim=0.0 ,inc=0.0, dec = 0.0;

    // for (int n=0; n<repeat; n++) {
    for (int y=0; y<h; y++) {
        for (int x=0; x<w; x++) {
            
            m1 = w*(y-1)<<2;
            m2 = w*y<<2;
            m3 = w*(y+1)<<2;
            
            
            n1 = (x-1)<<2;
            n2 = x<<2;
            n3 = (x+1)<<2;
            
            r = imgPixel[m2+n2];
            g = imgPixel[m2+n2+1];
            b = imgPixel[m2+n2+2];
            
          //  int h=RGB2HSB(r, g, b);
                       
//           if (h>300 || h<60)
                
                if (g>b) {
                    lim=r-g;
                    inc=lim*(1-r/255.0);
                    dec=lim*(r/255.0);
                 //   r=r+inc*0.2;
                    g=g-dec*0.1;
                }
                else
                {
                    lim=r-b;
                    inc=lim*(1-r/255.0);
                    dec=lim*(r/255.0);
                    
                 //   r=r+inc*0.2;
                    g=g-dec*0.1;
                }
            
            imgPixel[m2 + n2] = pixelRange(r);
            imgPixel[m2 + n2 + 1] = pixelRange(g);
            imgPixel[m2 + n2 + 2] = pixelRange(b);
        }
    }
}

#pragma  mark 图像局部对比度增强处理
void ImageContrastFilter(void *inImage, uint width, uint height, uint repeat)
{
   
    if (inImage == NULL) {
        return ;
    }

    
    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    
    int r = 0,g = 0,b = 0;
    int m1,m2,m3,n1,n2,n3;
    
    
    for (int y = 1; y<h-1; y++) {
        for (int x = 1; x<w-1; x++) {
            
            m1 = w*(y-1)<<2;
            m2 = w*y<<2;
            m3 = w*(y+1)<<2;
            
            n1 = (x-1)<<2;
            n2 = x<<2;
            n3 = (x+1)<<2;
            
//            r=g=b=0;
            
            r = imgPixel[m1+n1];
            g = imgPixel[m1+n1+1];
            b = imgPixel[m1+n1+2];
            
//            RGB rgb1={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
            RGB rgb1 = {r,g,b};
            HSI hsi1=RGBTOHSI(rgb1);
            
            
            r=imgPixel[m1+n2];
            g=imgPixel[m1+n2+1];
            b=imgPixel[m1+n2+2];
            
//            RGB rgb2={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
            RGB rgb2 = {r,g,b};
            HSI hsi2=RGBTOHSI(rgb2);
            
            r=imgPixel[m1+n3];
            g=imgPixel[m1+n3+1];
            b=imgPixel[m1+n3+2];
            
//            RGB rgb3={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
            RGB rgb3 = {r,g,b};
            HSI hsi3=RGBTOHSI(rgb3);
            
            
            
            r=imgPixel[m2+n1];
            g=imgPixel[m2+n1+1];
            b=imgPixel[m2+n1+2];
            
//            RGB rgb4={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
            RGB rgb4 = {r,g,b};
            HSI hsi4=RGBTOHSI(rgb4);
            
            r=imgPixel[m2+n2];
            g=imgPixel[m2+n2+1];
            b=imgPixel[m2+n2+2];
            
//            RGB rgb5={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
            RGB rgb5 = {r,g,b};
            HSI hsi5=RGBTOHSI(rgb5);
            
            r=imgPixel[m2+n3];
            g=imgPixel[m2+n3+1];
            b=imgPixel[m2+n3+2];
            
//            RGB rgb6={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
            RGB rgb6 = {r,g,b};
            HSI hsi6=RGBTOHSI(rgb6);
            
            
            r=imgPixel[m3+n1];
            g=imgPixel[m3+n1+1];
            b=imgPixel[m3+n1+2];
            
//            RGB rgb7={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
            RGB rgb7 = {r,g,b};
            HSI hsi7=RGBTOHSI(rgb7);
            
            
            r=imgPixel[m3+n2];
            g=imgPixel[m3+n2+1];
            b=imgPixel[m3+n2+2];
            
//            RGB rgb8={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
            RGB rgb8 = {r,g,b};
            HSI hsi8=RGBTOHSI(rgb8);
            
            r=imgPixel[m3+n3];
            g=imgPixel[m3+n3+1];
            b=imgPixel[m3+n3+2];
            
//            RGB rgb9={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
            RGB rgb9 = {r,g,b};
            HSI hsi9=RGBTOHSI(rgb9);
            
            
            double iAve=(hsi1.i+hsi2.i+hsi3.i+hsi4.i+hsi5.i+hsi6.i+hsi7.i+hsi8.i+hsi9.i)/9.0;
 
            
            hsi5.i=iAve+1.2*(hsi5.i-iAve);
            
            RGB  rgb=HSITORGB(hsi5);
            
            r=rgb.r;
            g=rgb.g;
            b=rgb.b;
            
            imgPixel[m2 + n2] = pixelRange(r);
            imgPixel[m2 + n2 + 1] = pixelRange(g);
            imgPixel[m2 + n2 + 2] = pixelRange(b);
        }
    }  
}

void ImageContrastFilterTest(void *inImage, uint width, uint height, uint repeat)
{
    
    if (inImage == NULL) {
        return ;
    }
    
    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    
    int r = 0,g = 0,b = 0;
    int m1,m2,m3,n1,n2,n3;
    
    double firstColum = 0.0,secondColum = 0.0,thirdColum = 0.0,sumColum = 0.0;
    
    for (int y = 1; y<h-1; y++) {
        for (int x = 1; x<w-1; x++) {
            
            m1 = w*(y-1)<<2;
            m2 = w*y<<2;
            m3 = w*(y+1)<<2;
            
            n1 = (x-1)<<2;
            n2 = x<<2;
            n3 = (x+1)<<2;
            
            HSI hsiCurrent;
            // 每行 开始 预处理.
            if (x == 1) {
                
                // first colum
                r = imgPixel[m1+n1];
                g = imgPixel[m1+n1+1];
                b = imgPixel[m1+n1+2];
//                RGB rgb1={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb1 = {r,g,b};
                HSI hsi1=RGBTOHSI(rgb1);
                
                r=imgPixel[m2+n1];
                g=imgPixel[m2+n1+1];
                b=imgPixel[m2+n1+2];
//                RGB rgb4={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb4 = {r,g,b};
                HSI hsi4=RGBTOHSI(rgb4);
                
                r=imgPixel[m3+n1];
                g=imgPixel[m3+n1+1];
                b=imgPixel[m3+n1+2];
//                RGB rgb7={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb7 = {r,g,b};
                HSI hsi7=RGBTOHSI(rgb7);
                
                firstColum = hsi1.i + hsi4.i + hsi7.i;
                
                // second Colum
                r=imgPixel[m1+n2];
                g=imgPixel[m1+n2+1];
                b=imgPixel[m1+n2+2];
                
//                RGB rgb2={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb2 = {r,g,b};
                HSI hsi2=RGBTOHSI(rgb2);
                
                r=imgPixel[m2+n2];
                g=imgPixel[m2+n2+1];
                b=imgPixel[m2+n2+2];
//                RGB rgb5={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb5 = {r,g,b};
                HSI hsi5=RGBTOHSI(rgb5);
                hsiCurrent = hsi5;
                
                r=imgPixel[m3+n2];
                g=imgPixel[m3+n2+1];
                b=imgPixel[m3+n2+2];
//                RGB rgb8={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb8 = {r,g,b};
                HSI hsi8=RGBTOHSI(rgb8);
                
                secondColum = hsi2.i + hsi5.i + hsi8.i;
                
                // third Colum
                r=imgPixel[m1+n3];
                g=imgPixel[m1+n3+1];
                b=imgPixel[m1+n3+2];
//                RGB rgb3={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb3 = {r,g,b};
                HSI hsi3=RGBTOHSI(rgb3);
                
                
                r=imgPixel[m2+n3];
                g=imgPixel[m2+n3+1];
                b=imgPixel[m2+n3+2];
//                RGB rgb6={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb6 = {r,g,b};
                HSI hsi6=RGBTOHSI(rgb6);
                
                r=imgPixel[m3+n3];
                g=imgPixel[m3+n3+1];
                b=imgPixel[m3+n3+2];
//                RGB rgb9={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb9 = {r,g,b};
                HSI hsi9=RGBTOHSI(rgb9);
    
                thirdColum = hsi3.i + hsi6.i + hsi9.i;
                
                sumColum = firstColum + secondColum + thirdColum;
            }
             
            if (x != 1) {
                sumColum = secondColum + thirdColum;
                firstColum = secondColum;
                secondColum = thirdColum;
                
                // current point
                r=imgPixel[m2+n2];
                g=imgPixel[m2+n2+1];
                b=imgPixel[m2+n2+2];
//                RGB rgb5={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb5 = {r,g,b};
                hsiCurrent=RGBTOHSI(rgb5);
                
                // third Colum
                r=imgPixel[m1+n3];
                g=imgPixel[m1+n3+1];
                b=imgPixel[m1+n3+2];
//                RGB rgb3={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb3 = {r,g,b};
                HSI hsi3=RGBTOHSI(rgb3);
                
                
                r=imgPixel[m2+n3];
                g=imgPixel[m2+n3+1];
                b=imgPixel[m2+n3+2];
//                RGB rgb6={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb6 = {r,g,b};
                HSI hsi6=RGBTOHSI(rgb6);
                
                r=imgPixel[m3+n3];
                g=imgPixel[m3+n3+1];
                b=imgPixel[m3+n3+2];
//                RGB rgb9={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
                RGB rgb9 = {r,g,b};
                HSI hsi9=RGBTOHSI(rgb9);
                
                thirdColum = hsi3.i + hsi6.i + hsi9.i;
                
                sumColum += thirdColum;
            }

            double iAve=sumColum/9.0;
            secondColum -= hsiCurrent.i;
            hsiCurrent.i=iAve+1.2*(hsiCurrent.i-iAve);
            secondColum += hsiCurrent.i;
            RGB  rgb=HSITORGB(hsiCurrent);
        
            r=rgb.r;
            g=rgb.g;
            b=rgb.b;
            
            imgPixel[m2 + n2] = pixelRange(r);
            imgPixel[m2 + n2 + 1] = pixelRange(g);
            imgPixel[m2 + n2 + 2] = pixelRange(b);
        }
    }  
}
//四个小滤镜

#pragma mark -- 图像明度和对比度调整
void imageBrightAndContrastAdjuet(void *inImage, uint width, uint height,int contrast,int brightness)
{
    
    if (inImage == NULL) {
        return ;
    }

   
    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    
    int r = 0,g = 0,b = 0;
    int m1,m2,m3,n1,n2,n3;

    
    
    int threshold = 128;
    
	// 计算对比度数组
	float cv = (contrast <= -255) ? -1.0f : contrast / 255.0f;
	if (contrast > 0 && contrast < 255) {
		cv = 1.0f / (1.0f - cv) - 1.0f;
	}
    
	
    
    for (int y=1; y<h-1; y++) {
        for (int x=1; x<w-1; x++) {
        
            m1 = w*(y-1)<<2;
            m2 = w*y<<2;
            m3 = w*(y+1)<<2;
            
            n1 = (x-1)<<2;
            n2 = x<<2;
            n3 = (x+1)<<2;
            
            r=imgPixel[m2+n2];
            g=imgPixel[m2+n2+1];
            b=imgPixel[m2+n2+2];
            
            
            r = (contrast > 0) ? pixelRange(r + brightness) : r;
            g = (contrast > 0) ? pixelRange(g + brightness) : g;
            b = (contrast > 0) ? pixelRange(b + brightness) : b;
            
            if (contrast >= 255) {
                r = (r > threshold) ? 255 : 0;
                g = (g > threshold) ? 255 : 0;
                b = (b > threshold) ? 255 : 0;
            } else {
                r = pixelRange(r + (int) ((r - threshold) * cv + 0.5f));
                g = pixelRange(g + (int) ((g - threshold) * cv + 0.5f));
                b = pixelRange(b + (int) ((b - threshold) * cv + 0.5f));
            }
            
            r = (contrast < 0) ? pixelRange(r + brightness) : r;
            g = (contrast < 0) ? pixelRange(g + brightness) : g;
            b = (contrast < 0) ? pixelRange(b + brightness) : b;
            
            imgPixel[m2+n2]=r;
            imgPixel[m2+n2+1]=g;
            imgPixel[m2+n2+2]=b;

        }
    }
    
	
}

#pragma mark 图像饱和度调整
void imageSaturationAdjuet(void *inImage, uint width, uint height,int saturation)
{
    
    if (inImage == NULL) {
        return ;
    }

    
    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    
    int r = 0,g = 0,b = 0;
    int m1,m2,m3,n1,n2,n3;
         
    for (int y=1; y<h-1; y++) {
        for (int x=1; x<w-1; x++) {
            
            m1 = w*(y-1)<<2;
            m2 = w*y<<2;
            m3 = w*(y+1)<<2;
            
            n1 = (x-1)<<2;
            n2 = x<<2;
            n3 = (x+1)<<2;
            
            r=imgPixel[m2+n2];
            g=imgPixel[m2+n2+1];
            b=imgPixel[m2+n2+2];
            
            
            float l;
            float factor = saturation / 100.0;
            
            // 调整饱和度
            int rgb_max = MAX(MAX(r, g), b);
            int rgb_min = MIN(MIN(r, g), b);
            
            l = (rgb_max + rgb_min) / (2 * 255.0f);
            
            r = (int) (r + (r - l * 255.0) * factor);
            g = (int) (g + (g - l * 255.0) * factor);
            b = (int) (b + (b - l * 255.0) * factor);

            
            imgPixel[m2+n2]=pixelRange(r);
            imgPixel[m2+n2+1]=pixelRange(g);
            imgPixel[m2+n2+2]=pixelRange(b);
            
        }
    }
    
	
}



#pragma mark -- 柔光混合
void imageSoftlightCompose(void *inImage, uint width, uint height,float opacity, float filling)
{
    
    if (inImage == NULL) {
        return ;
    }

    
    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    
    int r = 0,g = 0,b = 0;
    int m1,m2,m3,n1,n2,n3;
    float result, ftop, fbottom;
    
    for (int y=0; y<h; y++) {
        for (int x=0; x<w; x++) {
       
            m1 = w*(y-1)<<2;
            m2 = w*y<<2;
            m3 = w*(y+1)<<2;
            
            n1 = (x-1)<<2;
            n2 = x<<2;
            n3 = (x+1)<<2;
            
            r=imgPixel[m2+n2];
            g=imgPixel[m2+n2+1];
            b=imgPixel[m2+n2+2];

            
//            RGB rgb={static_cast<double>(r),static_cast<double>(g),static_cast<double>(b)};
            RGB rgb = {r,g,b};
            HSL hsl=RGBTOHSL(rgb);
            hsl.s=0;
            rgb=HSLTORGB(hsl);
            
            
            int top=rgb.r;
            int bottom=r;
            
            ftop = top / 255.0f;
            fbottom = bottom / 255.0f;
            
            if (ftop > 0.5) {
                result = (2 * ftop - 1) * (sqrt(fbottom) - fbottom) + fbottom;
            } else {
                result = (2 * ftop - 1) * (fbottom - fbottom * fbottom) + fbottom;
            }
            
            result = result > 1 ? 1 : result < 0 ? 0 : result;
            
            result = result * filling + fbottom * (1 - filling);
            result = result * opacity + fbottom * (1 - opacity);
            
            imgPixel[m2+n2]=r;
            
            top=rgb.g;
            bottom=g;
            
            ftop = top / 255.0f;
            fbottom = bottom / 255.0f;
            
            if (ftop > 0.5) {
                result = (2 * ftop - 1) * (sqrt(fbottom) - fbottom) + fbottom;
            } else {
                result = (2 * ftop - 1) * (fbottom - fbottom * fbottom) + fbottom;
            }
            
            result = result > 1 ? 1 : result < 0 ? 0 : result;
            
            result = result * filling + fbottom * (1 - filling);
            result = result * opacity + fbottom * (1 - opacity);
            
            imgPixel[m2+n2+1]=g;
            
            top=rgb.b;
            bottom=b;
            
            ftop = top / 255.0f;
            fbottom = bottom / 255.0f;
            
            if (ftop > 0.5) {
                result = (2 * ftop - 1) * (sqrt(fbottom) - fbottom) + fbottom;
            } else {
                result = (2 * ftop - 1) * (fbottom - fbottom * fbottom) + fbottom;
            }
            
            result = result > 1 ? 1 : result < 0 ? 0 : result;
            
            result = result * filling + fbottom * (1 - filling);
            result = result * opacity + fbottom * (1 - opacity);
            
            imgPixel[m2+n2+2]=b;

            
        }
    }
    
 }

#pragma mark -- 颜色加深混合
int deep_color_compose(int top, int bottom, float opacity, float filling) {
	float ftop, fbottom, result;
    
	ftop = top / 255.0f;
	fbottom = bottom / 255.0f;
    
	result = 1 - (1 - fbottom) / ftop;
    
	result = result > 1 ? 1 : result < 0 ? 0 : result;
    
	result = result * filling + fbottom * (1 - filling);
	result = result * opacity + fbottom * (1 - opacity);
    
	return (int) (result * 255.0);
}

#pragma mark --透明蒙版
void alpha_template_apply(RGB *rgb, int center_x, int center_y, int radius,
                          int row, int col, int threshold, float s_distance_min,
                          float s_alpha_max, float opacity) {
    if (rgb== NULL) {
        return ;
    }

    
    
    int r = rgb->r;
	int g = rgb->g;
	int b = rgb->b;
    
	float alpha, factor;
    
	factor = sqrt(
                  (float) (row - center_y) * (row - center_y)
                  + (col - center_x) * (col - center_x)) / radius;
	if (factor < s_distance_min) {
		alpha = 0;
	} else if (factor < 1) {
		alpha = s_alpha_max * (factor - s_distance_min) / (1 - s_distance_min);
	} else {
		alpha = s_alpha_max;
	}
    
	rgb->r = deep_color_compose(threshold, r, opacity, alpha);
	rgb->g = deep_color_compose(threshold, g, opacity, alpha);
	rgb->b = deep_color_compose(threshold, b, opacity, alpha);
}


#pragma mark -- 曲线调整
int curve_point_caculate(int r, float a, float b, float c, float d) {
	float fresult = a * r * r * r + b * r * r + c * r + d;
	return pixelRange((int)fresult);
}

#pragma mark -- 应用蒙版

void imageTemplateApply(void *inImage, uint width, uint height)
{
    
    
    if (inImage==NULL) {
        return;
    }
    
    
    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    
    int r = 0,g = 0,b = 0;
    int m1,m2,m3,n1,n2,n3;
   
    float s_distance_min = 0.3;
	float s_alpha_max = 0.3;
	float m_distance_min = 0.5;
	float m_alpha_max = 0.5;
    RGB rgb;
    
    int center_x = width / 2;
	int center_y = height / 2;
    
	int sradius = center_x > center_y ? center_y : center_x;
	int mradius = center_x < center_y ? center_y : center_x;

       
    for (int y=0; y<h; y++) {
        for (int x=0; x<w; x++) {
            m1 = w*(y-1)<<2;
            m2 = w*y<<2;
            m3 = w*(y+1)<<2;
            
            n1 = (x-1)<<2;
            n2 = x<<2;
            n3 = (x+1)<<2;
            
            r=imgPixel[m2+n2];
            g=imgPixel[m2+n2+1];
            b=imgPixel[m2+n2+2];

            rgb.r=r;
            rgb.b=b;
            rgb.g=g;
            
            
            // 应用透明度模板（短边）
			alpha_template_apply(&rgb, center_x, center_y, sradius, y, x, 150,
                                 s_distance_min, s_alpha_max, 1);
            
			// 应用透明度模板（长边）
			alpha_template_apply(&rgb, center_x, center_y, mradius, y, x, 150,
                                 m_distance_min, m_alpha_max, 0.3);
            
            r = curve_point_caculate(rgb.r, -5.537e-07, -0.0001636, 1.074,
                                     -6.55);
			g = curve_point_caculate(rgb.g, -2.289e-06, 0.0008385, 0.8678,
                                     8.041);
			b = curve_point_caculate(rgb.b, -2.89e-06, 0.0009999, 0.8405,
                                     11.13);

            
            imgPixel[m2+n2]=r;
            imgPixel[m2+n2+1]=g;
            imgPixel[m2+n2+2]=b;
        }
    }
    
}




/**
 * rise第一步，中间向边缘渐变
 */
void rgb_curve_template_apply(RGB *rgb, float distance_coeff, float distance_min, float distance_max) {
    
    if (rgb==NULL) {
        return ;
    }
    
    int r = rgb->r;
    int g = rgb->g;
    int b = rgb->b;
    
    // step1
    int tr;
    int tg;
    int tb;
    
    float coeff;
    
    if (distance_coeff < distance_min) {
        
    } else if (distance_coeff > distance_max) {
        tr = curve_point_caculate(r, 4.796e-08, -0.000443, 1.106, 0.1647);
        tg = curve_point_caculate(g, -3.012e-07, 0.0003739, 0.9247, -0.1707);
        tb = curve_point_caculate(b, -4.174e-07, 0.00141, 0.6621, 0.7623);
        
        r = curve_point_caculate(tr, 5.496e-08, 0.001652, 0.5756, -0.167);
        g = curve_point_caculate(tg, 5.496e-08, 0.001652, 0.5756, -0.167);
        b = curve_point_caculate(tb, 5.496e-08, 0.001652, 0.5756, -0.167);
    } else {
        tr = curve_point_caculate(r, 4.796e-08, -0.000443, 1.106, 0.1647);
        tg = curve_point_caculate(g, -3.012e-07, 0.0003739, 0.9247, -0.1707);
        tb = curve_point_caculate(b, -4.174e-07, 0.00141, 0.6621, 0.7623);
        
        coeff = (distance_coeff - distance_min) / (distance_max - distance_min);
        r = (int) (r + (tr - r) * coeff);
        g = (int) (g + (tg - g) * coeff);
        b = (int) (b + (tb - b) * coeff);
        
        tr = curve_point_caculate(pixelRange(r), 5.496e-08, 0.001652, 0.5756, -0.167);
        tg = curve_point_caculate(pixelRange(g), 5.496e-08, 0.001652, 0.5756, -0.167);
        tb = curve_point_caculate(pixelRange(b), 5.496e-08, 0.001652, 0.5756, -0.167);
        
        r = (int) (r + (tr - r) * coeff);
        g = (int) (g + (tg - g) * coeff);
        b = (int) (b + (tb - b) * coeff);
    }
    
    
    rgb->r = pixelRange(r);
    rgb->g = pixelRange(g);
    rgb->b = pixelRange(b);
}

/**
 * rise第二步，边缘向中间渐变
 */
void rgb_curve_template_apply_1(RGB *rgb, float distance_coeff, float distance_min, float
distance_max) {
    
    
    if (rgb==NULL) {
        return;
    }
    
    int r = rgb->r;
    int g = rgb->g;
    int b = rgb->b;
    
    // step2
    int tr = curve_point_caculate(r, 2.998e-07, -0.0003558, 1.07, -0.3471);
    int tg = curve_point_caculate(g, -5.619e-07, -6.455e-05, 1.054, -0.4835);
    int tb = curve_point_caculate(b, 1.163e-07, 0.0003513, 0.9019, 0.2235);
    
    float coeff;
    
    if (distance_coeff < distance_min) {
        r = tr;
        g = tg;
        b = tb;
        
        r = curve_point_caculate(r, -1.806e-06, -0.002215, 1.683, -1.31);
        g = curve_point_caculate(g, -1.806e-06, -0.002215, 1.683, -1.31);
        b = curve_point_caculate(b, -1.806e-06, -0.002215, 1.683, -1.31);
    } else if (distance_coeff > distance_max) {
    } else {
        coeff = (distance_coeff - distance_min) / (distance_max - distance_min);
        r = (int) (tr + (r - tr) * coeff);
        g = (int) (tg + (g - tg) * coeff);
        b = (int) (tb + (b - tb) * coeff);
        
        tr = curve_point_caculate(pixelRange(r), -1.806e-06, -0.002215, 1.683, -1.31);
        tg = curve_point_caculate(pixelRange(g), -1.806e-06, -0.002215, 1.683, -1.31);
        tb = curve_point_caculate(pixelRange(b), -1.806e-06, -0.002215, 1.683, -1.31);
        
        r = (int) (tr + (r - tr) * coeff);
        g = (int) (tg + (g - tg) * coeff);
        b = (int) (tb + (b - tb) * coeff);
    }
    
    rgb->r = pixelRange(r);
    rgb->g = pixelRange(g);
    rgb->b = pixelRange(b);
}

/*
 * rise第三步，rgb曲线最终调整
 */
void rgb_curve_template_apply_2(RGB *rgb) {
    
    if (rgb==NULL) {
        return ;
    }
    
    int r = rgb->r;
    int g = rgb->g;
    int b = rgb->b;
    
    // step3
    int tr = curve_point_caculate(r, 3.481e-08, -0.0008522, 1.164, 13.18);
    int tg = curve_point_caculate(g, -7.2e-07, -0.0005613, 1.188, 0.554);
    int tb = curve_point_caculate(b, 0, 0, 0.8745, 24);
    
    rgb->r = pixelRange(tr);
    rgb->g = pixelRange(tg);
    rgb->b = pixelRange(tb);
}


void imageRiseFilterProcess(void *inImage, uint width, uint height)
{
    
    if(inImage==NULL)
    {
        return;
    }
    
    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    
    int r = 0,g = 0,b = 0;
    int m1,m2,m3,n1,n2,n3;
    
    
	int center_x = width / 2;
	int center_y = height / 2;
    
    float distance_coeff;
    RGB rgb;
    
    for (int y=0; y<h; y++) {
        for (int x=0; x<w; x++) {
            
            m1 = w*(y-1)<<2;
            m2 = w*y<<2;
            m3 = w*(y+1)<<2;
            
            n1 = (x-1)<<2;
            n2 = x<<2;
            n3 = (x+1)<<2;
            
            r=imgPixel[m2+n2];
            g=imgPixel[m2+n2+1];
            b=imgPixel[m2+n2+2];
            
          
            rgb.r = r;
            rgb.g = g;
            rgb.b = b;
            
            // 计算当前位置的比例
            distance_coeff = sqrt((y - center_y) * (y - center_y) / ((float) (center_y * center_y)) + (x - center_x) * (x - center_x) / ((float) (center_x * center_x)));
            
            rgb_curve_template_apply(&rgb, distance_coeff, 0.4, 0.9);
            rgb_curve_template_apply_1(&rgb, distance_coeff, 0.6, 1.1);
            rgb_curve_template_apply_2(&rgb);
            
            r = rgb.r;
            g = rgb.g;
            b = rgb.b;

            
            imgPixel[m2+n2]=pixelRange(r);
            imgPixel[m2+n2+1]=pixelRange(g);
            imgPixel[m2+n2+2]=pixelRange(b);
            
        }
    }
    
	
}

//----------amaro filter

void amaro_rgb_curve_template_apply(RGB *rgb, float distance_coeff, float distance_min, float distance_max) {
    
    
    if(rgb==NULL)
    {
        return;
    }
    
    
    int r = rgb->r;
    int g = rgb->g;
    int b = rgb->b;
    
    // step1
    int tr;
    int tg;
    int tb;
    
    float coeff;
    
    if (distance_coeff < distance_min) {
        
    } else if (distance_coeff > distance_max) {
        tr = curve_point_caculate(r, -1.335e-07, -0.0004741, 1.131, -0.9739);
        tg = curve_point_caculate(g, -1.987e-07, -0.0001378, 1.114, -17.38);
        tb = curve_point_caculate(b, -6.838e-07, -0.00198, 1.444, -1.412);
        
        r = curve_point_caculate(tr, -7.659e-07, 0.002563, 0.3977, 0.5387);
        g = curve_point_caculate(tg, -7.659e-07, 0.002563, 0.3977, 0.5387);
        b = curve_point_caculate(tb, -7.659e-07, 0.002563, 0.3977, 0.5387);
    } else {
        tr = curve_point_caculate(r, -1.335e-07, -0.0004741, 1.131, -0.9739);
        tg = curve_point_caculate(g, -1.987e-07, -0.0001378, 1.114, -17.38);
        tb = curve_point_caculate(b, -6.838e-07, -0.00198, 1.444, -1.412);
        
        coeff = (distance_coeff - distance_min) / (distance_max - distance_min);
        r = (int) (r + (tr - r) * coeff);
        g = (int) (g + (tg - g) * coeff);
        b = (int) (b + (tb - b) * coeff);
        
        tr = curve_point_caculate(pixelRange(r), -7.659e-07, 0.002563, 0.3977, 0.5387);
        tg = curve_point_caculate(pixelRange(g), -7.659e-07, 0.002563, 0.3977, 0.5387);
        tb = curve_point_caculate(pixelRange(b), -7.659e-07, 0.002563, 0.3977, 0.5387);
        
        r = (int) (r + (tr - r) * coeff);
        g = (int) (g + (tg - g) * coeff);
        b = (int) (b + (tb - b) * coeff);
    }
    
    
    rgb->r = pixelRange(r);
    rgb->g = pixelRange(g);
    rgb->b = pixelRange(b);
}

void amaro_rgb_curve_template_apply_1(RGB *rgb, float distance_coeff, float distance_min, float distance_max) {
    
    
    if(rgb==NULL)
    {
        return;
    }
    
    
    int r = rgb->r;
    int g = rgb->g;
    int b = rgb->b;
    
    // step2
    int tr = curve_point_caculate(r, 1.9e-06, -0.001672, 1.303, -2.046);
    int tg = curve_point_caculate(g, -5.729e-08, -0.0004881, 1.155, -7.703);
    int tb = curve_point_caculate(b, -1.684e-06, -0.0002598, 1.072, 13.2);
    
    float coeff;
    
    if (distance_coeff < distance_min) {
        r = tr;
        g = tg;
        b = tb;
        
        r = curve_point_caculate(r, -5.478e-07, -0.003489, 1.927, -2.382);
        g = curve_point_caculate(g, -5.478e-07, -0.003489, 1.927, -2.382);
        b = curve_point_caculate(b, -5.478e-07, -0.003489, 1.927, -2.382);
    } else if (distance_coeff > distance_max) {
    } else {
        coeff = (distance_coeff - distance_min) / (distance_max - distance_min);
        r = (int) (tr + (r - tr) * coeff);
        g = (int) (tg + (g - tg) * coeff);
        b = (int) (tb + (b - tb) * coeff);
        
        tr = curve_point_caculate(pixelRange(r), -5.478e-07, -0.003489, 1.927, -2.382);
        tg = curve_point_caculate(pixelRange(g), -5.478e-07, -0.003489, 1.927, -2.382);
        tb = curve_point_caculate(pixelRange(b), -5.478e-07, -0.003489, 1.927, -2.382);
        
        r = (int) (tr + (r - tr) * coeff);
        g = (int) (tg + (g - tg) * coeff);
        b = (int) (tb + (b - tb) * coeff);
    }
    
    rgb->r = pixelRange(r);
    rgb->g = pixelRange(g);
    rgb->b = pixelRange(b);
}

void amaro_rgb_curve_template_apply_2(RGB *rgb) {
   
    if(rgb==NULL)
    {
        return;
    }
    
    
    int r = rgb->r;
    int g = rgb->g;
    int b = rgb->b;
    
    // step3
    int tr = curve_point_caculate(r, 0, 0, 0.9608, 10);
    int tg = curve_point_caculate(g, 4.416e-07, -0.001368, 1.362, -11.97);
    int tb = curve_point_caculate(b, 3.264e-07, -0.0002502, 0.9238, 14.95);
    
    rgb->r = tr;
    rgb->g = tg;
    rgb->b = tb;
}

void imageAmaroFilterProcess(void *inImage, uint width, uint height)
{
    
    if (inImage == NULL) {
        return;
    }
    
    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    
    int r = 0,g = 0,b = 0;
    int m1,m2,m3,n1,n2,n3;
    
    
	int center_x = width / 2;
	int center_y = height / 2;
    
    float distance_coeff;
    RGB rgb;
    
    for (int y=0; y<h; y++) {
        for (int x=0; x<w; x++) {
            
            m1 = w*(y-1)<<2;
            m2 = w*y<<2;
            m3 = w*(y+1)<<2;
            
            n1 = (x-1)<<2;
            n2 = x<<2;
            n3 = (x+1)<<2;
            
            r=imgPixel[m2+n2];
            g=imgPixel[m2+n2+1];
            b=imgPixel[m2+n2+2];
            
            
            rgb.r = r;
            rgb.g = g;
            rgb.b = b;
                        
            // 计算当前位置的比例
            distance_coeff = sqrt((y - center_y) * (y - center_y) / ((float) (center_y * center_y)) + (x - center_x) * (x - center_x) / ((float) (center_x * center_x)));
            
            amaro_rgb_curve_template_apply(&rgb, distance_coeff, 0.4, 0.9);
            amaro_rgb_curve_template_apply_1(&rgb, distance_coeff, 0.6, 1.1);
            amaro_rgb_curve_template_apply_2(&rgb);
            
            
            r = rgb.r;
            g = rgb.g;
            b = rgb.b;
            
            
            imgPixel[m2+n2]=pixelRange(r);
            imgPixel[m2+n2+1]=pixelRange(g);
            imgPixel[m2+n2+2]=pixelRange(b);
            
        }
    }
    
	
}

/* fuzzy filter
 * 1,  1,  1,  1,  1,
 * 1,  0,  0,  0,  1,
 * 1,  0,  0,  0,  1,
 * 1,  0,  0,  0,  1,
 * 1,  1,  1,  1,  1
 **/
void imageFilterBLUR(void *inImage, uint width, uint height, uint repeat)
{
    
    if (inImage == NULL) {
        return;
    }
    
    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    
    int r = 0,g = 0,b = 0;
    int m1,m2,m3,m4,m5,n1,n2,n3,n4,n5;
    
    for (int i=0; i<repeat; i++) {
        for (int y=2; y<h-2; y++) {
            for (int x=2; x<w-2; x++) {
                
                m1 = w*(y-2)<<2;
                m2 = w*(y-1)<<2;
                m3 = w*y<<2;
                m4 = w*(y+1)<<2;
                m5 = w*(y+2)<<2;
                
                n1 = (x-2)<<2;
                n2 = (x-1)<<2;
                n3 = x<<2;
                n4 = (x+1)<<2;
                n5 = (x+2)<<2;
                r=imgPixel[m1+n1];
                g=imgPixel[m1+n1+1];
                b=imgPixel[m1+n1+2];
                
                r+=imgPixel[m1+n2];
                g+=imgPixel[m1+n2+1];
                b+=imgPixel[m1+n2+2];
                
                r+=imgPixel[m1+n3];
                g+=imgPixel[m1+n3+1];
                b+=imgPixel[m1+n3+2];
                
                r+=imgPixel[m1+n4];
                g+=imgPixel[m1+n4+1];
                b+=imgPixel[m1+n4+2];
                
                r+=imgPixel[m1+n5];
                g+=imgPixel[m1+n5+1];
                b+=imgPixel[m1+n5+2];
                
                r+=imgPixel[m2+n1];
                g+=imgPixel[m2+n1+1];
                b+=imgPixel[m2+n1+2];
                r+=imgPixel[m2+n5];
                g+=imgPixel[m2+n5+1];
                b+=imgPixel[m2+n5+2];
                
                r+=imgPixel[m3+n1];
                g+=imgPixel[m3+n1+1];
                b+=imgPixel[m3+n1+2];
                r+=imgPixel[m3+n5];
                g+=imgPixel[m3+n5+1];
                b+=imgPixel[m3+n5+2];
                
                r+=imgPixel[m4+n1];
                g+=imgPixel[m4+n1+1];
                b+=imgPixel[m4+n1+2];
                r+=imgPixel[m4+n5];
                g+=imgPixel[m4+n5+1];
                b+=imgPixel[m4+n5+2];
                
                r+=imgPixel[m5+n1];
                g+=imgPixel[m5+n1+1];
                b+=imgPixel[m5+n1+2];
                
                r+=imgPixel[m5+n2];
                g+=imgPixel[m5+n2+1];
                b+=imgPixel[m5+n2+2];
                
                r+=imgPixel[m5+n3];
                g+=imgPixel[m5+n3+1];
                b+=imgPixel[m5+n3+2];
                
                r+=imgPixel[m5+n4];
                g+=imgPixel[m5+n4+1];
                b+=imgPixel[m5+n4+2];
                
                r+=imgPixel[m5+n5];
                g+=imgPixel[m5+n5+1];
                b+=imgPixel[m5+n5+2];
                
                r = r>>4;
                g = g>>4;
                b = b>>4;
                
                imgPixel[m3+n3]=pixelRange(r);
                imgPixel[m3+n3+1]=pixelRange(g);
                imgPixel[m3+n3+2]=pixelRange(b);
            }
        }
    }
}

//path pro


int curve_point_caculate_1(int r, double a, double b, double c, double d, double e) {
	double fresult = a * r * r * r * r + b * r * r * r + c * r * r + d * r + e;
	return pixelRange((int) fresult);
}

void path_step1(RGB *rgb, double distance_coeff,
                double distance_min, double distance_max, double la, double lb, double lc, double ld, double le,
                double dis1, double dis2, double dis3, double dis4, double dis5,
                double sec1, double sec2, double sec3, double sec4, double sec5) {
	int r = rgb->r;
	int g = rgb->g;
	int b = rgb->b;
    
	int tr;
	int tg;
	int tb;
    
    double dis_factor = distance_max - distance_min;
    dis1 *= dis_factor;
    dis2 *= dis_factor;
    dis3 *= dis_factor;
    dis4 *= dis_factor;
    dis5 *= dis_factor;
    
	double coeff;
    
    if (distance_coeff > distance_max) {
        tr = r;
        tg = g;
        tb = b;
        
		r = curve_point_caculate_1(tr, la, lb, lc, ld, le);
		g = curve_point_caculate_1(tg, la, lb, lc, ld, le);
		b = curve_point_caculate_1(tb, la, lb, lc, ld, le);
    } else if (distance_coeff > distance_min) {
        coeff = distance_coeff - distance_min;
        
        if (coeff > (dis1 + dis2 + dis3 + dis4)) {
            tr = curve_point_caculate_1(pixelRange(r), la, lb, lc, ld, le);
            tg = curve_point_caculate_1(pixelRange(g), la, lb, lc, ld, le);
            tb = curve_point_caculate_1(pixelRange(b), la, lb, lc, ld, le);
            
            r = (int) (r + (tr - r) * (sec1 + sec2 + sec3 + sec4) / 10.0 + ((tr - r) * sec5 / 10.0 / dis5) * (coeff - dis1 - dis2 - dis3 - dis4));
            g = (int) (g + (tg - g) * (sec1 + sec2 + sec3 + sec4) / 10.0 + ((tg - g) * sec5 / 10.0 / dis5) * (coeff - dis1 - dis2 - dis3 - dis4));
            b = (int) (b + (tb - b) * (sec1 + sec2 + sec3 + sec4) / 10.0 + ((tb - b) * sec5 / 10.0 / dis5) * (coeff - dis1 - dis2 - dis3 - dis4));
        } else if (coeff > (dis1 + dis2 + dis3)) {
            tr = curve_point_caculate_1(pixelRange(r), la, lb, lc, ld, le);
            tg = curve_point_caculate_1(pixelRange(g), la, lb, lc, ld, le);
            tb = curve_point_caculate_1(pixelRange(b), la, lb, lc, ld, le);
            
            r = (int) (r + (tr - r) * (sec1 + sec2 + sec3) / 10.0 + ((tr - r) * sec4 / 10.0 / dis4) * (coeff - dis1 - dis2 - dis3));
            g = (int) (g + (tg - g) * (sec1 + sec2 + sec3) / 10.0 + ((tg - g) * sec4 / 10.0 / dis4) * (coeff - dis1 - dis2 - dis3));
            b = (int) (b + (tb - b) * (sec1 + sec2 + sec3) / 10.0 + ((tb - b) * sec4 / 10.0 / dis4) * (coeff - dis1 - dis2 - dis3));
        } else if (coeff > (dis1 + dis2)) {
            tr = curve_point_caculate_1(pixelRange(r), la, lb, lc, ld, le);
            tg = curve_point_caculate_1(pixelRange(g), la, lb, lc, ld, le);
            tb = curve_point_caculate_1(pixelRange(b), la, lb, lc, ld, le);
            
            r = (int) (r + (tr - r) * (sec1 + sec2) / 10.0 + ((tr - r) * sec3 / 10.0 / dis3) * (coeff - dis1 - dis2));
            g = (int) (g + (tg - g) * (sec1 + sec2) / 10.0 + ((tg - g) * sec3 / 10.0 / dis3) * (coeff - dis1 - dis2));
            b = (int) (b + (tb - b) * (sec1 + sec2) / 10.0 + ((tb - b) * sec3 / 10.0 / dis3) * (coeff - dis1 - dis2));
        } else if (coeff > dis1) {
            tr = curve_point_caculate_1(pixelRange(r), la, lb, lc, ld, le);
            tg = curve_point_caculate_1(pixelRange(g), la, lb, lc, ld, le);
            tb = curve_point_caculate_1(pixelRange(b), la, lb, lc, ld, le);
            
            r = (int) (r + (tr - r) * sec1 / 10.0 + ((tr - r) * sec2 / 10.0 / dis2) * (coeff - dis1));
            g = (int) (g + (tg - g) * sec1 / 10.0 + ((tg - g) * sec2 / 10.0 / dis2) * (coeff - dis1));
            b = (int) (b + (tb - b) * sec1 / 10.0 + ((tb - b) * sec2 / 10.0 / dis2) * (coeff - dis1));
        } else if (coeff > 0) {
            tr = curve_point_caculate_1(pixelRange(r), la, lb, lc, ld, le);
            tg = curve_point_caculate_1(pixelRange(g), la, lb, lc, ld, le);;
            tb = curve_point_caculate_1(pixelRange(b), la, lb, lc, ld, le);
            
            r = (int) (r + ((tr - r) * sec1 / 10.0 / dis1) * coeff);
            g = (int) (g + ((tg - g) * sec1 / 10.0 / dis1) * coeff);
            b = (int) (b + ((tb - b) * sec1 / 10.0 / dis1) * coeff);
        }
    }
    
	rgb->r = pixelRange(r);
	rgb->g = pixelRange(g);
	rgb->b = pixelRange(b);
}

void path_step2(RGB *rgb, double distance_coeff,
                double distance_min, double distance_max, double la, double lb, double lc, double ld, double le,
                double dis1, double dis2, double dis3, double dis4, double dis5,
                double sec1, double sec2, double sec3, double sec4, double sec5) {
	int r = rgb->r;
	int g = rgb->g;
	int b = rgb->b;
    
	int tr;
	int tg;
	int tb;
    
    double dis_factor = distance_max - distance_min;
    dis1 *= dis_factor;
    dis2 *= dis_factor;
    dis3 *= dis_factor;
    dis4 *= dis_factor;
    dis5 *= dis_factor;
    
	double coeff;
    
    if (distance_coeff < distance_min) {
		tr = r;
		tg = g;
		tb = b;
        
		r = curve_point_caculate_1(tr, la, lb, lc, ld, le);
		g = curve_point_caculate_1(tg, la, lb, lc, ld, le);
		b = curve_point_caculate_1(tb, la, lb, lc, ld, le);
	} else if (distance_coeff < distance_max) {
        coeff = distance_coeff - distance_min;
        
        if (coeff > (dis1 + dis2 + dis3 + dis4)) {
            tr = curve_point_caculate_1(pixelRange(r), la, lb, lc, ld, le);
            tg = curve_point_caculate_1(pixelRange(g), la, lb, lc, ld, le);
            tb = curve_point_caculate_1(pixelRange(b), la, lb, lc, ld, le);
            
            r = (int) (tr + (r - tr) * (sec1 + sec2 + sec3 + sec4) / 10.0 + ((r - tr) * sec5 / 10.0 / dis5) * (coeff - dis1 - dis2 - dis3 - dis4));
            g = (int) (tg + (g - tg) * (sec1 + sec2 + sec3 + sec4) / 10.0 + ((g - tg) * sec5 / 10.0 / dis5) * (coeff - dis1 - dis2 - dis3 - dis4));
            b = (int) (tb + (b - tb) * (sec1 + sec2 + sec3 + sec4) / 10.0 + ((b - tb) * sec5 / 10.0 / dis5) * (coeff - dis1 - dis2 - dis3 - dis4));
        } else if (coeff > (dis1 + dis2 + dis3)) {
            tr = curve_point_caculate_1(pixelRange(r), la, lb, lc, ld, le);
            tg = curve_point_caculate_1(pixelRange(g), la, lb, lc, ld, le);
            tb = curve_point_caculate_1(pixelRange(b), la, lb, lc, ld, le);
            
            r = (int) (tr + (r - tr) * (sec1 + sec2 + sec3) / 10.0 + ((r - tr) * sec4 / 10.0 / dis4) * (coeff - dis1 - dis2 - dis3));
            g = (int) (tg + (g - tg) * (sec1 + sec2 + sec3) / 10.0 + ((g - tg) * sec4 / 10.0 / dis4) * (coeff - dis1 - dis2 - dis3));
            b = (int) (tb + (b - tb) * (sec1 + sec2 + sec3) / 10.0 + ((b - tb) * sec4 / 10.0 / dis4) * (coeff - dis1 - dis2 - dis3));
        } else if (coeff > (dis1 + dis2)) {
            tr = curve_point_caculate_1(pixelRange(r), la, lb, lc, ld, le);
            tg = curve_point_caculate_1(pixelRange(g), la, lb, lc, ld, le);
            tb = curve_point_caculate_1(pixelRange(b), la, lb, lc, ld, le);
            
            r = (int) (tr + (r - tr) * (sec1 + sec2) / 10.0 + ((r - tr) * sec3 / 10.0 / dis3) * (coeff - dis1 - dis2));
            g = (int) (tg + (g - tg) * (sec1 + sec2) / 10.0 + ((g - tg) * sec3 / 10.0 / dis3) * (coeff - dis1 - dis2));
            b = (int) (tb + (b - tb) * (sec1 + sec2) / 10.0 + ((b - tb) * sec3 / 10.0 / dis3) * (coeff - dis1 - dis2));
        } else if (coeff > dis1) {
            tr = curve_point_caculate_1(pixelRange(r), la, lb, lc, ld, le);
            tg = curve_point_caculate_1(pixelRange(g), la, lb, lc, ld, le);
            tb = curve_point_caculate_1(pixelRange(b), la, lb, lc, ld, le);
            
            r = (int) (tr + (r - tr) * sec1 / 10.0 + ((r - tr) * sec2 / 10.0 / dis2) * (coeff - dis1));
            g = (int) (tg + (g - tg) * sec1 / 10.0 + ((g - tg) * sec2 / 10.0) / dis2 * (coeff - dis1));
            b = (int) (tb + (b - tb) * sec1 / 10.0 + ((b - tb) * sec2 / 10.0) / dis2 * (coeff - dis1));
        } else if (coeff > 0) {
            tr = curve_point_caculate_1(pixelRange(r), la, lb, lc, ld, le);
            tg = curve_point_caculate_1(pixelRange(g), la, lb, lc, ld, le);
            tb = curve_point_caculate_1(pixelRange(b), la, lb, lc, ld, le);
            
            r = (int) (tr + ((r - tr) * sec1 / 10.0 / dis1) * coeff);
            g = (int) (tg + ((g - tg) * sec1 / 10.0 / dis1) * coeff);
            b = (int) (tb + ((b - tb) * sec1 / 10.0 / dis1) * coeff);
        }
	}
    
	rgb->r = pixelRange(r);
	rgb->g = pixelRange(g);
	rgb->b = pixelRange(b);
}

void path_step3(RGB *rgb, double distance_coeff, double distance_max) {
	int r = rgb->r;
	int g = rgb->g;
	int b = rgb->b;
    
    distance_coeff /= distance_max;
    
    int r_threshold;//0x98;
    int g_threshold;//0x99;
    int b_threshold;//0x82;
    
    double opacity = 0;
    
    if (distance_coeff < 0.3) {
        opacity = 0.05 + 0.05 / 0.3 * distance_coeff;
    } else if (distance_coeff < 0.56) {
        opacity = 0.10 + 0.15 / 0.26 * (distance_coeff - 0.3);
    } else if (distance_coeff < 0.80) {
        opacity = 0.25 + 0.34 / 0.24 * (distance_coeff - 0.56);
    } else {
        opacity = 0.59 + 0.41 / 0.20 * (distance_coeff - 0.8);
    }
    
    if (distance_coeff < 0.55) {
        r_threshold = 0x98;
        g_threshold = 0x99;
        b_threshold = 0x82;
    } else if (distance_coeff < 0.93) {
        r_threshold = 0x98 - (0x98 - 0x6e) / 0.38 * (distance_coeff - 0.55);
        g_threshold = 0x99 - (0x99 - 0x5f) / 0.38 * (distance_coeff - 0.55);
        b_threshold = 0x82 - (0x82 - 0x5d) / 0.38 * (distance_coeff - 0.55);
    } else {
        r_threshold = 0x6e;
        g_threshold = 0x5f;
        b_threshold = 0x5d;
    }
    
    int tr = (r < r_threshold) ? r : r_threshold;
    int tg = (g < g_threshold) ? g : g_threshold;
    int tb = (b < b_threshold) ? b : b_threshold;
    
    r = (int) (tr * opacity + r * (1 - opacity));
    g = (int) (tg * opacity + g * (1 - opacity));
    b = (int) (tb * opacity + b * (1 - opacity));
    
	rgb->r = pixelRange(r);
	rgb->g = pixelRange(g);
	rgb->b = pixelRange(b);
}

void rgb_curve_shadow_converg_apply(RGB *rgb, double distance_coeff,
                                    double distance_min, double distance_max, double ra, double rb, double rc,
                                    double rd, double ga, double gb, double gc, double gd, double ba, double bb,
                                    double bc, double bd, double la, double lb, double lc, double ld) {
	int r = rgb->r;
	int g = rgb->g;
	int b = rgb->b;
    
	int tr;
	int tg;
	int tb;
    
	double coeff;
    
	if (distance_coeff < distance_min) {
		tr = curve_point_caculate(r, ra, rb, rc, rd);
		tg = curve_point_caculate(g, ga, gb, gc, gd);
		tb = curve_point_caculate(b, ba, bb, bc, bd);
        
		r = curve_point_caculate(tr, la, lb, lc, ld);
		g = curve_point_caculate(tg, la, lb, lc, ld);
		b = curve_point_caculate(tb, la, lb, lc, ld);
	} else if (distance_coeff < distance_max) {
		tr = curve_point_caculate(r, ra, rb, rc, rd);
		tg = curve_point_caculate(g, ga, gb, gc, gd);
		tb = curve_point_caculate(b, ba, bb, bc, bd);
        
		coeff = (distance_coeff - distance_min) / (distance_max - distance_min);
		r = (int) (tr + (r - tr) * coeff);
		g = (int) (tg + (g - tg) * coeff);
		b = (int) (tb + (b - tb) * coeff);
        
		tr = curve_point_caculate(pixelRange(r), la, lb, lc, ld);
		tg = curve_point_caculate(pixelRange(g), la, lb, lc, ld);
		tb = curve_point_caculate(pixelRange(b), la, lb, lc, ld);
        
		r = (int) (tr + (r - tr) * coeff);
		g = (int) (tg + (g - tg) * coeff);
		b = (int) (tb + (b - tb) * coeff);
	}
    
	rgb->r = pixelRange(r);
	rgb->g = pixelRange(g);
	rgb->b = pixelRange(b);
}


void imageProFilterProcess(void *inImage, uint width, uint height)
{
    
    if (inImage == NULL) {
        return;
    }
    
    // 设置RGB参数值
    double la1 = 1.242e-07;
	double lb1 = -2.726e-05;
	double lc1 = 0.001664;
	double ld1 = 0.3025;
    double le1 = -0.3201;
    
	double la2 = 1.585e-07;
	double lb2 = -9.574e-05;
	double lc2 = 0.01628;
	double ld2 = 0.4404;
    double le2 = 1.364 + 10;
    
	double ra3 = 8.214e-06;
	double rb3 = -0.005948;
	double rc3 = 2.177;
	double rd3 = -46.11;
	double ga3 = -5.161e-06;
	double gb3 = 0.001879;
	double gc3 = 0.8686;
	double gd3 = 2.588;
	double ba3 = -7.206e-07;
	double bb3 = 0.001104;
	double bc3 = 0.6422;
	double bd3 = 27.4;
    double la3 = -1.389e-06;
    double lb3 = 0.001411;
    double lc3 = 0.6832;
    double ld3 = 13.56;

    
    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    
    int r = 0,g = 0,b = 0;
    int m1,m2,m3,n1,n2,n3;
    
    
	int center_x = width / 2;
	int center_y = height / 2;
    
    float distance_coeff;
    RGB rgb;
    
    for (int y=0; y<h; y++) {
        for (int x=0; x<w; x++) {
            
            m1 = w*(y-1)<<2;
            m2 = w*y<<2;
            m3 = w*(y+1)<<2;
            
            n1 = (x-1)<<2;
            n2 = x<<2;
            n3 = (x+1)<<2;
            
            r=imgPixel[m2+n2];
            g=imgPixel[m2+n2+1];
            b=imgPixel[m2+n2+2];
            
            
            rgb.r = r;
            rgb.g = g;
            rgb.b = b;
            
            distance_coeff = sqrt((y - center_y) * (y - center_y) / ((double) (center_y * center_y))
                                  + (x - center_x) * (x - center_x) / ((double) (center_x * center_x)));
            
            path_step1(&rgb, distance_coeff, 0.0, sqrt(2.0), la1, lb1, lc1, ld1, le1,
                       0.25, 0.25, 0.2, 0.2, 0.1,
                       1.5, 1.5, 2.0, 2.0, 3.0);
            path_step2(&rgb, distance_coeff, 0.0, sqrt(2.0), la2, lb2, lc2, ld2, le2,
                       0.3, 0.3, 0.15, 0.15, 0.1,
                       1.0, 1.0, 2.0, 3.0, 3.0);
            
            rgb_curve_shadow_converg_apply(&rgb, 0, 0.1, 0,
                                           ra3, rb3, rc3, rd3, ga3, gb3, gc3, gd3,
                                           ba3, bb3, bc3, bd3, la3, lb3, lc3, ld3);
            
            path_step3(&rgb, distance_coeff, sqrt(2.0));
            
            r = rgb.r;
            g = rgb.g;
            b = rgb.b;
            
            
            imgPixel[m2+n2]=pixelRange(r);
            imgPixel[m2+n2+1]=pixelRange(g);
            imgPixel[m2+n2+2]=pixelRange(b);
            
        }
    }
    
	
}
/*
void GammaAdujest(void *inImage, uint width, uint height,RGB* rgb)
{
        
    if (inImage == NULL) {
        return ;
    }
    
    unsigned char *imgPixel = (unsigned char*)inImage;
    uint w = width, h = height;
    
    int m2,n2;
    int R,G,B;
    
    int _colBalance[4]={0,0,0,0};
    float gammas[3]={0.0};
    int _gammaTresh = 6;
    int  _gammaBase = 250;
    float _gammaRed = 0.3;
    float avgC,maxRGB,minRGB;
      
    for (int y=0; y<h;y=y+(int)(h/20.0)) {
        for (int x=0; x<w;x=x+(int)(w/20.0)) {
            
            m2 = w*y<<2;            
            n2 = x<<2;            
            
            R = imgPixel[m2+n2];
            G = imgPixel[m2+n2+1];
            B = imgPixel[m2+n2+2];
            avgC = (R+G+B+3 *_neutralCPoint)/3.0;
            maxRGB = MAX(MAX(R, G), B);
            minRGB = MIN(MIN(R, G), B);
        
            if ((maxRGB-minRGB)/avgC > 0.001 && avgC > 255 && (maxRGB-minRGB)/avgC < 255 && maxRGB < 255 && minRGB > 0)
            {
                _colBalance[0]=_colBalance[0]+(R + _neutralCPoint- avgC);
				_colBalance[1]=_colBalance[1]+(G + _neutralCPoint- avgC);
				_colBalance[2]=_colBalance[2]+(B + _neutralCPoint- avgC);
                _colBalance[3]=_colBalance[3]+1;
            }
        }
    }
    
    float value=0.0;
    
    for (int i=0; i<4; i++) {
        value=_colBalance[i];
        
		value=value/float(_colBalance[3]);
        if (value > _gammaTresh) {
            value = (value - _gammaTresh) * _gammaRed + _gammaTresh;
        }
        else if(value < (-1*_gammaTresh))
        {
            value=(value+_gammaTresh)*_gammaRed-_gammaTresh;
        }
        else
        {
            value=value;
        }
        
        gammas[i]=1+(value/_gammaBase);
    }
    
    rgb->r=gammas[0];
    rgb->g=gammas[1];
    rgb->b=gammas[2];
}

void getNewValues(float *oldValue,float * newValues,int len,float* defCurve_min,float* defCurve_max,float weight,float *limits)
{

    float* defCurve=(float *)malloc(sizeof(float)*len);
    
    for (int i=0; i<len; i++) {
        
        newValues[i]=0.0;
        if (oldValue[i] > defCurve_max[i]) {
            defCurve[i]=defCurve_max[i];
        }
        else if(oldValue[i]<defCurve_min[i]){
            defCurve[i]=defCurve_min[i];
        }
        else
        {
            defCurve[i]=oldValue[i];
        }
    }
   
    float newValue = 0.0;
    for (int i=0; i<len; i++) {
        newValue = defCurve[i]*weight + oldValue[i]*(1.0-weight);
        if (i<len-1)
        {
            newValue = MIN(MIN(newValue, ((limits[0]+oldValue[i])*limits[1])-limits[0]), oldValue[i]+limits[2]);
            newValue = MAX(MAX(newValue, ((limits[0]+oldValue[i])/limits[1])-limits[0]), oldValue[i]-limits[2]);
        }
        newValues[i]=newValue; 
    }
    
    free(defCurve);
}

float valueRemap(float *Xpoints,float *Ypoints,int len,float Xvalue)
{
    float x0,x1,y0,y1;
    float Yvalue=0.0;
    int temp = 0;
    for (int i=0; i<len; i++) {
        temp = i-1;
        if (temp<0) {
            temp = len-1;
        }
        if (Xpoints[temp] <=Xvalue && Xpoints[temp+1]>=Xvalue ) {
            x0=Xpoints[temp];
            x1=Xpoints[temp+1];
            y0=Ypoints[temp];
            y1=Ypoints[temp+1];
            break;
        }
    }
    
    if (x1==x0) {
        Yvalue=y0;
    }
    else
    {
        Yvalue=y0 + (Xvalue-x0)*(y1-y0)/float(x1-x0);
    }
   
    return Yvalue;
}


RGB getRGB3(RGB rgb,float newSat,float newBrightness)
{
    RGB RGB;
    
    float R2=rgb.r;
    float G2=rgb.g;
    float B2=rgb.b;
    
	float curBrightness = 0.299*R2 + 0.587*G2 + 0.114*B2;
    float curSpread =MAX(MAX(R2, G2), B2)-MIN(MIN(R2, G2), B2);

	float diff = newBrightness + curBrightness;
    
    R2 += diff;
    G2 += diff;
    B2 += diff;
	
	float avg = (R2 + G2 +B2) / 3.0;
	float neededSpread = (newBrightness+_neutralCPoint)*newSat;
    
    float boost=0.0;
	if (curSpread == 0)
    {
        boost=1;
    }
    else
    {    boost = neededSpread/float(curSpread);
       
    }
    
    R2=avg + (R2-avg)*boost;
    G2=avg + (G2-avg)*boost;
    B2=avg + (B2-avg)*boost;

    float realBrightness = sqrt(0.241*R2*R2 + 0.691*G2*G2+ 0.068*B2*B2);
    for (int i=0; i<5; i++) {
        if (MIN(MIN(R2, G2), B2) < 0 || abs(realBrightness-newBrightness) < 0.1)
        {
            break;
        }
        
        diff = newBrightness - realBrightness;
        R2=R2 + diff;
        G2=G2 + diff;
        B2=B2 + diff;
        realBrightness = sqrt(0.241*R2*R2 + 0.691*G2*G2+ 0.068*B2*B2);
    }
    
    RGB.r=R2;
    RGB.g=G2;
    RGB.b=B2;
  
    return RGB;    
}


void Insert(float *str,int n)
{
    int j;
    float temp;
    for(int i=1;i<n;i++)
    {
        temp=str[i];
        j=i-1;
        while(j>=0&&temp<str[j])
        {
            str[j+1]=str[j];
            j--;
        }
        str[j+1]=temp;
    }
}

// doing ANALYSIS	- round TWO
void AnalysisRoundTwo(RGB* rgb,void *inImage,void *blurImage,void *maskImg, uint width, uint height)
{
    if (inImage == NULL) {
        return ;
    }
    
    unsigned char *imgPixel = (unsigned char*)inImage;
    unsigned char *blurPixel = (unsigned char*)blurImage;
    unsigned char *maskPixel = (unsigned char*)maskImg;
    
    
    uint w = width, h = height;
    int m2,n2;
    
    float* brightnessList=(float*)malloc(sizeof(float)*(w*h));
    float* sharpList=(float*)malloc(sizeof(float)*(w*h));
    float* saturationList=(float*)malloc(sizeof(float)*(w*h));
    
    int ll=0,ll2=0,ll3=0;
    int R,G,B,Rmm,Gmm,Bmm;
    double brightness,brightnessMM,saturationMM;
    float sharpDiff,saturation;
    
    for (int y=0; y<h;y+=(h/20)) {
        for (int x=0; x<w;x+=(w/20)) {
            
            m2 = w*y<<2;
            n2 = x<<2;
            
            R = imgPixel[m2+n2];
            G = imgPixel[m2+n2+1];
            B = imgPixel[m2+n2+2];
          
            R = 255*(pow((R/255.0), rgb->r));
            G = 255*(pow((G/255.0), rgb->g));
            B = 255*(pow((B/255.0), rgb->b));
            
            brightness = sqrt(0.241*pow(R, 2) + 0.691*pow(G, 2) + 0.068*pow(B, 2));
            if(	brightness > 3.0 && brightness < 253.0)
            {
				brightnessList[ll++]=brightness;
            }
        
            Rmm = blurPixel[m2+n2];
            Gmm = blurPixel[m2+n2+1];
            Bmm = blurPixel[m2+n2+2];
            
            brightnessMM = sqrt(0.241*pow(Rmm, 2) + 0.691*pow(Gmm, 2) + 0.068*pow(Bmm, 2));
            sharpDiff = (abs((brightnessMM-brightness))) /(brightnessMM+_neutralPointSh);
            sharpList[ll2++]=sharpDiff;
            
            saturation = (MAX(MAX(R, G), B)-MIN(MIN(R, G), B))/(brightness + _neutralCPoint);
            if (_colorMaskWeight > 0)
            {
                saturationMM = (MAX(MAX(Rmm, Gmm), Bmm)-MIN(MIN(Rmm, Gmm), Bmm))/(brightnessMM+_neutralCPoint);
				saturation = (saturationMM * _colorMaskWeight) + (saturation * (1-_colorMaskWeight));
            }
             
            saturationList[ll3++]=saturation;
        }
    }
    

    // For Brightness
    float oldValueB[6]={0.0};
    int numberOfItemsB = ll;
    oldValueB[0]=0;
    Insert(brightnessList,ll);

    for (int i=1; i<5; i++) {
        int point=_brgCrvPoints[i-1];
        float value=brightnessList[int (floorf(point/100.0*(numberOfItemsB)))];
        oldValueB[i]=value;
    }
    oldValueB[5]=255;
    float newValuesB[6]={0.0};
    
   getNewValues(oldValueB,newValuesB,6,_brgCrv,_brgCrv,_brgCrvWeight,_br_limits);
    
    // For saturation

    int numberOfItemsC=ll3;
    float oldValuesC[6]={0};
    oldValuesC[0]=0;
    
    Insert(saturationList,ll3);
    for (int i=1; i<5; i++) {
        int point=_colCurvePoints[i-1];
        float value=saturationList[int(point/100.0*numberOfItemsC)];
        oldValuesC[i]=value;
    }
    oldValuesC[5]=1000;
    float newValuesC[6]={0.0};
   
    getNewValues(oldValuesC,newValuesC,6,_colCurve_min,_colCurve_max,_colCurveWeight,_sat_limits);
    
      

    Insert(sharpList,ll2);
    int numberOfItemsS=ll2;
    float oldValuesS[5]={0,0,0,0,50};
    oldValuesS[1]= sharpList[int(0.40*numberOfItemsS)];
    oldValuesS[2]= sharpList[int(0.80*numberOfItemsS)];
    oldValuesS[3]= sharpList[int(0.99*numberOfItemsS)];
    float newValuesS[5]={0.0};
    getNewValues(oldValuesS,newValuesS,5,_sharpCurve,_sharpCurve,_sharpCurveWeight,_sharp_limits);
    
    
    int Rs,Gs,Bs,Rrm,Grm,Brm;
    for (int y=0; y<h; y++) {
        for (int x=0; x<w; x++) {
            
            m2 = w*y<<2;            
            n2 = x<<2;
            
            R = imgPixel[m2+n2];
            G = imgPixel[m2+n2+1];
            B = imgPixel[m2+n2+2];
        
            Rs = maskPixel[m2+n2];
            Gs = maskPixel[m2+n2+1];
            Bs = maskPixel[m2+n2+2];
            
            float diff =abs(Rs-R)/float(R +_neutralPointSh) + \
            abs(Gs - G )/float(G + _neutralPointSh) + \
            abs(Bs - B) / float(B +_neutralPointSh);
            
            if (diff< 0.08 && diff >0.0) {
                float rw=0.8;
                R = pixelRange(Rs*rw+R*(1-rw));
                G = pixelRange(Gs*rw+G*(1-rw));
                B = pixelRange(Bs*rw+B*(1-rw));
            }
            
            R = 255*(pow((R/255.0), rgb->r));
            G = 255*(pow((G/255.0), rgb->g));
            B = 255*(pow((B/255.0), rgb->b));
            
            
            Rrm = blurPixel[m2+n2];
            Grm = blurPixel[m2+n2+1];
            Brm = blurPixel[m2+n2+2];

            float brightnessMM=sqrt(0.241*Rrm*Rrm + 0.691*Grm*Grm+ 0.068*Brm*Brm);
			float brightnessMMNew = valueRemap(oldValueB,newValuesB,6,brightnessMM);
            
			
            float brightness=sqrt(0.241*R*R + 0.691*G*G+ 0.068*B*B);
            float curSharp = (brightness+_neutralPointSh)/(brightnessMM+_neutralPointSh)-1.0;
            float newSharp=0.0;
            if( curSharp >= 0)
            {
				newSharp = valueRemap(oldValuesS,newValuesS,6,curSharp);
            }
            else{
                newSharp = valueRemap(oldValuesS,newValuesS,6,-curSharp) * (-1);
            }
            
            float newBrightness=(brightnessMMNew+_neutralPointSh)*(1+newSharp) -_neutralPointSh;
            float curSaturation = (MAX(MAX(R, G), B)-MIN(MIN(R, G), B))/(brightness+_neutralCPoint);
			float newSat=valueRemap(oldValuesC,newValuesC,5,curSaturation);
          
            RGB rgb;
            rgb.r=R;
            rgb.g=G;
            rgb.b=B;
            
            rgb = getRGB3(rgb,newSat,newBrightness);
            
            R=rgb.r;
            G=rgb.g;
            B=rgb.b;
            
            imgPixel[m2 + n2] = pixelRange(R);
            imgPixel[m2 + n2 + 1] = pixelRange(G);
            imgPixel[m2 + n2 + 2] = pixelRange(B);
        }
    }
}
*/
