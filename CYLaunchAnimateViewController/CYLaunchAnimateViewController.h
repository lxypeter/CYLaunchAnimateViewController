//
//  CYLaunchAnimateViewController.h
//  CYLaunchAnimateView
//
//  Created by Peter Lee on 16/8/24.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CYLaunchAnimateType){
    CYLaunchAnimateTypeNone = 0,
    CYLaunchAnimateTypeFade,
    CYLaunchAnimateTypeFadeAndZoomIn,
    CYLaunchAnimateTypePointZoomIn1,
    CYLaunchAnimateTypePointZoomIn2,
    CYLaunchAnimateTypePointZoomOut,
};

typedef void(^CompleteBlock)();

@interface CYLaunchAnimateViewController : UIViewController

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) CYLaunchAnimateType animateType;
@property (nonatomic, assign) CGFloat animateDuration;
@property (nonatomic, assign) CGFloat waitDuration;
@property (nonatomic, copy) CompleteBlock complete;
@property (nonatomic, assign) BOOL showSkipButton;

- (instancetype)initWithContentView:(UIView *)contentView animateType:(CYLaunchAnimateType)animateType showSkipButton:(BOOL)showSkipButton;

- (void)show;
- (void)dismissAtOnce;

@end
