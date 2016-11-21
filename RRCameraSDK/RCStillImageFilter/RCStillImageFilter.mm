//
//  RCStillImageFilter.m
//  RRCameraSDK
//
//  Created by ran.shi on 14-7-20.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCStillImageFilter.h"
#import "RRFaceFilter.h"
#import "RRSceneryFilter.h"
#import "RCGPUImageFilters.h"
#import "RCGPUImageFaceAcneFilter.h"

static DirectSeeding g_DirectSeeding;
NSString *g_strickerPath;
@implementation RCStillImageFilter
+ (NSDictionary *)getTuningDicWithStruct:(RRTuningParameters)tuingParam{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(tuingParam.lux) forKey:@"lux"];
    [dic setValue:@(tuingParam.brightness) forKey:@"brightness"];
    [dic setValue:@(tuingParam.contrast) forKey:@"contrast"];
    [dic setValue:@(tuingParam.saturation) forKey:@"saturation"];
    [dic setValue:@(tuingParam.temperature) forKey:@"temperature"];
    [dic setValue:@(tuingParam.highlight) forKey:@"highlight"];
    [dic setValue:@(tuingParam.shadow) forKey:@"shadow"];
    [dic setValue:@(tuingParam.sharpness) forKey:@"sharpness"];
    [dic setValue:@(tuingParam.vignetteEnd) forKey:@"vignetteEnd"];
    [dic setValue:@(tuingParam.isLinearOpen) forKey:@"isLinearOpen"];
    [dic setValue:@(tuingParam.linearCenter) forKey:@"linearCenter"];
    [dic setValue:@(tuingParam.linearRadius) forKey:@"linearRadius"];
    [dic setValue:@(tuingParam.isRadialOpen) forKey:@"isRadialOpen"];
    [dic setValue:@(tuingParam.radialCenterX) forKey:@"radialCenterX"];
    [dic setValue:@(tuingParam.radialCenterY) forKey:@"radialCenterY"];
    [dic setValue:@(tuingParam.radialRadius) forKey:@"radialRadius"];
    [dic setValue:@(tuingParam.rotation2d) forKey:@"rotation2d"];
    [dic setValue:@(tuingParam.horizontalRotation3d) forKey:@"horizontalRotation3d"];
    [dic setValue:@(tuingParam.verticalRotation3d) forKey:@"verticalRotation3d"];
    [dic setValue:@(tuingParam.lightShadow) forKey:@"lightShadow"];
    [dic setValue:@(tuingParam.colorLightShadowType) forKey:@"colorLightShadowType"];
    [dic setValue:@(tuingParam.colorLightShadow) forKey:@"colorLightShadow"];
    [dic setValue:@(tuingParam.colorHighLightType) forKey:@"colorHighLightType"];
    [dic setValue:@(tuingParam.colorHighLight) forKey:@"colorHighLight"];
    [dic setValue:@(tuingParam.fade) forKey:@"fade"];
    return dic;
}
+ (RRTuningParameters)getTuningStructWithDic:(NSDictionary *)dic{
    RRTuningParameters tuning = [RCStillImageFilter getDefaultTuingParameters];
    tuning.lux = [[dic valueForKey:@"lux"] floatValue];
    tuning.brightness = [[dic valueForKey:@"brightness"] floatValue];
    tuning.contrast = [[dic valueForKey:@"contrast"] floatValue];
    tuning.saturation = [[dic valueForKey:@"saturation"] floatValue];
    tuning.temperature = [[dic valueForKey:@"temperature"] floatValue];
    tuning.highlight = [[dic valueForKey:@"highlight"] floatValue];
    tuning.shadow = [[dic valueForKey:@"shadow"] floatValue];
    tuning.sharpness = [[dic valueForKey:@"sharpness"] floatValue];
    tuning.vignetteEnd = [[dic valueForKey:@"vignetteEnd"] floatValue];
    
    tuning.isLinearOpen = [[dic valueForKey:@"isLinearOpen"] boolValue];
    tuning.linearCenter = [[dic valueForKey:@"linearCenter"] floatValue];
    tuning.linearRadius = [[dic valueForKey:@"linearRadius"] floatValue];
    
    tuning.isRadialOpen = [[dic valueForKey:@"isRadialOpen"] boolValue];
    tuning.radialCenterX = [[dic valueForKey:@"radialCenterX"] floatValue];
    tuning.radialCenterY = [[dic valueForKey:@"radialCenterY"] floatValue];
    tuning.radialRadius = [[dic valueForKey:@"radialRadius"] floatValue];
    tuning.rotation2d = [[dic valueForKey:@"rotation2d"] floatValue];
    tuning.horizontalRotation3d = [[dic valueForKey:@"horizontalRotation3d"] floatValue];
    tuning.verticalRotation3d = [[dic valueForKey:@"verticalRotation3d"] floatValue];
    tuning.lightShadow = [[dic valueForKey:@"lightShadow"] floatValue];
    tuning.colorLightShadowType = [[dic valueForKey:@"colorLightShadowType"] intValue];
    tuning.colorLightShadow = [[dic valueForKey:@"colorLightShadow"] floatValue];
    tuning.colorHighLightType = [[dic valueForKey:@"colorHighLightType"] intValue];
    tuning.colorHighLight = [[dic valueForKey:@"colorHighLight"] floatValue];
    tuning.fade = [[dic valueForKey:@"fade"] floatValue];
    
    return tuning;
}

+ (NSDictionary *)getFaceDicWithStruct:(FaceParameters)faceParam{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(faceParam.faceIsInit) forKey:@"faceIsInit"];
    [dic setValue:@(faceParam.faceIsGetFace) forKey:@"faceIsGetFace"];
    [dic setValue:@(faceParam.faceIsAkeybeauty) forKey:@"faceIsAkeybeauty"];
    [dic setValue:@(faceParam.faceIsDermabrasion) forKey:@"faceIsDermabrasion"];
    [dic setValue:@(faceParam.faceIsWhitening) forKey:@"faceIsWhitening"];
    [dic setValue:@(faceParam.faceIsLift) forKey:@"faceIsLift"];
    [dic setValue:@(faceParam.faceIsEyeBigger) forKey:@"faceIsEyeBigger"];
    [dic setValue:@(faceParam.faceIsEyeBeauty) forKey:@"faceIsEyeBeauty"];
    [dic setValue:@(faceParam.faceAkeybeauty) forKey:@"faceAkeybeauty"];
    [dic setValue:@(faceParam.faceDermabrasion) forKey:@"faceDermabrasion"];
    [dic setValue:@(faceParam.faceWhitening) forKey:@"faceWhitening"];
    [dic setValue:@(faceParam.faceLift) forKey:@"faceLift"];
    [dic setValue:@(faceParam.faceEyeBigger) forKey:@"faceEyeBigger"];
    [dic setValue:@(faceParam.faceEyeBeauty) forKey:@"faceEyeBeauty"];
    return dic;
}
+ (FaceParameters)getFaceParamStructWithDic:(NSDictionary *)dic{
    FaceParameters faceParams = [RCStillImageFilter getDefaultFaceParameters];
    faceParams.faceIsInit = [[dic valueForKey:@"faceIsInit"] boolValue];
    faceParams.faceIsGetFace = [[dic valueForKey:@"faceIsGetFace"] boolValue];
    faceParams.faceIsAkeybeauty = [[dic valueForKey:@"faceIsAkeybeauty"] boolValue];
    faceParams.faceIsDermabrasion = [[dic valueForKey:@"faceIsDermabrasion"] boolValue];
    faceParams.faceIsWhitening = [[dic valueForKey:@"faceIsWhitening"] boolValue];
    faceParams.faceIsLift = [[dic valueForKey:@"faceIsLift"] boolValue];
    faceParams.faceIsEyeBigger = [[dic valueForKey:@"faceIsEyeBigger"] boolValue];
    faceParams.faceIsEyeBeauty = [[dic valueForKey:@"faceIsEyeBeauty"] boolValue];
    faceParams.faceAkeybeauty = [[dic valueForKey:@"faceAkeybeauty"] floatValue];
    faceParams.faceDermabrasion = [[dic valueForKey:@"faceDermabrasion"] floatValue];
    faceParams.faceWhitening = [[dic valueForKey:@"faceWhitening"] floatValue];
    faceParams.faceLift = [[dic valueForKey:@"faceLift"] floatValue];
    faceParams.faceEyeBigger = [[dic valueForKey:@"faceEyeBigger"] floatValue];
    faceParams.faceEyeBeauty = [[dic valueForKey:@"faceEyeBeauty"] floatValue];

    return faceParams;
}

+ (NSString *)getFilterType:(RRFilterType)index{
    switch (index) {
        case RR_AMARO_FILTER:
            return @"AMARO";
            break;
        case RR_MOJITO_FILTER:
            return @"MOJITO";
            break;
        case RR_VI_LOMOFI_FILTER:
            return @"VI_LOMOFI";
            break;
        case RR_CITYLIGHT_FILTER:
            return @"CITYLIGHT";
            break;
        case RR_VI_HUDSON_FILTER:
            return @"VI_HUDSON";
            break;
        case RR_VI_LARK_FILTER:
            return @"VI_LARK";
            break;
        case RR_VI_EARLYBIRD_FILTER:
            return @"VI_EARLYBIRD";
            break;
        case RR_VI_HEFE_FILTER:
            return @"VI_HEFE";
            break;
        case RR_VI_RISE_FILTER:
            return @"VI_RISE";
            break;
        case RR_LINHOF_FILTER:
            return @"LINHOF";
            break;
        case RR_VI_REYES_FILTER:
            return @"VI_REYES";
            break;
        case RR_VI_CREMA_FILTER:
            return @"VI_CREMA";
            break;
        case RR_WALDEN_FILTER:
            return @"WALDEN";
            break;
        case RR_VI_ADEN_FILTER:
            return @"VI_ADEN";
            break;
        case RR_HIGHCONTRASTBLACKANDWHITE_FILTER:
            return @"HIGHCONTRASTBLACKANDWHITE";
            break;
        case RR_CARTOON_FILTER:
            return @"CARTOON";
            break;
        case RR_COLORADJUST_FILTER:
            return @"COLORADJUST";
            break;
        case RR_MUMU_FILTER:
            return @"MUMU";
            break;
        case RR_BEAUTYFACE_FILTER:
            return @"BEAUTYFACE";
            break;
        case RR_VI_SUTRO_FILTER:
            return @"VI_SUTRO";
            break;
        case RR_VI_SLUMBER_FILTER:
            return @"VI_SLUMBER";
            break;
        case RR_VI_LUDWID_FILTER:
            return @"VI_LUDWID";
            break;
        case RR_VI_PERPETUA_FILTER:
            return @"VI_PERPETUA";
            break;
        case RR_QUIETLYELEGANT_FILTER:
            return @"QUIETLYELEGANT";
            break;
        case RR_VI_VALENCIA_FILTER:
            return @"VI_VALENCIA";
            break;
        case RR_YEARSV7_FILTER:
            return @"YEARSV7";
            break;
        case RR_VI_MAYFAIR_FILTER:
            return @"VI_MAYFAIR";
            break;
        case RR_DUSK_FILTER:
            return @"DUSK";
            break;
        case RR_VI_JUNO_FILTER:
            return @"VI_JUNO";
            break;
        case RR_BLACKWHITESTYLE_FILTER:
            return @"BLACKWHITESTYLE";
            break;
        case RR_STARLIGHT_FILTER:
            return @"STARLIGHT";
            break;
        case RR_SCENERY_FILTER:
            return @"SCENERY";
            break;
        case RR_SINGLECHANNEL_FILTER:
            return @"SINGLE_CHANNEL";
            break;
        case RR_MAGIC_MIRROR_FILTER:
            return @"MAGIC_MIRROR";
            break;
        case RR_MOSAIC_FILTER:
            return @"MOSAIC";
            break;
        case RR_REAL_BEAUTY_FACE_FILTER:
            return @"REAL_BEAUTY_FACE";
            break;
        case RR_DELICIOUS_FOOD_FILTER:
            return @"DELICIOUS_FOOD";
            break;
        case RR_SKETCH_FILTER:
            return @"SKETCH";
            break;
        case RR_COOLWARM_FILTER:
            return @"COOLWARM";
            break;
        default:
            break;
    }
    return @"";
}
//图片滤镜
+ (UIImage *)imageByFilteringImage:(UIImage *)image type:(RRFilterType)type value:(CGFloat)value
{
    if (image == nil) {
        return nil;
    }
    GPUImageOutput<GPUImageInput> *filter;
    switch (type) {
        case RR_HIGHCONTRASTBLACKANDWHITE_FILTER:
            filter = [[RCGPUImageHighContrastBlackAndWhiteFilter alloc] initOpacity:1.0];
            break;
        case RR_CARTOON_FILTER:           //漫画风景
            filter = [[RCGPUImageCartoonMainFilter alloc] initOpacity:1.0 Img:image];
            break;
        case RR_COLORADJUST_FILTER:      //午后阳光
            filter = [[RCGPUImageColorAdjustFilter alloc] initOpacity:1.0];
            break;
        case RR_MUMU_FILTER:             //穆穆
            filter = [[RCGPUImageMuMuFilter alloc] initOpacity:1.0];
            break;
        case RR_AMARO_FILTER:            //浪漫
            filter = [[RCGPUImageAmaroFilter alloc] init];
            break;
        case RR_MOJITO_FILTER:           //莫吉托
            filter = [[RCGPUImageMojitoFilter alloc] init];
            break;
        case RR_VI_LOMOFI_FILTER:        //胶片
            filter = [[RCGPUImageLomofiFilter alloc] init];
            break;
        case RR_CITYLIGHT_FILTER:        //城市之光
            filter = [[RCGPUImageCityLightFilter alloc] init];
            break;
        case RR_VI_HUDSON_FILTER:        //经典
            filter = [[RCGPUImageHudsonFilter alloc] init];
            break;
        case RR_VI_LARK_FILTER:          //绿野
            filter = [[RCGPUImageInsLarkFilter alloc] init];
            break;
        case RR_VI_EARLYBIRD_FILTER:     //余晖
            filter = [[RCGPUImageEarlybirdFilter alloc] init];
            break;
        case RR_VI_HEFE_FILTER:          //电影
            filter = [[RCGPUImageHefeFilter alloc] init];
            break;
        case RR_VI_RISE_FILTER:          //文艺（年华）
            filter = [[RCGPUImageRiseFilter alloc] init];
            break;
        case RR_LINHOF_FILTER:           //林哈夫
            filter =  [[RCGPUImageLinhofFilter alloc] init];
            break;
        case RR_VI_REYES_FILTER:         //迷雾
            filter = [[RCGPUImageInsReyesFilter alloc] init];
            break;
        case RR_VI_CREMA_FILTER:         //暖咖
            filter = [[RCGPUImageInsCremaFilter alloc] init];
            break;
        case RR_WALDEN_FILTER:           //日系
            filter = [[RCGPUImageWaldenFilter alloc] init];
            break;
        case RR_VI_ADEN_FILTER:          //年华
            filter = [[RCGPUImageInsAdenFilter alloc] init];
            break;
        case RR_BEAUTYFACE_FILTER:       //美颜
            filter = [[RCGPUImageFaceBeautifyFilter alloc] initImg:image];
            break;
        case RR_VI_SUTRO_FILTER:         //暗角
            filter = [[RCGPUImageSutroFilter alloc] init];
            break;
        case RR_VI_SLUMBER_FILTER:       //逆光
            filter = [[RCGPUImageInsSlumberFilter alloc] init];
            break;
        case RR_VI_LUDWID_FILTER:        //墨迹
            filter = [[RCGPUImageInsLudwidFilter alloc] init];
            break;
        case RR_VI_PERPETUA_FILTER:      //隧道
            filter = [[RCGPUImageInsPerpetuaFilter alloc] init];
            break;
        case RR_QUIETLYELEGANT_FILTER:   //淡雅
            filter = [[RCGPUImageQuietlyElegantFilter alloc] init];
            break;
        case RR_VI_VALENCIA_FILTER:      //军装
            filter = [[RCGPUImageValenciaFilter alloc] init];
            break;
        case RR_YEARSV7_FILTER:          //润色
            filter = [[RCGPUImageYearsV7Filter alloc] init];
            break;
        case RR_VI_MAYFAIR_FILTER:       //街拍
            filter = [[RCGPUImageInsMayFairFilter alloc] init];
            break;
        case RR_DUSK_FILTER:             //暮然
            filter = [[RCGPUImageDuskFilter alloc] init];
            break;
        case RR_VI_JUNO_FILTER:          //艳阳
            filter = [[RCGPUImageInsJunoFilter alloc] init];
            break;
        case RR_BLACKWHITESTYLE_FILTER:  //黑白
            filter = [[RCGPUImageBlackWhiteStyleFilter alloc] init];
            break;
        case RR_STARLIGHT_FILTER:        //星光
            filter = [[RCGPUImageStarLightFilter alloc] init];
            break;
        case RR_SCENERY_FILTER:
            filter = [[RCGPUImageSceneryFilter alloc] init];
            break;
        case RR_SKETCH_FILTER:
            filter = [[RCGPUImageSketchFilter alloc] init];
            break;
        case RR_SINGLECHANNEL_FILTER:   //橘子红了
            filter = [[RCGPUImageSingleChannelFilter alloc] init];
            break;
        case RR_MAGIC_MIRROR_FILTER:    //哈哈镜
            filter = [[RCGPUImageMagicMirrorFilter alloc] init];
            break;
        case RR_MOSAIC_FILTER:
            filter = [[RCGPUImageMosaicFilter alloc] initSize:image.size];
            break;
        case RR_REAL_BEAUTY_FACE_FILTER:
            filter = [[RCGPUImageRealFaceBeautyFilter alloc] initOpacity:0.65];
            break;
        case RR_DELICIOUS_FOOD_FILTER:
            filter = [[RCGPUImageRise2Filter alloc] init];
            break;
        case RR_COOLWARM_FILTER:
            filter = [[RCGPUImageCoolWarmFilter alloc]init];
            break;
        case RR_SYMMETRIC_FILTER:
            filter = [[RCGPUImageSymmetricFilter alloc]init];
            break;
        case RR_P100_FILTER:    //清凉
            filter = [[RCGPUImageP100Filter alloc] init];
            break;
        case RR_L100_FILTER:    //深邃
            filter = [[RCGPUImageL100Filter alloc] init];
            break;
        case RR_A100_FILTER:    //雅致
            filter = [[RCGPUImagea100Filter alloc] init];
            break;

        case RR_LIUSANGEN_FILTER://刘三根
            filter = [[RCGPUImageAllisonColorFilter alloc]init];
            break;
        case RR_QINJI_FILTER:   //青寂
            filter = [[RCGPUImageKaichengFilter alloc]init];
            break;
        case RR_MATUANZHANG_FILTER://麻团张
            filter = [[RCGPUImageMatuanzhangFilter alloc]init];
            break;
        case RR_WULIANGQIU_FILTER://无良球
            filter = [[RCGPUImageQiujianingFilter alloc]init];
            break;
        case RR_C001_FILTER:
            filter = [[RCGPUImageC001Filter alloc]init];
            break;
        case RR_C002_FILTER:
            filter = [[RCGPUImageC002Filter alloc]init];
            break;
        case RR_C003_FILTER:
            filter = [[RCGPUImageC003Filter alloc]init];
            break;
        case RR_C004_FILTER:
            filter = [[RCGPUImageC004Filter alloc]init];
            break;
        case RR_C005_FILTER:
            filter = [[RCGPUImageC005Filter alloc]init];
            break;
        case RR_C006_FILTER:
            filter = [[RCGPUImageC006Filter alloc]init];
            break;
        case RR_R001_FILTER://温暖
            filter = [[RCGPUImageR001Filter alloc]init];
            break;
        case RR_R102_FILTER://淡雅
            filter = [[RCGPUImageR102Filter alloc]init];
            break;
        case RR_R302_FILTER://森山
            filter = [[RCGPUImageR302Filter alloc]init];
            break;
        case RR_R402_FILTER://天真
            filter = [[RCGPUImageR402Filter alloc]init];
            break;
        case RR_R303_FILTER://明亮
            filter = [[RCGPUImageR303Filter alloc]init];
            break;
        default:
            return image;
    }
    
    if (filter == nil)
    {
        return image;
    }
    
    GPUImagePicture *sourcePicture1 = [[GPUImagePicture alloc] initWithImage:image];

    if (type == RR_BEAUTYFACE_FILTER || type == RR_CARTOON_FILTER || type == RR_DELICIOUS_FOOD_FILTER) {
        [sourcePicture1 addTarget:filter];
    } else {
        GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
        [(GPUImageSharpenFilter *)sharpenFilter setSharpness:(0.5f)];
        [sourcePicture1 addTarget:sharpenFilter];
        [sharpenFilter addTarget:filter];
    }
    [filter useNextFrameForImageCapture];
    [sourcePicture1 processImage];
    
    return [filter imageFromCurrentFramebuffer];
}

void stillImageDataReleaseCallbackTmp(void *releaseRefCon, const void *baseAddress)
{
    free((void *)baseAddress);
}

//UIImage转CVPixelBufferRef
+(CVPixelBufferRef) ImageToSampleBuffer:(CGImageRef) cgImageFromBytes
{
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGSize finalSize = CGSizeMake(CGImageGetWidth(cgImageFromBytes), CGImageGetHeight(cgImageFromBytes));
    
    GLubyte *imageData = (GLubyte *) calloc(1, (int)finalSize.width * (int)finalSize.height * 4);
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (int)finalSize.width, (int)finalSize.height, 8, (int)finalSize.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, finalSize.width, finalSize.height), cgImageFromBytes);
    //CGImageRelease(cgImageFromBytes);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(genericRGBColorspace);
    //    CGDataProviderRelease(dataProvider);
    
    CVPixelBufferRef pixel_buffer = NULL;
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault, finalSize.width, finalSize.height, kCVPixelFormatType_32BGRA, imageData, finalSize.width * 4, stillImageDataReleaseCallbackTmp, NULL, NULL, &pixel_buffer);
    
    return pixel_buffer;
}

+(UIImage *)ImageBufferToImage:(CVImageBufferRef) imageBuffer
{
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    //从 CVImageBufferRef 取得影像的细部信息
    uint8_t *base;
    size_t width, height, bytesPerRow;
    base = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    width = CVPixelBufferGetWidth(imageBuffer);
    height = CVPixelBufferGetHeight(imageBuffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    //利用取得影像细部信息格式化 CGContextRef
    CGColorSpaceRef colorSpace;
    CGContextRef cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    //透过 CGImageRef 将 CGContextRef 转换成 UIImage
    CGImageRef cgImage;
    UIImage *image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return image;
}

//图片滤镜
+ (GPUImageOutput<GPUImageInput> *)directFilter:(NSInteger)filterType
{

    GPUImageOutput<GPUImageInput> *filter;
    switch (filterType) {
        case RR_R001_FILTER://温暖
            filter = [[RCGPUImageR001Filter alloc]init];
            break;
        case RR_R101_FILTER://文艺 日系
            filter = [[RCGPUImageR101Filter alloc]init];
            break;
        case RR_R401_FILTER://浪漫  梦幻
            filter = [[RCGPUImageR401Filter alloc]init];
            break;
        case RR_R202_FILTER://暮色 蓝调
            filter = [[RCGPUImageR202Filter alloc]init];
            break;
        case RR_R402_FILTER://天真 淡雅
            filter = [[RCGPUImageR402Filter alloc]init];
            break;
        case RR_R303_FILTER://明亮
            filter = [[RCGPUImageR303Filter alloc]init];
            break;
        default:
            return nil;
    }
    
    
    return filter;
}

//+ (void)directSeedingUpdateTargetsForVideoCameraUsingCacheTextureAtWidth:(int)bufferWidth height:(int)bufferHeight GPUImageOutput:(GPUImageOutput<GPUImageInput> *)filter;
//{
//    NSMutableArray *targets, *targetTextureIndices;
//    targets=[filter targets];
//    targetTextureIndices=[filter targetToIgnoreForUpdates];
//    for (id<GPUImageInput> currentTarget in targets)
//    {
//        NSInteger indexOfObject = [targets indexOfObject:currentTarget];
//        NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
//        
//        [currentTarget setCurrentlyReceivingMonochromeInput:NO];
//        [currentTarget setInputSize:pixelSizeOfImage atIndex:textureIndexOfTarget];
//        [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
//        [currentTarget newFrameReadyAtTime:kCMTimeIndefinite atIndex:textureIndexOfTarget];
//    }
////    
////    // First, update all the framebuffers in the targets
////    for (id<GPUImageInput> currentTarget in targets)
////    {
////        if ([currentTarget enabled])
////        {
////            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
////            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
////            
//////            if (currentTarget != self.targetToIgnoreForUpdates)
//////            {
//////                [currentTarget setInputRotation:outputRotation atIndex:textureIndexOfTarget];
//////                [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:textureIndexOfTarget];
//////                
//////                if ([currentTarget wantsMonochromeInput] && captureAsYUV)
//////                {
//////                    [currentTarget setCurrentlyReceivingMonochromeInput:YES];
//////                    // TODO: Replace optimization for monochrome output
//////                    [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
//////                }
//////                else
//////                {
//////                    [currentTarget setCurrentlyReceivingMonochromeInput:NO];
//////                    [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
//////                }
//////            }
//////            else
//////            {
////                [currentTarget setInputRotation:outputRotation atIndex:textureIndexOfTarget];
////                [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
//////            }
////        }
////    }
////    
////    // Then release our hold on the local framebuffer to send it back to the cache as soon as it's no longer needed
////    [outputFramebuffer unlock];
////    outputFramebuffer = nil;
////    
////    // Finally, trigger rendering as needed
////    for (id<GPUImageInput> currentTarget in targets)
////    {
////        if ([currentTarget enabled])
////        {
////            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
////            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
////            
////            if (currentTarget != self.targetToIgnoreForUpdates)
////            {
////                [currentTarget newFrameReadyAtTime:kCMTimeIndefinite atIndex:textureIndexOfTarget];
////            }
////        }
////    }
//}

+(GPUImageFilterGroup *)GetBeautyFaceFilter;
{
    int indx=0;
    float opacity=0.65;
    GPUImageFilterGroup *filterRes = [[GPUImageFilterGroup alloc]init];
    DirectSeeding directSeedingData;
    
    DirectSeeding *directSeeding=[RCStillImageFilter getDirectSeeding];
    directSeedingData=*directSeeding;
    
    GPUImageOutput<GPUImageInput> *ga_imgfilter[10];
        RCGPUImageRealFaceBeautyFilter *RealFaceBeautyFilter = [[RCGPUImageRealFaceBeautyFilter alloc]initOpacity:opacity];
        ga_imgfilter[indx] = RealFaceBeautyFilter;
        if (indx>0) {
            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
        }
        indx++;
        

            //RCGPUImageBrightnessFilter *BrightnessFilter = [[RCGPUImageBrightnessFilter alloc] init];
            
            CGFloat brightness=0.0;
            if (directSeedingData.beautyFacelevel==1)
            {
                brightness=10.0;
            }
            else if (directSeedingData.beautyFacelevel==2)
            {
                brightness=40.0;
            }
            else
            {
                brightness=60.0;
            }
            
            //[(RCGPUImageBrightnessFilter *)BrightnessFilter setBrightness:brightness];
            
            RCGPUImageBrightnessNewFilter*brightnessFilter=[[RCGPUImageBrightnessNewFilter alloc] init];
            
            [brightnessFilter setBrightness:brightness/100.0];
            
            ga_imgfilter[indx]=brightnessFilter;
            if (indx>0) {
                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
            }
            indx++;
            
            //OptionalColors可选颜色 0是相对 1是绝对  1是红 9是黑
            RCGPUImageOptionalColorsFilter *OptionalColorsFilter = [[RCGPUImageOptionalColorsFilter alloc] initColor:1 initType:0 initC:-10 initM:0 initY:0 initB:-35];
            ga_imgfilter[indx]=OptionalColorsFilter;
            if (indx>0) {
                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
            }
            indx++;
            
            //OptionalColors可选颜色 0是相对 1是绝对  1是红 9是黑
            RCGPUImageOptionalColorsFilter *OptionalColorsFilter2 = [[RCGPUImageOptionalColorsFilter alloc] initColor:2 initType:0 initC:0 initM:0 initY:0 initB:-50];
            ga_imgfilter[indx]=OptionalColorsFilter2;
            if (indx>0) {
                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
            }
            indx++;
    
    if (directSeedingData.filterType>0) {
        GPUImageOutput<GPUImageInput> * directfilter=[RCStillImageFilter directFilter:directSeedingData.filterType];
        if (directfilter!=nil) {
            ga_imgfilter[indx]=directfilter;
            if (indx>0) {
                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
            }
            indx++;
        }
        
    }
    
//    if (directSeedingData.isSticker)
//    {
//
//        DressupFilter = [[RCGPUImageDressupFilter alloc] initIndex:1];
//
//        if (DressupFilter!=nil) {
//            ga_imgfilter[indx]=DressupFilter;
//            if (indx>0) {
//                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
//            }
//            indx++;
//        }
//        
//    }
    
    filterRes.initialFilters = [NSArray arrayWithObjects:ga_imgfilter[0],nil];
    filterRes.terminalFilter = ga_imgfilter[indx-1];
    return filterRes;
}

+ (void)setStickerPath:(NSDictionary *)info;
{

    NSString *path = [info objectForKey:@"path"];
    g_strickerPath = path;
//    [RCStillImageFilter configDynamicPasterParameters:path];
    DirectSeeding *directSeeding=[RCStillImageFilter getDirectSeeding];
    [RCStillImageFilter setDirectisNeedSticker:true];
    directSeeding->nCycletimes=[[info objectForKey:@"time"] integerValue];
    directSeeding->isStickerStart=true;
}

+(GPUImageFilterGroup *)GetDressupFilter;
{
    DressupFilter = [[RCGPUImageDressupFilter alloc] initIndex:1];
    
    return DressupFilter;
}

+ (CVPixelBufferRef )directSeedingFilter:(CVPixelBufferRef )PixelBufferRefIn boolCamerFront:(bool)boolCamerFront
{
    DirectSeeding directSeedingData;
    
    DirectSeeding *directSeeding=[RCStillImageFilter getDirectSeeding];
    directSeedingData=*directSeeding;
    
    static bool isFirst=true;
//    if (isFirst==true)
//    {
//        directSeedingtype->isNeedInit=true;
//    }
    
    CVPixelBufferRef PixelBufferRefOut=nil;
    GPUImageOutput<GPUImageInput> *filter=NULL;
    GPUImageFilterGroup *filterRes = [[GPUImageFilterGroup alloc]init];
    
//    NSDate* tmpStartDataf = [[NSDate date] init];
    UIImage *image=[self ImageBufferToImage:PixelBufferRefIn];//0.8ms

//    double deltaTimes = [[NSDate date] timeIntervalSinceDate:tmpStartDataf];
//    NSLog(@"ImageBufferToImage：%f ms\n", deltaTimes*1000);
    
    GPUImageOutput<GPUImageInput> *ga_imgfilter[10];
    int indx=0;
    
    CGRect phoneRect = [[UIScreen mainScreen] bounds];
    
    static int indxtmp=0;
    indxtmp++;
//    NSDate* tmpStartData14 = [[NSDate date] init];
    if (image.size.width/image.size.height!=phoneRect.size.width/phoneRect.size.height)
    {
        CGRect viewRect;
        viewRect.size.width=image.size.width;
        viewRect.size.height=viewRect.size.width*phoneRect.size.height/phoneRect.size.width;
        if (viewRect.size.height>image.size.height)
        {
            viewRect.size.height=image.size.height;
            viewRect.size.width=viewRect.size.height*phoneRect.size.width/phoneRect.size.height;
        }
        viewRect.origin.x=(image.size.width-viewRect.size.width)/2.0;
        viewRect.origin.y=(image.size.height-viewRect.size.height)/2.0;
        
        viewRect.origin.x=viewRect.origin.x/image.size.width;
        viewRect.origin.y=viewRect.origin.y/image.size.height;
        viewRect.size.width=viewRect.size.width/image.size.width;
        viewRect.size.height=viewRect.size.height/image.size.height;
        
        
        GPUImageCropFilter *cropFilter;
//        if (directSeedingtype->isNeedInit) {
//            g_cropFilter=[GPUImageCropFilter new];
//            [g_cropFilter setCropRegion:viewRect];
//        }
//        cropFilter=g_cropFilter;

        cropFilter=[GPUImageCropFilter new];
        [cropFilter setCropRegion:viewRect];
        ga_imgfilter[indx] = cropFilter;
        if (indx>0) {
            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
        }
        indx++;
    }

    CGFloat opacity=0.65;
    if (directSeedingData.beautyFacelevel>0) {
        RCGPUImageRealFaceBeautyFilter *RealFaceBeautyFilter = [[RCGPUImageRealFaceBeautyFilter alloc]initOpacity:opacity];
        ga_imgfilter[indx] = RealFaceBeautyFilter;
        if (indx>0) {
            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
        }
        indx++;


        if (YES)
        {
            //RCGPUImageBrightnessFilter *BrightnessFilter = [[RCGPUImageBrightnessFilter alloc] init];
            
            CGFloat brightness=0.0;
            if (directSeedingData.beautyFacelevel==1)
            {
                brightness=10.0;
            }
            else if (directSeedingData.beautyFacelevel==2)
            {
                brightness=40.0;
            }
            else
            {
                brightness=60.0;
            }
            
            //[(RCGPUImageBrightnessFilter *)BrightnessFilter setBrightness:brightness];
            
            RCGPUImageBrightnessNewFilter*brightnessFilter=[[RCGPUImageBrightnessNewFilter alloc] init];
         
            [brightnessFilter setBrightness:brightness/100.0];
            
            //        RCGPUImageBrightnessFilter *BrightnessFilter;
            //        if (directSeedingtype->isNeedInit) {
            //            g_BrightnessFilter=[[RCGPUImageBrightnessFilter alloc] init];
            //            [g_BrightnessFilter setBrightness:25];
            //        }
            //        BrightnessFilter=g_BrightnessFilter;
            
            ga_imgfilter[indx]=brightnessFilter;
            if (indx>0) {
                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
            }
            indx++;
            
            //        //Contrast
            //        RCGPUImageContrastFilter *ContrastFilter = [[RCGPUImageContrastFilter alloc] init];
            //        [(RCGPUImageContrastFilter *)ContrastFilter setContrast:25];
            ////        RCGPUImageContrastFilter *ContrastFilter;
            ////        if (directSeedingtype->isNeedInit) {
            ////            g_ContrastFilter=[[RCGPUImageContrastFilter alloc] init];
            ////            [g_ContrastFilter setContrast:25];
            ////        }
            ////        ContrastFilter=g_ContrastFilter;
            //        ga_imgfilter[indx]=ContrastFilter;
            //        if (indx>0) {
            //            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
            //        }
            //        indx++;
            
            //OptionalColors可选颜色 0是相对 1是绝对  1是红 9是黑
            RCGPUImageOptionalColorsFilter *OptionalColorsFilter = [[RCGPUImageOptionalColorsFilter alloc] initColor:1 initType:0 initC:-10 initM:0 initY:0 initB:-35];
            ga_imgfilter[indx]=OptionalColorsFilter;
            if (indx>0) {
                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
            }
            indx++;
            
            //OptionalColors可选颜色 0是相对 1是绝对  1是红 9是黑
            RCGPUImageOptionalColorsFilter *OptionalColorsFilter2 = [[RCGPUImageOptionalColorsFilter alloc] initColor:2 initType:0 initC:0 initM:0 initY:0 initB:-50];
            ga_imgfilter[indx]=OptionalColorsFilter2;
            if (indx>0) {
                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
            }
            indx++;

        }
        else
        {
//            GPUImageBrightnessFilter*brightnessFilter=[[GPUImageBrightnessFilter alloc] init];
//            
//            CGFloat brightness=0.0;
//            if (directSeedingData.beautyFacelevel==1)
//            {
//                brightness=5.0+brightnessAdd;
//            }
//            else if (directSeedingData.beautyFacelevel==2)
//            {
//                brightness=20.0+brightnessAdd;
//            }
//            else
//            {
//                brightness=30.0+brightnessAdd;
//            }
//            
//            [brightnessFilter setBrightness:brightness/100.0];
//            
//            ga_imgfilter[indx] = brightnessFilter;
//            if (indx>0) {
//                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
//            }
//            indx++;
        }
        
    }
//    double deltaTime14 = [[NSDate date] timeIntervalSinceDate:tmpStartData14];
//    NSLog(@"filterinit：%f ms\n", deltaTime14*1000);

    if (directSeedingData.filterType>0) {
        GPUImageOutput<GPUImageInput> * directfilter=[RCStillImageFilter directFilter:directSeedingData.filterType];
        if (directfilter!=nil) {
            ga_imgfilter[indx]=directfilter;
            if (indx>0) {
                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
            }
            indx++;
        }

    }
    
    if (false&&boolCamerFront) {
        RCGPUImageLRexchangeFilter * LRexchangeFilter=[[RCGPUImageLRexchangeFilter alloc] init];
        ga_imgfilter[indx]=LRexchangeFilter;
        if (indx>0) {
            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
        }
        indx++;
    }
    
    if (indx==0) {
        return PixelBufferRefIn;
    }
    
    filterRes.initialFilters = [NSArray arrayWithObjects:ga_imgfilter[0],nil];
    filterRes.terminalFilter = ga_imgfilter[indx-1];
    filter= filterRes;
    if (directSeedingData.isNeedInit==true)
    {
        //directSeedingtype->isNeedInit=false;
        
        [RCStillImageFilter setDirectisNeedInit:false];
    }
    
    isFirst=false;

    if (image!=nil) {
        
        if (indxtmp>50) {
            [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
        }
//        [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
//        NSDate* tmpStartData4 = [[NSDate date] init];
        GPUImagePicture *sourcePicture1 = [[GPUImagePicture alloc] initWithImage:image];
//        double deltaTime4 = [[NSDate date] timeIntervalSinceDate:tmpStartData4];
//        NSLog(@"initWithImage：%f ms\n", deltaTime4*1000);
//        NSDate* tmpStartData13 = [[NSDate date] init];
        
        [sourcePicture1 addTarget:filter];

        [filter useNextFrameForImageCapture];

//        double deltaTime13 = [[NSDate date] timeIntervalSinceDate:tmpStartData13];
//        NSLog(@"addTarget+useNextFrameForImageCapture：%f ms\n", deltaTime13*1000);

        
//                NSDate* tmpStartData3 = [[NSDate date] init];
        [sourcePicture1 processImage];

//        double deltaTime3 = [[NSDate date] timeIntervalSinceDate:tmpStartData3];
//        NSLog(@"processImage：%f ms\n", deltaTime3*1000);
        
        
//                NSDate* tmpStartData2 = [[NSDate date] init];
        UIImage *arrayImage=[filter imageFromCurrentFramebuffer];
//        double deltaTime2 = [[NSDate date] timeIntervalSinceDate:tmpStartData2];
//        NSLog(@"imageFromCurrentFramebuffer：%f ms\n", deltaTime2*1000);
        
//        [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
        
        if (indxtmp>50) {
            [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
            indxtmp=0;
        }
//        NSDate* tmpStartData = [[NSDate date] init];
        PixelBufferRefOut=[self ImageToSampleBuffer:arrayImage.CGImage];//1.7ms
//        double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
//        NSLog(@"ImageToSampleBuffer：%f ms\n", deltaTime*1000);

    }
    
//    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
//    NSLog(@"ttttt：%f ms\n", deltaTime*1000);

    return PixelBufferRefOut;
}

+ (UIImage *)imageAdjustableFaceBeauty:(UIImage *)image RRFaceParameters:(FaceParameters *)faceParameters
{
    if (image == nil) {
        return nil;
    }

    GPUImageOutput<GPUImageInput> * filter=[[RCGPUImageFaceMainFilter alloc]initImg:image RRFaceParameters:faceParameters];
    
    UIImage *imgtmp;
    if (filter == nil)
    {
        imgtmp = image;
    }
    else
    {
        GPUImagePicture *sourcePicture1 = [[GPUImagePicture alloc] initWithImage:image];
        
        [sourcePicture1 addTarget:filter];
        
        [filter useNextFrameForImageCapture];
        [sourcePicture1 processImage];
        UIImage *img = [filter imageFromCurrentFramebuffer];
        imgtmp=img;
    }

    
    if (faceParameters->faceIsAcne&&faceParameters->faceIsGetFace)
    {
        
        for (int i=0; i<faceParameters->faceAcneNum; i++)
        {
            if (faceParameters->faceAcneManual[i].model==0)
            {
                imgtmp=AutomaticAcne(imgtmp,&faceData,faceParameters->faceAcneManual[i].range);
            }
            else
            {
                imgtmp=ManualAcne(imgtmp,faceParameters->faceAcneManual[i].poi1.x,faceParameters->faceAcneManual[i].poi1.y,faceParameters->faceAcneManual[i].range);
            }
        }
    }
    return imgtmp;
}

+ (UIImage *)imageByTotalTuningImage:(UIImage *)image para:(RRTuningParameters) para
{
    if (image == nil) {
        return nil;
    }
    
    GPUImageOutput<GPUImageInput> *filter;

    InsFineTune inFineTuneUse;
    memset(&inFineTuneUse,0,sizeof(InsFineTune));
    inFineTuneUse.brightness=(para.brightness-0.5)*2.0;
    inFineTuneUse.contrast=(para.contrast-0.5)*2.0;
    inFineTuneUse.saturation=(para.saturation-0.5)*2.0;
    inFineTuneUse.temperature=(para.temperature-0.5)*2.0;
    inFineTuneUse.fade=(para.fade);
    inFineTuneUse.vignette=-(para.lightShadow-0.5)*2.0*0.4;

    if (para.colorHighLightType>0)
    {
        int tem;
        tem=para.colorHighLightType-1;
        if (tem>7)
        {
            tem=7;
        }
        inFineTuneUse.tintHighlightsColor.one=ga_Data[tem][0];
        inFineTuneUse.tintHighlightsColor.two=ga_Data[tem][1];
        inFineTuneUse.tintHighlightsColor.three=ga_Data[tem][2];
        inFineTuneUse.tintHighlightsIntensity=para.colorHighLight;
    }

    if (para.colorLightShadowType>0)
    {
        int tem;
        tem=para.colorLightShadowType-1;
        if (tem>7)
        {
            tem=7;
        }
        inFineTuneUse.tintShadowsColor.one=ga_Data[tem][0];
        inFineTuneUse.tintShadowsColor.two=ga_Data[tem][1];
        inFineTuneUse.tintShadowsColor.three=ga_Data[tem][2];
        inFineTuneUse.tintShadowsIntensity=para.colorLightShadow;
    }

    inFineTuneUse.sharpenDisabled=1.0;

    GPUImageOutput<GPUImageInput> *filter1;
    filter1 = [[RCGPUImageInsFineTuneFilter alloc] initStruct:&inFineTuneUse];
    
    //    filter = [[RCGPUImageTotalTuneFilter alloc]
    //              initWithParameters:para.lux
    //              brightness:para.brightness contrast:para.contrast saturation:para.saturation
    //              temperature:para.temperature highlight:para.highlight shadow:para.shadow
    //              sharpness:para.sharpness vignetteEnd:para.vignetteEnd
    //              isLinearOpen:para.isLinearOpen linearCenter:para.linearCenter linearRadius:para.linearRadius
    //              isRadialOpen:para.isRadialOpen radialCenterX:para.radialCenterX
    //              radialCenterY:para.radialCenterY radialRadius:para.radialRadius
    //              image:image];

    inFineTuneUse.lux2 = para.lux;
    inFineTuneUse.rotation2d2 = para.rotation2d;
    inFineTuneUse.horizontalRotation3d2 = para.horizontalRotation3d;
    inFineTuneUse.verticalRotation3d2 = para.verticalRotation3d;
    inFineTuneUse.sharpness2 = para.sharpness;
    inFineTuneUse.vignetteEnd2 = para.vignetteEnd;
    filter=[[RCGPUImageTotalTuneFilter alloc]initWithParameters:&inFineTuneUse image:image];

    if (filter == nil&&filter1 == nil) {
        return image;
    }

    GPUImagePicture *sourcePicture1 = [[GPUImagePicture alloc] initWithImage:image];

    [sourcePicture1 addTarget:filter1];
    if (filter==nil)
    {
        filter=filter1;
    }
    else
    {
        [filter1 addTarget:filter];
    }

    [filter useNextFrameForImageCapture];
    [sourcePicture1 processImage];

    UIImage * result = [filter imageFromCurrentFramebuffer];

    [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];

    return result;
}

+ (UIImage *)blendTwoImage:(UIImage *)topLayer bottomLayer:(UIImage *)bottomLayer opacity:(CGFloat)opacity
{
    UIImage *image = [self OpacityImage:topLayer opacity:opacity];
    return [self blendImage:image bottomLayer:bottomLayer];
}

+ (UIImage *)OpacityImage:(UIImage *)image opacity:(CGFloat)opacity
{
    //Opacity
    GPUImageOpacityFilter *OpacityFilter = [[GPUImageOpacityFilter alloc] init];
    [(GPUImageOpacityFilter *)OpacityFilter setOpacity:(opacity)];

    GPUImagePicture *sourcePicture = [[GPUImagePicture alloc] initWithImage:image];
    [sourcePicture addTarget:OpacityFilter];
    [OpacityFilter useNextFrameForImageCapture];
    [sourcePicture processImage];
    
    return [OpacityFilter imageFromCurrentFramebuffer];
}

+ (UIImage *)blendImage:(UIImage *)topLayer bottomLayer:(UIImage *)bottomLayer
{
    //NormalBlendFilter
    GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
    
    GPUImagePicture *sourcePicture1 = [[GPUImagePicture alloc] initWithImage:topLayer];
    GPUImagePicture *sourcePicture2 = [[GPUImagePicture alloc] initWithImage:bottomLayer];
    
    [sourcePicture1 addTarget:NormalBlendFilter atTextureLocation:1];
    [sourcePicture2 addTarget:NormalBlendFilter atTextureLocation:0];
    [NormalBlendFilter useNextFrameForImageCapture];
    [sourcePicture1 processImage];
    [sourcePicture2 processImage];
    
    return [NormalBlendFilter imageFromCurrentFramebuffer];
}

+ (UIImage *)imageByDaub:(UIImage *)image sFilter:(SFilter*)sFilter
{
    return [RCGPUImageDaubFilter filterImg:image SFilter:sFilter];
}

+ (UIImage*)exportImage:(UIImage*)image
{
    return [RCGPUImageDaubFilter exportImage:image];
}

+ (void)releaseDaubFilterImagePixel
{
    [RCGPUImageDaubFilter releaseImgPixel];
}
+ (RRTuningParameters)getDefaultTuingParameters{
    struct RRTuningParameters tuing = {0.5,0.5,0.5,0.5,0.5,0,0,0,0,false,0.5,0.5,false,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0,0.5,0,0.5,0};
    return tuing;
}
+ (FaceParameters)getDefaultFaceParameters{
    FaceParameters faceParams = {false, false, false, false, false, false, false, false, 0, 0, 0, 0, 0, 0};
    return faceParams;
}
//取直播滤镜的参数
+ (DirectSeeding *)getDirectSeeding
{
    @synchronized(self)
    {
        return &g_DirectSeeding;
    }
}
//写直播滤镜的人脸level
+ (void)setDirectBeautyFacele:(int)beautyFacelevel
{
    @synchronized(self)
    {
        g_DirectSeeding.beautyFacelevel=beautyFacelevel;
    }
}
//写直播滤镜的是否初始化
+ (void)setDirectisNeedInit:(bool)isNeedInit
{
    @synchronized(self)
    {
        g_DirectSeeding.isNeedInit=isNeedInit;
    }
}

+ (void)setDirectisNeedSticker:(bool)isNeedSticker
{
    @synchronized(self)
    {
        g_DirectSeeding.isSticker=isNeedSticker;
    }
}

//写直播滤镜的滤镜类型
+ (void)setDirectFilter:(NSInteger)type
{
    @synchronized(self)
    {
        g_DirectSeeding.filterType=type;
    }
}

+ (BOOL)configDynamicPasterParameters:(NSString *)pasterPath
{
    [self releaseFilterResources];
    
    if (!pasterPath) {
        return NO;
    }
    
    NSString *configFile = [pasterPath stringByAppendingPathComponent:@"config"];
    NSString *configContent = [NSString stringWithContentsOfFile:configFile encoding:NSUTF8StringEncoding error:nil];

    NSData *jsonData = [configContent dataUsingEncoding:NSUTF8StringEncoding];

    if (!jsonData) {
        return NO;
    }

    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return NO;
    }

    NSDictionary *configInfo = dic;

#ifdef DEBUG
    NSLog(@"Config Content: %@", configInfo);
#endif
    if (!configInfo) {
        return NO;
    }
    
    NSString *type = configInfo[@"type"];
    if ([type characterAtIndex:0]=='N') {
        faceSticker.stickerCount=0;
    }
    else
    {
        faceSticker.stickerCount=1;
    }
    faceSticker.faceStickerInf[0].positionType=(int)([type characterAtIndex:0] - 'A' + 1);
    
    if (faceSticker.faceStickerInf[0].imageName!=nil) {
        free(faceSticker.faceStickerInf[0].imageName);
        faceSticker.faceStickerInf[0].imageName=nil;
    }
    const char *imageName = [[pasterPath stringByAppendingPathComponent:configInfo[@"name"]] UTF8String];
    char *imageNameCopy = (char *)malloc(strlen(imageName) + 1);
    strcpy(imageNameCopy, imageName);
    faceSticker.faceStickerInf[0].imageName = imageNameCopy;
    faceSticker.faceStickerInf[0].count=[configInfo[@"num"]intValue];
    CGFloat width = [configInfo[@"width"] floatValue];
    CGFloat height = [configInfo[@"height"] floatValue];
    NSArray *relativePostions=configInfo[@"refpts"];
    faceSticker.faceStickerInf[0].point[0]=CGPointMake([relativePostions[0] floatValue] / width, [relativePostions[1] floatValue] / height);
    faceSticker.faceStickerInf[0].point[1]=CGPointMake([relativePostions[2] floatValue] / width, [relativePostions[3] floatValue] / height);
    faceSticker.faceStickerInf[0].point[2]=CGPointMake([relativePostions[4] floatValue] / width, [relativePostions[5] floatValue] / height);
    
    if ([configInfo[@"ifbackground"] boolValue]) {
        faceSticker.stickerBackCount = 1;
        faceSticker.faceStickerBackInf[0].count = [configInfo[@"bknum"]intValue];
        if (faceSticker.faceStickerBackInf[0].imageName!=nil) {
            free(faceSticker.faceStickerBackInf[0].imageName);
            faceSticker.faceStickerBackInf[0].imageName=nil;
        }
        const char *imageName = [[pasterPath stringByAppendingPathComponent:configInfo[@"bkname"]] UTF8String];
        char *imageNameCopy = (char *)malloc(strlen(imageName) + 1);
        strcpy(imageNameCopy, imageName);
        faceSticker.faceStickerBackInf[0].imageName = imageNameCopy;
        faceSticker.faceStickerBackInf[0].rect = CGRectMake(0, 0, 1.0,1.0);//[configInfo[@"bkwidth"] floatValue], [configInfo[@"bkheight"] floatValue]);
    } else {
        faceSticker.stickerBackCount = 0;
    }
    
    NSString *musicName = configInfo[@"music"];
    if (musicName.length > 0) {
        const char *soundFile = [[pasterPath stringByAppendingPathComponent:musicName] UTF8String];
        faceSticker.soundFile = (char *)malloc(strlen(soundFile) + 1);
        strcpy(faceSticker.soundFile, soundFile);
    }
    
    return YES;
}

+ (void)releaseFilterResources;
{
    for (int i=0; i<5; i++) {
        if (faceSticker.faceStickerInf[i].imageName!=nil) {
            free(faceSticker.faceStickerInf[i].imageName);
            faceSticker.faceStickerInf[i].imageName=nil;
        }
    }
    
    for (int i=0; i<2; i++) {
        if (faceSticker.faceStickerBackInf[i].imageName!=nil) {
            free(faceSticker.faceStickerBackInf[i].imageName);
            faceSticker.faceStickerBackInf[i].imageName=nil;
        }
    }
    
    if (faceSticker.soundFile != nil) {
        free(faceSticker.soundFile);
        faceSticker.soundFile = nil;
    }
    
    faceSticker.stickerCount = 0;
    faceSticker.stickerBackCount = 0;
}

@end
