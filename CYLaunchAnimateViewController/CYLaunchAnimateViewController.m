//
//  CYLaunchAnimateViewController.m
//  CYLaunchAnimateView
//
//  Created by Peter Lee on 16/8/24.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "CYLaunchAnimateViewController.h"

@interface CYSkipButton : UIButton

@property (nonatomic, assign) NSInteger remainSec;
@property (nonatomic, strong) UILabel *remainSecLabel;

@end

@implementation CYSkipButton

- (UILabel *)remainSecLabel{
    if (!_remainSecLabel) {
        _remainSecLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bounds.size.height/2, self.bounds.size.width, 13)];
        _remainSecLabel.textAlignment = NSTextAlignmentCenter;
        _remainSecLabel.font = [UIFont systemFontOfSize:12];
        _remainSecLabel.text = @"0 s";
    }
    return _remainSecLabel;
}

- (void)setRemainSec:(NSInteger)remainSec{
    _remainSec = remainSec;
    self.remainSecLabel.text = [NSString stringWithFormat:@"%@ s",@(remainSec)];
}

- (instancetype)init{
    CGRect skipButtonBounds = CGRectMake(0, 0, 40, 40);
    self = [super initWithFrame:skipButtonBounds];
    if (self) {
        [self setTitle:@"Skip" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = skipButtonBounds.size.height/2;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 2;
        [self addSubview:self.remainSecLabel];
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, contentRect.size.height/2-13, contentRect.size.width, 13);
}

@end

static const CGFloat kDefaultAnimateDuration = 0.8;
static const CGFloat kDefaultWaitDuration = 3.0;

@interface CYLaunchAnimateViewController ()

@property (nonatomic, strong) CYSkipButton *skipButton;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat timePass;

@end

@implementation CYLaunchAnimateViewController

#pragma mark - lazy load
- (CYSkipButton *)skipButton{
    if (!_skipButton) {
        _skipButton = [[CYSkipButton alloc]init];
        CGRect skipButtonFrame = _skipButton.bounds;
        skipButtonFrame.origin.x = self.view.frame.size.width - _skipButton.frame.size.width - 20;
        skipButtonFrame.origin.y = 40;
        self.skipButton.frame = skipButtonFrame;
    }
    return _skipButton;
}

#pragma mark - init method
- (instancetype)init{
    self = [super init];
    if (self) {
        _animateDuration = kDefaultAnimateDuration;
        _waitDuration = kDefaultWaitDuration;
    }
    return self;
}

- (instancetype)initWithContentView:(UIView *)contentView animateType:(CYLaunchAnimateType)animateType showSkipButton:(BOOL)showSkipButton{
    self = [self init];
    if (self) {
        _contentView = contentView;
        _animateType = animateType;
        _showSkipButton = showSkipButton;
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    [self configureSubViews];
}

- (void)viewDidAppear:(BOOL)animated{
    [self configureTimer];
}

- (void)configureSubViews{
    NSAssert(_contentView, @"contentView must not be nil!");
    
    self.view.backgroundColor = [UIColor clearColor];
    _contentView.center = CGPointMake(self.view.center.x, self.view.center.y);
    [self.view addSubview:_contentView];
    
    if(self.showSkipButton){
        self.skipButton.remainSec = _waitDuration;
        [self.view addSubview:self.skipButton];
        [self.skipButton addTarget:self action:@selector(dismissAtOnce) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)configureTimer{
    self.timePass = 0.0;
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
    self.timer = timer;
    [timer fire];
}

#pragma mark - control method
- (void)countDown{
    _timePass+=0.1;
    _skipButton.remainSec = _waitDuration-_timePass<0?0:_waitDuration-_timePass;
    if(_waitDuration<=_timePass){
        [self.timer invalidate];
        self.timer = nil;
        [self dismiss];
    }
}

- (void)dismiss{
    
    switch (self.animateType){
        case CYLaunchAnimateTypeFade:{
            CABasicAnimation *animation = [CABasicAnimation animation];
            animation.delegate = self;
            [animation setDuration:_animateDuration];
            animation.keyPath = @"opacity";
            animation.toValue = @(0);
            [self.view.layer addAnimation:animation forKey:nil];
            break;
        }
        case CYLaunchAnimateTypeFadeAndZoomIn:{
            CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
            groupAnimation.delegate = self;
            [groupAnimation setDuration:_animateDuration];
            
            CABasicAnimation *fadeAnimation = [CABasicAnimation animation];
            fadeAnimation.keyPath = @"opacity";
            fadeAnimation.toValue = @(0);
            
            CABasicAnimation *zoomInAnimation = [CABasicAnimation animation];
            zoomInAnimation.keyPath = @"transform.scale";
            zoomInAnimation.toValue = @(2.0);
            
            groupAnimation.animations = @[fadeAnimation,zoomInAnimation];
            
            [self.view.layer addAnimation:groupAnimation forKey:nil];
            break;
        }
        case CYLaunchAnimateTypePointZoomOut1:{
            
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            self.view.layer.mask = maskLayer;
            
            CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            [maskLayerAnimation setDuration:_animateDuration];
            maskLayerAnimation.delegate = self;
            
            UIBezierPath *beginPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
            UIBezierPath *beginCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y) radius:1 startAngle:0 endAngle:2 * M_PI clockwise:NO];
            [beginPath appendPath:beginCirclePath];
            maskLayerAnimation.fromValue = (__bridge id)(beginPath.CGPath);
            
            UIBezierPath *endPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
            UIBezierPath *endCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y) radius:hypot(screenSize.height, screenSize.width)/2 startAngle:0 endAngle:2 * M_PI clockwise:NO];
            [endPath appendPath:endCirclePath];
            maskLayerAnimation.toValue = (__bridge id)((endPath.CGPath));
            
            maskLayerAnimation.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            [maskLayer addAnimation:maskLayerAnimation forKey:nil];
            
            break;
        }
        case CYLaunchAnimateTypePointZoomOut2:{
            
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            self.view.layer.mask = maskLayer;
            
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            
            CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
            [keyFrameAnimation setDuration:_animateDuration];
            keyFrameAnimation.delegate = self;
            
            UIBezierPath *pathOne = [UIBezierPath bezierPathWithRect:self.view.bounds];
            UIBezierPath *pathOneCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y) radius:1.0 startAngle:0 endAngle:2 * M_PI clockwise:NO];
            [pathOne appendPath:pathOneCircle];
            
            UIBezierPath *pathTwo = [UIBezierPath bezierPathWithRect:self.view.bounds];
            UIBezierPath *pathTwoCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y) radius:screenSize.width/2*0.7 startAngle:0 endAngle:2 * M_PI clockwise:NO];
            [pathTwo appendPath:pathTwoCircle];
            
            UIBezierPath *pathThree = [UIBezierPath bezierPathWithRect:self.view.bounds];
            UIBezierPath *pathThreeCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y) radius:screenSize.width/2*0.5 startAngle:0 endAngle:2 * M_PI clockwise:NO];
            [pathThree appendPath:pathThreeCircle];
            
            UIBezierPath *pathFour = [UIBezierPath bezierPathWithRect:self.view.bounds];
            UIBezierPath *pathFourCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y) radius:hypot(screenSize.height, screenSize.width)/2 startAngle:0 endAngle:2 * M_PI clockwise:NO];
            [pathFour appendPath:pathFourCircle];
            
            keyFrameAnimation.values = @[(__bridge id)(pathOne.CGPath),(__bridge id)(pathTwo.CGPath),(__bridge id)(pathThree.CGPath),(__bridge id)(pathFour.CGPath)];
            keyFrameAnimation.keyTimes = @[@(0),@(0.3),@(0.6),@(1)];
            
            [maskLayer addAnimation:keyFrameAnimation forKey:nil];
            
            break;
        }
        case CYLaunchAnimateTypePointZoomIn1:{
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            self.view.layer.mask = maskLayer;
            
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            
            CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
            [keyFrameAnimation setDuration:_animateDuration];
            keyFrameAnimation.delegate = self;
            
            UIBezierPath *pathOne = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y) radius:hypot(screenSize.height, screenSize.width)/2 startAngle:0 endAngle:2 * M_PI clockwise:NO];
            
            UIBezierPath *pathTwo = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y) radius:screenSize.width/2*0.5 startAngle:0 endAngle:2 * M_PI clockwise:NO];
            
            UIBezierPath *pathThree = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y) radius:screenSize.width/2*0.7 startAngle:0 endAngle:2 * M_PI clockwise:NO];
            
            UIBezierPath *pathFour = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y) radius:1 startAngle:0 endAngle:2 * M_PI clockwise:NO];
            
            keyFrameAnimation.values = @[(__bridge id)(pathOne.CGPath),(__bridge id)(pathTwo.CGPath),(__bridge id)(pathThree.CGPath),(__bridge id)(pathFour.CGPath)];
            keyFrameAnimation.keyTimes = @[@(0),@(0.5),@(0.9),@(1)];
            
            [maskLayer addAnimation:keyFrameAnimation forKey:nil];
            
            break;
        }
        case CYLaunchAnimateTypePointZoomIn2:{
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            self.view.layer.mask = maskLayer;
            
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            
            CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            [maskLayerAnimation setDuration:_animateDuration];
            maskLayerAnimation.delegate = self;
            
            UIBezierPath *beginPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y) radius:hypot(screenSize.height, screenSize.width)/2 startAngle:0 endAngle:2 * M_PI clockwise:NO];
            
            UIBezierPath *endPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.center.x, self.view.center.y) radius:1 startAngle:0 endAngle:2 * M_PI clockwise:NO];
            
            maskLayerAnimation.fromValue = (__bridge id)(beginPath.CGPath);
            maskLayerAnimation.toValue = (__bridge id)(endPath.CGPath);
            
            [maskLayer addAnimation:maskLayerAnimation forKey:nil];
            
            break;
        }
        default:
            break;
    }
}

- (void)dismissAtOnce{
    [self.timer invalidate];
    self.timer = nil;
    [self.view removeFromSuperview];
    if (_complete) {
        self.complete();
    }
}

- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NSAssert(window,@"keyWindow must be init!");
    [window addSubview:self.view];
}

#pragma mark - delegate method
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self dismissAtOnce];
}

@end
