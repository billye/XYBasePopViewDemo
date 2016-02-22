//
//  YCBaseConentView+YCPopView.h
//  iWeidao
//
//  Created by billyye on 15/12/21.
//  Copyright © 2015年 yongche. All rights reserved.
//

#import "XYBaseConentView.h"

typedef enum
{
    YCPopAnimatedTypeNone =0,
    YCPopAnimatedTypeFromLeft,
    YCPopAnimatedTypeFromTop,
    YCPopAnimatedTypeFromBottom,
    YCPopAnimatedTypeFromRgiht,
    YCPopAnimatedTypeChageAlpha,
}YCPopAnimatedType;

typedef void(^YCPopCompleteBlock)(id model);

@interface XYBaseConentView (YCPopView)

- (void)showViewInWindowWithAnimatedType:(YCPopAnimatedType)animatedType
                                   model:(id)model
                        popCompleteBlock:(void(^)(id model))completeBlock;

- (void)showViewInSuperView:(UIView *)superView
               animatedType:(YCPopAnimatedType)animatedType
                      model:(id)model
           popCompleteBlock:(void(^) (id model))completeBlock;

+ (void)dismissPopViewFromSuperView:(UIView *)superView
                       animatedType:(YCPopAnimatedType)animatedType
                   popCompleteBlock:(void(^) (id model))compeleteBlock;

+ (BOOL)haveShowInSuperView:(UIView *)superView;

- (void)dismissViewWithAnimatedType:(YCPopAnimatedType)animatedType;

- (void)setDissmissViewWithCompleteBlock:(void(^) (id model))completeBlock;

@end