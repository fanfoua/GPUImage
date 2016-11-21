//
//  RRColorTransform.m
//  RROpenCV
//
//  Created by lych on 10/23/12.
//  Copyright (c) 2012 lych. All rights reserved.
//

#import "RRColorTransform.h"
#import "RRFilterTool.h"


HSL RGBTOHSL(RGB rgb)
{
    HSL hsl = {0,0,0};
    float r = rgb.r/255, b = rgb.b/255, g = rgb.g/255;
    float minval = MIN(MIN(r, g), b);
    float maxval = MAX(MAX(r, g), b);
    
    if (maxval == minval) {
        hsl.h = 0.0;
    }
    else if (r == maxval && g >= b) {
        hsl.h = 60*((g - b)/(maxval-minval)) + 0.0;
    }
    else if (r == maxval && g < b) {
        hsl.h = 60*((g - b)/(maxval-minval)) + 360.0;
    }
    else if (g == maxval)
    {
        hsl.h = 60*((b - r)/(maxval-minval)) + 120.0;
    }
    else if (b == maxval)
    {
        hsl.h = 60*((r - g)/(maxval-minval)) + 240.0;
    }
    
    hsl.l = (maxval + minval)/2;
    
    if (0 == hsl.l || maxval == minval) {
        hsl.s = 0.0;
    }
    else if (0 < hsl.l && hsl.l <= 0.5) {
        hsl.s = (maxval-minval)/(maxval+minval);
    }
    else if (hsl.l > 0.5) {
        hsl.s = (maxval-minval)/(2- maxval - minval);
    }
    
    return hsl;
}


RGB HSLTORGB(HSL hsl)
{
    RGB rgb;
    float p,q,h,r,g,b;
    if (hsl.l >= 0.5) {
        q = hsl.l + hsl.s - (hsl.l*hsl.s);
    }
    else
    {
        q = hsl.l*(1+hsl.s);
    }
    
    p = 2*hsl.l - q;
    
    h = hsl.h/360.0;
    r = h + 1/3.0;
    g = h;
    b = h - 1/3.0;
    
    r = r > 1.0 ? (r - 1.0):((r < 0)?(r += 1.0): r);
    g = g > 1.0 ? (g - 1.0):((g < 0)?(g += 1.0): g);
    b = b > 1.0 ? (b - 1.0):((b < 0)?(b += 1.0): b);
    
    rgb.r = RGB_FloatToInt(r, p, q);
    rgb.g = RGB_FloatToInt(g, p, q);
    rgb.b = RGB_FloatToInt(b, p, q);
    
    return rgb;
}

HSB RGBTOHSB(RGB rgb)
{
    HSB hsb;
    float r = rgb.r/255, b = rgb.b/255, g = rgb.g/255;
    float minval = MIN(MIN(r, g), b);
    float maxval = MAX(MAX(r, g), b);
    float diff=(float)(maxval-minval);
    
    float del_r,del_g,del_b;
    hsb.b = maxval;
    
    if (diff == 0) {
        hsb.s = 0;
        hsb.h = 0;
    }
    else
    {
        hsb.s = 1 - minval/maxval;
        
        del_r = (((maxval - r)/6) + (diff/2))/diff;
        del_g = (((maxval - g)/6) + (diff/2))/diff;
        del_b = (((maxval - b)/6) + (diff/2))/diff;
        
        if (r == maxval) {
            hsb.h = del_b - del_g;
        }
        else if (g == maxval)
        {
            hsb.h = 1.0/3 +del_r - del_b;
        }
        else if (b == maxval)
        {
            hsb.h = 2.0/3 +del_g - del_r;
        }
        
        if (hsb.h < 0) {
            hsb.h += 1;
        }
        if (hsb.h > 1) {
            hsb.h -= 1;
        }
    }
    
    return hsb;
}

int RGB2HSB(int r,int g,int b)
{
    int minval=((r<g?r:g))<b?(r<g?r:g):b;
    int maxval=((r>g?r:g))>b?(r>g?r:g):b;
    float hue=0.0;
    
    if (maxval==minval) {
        hue=0.0;
    }
    else
    {
        float diff=(float)(maxval-minval);
        float rnorm=(maxval-r)/diff;
        float gnorm=(maxval-g)/diff;
        float bnorm=(maxval-b)/diff;
        
        hue=0.0;
        
        if (r==maxval) {
            hue=60.0*(6.0+bnorm-gnorm);
        }
        
        if (g==maxval) {
            hue=60.0*(2.0+rnorm-bnorm);
        }
        
        if (b==maxval) {
            hue=60.0*(4.0+gnorm-rnorm);
        }
        
        if (hue > 360.0) {
            hue=hue-360.0;
        }
    }
    
    return hue;
}


RGB HSBTORGB(HSB hsb)
{
    RGB rgb;
    int i;
    float f,p,q,t;
    if (hsb.s == 0) {
        rgb.r = hsb.b*255;
        rgb.g = hsb.b*255;
        rgb.b = hsb.b*255;
    }
    else
    {
        f = hsb.h*6;
        i = f;
        p = hsb.b*(1-hsb.s);
        q = hsb.b*(1-hsb.s*(f - i));
        t = hsb.b*(1-hsb.s*(1-f + i));
        
        switch (i) {
            case 0:
                rgb.r = hsb.b,
                rgb.g = t,
                rgb.b = p;
                break;
            case 1:
                rgb.r = q,
                rgb.g = hsb.b,
                rgb.b = p;
                break;
            case 2:
                rgb.r = p,
                rgb.g = hsb.b,
                rgb.b = t;
                break;
            case 3:
                rgb.r = p,
                rgb.g = q,
                rgb.b = hsb.b;
                break;
            case 4:
                rgb.r = t,
                rgb.g = p,
                rgb.b = hsb.b;
                break;
            case 5:
                rgb.r = hsb.b,
                rgb.g = p,
                rgb.b = q;
                break;
            default:
                break;
        }
    }
    
    rgb.r *= 255;
    rgb.g *= 255;
    rgb.b *= 255;
    
    return rgb;
}

HSI RGBTOHSI(RGB rgb)
{

    HSI hsi;
    
    int  r=rgb.r;
    int g=rgb.g;
    int b=rgb.b;
    
    double hue=0.0;
    double saturation=0.0,intensity=0.0;
    
    int max=MAX(MAX(r, g), b);
    int min=MIN(MIN(r, g), b);
    int c=max-min;
    
    if (0 == c) {
        // hue is unreasonable here, so give a random value to it.
        hue = 3.5;
    } else if (max == r) {
        hue = (double) (g - b) / c;
        if (hue < 0) {
            hue += 6.0;
        }
    } else if (max == g) {
        hue = 2.0 + (double) (b - r) / c;
    } else {
        hue = 4.0 + (double) (r - g) / c;
    }
    
    hue *= 60;
    
    //  hue=acos((((r-g)+(r-b))/2)/sqrt(((r-g)*(r-g)+(g-b)*(r-b))));
    
    double i=(double)(r+g+b)/3;
    int m=MIN(MIN(r, g), b);
    int cc=MAX(MAX(r, g), b)-m;
    double s;
    
    if (0==cc) {
        s=0.0;
    }else
    {
        s=1.0-m/i;
    }
    
    saturation=s;
    
    intensity=(double)(r+g+b)/765.0;
    
    hsi.h=hue;
    hsi.s=saturation;
    hsi.i=intensity;
   
    
    return hsi;
    
    
}

RGB HSITORGB(HSI hsi)
{
    int r, g, b;
    double h=hsi.h,s=hsi.s,i=hsi.i;
    
    int min;
    double h1 = h;
    
    RGB rgb;
    
    min = (int)(i * (1.0 - s) * 255);
    
    if (h <= 60.0) {
        h1 /= 60;
        b = min;
        g = (int)((h1 * (3 * i * 255 - 2 * b) + b) / (1.0 + h1));
        r = (int)(3 * i * 255) - g - b;
        
    } else if (h > 60.0 && h <= 120.0) {
        h1 /= 60;
        h1 -= 2.0;
        b = min;
        r = (int)((-h1 * (3 * i * 255 - 2 * b) + b) / (1.0 - h1));
        g = (int)(3 * i * 255) - b - r;
    } else if (h > 120.0 && h <= 180.0) {
        h1 /= 60;
        h1 -= 2.0;
        r = min;
        b = (int)((h1 * (3 * i * 255 - 2 * r) + r) / (1.0 + h1));
        g = (int)(3 * i * 255) - b - r;
    } else if (h > 180.0 && h <= 240.0) {
        h1 /= 60;
        h1 -= 4.0;
        r = min;
        g = (int)((-h1 * (3 * i * 255 - 2 * r) + r) / (1.0 - h1));
        b = (int)(3 * i * 255) - r - g;
    } else if (h > 240.0 && h <= 300.0) {
        h1 /= 60;
        h1 -= 4.0;
        g = min;
        r = (int)((h1 * (3 * i * 255 - 2 * g) + g) / (1.0 + h1));
        b = (int)(3 * i * 255) - r - g;
    } else {
        h1 /= 60;
        h1 -= 6.0;
        g = min;
        b = (int)((-h1 * (3 * i * 255 - 2 * g) + g) / (1.0 - h1));
        r = (int)(3 * i * 255) - g - b;
    }
    
    rgb.r=r;
    rgb.b=b;
    rgb.g=g;
    
    return rgb;
}

YCBCR RGBTOYCBCR(RGB rgb,int type)
{
    YCBCR ycbcr;
    if (1 == type) {
        ycbcr.Y  =  rgb.r * 0.25678824 + rgb.g * 0.50412941 + rgb.b * 0.09790588 + 16;
        ycbcr.Cb = -rgb.r * 0.1482229 - rgb.g * 0.29099279 + rgb.b * 0.43921569 + 128;
        ycbcr.Cr =  rgb.r * 0.43921569 - rgb.g * 0.36778831 - rgb.b * 0.07142737 + 128;
    }
    else if (2 == type)
    {
        ycbcr.Y  =  rgb.r * 0.18258588 + rgb.g * 0.61423059 + rgb.b * 0.06200706 + 16;
        ycbcr.Cb = -rgb.r * 0.10064373 - rgb.g * 0.33857195 + rgb.b * 0.43921569 + 128;
        ycbcr.Cr =  rgb.r * 0.43921569 - rgb.g * 0.39894216 - rgb.b * 0.04027352 + 128;
    }
    else if (3 == type)
    {
        ycbcr.Y  =  rgb.r * 0.25678824 + rgb.g * 0.50412941 + rgb.b * 0.09790588 + 16;
        ycbcr.Cb = -rgb.r * 0.1482229 - rgb.g * 0.29099279 + rgb.b * 0.43921569 + 128;
        ycbcr.Cr =  rgb.r * 0.43921569 - rgb.g * 0.36778831 - rgb.b * 0.07142737 + 128;
    }
    
    return ycbcr;
}
