//
//  YCBaseConentView+YCPopView.m
//  iWeidao
//
//  Created by billyye on 15/12/21.
//  Copyright © 2015年 yongche. All rights reserved.
//

#import "XYBaseConentView+YCPopView.h"
#import <objc/runtime.h>

#define YCPopViewTag 9999999

@implementation XYBaseConentView (YCPopView)

#pragma mark - Set Methods
- (void)setPopParentView:(UIView *)parentView
{
    objc_setAssociatedObject(self,@selector(setPopParentView:),parentView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)popParentView
{
    UIView *parentView = objc_getAssociatedObject(self, @selector(setPopParentView:));
    return parentView != nil ? parentView : [self keyWindow];
}

- (void)setShowCompleteBlock:(void(^) (id model))completeBlock
{
    objc_setAssociatedObject(self,@selector(setShowCompleteBlock:),completeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (YCPopCompleteBlock)showCompleteBlock
{
    return objc_getAssociatedObject(self,@selector(setShowCompleteBlock:));
}

- (void)setDismissCompleteBlock:(void(^) (id model))completeBlock
{
    objc_setAssociatedObject(self,@selector(setDismissCompleteBlock:),completeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (YCPopCompleteBlock)dismissCompleteBlock
{
    return objc_getAssociatedObject(self,@selector(setDismissCompleteBlock:));
}

- (void)setPopAnimatedType:(YCPopAnimatedType)animatedType
{
    NSNumber *type = [NSNumber numberWithInteger:animatedType];
    objc_setAssociatedObject(self, @selector(setPopAnimatedType:),type, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (YCPopAnimatedType)popAnimatedType
{
    NSNumber *type = objc_getAssociatedObject(self,@selector(setPopAnimatedType:));
    return (YCPopAnimatedType)[type integerValue];
}

- (void)addPopMaskView
{
    UIView *popParentView = [self popParentView];
    UIView *maskView = [self maskViewWithFrame:popParentView.bounds];
    [popParentView addSubview:maskView];
    objc_setAssociatedObject(self, @selector(addPopMaskView),maskView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)maskView
{
    return objc_getAssociatedObject(self, @selector(addPopMaskView));
}

- (void)setupView
{
    UIView *parentView = [self popParentView];
    [self addPopMaskView];
    [parentView addSubview:self];
}

#pragma mark - Public Methods
- (void)showViewInWindowWithAnimatedType:(YCPopAnimatedType)animatedType
                                           model:(id)model
                                popCompleteBlock:(void(^)(id model))completeBlock
{
    [self setPopAnimatedType:animatedType];
    [self setContentViewWithModel:model];
    [self setShowCompleteBlock:completeBlock];
    [self setupView];
    [self showContentViewWithAnimatedType:animatedType];
}

- (void)showViewInSuperView:(UIView *)superView
                       animatedType:(YCPopAnimatedType)animatedType
                              model:(id)model
                   popCompleteBlock:(void(^) (id model))completeBlock
{
    [self setPopParentView:superView];
    [self setPopAnimatedType:animatedType];
    [self setContentViewWithModel:model];
    [self setShowCompleteBlock:completeBlock];
    [self setupView];
    [self showContentViewWithAnimatedType:animatedType];
}

+ (void)dismissPopViewFromSuperView:(UIView *)superView
                       animatedType:(YCPopAnimatedType)animatedType
                   popCompleteBlock:(void(^) (id model))compeleteBlock
{
    XYBaseConentView *popView = [XYBaseConentView searchPopViewFromView:superView];
    if (popView) {
        [popView setPopAnimatedType:animatedType];
        [popView setDismissCompleteBlock:compeleteBlock];
        [popView dismissContentViewWithAnimatedType:animatedType];
    }
}

+ (BOOL)haveShowInSuperView:(UIView *)superView
{
    XYBaseConentView *popView = [XYBaseConentView searchPopViewFromView:superView];
    return popView != nil;
}

- (void)dismissViewWithAnimatedType:(YCPopAnimatedType)animatedType
{
    [self dismissContentViewWithAnimatedType:animatedType];
}

- (void)setDissmissViewWithCompleteBlock:(void(^) (id model))completeBlock
{
    [self setDismissCompleteBlock:completeBlock];
}

#pragma mark - Animation Methods
- (void)clearAllInstalledSubviews
{
    [self removeFromSuperview];
    [[self maskView] removeFromSuperview];
}

- (void)showAnimationCompletedCallBack
{
    YCPopCompleteBlock showCompleteBlock = [self showCompleteBlock];
    if (showCompleteBlock) {
        showCompleteBlock(self);
    }
    [self setShowCompleteBlock:nil];
}

- (void)dismissAnimationCompletedCallBack
{
    YCPopCompleteBlock dismissCompleteBlock = [self dismissCompleteBlock];
    if (dismissCompleteBlock) {
        dismissCompleteBlock(self);
    }
    [self setDismissCompleteBlock:nil];
}

- (void)showContentViewWithAnimatedType:(YCPopAnimatedType)animatedType
{
    CGPoint startPosition = [self startPositionForAnimationType:animatedType];
    CGPoint endPosition = [self endPositionForAnimationType:animatedType];
    CGFloat startAlpha = [self startAlphaForAnimationType:animatedType isShow:NO];
    CGFloat endAlpha = [self endAlphaForAnimationType:animatedType isShow:NO];
    
    if (animatedType != YCPopAnimatedTypeNone) {
        
        self.center = startPosition;
        self.userInteractionEnabled = NO;
        self.maskView.alpha = 0;
        self.alpha = startAlpha;
        
        [UIView animateWithDuration:0.4 animations:^{
            
            self.alpha = endAlpha;
            self.center = endPosition;
            self.maskView.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            self.userInteractionEnabled = YES;
            [self showAnimationCompletedCallBack];
        }];
    } else {
        
        self.center = endPosition;
        [self showAnimationCompletedCallBack];
    }
}

- (void)dismissContentViewWithAnimatedType:(YCPopAnimatedType)animatedType
{
    if (animatedType != YCPopAnimatedTypeNone) {
        
        CGPoint startPosition = [self startPositionForAnimationType:animatedType];
        CGFloat startAlpha = [self startAlphaForAnimationType:animatedType isShow:NO];
        CGFloat endAlpha = [self endAlphaForAnimationType:animatedType isShow:NO];
        
        self.alpha = startAlpha;
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.4 animations:^{
            
            self.center = startPosition;
            self.alpha = endAlpha;
            self.maskView.alpha = 0;
            
        }completion:^(BOOL finished) {
            
            self.userInteractionEnabled = YES;
            [self dismissAnimationCompletedCallBack];
            [self clearAllInstalledSubviews];
        }];
    } else {
        [self clearAllInstalledSubviews];
        [self dismissAnimationCompletedCallBack];
    }
}

- (CGFloat)startAlphaForAnimationType:(YCPopAnimatedType)animatedType isShow:(BOOL)show
{
    CGFloat alpha = 1.0;
    if (animatedType == YCPopAnimatedTypeChageAlpha && show) {
        alpha = 0.0;
    }
    return alpha;
}

- (CGFloat)endAlphaForAnimationType:(YCPopAnimatedType)animatedType isShow:(BOOL)show
{
    CGFloat alpha = 1.0;
    if (animatedType == YCPopAnimatedTypeChageAlpha && !show) {
        alpha = 0.0;
    }
    return alpha;
}


- (CGPoint)startPositionForAnimationType:(YCPopAnimatedType)animatedType
{
    CGPoint startPosition = CGPointZero;
    CGSize contentSize = CGSizeMake(CGRectGetWidth(self.frame),CGRectGetHeight(self.frame));
    
    UIView *parentView = [self popParentView];
    if (parentView == nil) {
        parentView = [self keyWindow];
    }
    CGFloat width = CGRectGetWidth(parentView.frame);
    CGFloat height = CGRectGetHeight(parentView.frame);
    
    switch (animatedType) {
        case YCPopAnimatedTypeNone: {
            
            startPosition = CGPointMake(width/2,height/2);
        }
            break;
        case YCPopAnimatedTypeFromBottom: {
            
            startPosition = CGPointMake(width/2,height + contentSize.height/2);
        }
            break;
        case YCPopAnimatedTypeFromLeft: {
            
            startPosition = CGPointMake(-contentSize.width/2,height/2);
        }
            break;
        case YCPopAnimatedTypeFromRgiht: {
            
            startPosition = CGPointMake(width + contentSize.width/2,height/2);
        }
            break;
        case YCPopAnimatedTypeFromTop: {
            startPosition = CGPointMake(width/2, -contentSize.height/2);
        }
            break;
        case YCPopAnimatedTypeChageAlpha: {
            startPosition = CGPointMake(width/2,height/2);
        }
            break;
        default:
            break;
    }
    return startPosition;
}

- (CGPoint)endPositionForAnimationType:(YCPopAnimatedType)animatedType
{
    UIView *parentView = [self popParentView];
    if (parentView == nil) {
        parentView = [self keyWindow];
    }
    CGFloat width = CGRectGetWidth(parentView.frame);
    CGFloat height = CGRectGetHeight(parentView.frame);
    
    return CGPointMake(width/2,height/2);
}

#pragma Action Methods
- (void)tapMaskViewAction:(UITapGestureRecognizer *)gesture
{
    [self dismissContentViewWithAnimatedType:[self popAnimatedType]];
}

#pragma mark - Private Methods
+ (XYBaseConentView *)searchPopViewFromView:(UIView *)superView
{
    __block XYBaseConentView *popView = nil;
    [superView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.tag == YCPopViewTag && [obj isKindOfClass:[XYBaseConentView class]]) {
            popView = obj;
            *stop = YES;
        }
    }];
    return popView;
}

- (UIWindow *)keyWindow
{
    return [UIApplication sharedApplication].keyWindow;
}

- (UIView *)maskViewWithFrame:(CGRect)frame
{
    UIView *maskView = [[UIView alloc] initWithFrame:frame];
    maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskViewAction:)];
    [maskView addGestureRecognizer:tapGesture];
    
    return maskView;
}

@end