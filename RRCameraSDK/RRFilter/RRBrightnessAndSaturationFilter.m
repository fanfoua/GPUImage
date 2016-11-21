//
//  RRBrightnessAndSaturationFilter.mm
//  RRCameraSDK
//
//  Created by 淮静 on 14-8-8.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#include <math.h>
#include <stdio.h>
#include "RRBrightnessAndSaturationFilter.h"

int BrightnessAndSaturation(unsigned char* src, int height,  int width,
                             int channels)
{
    if (src == 0) {
        return -1;
    }
    if (channels != 4) {
        return -2;
    }
    
    int rgbChannels = 3;

    //split RGB
    int n = width * height;
    unsigned char** pimgChannel =  (unsigned char **)malloc(sizeof(unsigned char *)*rgbChannels);
    float* S = malloc(sizeof(float)*n);
    unsigned char* V = malloc(sizeof(unsigned char)*n);
    
    int i = 0, j = 0;
    for(i = 0; i < rgbChannels; i++)
    {
        pimgChannel[i] = malloc(sizeof(unsigned char)*n);
    }
    
    int k=0;
    for(k = 0, i = 0;i < n * channels;i += channels, k++)
    {
        pimgChannel[0][k] = src[i];     //b
        pimgChannel[1][k] = src[i+1];   //g
        pimgChannel[2][k] = src[i+2];   //r
    }
    
    //to S、V
    for(k = 0, i = 0;i < n * channels;i += channels, k++)
    {
        unsigned char b = src[i], g = src[i+1], r = src[i+2];
        unsigned char vmin,v;
        
        float diff,s;
        v = vmin = r;
        if( v < g) v = g;
        if(v < b) v = b;
        if( vmin > g ) vmin = g;
        if( vmin > b ) vmin = b;
        
        diff =(float)(v - vmin);
        if(v == 0)
            s = 0;
        else
            s = diff / v;
        
        S[k] = s;
        V[k] = v;
    }
    
    //avg of S
    float SSum = 0.0,Savg = 0.0;
    for(i = 0; i < n; i++)
    {
        float ss = S[i];
        SSum += ss;
    }
    Savg = SSum / n;
    
    //avg of V
    float sum = 0, avg = 0.0;
    for(i = 0; i < n; i++)
    {
        sum += (float)V[i] / 255;
    }
    avg = sum/n;
    
    //get the value of Gamma
    float minSaturation = 0.20;
    float maxSaturation = 0.45;
    int value, threshold, maxValue,minValue;
    float Gamma = 1.0, x = 0;
    if(Savg > minSaturation && Savg < maxSaturation)
        Gamma = 1.0;
    else if(Savg <= minSaturation)
        Gamma = (float)1.0 + (minSaturation - Savg);
    else
        Gamma = (float)1.0 - (Savg - maxSaturation);
    printf("%f,%f\n",Savg, Gamma);
    
    
    //adjust contrast and saturation
    for(k = 0; k < rgbChannels; k++)
    {
        maxValue = 0,minValue = 255;
        for(i = 0; i < n; i++)
        {
            value = (int)pimgChannel[k][i];
            if( value < minValue)
                minValue = value;
            if (value > maxValue)
                maxValue = value;
            
        }
        threshold = maxValue - minValue;
        for(i = 0; i < n; i++)
        {
            value = (int)pimgChannel[k][i];
            if(Gamma == 1)
            {
                x = pow((float)(value - minValue)/threshold,Gamma) * 255;
                if(x <= 255)
                    pimgChannel[k][i] = (int)x;
                else
                    pimgChannel[k][i] = 255;
            }
            else
            {
                if(value < minValue + threshold*0.05)
                    pimgChannel[k][i] = minValue;
                else if (value > maxValue - threshold*0.05)
                    pimgChannel[k][i] = maxValue;
                else
                {
                    x = pow((float)(value - minValue)/threshold,Gamma) * 255;
                    if(x <= 255)
                        pimgChannel[k][i] = (int)x;
                    else
                        pimgChannel[k][i] = 255;
                    
                }
            }
        }
    }
    
    //adjusting lightness
    float maxV = 0.75;
    float threshV = 0.3;
    float H_max = 0.0;
    H_max = (maxV - avg)*threshV;
    
    for(k = 0; k < rgbChannels; k++)
    {
        for(int i = 0; i < n; i++)
        {
            x = H_max * (float)V[i];
            if(pimgChannel[k][i] + (int)x <= 255)
            {
                pimgChannel[k][i] += (int)x;
            }
            else
                pimgChannel[k][i] = 255;
        }
    }
    
    //merge RGBA
    k = 0;
    while(k < rgbChannels)
    {
        for(j = 0;j < width * height;j++)
        {
            int temp = j*channels + k;
            src[temp] = pimgChannel[k][j];
        }
        k++;
    }
    
    free(S);
    free(V);
    
    for(i = 0;i < rgbChannels; i++)
    {
        free(pimgChannel[i]);
    }
    free(pimgChannel);
    return 0;
}