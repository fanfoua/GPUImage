//
//  RRPhotoFilter.h
//  RROpenCV
//
//  Created by lych on 10/23/12.
//  Copyright (c) 2012 lych. All rights reserved.
//
#import "RRColorTransform.h"
#import "RRFilterTool.h"
/**
 *   功能说明:
 *   完成照片磨皮和美白处理。
 **/

/**
 * @brief 图像美白处理
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @param repeat 操作次数（某些操作只处理一次）
 * @return null
 */
void ImageWhitenFilter(void *inImage, uint width, uint height, uint repeat);
void ImageWhitenFilterTest(void *inImage, uint width, uint height, uint repeat);

/**
 * @brief 
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @param repeat 操作次数（某些操作只处理一次）
 * @return
 */

void ImageHueFilter(void *inImage, uint width, uint height, uint repeat);

/**
 * @brief
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @param repeat 操作次数（某些操作只处理一次）
 * @return null
 */
void ImageSaturationFilter(void *inImage, uint width, uint height, uint repeat);

/**
 * @brief 图像磨皮处理（双边滤波）
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @param ds     距离
 * @param rs     相似性
 * @return null
 */
void bilateral_filter(void *inImage,uint width, uint height, int ds, int rs);

/**
 * @brief 图像磨皮处理（双边滤波）
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @param ds     距离
 * @param rs     相似性
 * @return null
 */

void ImageBilateralFilter(void *inImage,uint width, uint height, int ds, int rs);
// 双边滤波
void domain_bilateral_filter(void *inImage,uint width, uint height, double sigma_spatial, double sigma_range);
// 优化双边滤波
void domain_fuck_bilateral_filter(void *inImage,uint width, uint height, double sigma_spatial, double sigma_range);
/**
 * @brief 脸部红润处理(CMYK 颜色空间 模拟photoshop可选颜色算法)
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @param repeat 操作次数（某些操作只处理一次）
 * @return null
 */
void ImageCMYKToRed(void *inImage, uint width, uint height, uint repeat);

/**
 * @brief 图像对比度增强处理
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @param repeat 操作次数（某些操作只处理一次）
 * @return null
 */
void ImageContrastFilter(void *inImage, uint width, uint height, uint repeat);

/**
 * @brief 图像直方图增强处理
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @return null
 */
void ImageHistoEqualizationFilter(void *inImage, uint width, uint height);

/**
 * @brief 图像锐化增强处理
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @param repeat 操作次数
 * @return null
 */
void ImageSharpenFilter(void *inImage, uint width, uint height, uint repeat);

/**
 * @brief 图像明度和对比度调整
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @return null
 */
void imageBrightAndContrastAdjuet(void *inImage, uint width, uint height,int contrast,int brightness);

/**
 * @brief 图像曲线调整
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @return null
 */

void imageCurveAdjuet(void *inImage, uint width, uint height);

/**
 * @brief PhotoShop图像饱和度调整算法 
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @return null
 */
void imageSaturationAdjuet(void *inImage, uint width, uint height,int saturation);

/**
 * @brief 柔光混合方式
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @param opacity 上层图层的不透明度
 * @param filling 上层图层的填充不透明度
 * @return null
 */

void imageSoftlightCompose(void *inImage, uint width, uint height,float opacity, float filling);


/**
 * @brief 对图像应用蒙版
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @return null
 */

void imageTemplateApply(void *inImage, uint width, uint height);
void rgb_curve_template_apply(RGB *rgb, float distance_coeff, float distance_min, float distance_max);
void rgb_curve_template_apply_1(RGB *rgb, float distance_coeff, float distance_min, float distance_max);
void rgb_curve_template_apply_2(RGB *rgb);

/**
 * @brief Rise滤镜效果
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @return null
 */
void imageRiseFilterProcess(void *inImage, uint width, uint height);

/**
 * @brief 滤镜效果
 * @param inImage RGB数据源
 * @param width  图像宽度
 * @param height 图像高度
 * @return null
 */
void imageAmaroFilterProcess(void *inImage, uint width, uint height);

void imageFilterBLUR(void *inImage, uint width, uint height, uint repeat);

void imageProFilterProcess(void *inImage, uint width, uint height);


void ImageContrastFilterTest(void *inImage, uint width, uint height, uint repeat);

void GammaAdujest(void *inImage, uint width, uint height,RGB* rgb);
void AnalysisRoundTwo(RGB* rgb,void *inImage,void *blurImage,void *MaskImg, uint width, uint height);
