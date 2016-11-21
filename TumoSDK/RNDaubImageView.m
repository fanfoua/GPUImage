//
//  RNDaubImageView.m
//  CXTouchMoveTest
//
//  Created by .Mr.SupEr on 15/7/13.
//  Copyright (c) 2015年 renren. All rights reserved.
//

#import "RNDaubImageView.h"

//static const int kTotalArrayCapacity = 100;
static const NSTimeInterval kSamplePointTimeInterval = 0.02;

@interface RNDaubImageView ()

@property (nonatomic, assign) BOOL shouldSamplePoint;
@property (nonatomic, strong) NSMutableArray *everyPathArray;
@property (nonatomic, strong) NSMutableArray *invalidSwipeArray;
@property (nonatomic, strong) SFilter *sFilter;
@property (nonatomic, strong) SSwipe *currentSwipe;
@property (nonatomic, assign) CGPoint lastImagePoint;
@property (nonatomic, assign) CGFloat distanceRatio;

@end

@implementation RNDaubImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.shouldSamplePoint = YES;
        self.distanceRatio = 0.1;
        self.sFilter = [[SFilter alloc] init];
        self.sFilter.swipeGroup = [[SSwipeGroup alloc] init];
        self.sFilter.swipeGroup.swipes = [[NSMutableArray alloc] init];
        self.sFilter.operaType = 0;

        self.currentSwipe = [[SSwipe alloc] init];
        self.currentSwipe.swipeType = 0;
        self.currentSwipe.width = 50;

        self.currentSwipeWidth = 50;
        self.everyPathArray = [NSMutableArray array];
        self.invalidSwipeArray = [NSMutableArray array];
    }
    return self;
}

- (void)setCurrentSwipeType:(int)currentSwipeType
{
    _currentSwipeType = currentSwipeType;
    //根据笔刷的类型设置最短距离
    self.distanceRatio = currentSwipeType == 4 ? 0.05 : 0.1;
    _currentSwipe.swipeType = currentSwipeType;
}

- (void)setCurrentSwipeWidth:(int)currentSwipeWidth
{
    _currentSwipeWidth = currentSwipeWidth;
    _currentSwipe.width = currentSwipeWidth;
}

- (void)resetShouldSamplePoint
{
    self.shouldSamplePoint = YES;
}

- (CGPoint)getImagePoint:(CGPoint)point
{
    CGSize imageSize = self.image.size;
    int x = (point.x/self.frame.size.width)*imageSize.width;
    int y = (point.y/self.frame.size.height)*imageSize.height;
    return CGPointMake(MAX(MIN(x,imageSize.width-1),0), MAX(MIN(y, imageSize.height-1),0));
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
//    self.shouldSamplePoint = YES;
    self.sFilter.operaType = 0;
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint imagePoint = [self getImagePoint:currentPoint];
    self.lastImagePoint = imagePoint;
    NSValue *pointValue = [NSValue valueWithCGPoint:imagePoint];
    [self.everyPathArray addObject:pointValue];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
//    if (self.shouldSamplePoint) {
//        self.shouldSamplePoint = NO;
//        [self performSelector:@selector(resetShouldSamplePoint) withObject:nil afterDelay:kSamplePointTimeInterval];
//    }
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint imagePoint = [self getImagePoint:currentPoint];
    CGFloat distance = sqrt((imagePoint.x - self.lastImagePoint.x)*(imagePoint.x - self.lastImagePoint.x)+(imagePoint.y - self.lastImagePoint.y)*(imagePoint.y - self.lastImagePoint.y));
    CGFloat fixedDistance = sqrt(self.image.size.width*self.image.size.width+self.image.size.height*self.image.size.height)*self.distanceRatio;
    if (distance >= fixedDistance) {
        [self fillTheEmptyDistance:distance fixedDistance:fixedDistance firstPoint:self.lastImagePoint secondPoint:imagePoint];
        NSValue *pointValue = [NSValue valueWithCGPoint:imagePoint];
        [self.everyPathArray addObject:pointValue];
        [self pointArrayDidChange];
        self.lastImagePoint = imagePoint;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.everyPathArray.count == 1) {
        self.currentSwipe.pointLine = self.everyPathArray;
        self.currentSwipe.num = (int)self.currentSwipe.pointLine.count;
        if (![self.sFilter.swipeGroup.swipes containsObject:self.currentSwipe]) {
            [self.sFilter.swipeGroup.swipes addObject:self.currentSwipe];
            self.sFilter.swipeGroup.num = (int)self.sFilter.swipeGroup.swipes.count;
        }
        if ([self.delegate respondsToSelector:@selector(didMoveWithFilterParam:)]) {
            [self.delegate didMoveWithFilterParam:self.sFilter];
        }
    }

    [self.invalidSwipeArray removeAllObjects];  //移除所有无效笔画
    self.currentSwipe = [[SSwipe alloc] init];
    self.currentSwipe.width = self.currentSwipeWidth;
    self.currentSwipe.swipeType = self.currentSwipeType;
    self.everyPathArray = [NSMutableArray array];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)fillTheEmptyDistance:(CGFloat)distance fixedDistance:(CGFloat)fixedDistance firstPoint:(CGPoint)firstPoint secondPoint:(CGPoint)secondPoint
{
    int supplementPointNum = distance / fixedDistance;
    for (int i = 1; i < supplementPointNum; ++i) {
        int x = firstPoint.x + (secondPoint.x - firstPoint.x) * i / supplementPointNum;
        int y = firstPoint.y + (secondPoint.y - firstPoint.y) * i / supplementPointNum;
        NSValue *pointValue = [NSValue valueWithCGPoint:CGPointMake(x, y)];
        [self.everyPathArray addObject:pointValue];
        [self pointArrayDidChange];
    }
}

- (void)pointArrayDidChange
{
    [self.invalidSwipeArray removeAllObjects];  //移除所有无效笔画
    self.currentSwipe.pointLine = self.everyPathArray;
    self.currentSwipe.num = (int)self.currentSwipe.pointLine.count;
    if (![self.sFilter.swipeGroup.swipes containsObject:self.currentSwipe]) {
        [self.sFilter.swipeGroup.swipes addObject:self.currentSwipe];
    }
    self.sFilter.swipeGroup.num = (int)self.sFilter.swipeGroup.swipes.count;
    if ([self.delegate respondsToSelector:@selector(didMoveWithFilterParam:)]) {
        [self.delegate didMoveWithFilterParam:self.sFilter];
    }
}

- (void)revokeLastStep
{
    if (self.sFilter.swipeGroup.swipes.count) {
        SSwipe *lastStep = self.sFilter.swipeGroup.swipes.lastObject;
        [self.invalidSwipeArray addObject:lastStep];
        self.sFilter.operaType = 1;
        [self.sFilter.swipeGroup.swipes removeLastObject];
        self.sFilter.swipeGroup.num = (int)self.sFilter.swipeGroup.swipes.count;
        if ([self.delegate respondsToSelector:@selector(didMoveWithFilterParam:)]) {
            [self.delegate didMoveWithFilterParam:self.sFilter];
        }
    }
}

- (void)recoveryLastStep
{
    if (self.invalidSwipeArray.count) {
        SSwipe *lastStep = self.invalidSwipeArray.lastObject;
        [self.invalidSwipeArray removeLastObject];
        [self.sFilter.swipeGroup.swipes addObject:lastStep];
        self.sFilter.swipeGroup.num = (int)self.sFilter.swipeGroup.swipes.count;
        self.sFilter.operaType = 2;
        if ([self.delegate respondsToSelector:@selector(didMoveWithFilterParam:)]) {
            [self.delegate didMoveWithFilterParam:self.sFilter];
        }
    }
}

- (UIImage*)exportImage:(UIImage*)image
{
    return [RCStillImageFilter exportImage:image];
}

- (void)releaseDaubFilterPixel
{
    [RCStillImageFilter releaseDaubFilterImagePixel];
}

- (BOOL)canRecoveryLastStep{
    return self.invalidSwipeArray.count > 0;
}

- (BOOL)canRevokeLastStep{
    return self.sFilter.swipeGroup.swipes.count > 0;
}

- (void)resetData{
    [self.invalidSwipeArray removeAllObjects];
    [self.sFilter.swipeGroup.swipes removeAllObjects];
}

@end
