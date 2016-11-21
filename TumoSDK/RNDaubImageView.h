//
//  RNDaubImageView.h
//  CXTouchMoveTest
//
//  Created by .Mr.SupEr on 15/7/13.
//  Copyright (c) 2015年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFilter.h"

@protocol RNDaubImageViewDelegate <NSObject>

- (void)didMoveWithFilterParam:(SFilter*)sFilter;

@end

@interface RNDaubImageView : UIImageView

@property (nonatomic, weak) id<RNDaubImageViewDelegate> delegate;

//  设置当前的滑动类型  0 涂抹  1 橡皮擦   默认为 0 涂抹
@property (nonatomic, assign) int currentSwipeType;
//  设置当前的笔刷宽度      10 ~ 100     默认为 50 宽度
@property (nonatomic, assign) int currentSwipeWidth;

//  撤销上一步操作
- (void)revokeLastStep;

//  恢复上一步操作
- (void)recoveryLastStep;

//  每次切换图片的时候都需要调用一次
- (UIImage*)exportImage:(UIImage*)image;

//  涂改之后不保存 ，请调用释放
- (void)releaseDaubFilterPixel;

- (BOOL)canRevokeLastStep;

- (BOOL)canRecoveryLastStep;

- (void)resetData;

@end
