//
//  RCStillImageFilter.h
//  RRCameraSDK
//
//  Created by ran.shi on 14-7-20.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import <Foundation/Foundation.h>
//typedef enum {
//    AMARO,            //浪漫
//    MOJITO,           //莫吉托
//    VI_LOMOFI,        //胶片
//    CITYLIGHT,        //城市之光
//    VI_HUDSON,        //经典
//    VI_LARK,          //绿野
//    VI_EARLYBIRD,     //余晖
//    VI_HEFE,          //电影
//    VI_RISE,          //文艺（年华）
//    LINHOF,           //林哈夫
//    VI_REYES,         //迷雾
//    VI_CREMA,         //暖咖
//    WALDEN,           //日系
//    VI_ADEN,          //年华
//    HIGHCONTRASTBLACKANDWHITE,    //高光反差黑白
//    CARTOON,          //漫画风景 (友拍)
//    COLORADJUST,      //午后阳光 (友拍)
//    MUMU,             //穆穆 (友拍)
//    BEAUTYFACE,       //美颜
//    VI_SUTRO,         //暗角
//    VI_SLUMBER,       //逆光
//    VI_LUDWID,        //墨迹
//    VI_PERPETUA,      //隧道
//    QUIETLYELEGANT,   //淡雅
//    VI_VALENCIA,      //军装
//    YEARSV7,          //润色
//    VI_MAYFAIR,       //街拍
//    DUSK,             //暮然
//    VI_JUNO,          //艳阳
//    BLACKWHITESTYLE,  //黑白
//    STARLIGHT,        //星光
//    SCENERY,          //智能美化
//    SINGLE_CHANNEL,    //橘子红了
//    MAGIC_MIRROR,     //哈哈镜
//    MOSAIC,           //马赛克
//    REAL_BEAUTY_FACE, //美颜实时滤镜
//    DELICIOUS_FOOD,   //美食实时滤镜
//    SKETCH,           //素描
//    COOLWARM,           //冷暖
//    SYMMETRIC           //镜像
//} RRfilterName;

typedef NS_ENUM(NSInteger, RRFilterType) {
    RR_L100_FILTER,             //深邃
    RR_A100_FILTER,             //雅致
    RR_P100_FILTER,             //清凉
    RR_AMARO_FILTER,            //浪漫
    RR_MOJITO_FILTER,           //莫吉托
    RR_VI_LOMOFI_FILTER,        //胶片
    RR_CITYLIGHT_FILTER,        //城市之光
    RR_VI_HUDSON_FILTER,        //经典
    RR_VI_LARK_FILTER,          //绿野
    RR_VI_HEFE_FILTER,          //电影
    RR_VI_RISE_FILTER,          //文艺（年华）
    RR_LINHOF_FILTER,           //林哈夫
    RR_WALDEN_FILTER,           //日系
    RR_VI_ADEN_FILTER,          //年华
    RR_CARTOON_FILTER,          //漫画风景 (友拍)
    RR_COLORADJUST_FILTER,      //午后阳光 (友拍)
    RR_MUMU_FILTER,             //穆穆 (友拍)
    RR_BEAUTYFACE_FILTER,       //美颜
    RR_VI_LUDWID_FILTER,        //墨迹
    RR_VI_PERPETUA_FILTER,      //隧道
    RR_VI_VALENCIA_FILTER,      //军装
    RR_VI_MAYFAIR_FILTER,       //街拍
    RR_VI_JUNO_FILTER,          //艳阳
    RR_BLACKWHITESTYLE_FILTER,  //黑白
    RR_STARLIGHT_FILTER,        //星光
    RR_SCENERY_FILTER,          //智能美化
    RR_SINGLECHANNEL_FILTER,    //橘子红了
    RR_MAGIC_MIRROR_FILTER,     //哈哈镜
    RR_MOSAIC_FILTER,           //马赛克
    RR_REAL_BEAUTY_FACE_FILTER, //美颜实时滤镜
    RR_DELICIOUS_FOOD_FILTER,   //美食实时滤镜
    RR_SKETCH_FILTER,           //素描
    RR_COOLWARM_FILTER,         //冷暖滤镜
    RR_SYMMETRIC_FILTER,        //镜像滤镜
    RR_VI_EARLYBIRD_FILTER,     //余晖
    RR_VI_REYES_FILTER,         //迷雾
    RR_VI_CREMA_FILTER,         //暖咖
    RR_HIGHCONTRASTBLACKANDWHITE_FILTER,    //高光反差黑白
    RR_VI_SUTRO_FILTER,         //暗角
    RR_VI_SLUMBER_FILTER,       //逆光
    RR_QUIETLYELEGANT_FILTER,   //淡雅
    RR_YEARSV7_FILTER,          //润色
    RR_DUSK_FILTER,             //暮然
    
    RR_LIUSANGEN_FILTER,         //刘三根
    RR_QINJI_FILTER,             //青寂
    RR_MATUANZHANG_FILTER,      //麻团张
    RR_WULIANGQIU_FILTER,       //无良球
    RR_C001_FILTER,
    RR_C002_FILTER,
    RR_C003_FILTER,
    RR_C004_FILTER,
    RR_C005_FILTER,
    RR_C006_FILTER,
    RR_R001_FILTER,             //温暖
    RR_R101_FILTER,              //文艺
    RR_R102_FILTER,
    RR_R202_FILTER,              //暮色
    RR_R302_FILTER,
    RR_R401_FILTER,              //浪漫
    RR_R402_FILTER,             //天真
    RR_R303_FILTER,             //明亮
    RR_FILTER_COUNT
};

//直播滤镜参数
struct RRDirectSeeding
{
    int beautyFacelevel;//美颜等级 0是不美颜
    int filterType;//使用哪一款滤镜，如果不使用滤镜赋值－1
    bool isSticker;
    bool isNeedInit;
    bool isStickerStart;
    int nCycletimes;
};
typedef struct RRDirectSeeding DirectSeeding;

extern NSString *g_strickerPath;

struct RRTuningParameters {
    float lux;                  //0.5
    float brightness;           //0.5
    float contrast;             //0.5
    float saturation;           //0.5
    float temperature;          //0.5
    float highlight;            //0
    float shadow;               //0
    //    float hue;
    float sharpness;//锐化       //0
    float vignetteEnd;//暗角     //0
    
    //linear
    bool isLinearOpen;          //false
    CGFloat linearCenter;       //0.5
    CGFloat linearRadius;       //0.5
    //radial
    bool isRadialOpen;          //false
    CGFloat radialCenterX;      //0.5
    CGFloat radialCenterY;      //0.5
    CGFloat radialRadius;       //0.5
    float rotation2d;//2d旋转                      //0.5
    float horizontalRotation3d;//3d水平旋转         //0.5
    float verticalRotation3d;//3d垂直旋转           //0.5
    float lightShadow;//光影                       //0.5
    int colorLightShadowType;//颜色光影类型 0~8     //0
    float colorLightShadow;//颜色光影程度           //0.5
    int colorHighLightType;//颜色高光类型 0~8       //0
    float colorHighLight;//颜色高光程度             //0.5
    float fade;//褪色                              //0
    
};
typedef struct RRTuningParameters RRTuningParameters;

struct RRFaceTwoPoint
{
    CGPoint poi1;
    CGPoint poi2;
    float range;//自动是进度条，手动是区域大小
    int model;//0是自动，1是手动
};
typedef struct RRFaceTwoPoint FaceTwoPoint;

struct RRFaceOnePoint
{
    CGPoint poi1;
    float range;//自动是进度条，手动是区域大小
    int model;//0是自动，1是手动
};
typedef struct RRFaceOnePoint FaceOnePoint;

struct RRFaceParameters {
    bool faceIsInit;//是否需要初始化
    bool faceIsGetFace;//是否是人脸
    bool faceIsAkeybeauty;//是否开启一键美颜
    bool faceIsDermabrasion;//是否磨皮
    bool faceIsWhitening;//是否美白
    bool faceIsLift;//是否瘦脸
    int  faceLiftNum;//瘦脸次数
    bool faceIsEyeBigger;//是否大眼
    int  faceEyeBiggerNum;//大眼次数
    bool faceIsEyeBeauty;//是否亮眼
    int  faceEyeBeautyNum;//亮眼次数
    bool faceIsAcne;//是否祛痘
    int faceAcneNum;//祛痘次数
    
    float faceAkeybeauty;//一键美颜系数
    float faceDermabrasion;//磨皮系数
    float faceWhitening;//美白系数
    float faceLift;//瘦脸系数，不再使用
    FaceTwoPoint faceLiftManual[5];//瘦脸手动调节参数
    float faceEyeBigger;//大眼系数，不再使用
    FaceOnePoint faceEyeBiggerManual[5];//大眼手动调节参数
    float faceEyeBeauty;//亮眼系数，不再使用
    FaceOnePoint faceEyeBeautyManual[5];//亮眼手动调节参数
    
    FaceOnePoint faceAcneManual[5];//祛痘手动调节参数
};
typedef struct RRFaceParameters FaceParameters;

#define kStickerCompleteNotification @"kStickerCompleteNotification"

@class SFilter;

@interface RCStillImageFilter : NSObject
+ (NSDictionary *)getTuningDicWithStruct:(RRTuningParameters)tuingParam;
+ (RRTuningParameters)getTuningStructWithDic:(NSDictionary *)dic;
+ (RRTuningParameters)getDefaultTuingParameters;
+ (NSDictionary *)getFaceDicWithStruct:(FaceParameters)faceParam;
+ (FaceParameters)getFaceParamStructWithDic:(NSDictionary *)dic;
+ (FaceParameters)getDefaultFaceParameters;

+ (UIImage *)imageByFilteringImage:(UIImage *)image type:(RRFilterType)type value:(CGFloat)value;
+ (UIImage *)blendTwoImage:(UIImage *)topLayer bottomLayer:(UIImage *)bottomLayer opacity:(CGFloat)opacity;

// 微调
+ (UIImage *)imageByTotalTuningImage:(UIImage *)image para:(RRTuningParameters) para;

// 涂抹接口
+ (UIImage *)imageByDaub:(UIImage *)image sFilter:(SFilter*)sFilter;
+ (UIImage*)exportImage:(UIImage*)image;
+ (void)releaseDaubFilterImagePixel;
+ (NSString *)getFilterType:(RRFilterType)index;

//可调节美颜接口
+ (UIImage *)imageAdjustableFaceBeauty:(UIImage *)image RRFaceParameters:(FaceParameters *)faceParameters;

+ (CVPixelBufferRef )directSeedingFilter:(CVPixelBufferRef )PixelBufferRefIn boolCamerFront:(bool)boolCamerFront;

+ (void)stillProcessVideoSampleBuffer:(CMSampleBufferRef) sampleBufferRef;

+ (BOOL)configDynamicPasterParameters:(NSString *)pasterPath;

+ (void)releaseFilterResources;

+ (void)setDirectisNeedSticker:(bool)isNeedSticker;

+ (void)setStickerPath:(NSDictionary *)info;

+(GPUImageFilterGroup *)GetDressupFilter;

//获取美颜filter
+(GPUImageFilterGroup *)GetBeautyFaceFilter;

+ (DirectSeeding *)getDirectSeeding;
+ (void)setDirectisNeedInit:(bool)isNeedInit;
+ (void)setDirectBeautyFacele:(int)beautyFacelevel;
+ (void)setDirectFilter:(NSInteger)type;
+ (GPUImageOutput<GPUImageInput> *)directFilter:(NSInteger)filterType;
@end
