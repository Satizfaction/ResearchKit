/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#import "ORKCircleViewSlider.h"
#import "ORKCircleViewMath.h"
#import "ORKCircleViewTrackLayer.h"

NSString *const ORKCircleViewSliderStartAngleKey = @"ORKCircleViewSliderStartAngleKey";
NSString *const ORKCircleViewSliderBarColorKey = @"ORKCircleViewSliderBarColorKey";
NSString *const ORKCircleViewSliderTrackingColorKey = @"ORKCircleViewSliderTrackingColorKey";
NSString *const ORKCircleViewSliderThumbColorKey = @"ORKCircleViewSliderThumbColorKey";
NSString *const ORKCircleViewSliderThumbImageKey = @"ORKCircleViewSliderThumbImageKey";
NSString *const ORKCircleViewSliderBarWidthKey = @"ORKCircleViewSliderBarWidthKey";
NSString *const ORKCircleViewSliderThumbWidthKey = @"ORKCircleViewSliderThumbWidthKey";
NSString *const ORKCircleViewSliderMaxValueKey = @"ORKCircleViewSliderMaxValueKey";
NSString *const ORKCircleViewSliderMinValueKey = @"ORKCircleViewSliderMinValueKey";
NSString *const ORKCircleViewSliderSliderEnabledKey = @"ORKCircleViewSliderSliderEnabledKey";
NSString *const ORKCircleViewSliderViewInsetKey = @"ORKCircleViewSliderViewInsetKey";
NSString *const ORKCircleViewSliderMinMaxSwitchTresholdKey = @"ORKCircleViewSliderMinMaxSwitchTresholdKey";

@interface ORKCircleViewSlider ()
@property (nonatomic) CGFloat minThumbTouchAreaWidth;
@property (nonatomic) CGFloat latestDegree;

@property (nonatomic) UIView *thumbView;
@property (nonatomic) ORKCircleViewTrackLayer *trackLayer;
@property (nonatomic, readonly) ORKCircleViewTrackLayerSetting *setting;

// Options
@property (nonatomic) CGFloat startAngle;
@property (nonatomic) UIColor *barColor;
@property (nonatomic) UIColor *trackingColor;
@property (nonatomic) UIColor *thumbColor;
@property (nonatomic) CGFloat barWidth;
@property (nonatomic) CGFloat maxValue;
@property (nonatomic) CGFloat minValue;
@property (nonatomic) BOOL sliderEnabled;
@property (nonatomic) CGFloat viewInset;
@property (nonatomic) CGFloat minMaxSwitchTreshold; // from 0.0 to 1.0
@property (nonatomic) UIImage *thumbImage;
@property (nonatomic) CGFloat thumbWidth;

@end

@implementation ORKCircleViewSlider
@synthesize thumbWidth = _thumbWidth;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = UIColor.clearColor;
}

- (instancetype)initWithFrame:(CGRect)frame options:(NSDictionary*)options {
    self = [super initWithFrame:frame];
    if (self) {
        self.startAngle = -90;
        self.barColor = UIColor.lightGrayColor;
        self.trackingColor = UIColor.blueColor;
        self.thumbColor = UIColor.blackColor;
        self.barWidth = 20;
        self.maxValue = 101;
        self.minValue = 0;
        self.sliderEnabled = true;
        self.viewInset = 20;
        self.minMaxSwitchTreshold = 0.0;
        self.thumbWidth = CGFLOAT_MAX;
        
        if (options) {
            [self buildWithOptions:options];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
            tapGesture.numberOfTouchesRequired = 1;
            [self addGestureRecognizer:tapGesture];
        }
    }
    return self;
}

- (void)setValue:(CGFloat)newValue {
    CGFloat value = newValue;
    CGFloat significantChange = (self.maxValue - self.minValue) * (1.0 - self.minMaxSwitchTreshold);
    BOOL isSignificantChangeOccured = fabs(newValue - self.value) > significantChange;
    if (isSignificantChangeOccured) {
        if (self.value < value) {
            newValue = self.minValue;
        } else {
            newValue = self.maxValue;
        }
    } else {
        value = newValue;
    }
    
    _value = value;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    double degree = [ORKCircleViewMath degreeFromValueWithStartAngle:self.startAngle value:self.value maxValue:self.maxValue minValue:self.minValue];
    // fix rendering issue near max value
    // substract 1/100 of one degree from the current degree to fix a very little overflow
    // which otherwise cause to display a layer as it is on a min value
    if (self.value == self.maxValue) {
        degree -= degree / (360 * 100);
    }
    [self layoutWithDegree:degree];
}

- (void)setTrackLayer:(ORKCircleViewTrackLayer *)trackLayer {
    _trackLayer = trackLayer;
    
    [self.layer addSublayer:_trackLayer];
}

- (void)setThumbView:(UIView *)thumbView {
    _thumbView = thumbView;
    
    if (self.sliderEnabled) {
        _thumbView.backgroundColor = self.thumbColor;
        _thumbView.center = [self thumbCenterFromDegree:self.startAngle];
        _thumbView.layer.cornerRadius = _thumbView.bounds.size.width * 0.5;
        [self addSubview:_thumbView];
        
        if (self.thumbImage) {
            UIImageView *thumbImageView = [[UIImageView alloc] initWithFrame:_thumbView.bounds];
            thumbImageView.image = self.thumbImage;
            [_thumbView addSubview:thumbImageView];
            _thumbView.backgroundColor = UIColor.clearColor;
        }
    } else {
        [_thumbView setHidden:YES];
    }
}

- (CGFloat)thumbWidth {
    if (_thumbWidth != CGFLOAT_MAX) {
        return _thumbWidth;
    }
    return self.thumbImage.size.height;
}

- (ORKCircleViewTrackLayerSetting *)setting {
    return [[ORKCircleViewTrackLayerSetting alloc] initWithStartAngle:self.startAngle
                                                             barWidth:self.barWidth
                                                             barColor:self.barColor
                                                        trackingColor:self.trackingColor];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if (self.trackLayer == nil) {
        self.trackLayer = [[ORKCircleViewTrackLayer alloc] initWithBounds:CGRectInset(self.bounds, self.viewInset, self.viewInset) setting:self.setting];
    }
    if (self.thumbView == nil) {
        if (self.thumbImage) {
            self.thumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.thumbImage.size.width, self.thumbImage.size.height)];
        } else {
            self.thumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.thumbWidth, self.thumbWidth)];
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self.sliderEnabled ? self : nil;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    UIView *superView = self.superview;
    while (superView) {
        if ([superView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)superView;
            [scrollView setScrollEnabled:NO];
            break;
        }
        superView = superView.superview;
    }
    return YES;
}

- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event {
    UIView *superView = self.superview;
    while (superView) {
        if ([superView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)superView;
            [scrollView setScrollEnabled:YES];
            break;
        }
        superView = superView.superview;
    }
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGFloat degree = [ORKCircleViewMath pointPairToBearingDegreesWithStartPoint:self.center endPoint:[touch locationInView:self]];
    self.latestDegree = degree;
    [self layoutWithDegree:degree];
    CGFloat value = [ORKCircleViewMath adjustValueWithStartAngle:self.startAngle degree:degree maxValue:self.maxValue minValue:self.minValue];
    self.value = value;
    return YES;
}

- (void)tapHandle:(UIGestureRecognizer *)gesture {
    if (self.isUserInteractionEnabled) {
        CGFloat degree = [ORKCircleViewMath pointPairToBearingDegreesWithStartPoint:self.center endPoint:[gesture locationInView:self]];
        self.latestDegree = degree;
        [self layoutWithDegree:degree];
        CGFloat value = [ORKCircleViewMath adjustValueWithStartAngle:self.startAngle degree:degree maxValue:self.maxValue minValue:self.minValue];
        self.thumbView.transform = CGAffineTransformMakeRotation([ORKCircleViewMath degreesToRadiansWithAngle:degree]);
        self.value = value;
    }
}

- (void)changeOptions:(NSDictionary *)options {
    [self buildWithOptions:options];
    [self updateUI];
}

- (void)updateUI {
    if (self.trackLayer != nil) {
        [self.trackLayer removeFromSuperlayer];
    }
    self.trackLayer = [[ORKCircleViewTrackLayer alloc] initWithBounds:CGRectInset(self.bounds, self.viewInset, self.viewInset) setting:self.setting];
    
    if (self.thumbView) {
        [self.thumbView removeFromSuperview];
    }
    
    if (self.thumbImage) {
        self.thumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.thumbImage.size.width, self.thumbImage.size.height)];
    } else {
        self.thumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.thumbWidth, self.thumbWidth)];
    }
    
    [self layoutWithDegree:self.latestDegree];
}

- (void)buildWithOptions:(NSDictionary *)options {
    if ([options objectForKey:ORKCircleViewSliderStartAngleKey]) {
        self.startAngle = [options[ORKCircleViewSliderStartAngleKey] doubleValue];
        self.latestDegree = self.startAngle;
    }
    if ([options objectForKey:ORKCircleViewSliderBarColorKey]) {
        self.barColor = [NSKeyedUnarchiver unarchiveObjectWithData:options[ORKCircleViewSliderBarColorKey]];
    }
    if ([options objectForKey:ORKCircleViewSliderTrackingColorKey]) {
        self.trackingColor = [NSKeyedUnarchiver unarchiveObjectWithData:options[ORKCircleViewSliderTrackingColorKey]];
    }
    if ([options objectForKey:ORKCircleViewSliderThumbColorKey]) {
        self.thumbColor = [NSKeyedUnarchiver unarchiveObjectWithData:options[ORKCircleViewSliderThumbColorKey]];
    }
    if ([options objectForKey:ORKCircleViewSliderThumbImageKey]) {
        self.thumbImage = options[ORKCircleViewSliderThumbImageKey];
    }
    if ([options objectForKey:ORKCircleViewSliderBarWidthKey]) {
        self.barWidth = [options[ORKCircleViewSliderBarWidthKey] doubleValue];
    }
    if ([options objectForKey:ORKCircleViewSliderThumbWidthKey]) {
        self.thumbWidth = [options[ORKCircleViewSliderThumbWidthKey] doubleValue];
    }
    if ([options objectForKey:ORKCircleViewSliderMaxValueKey]) {
        self.maxValue = [options[ORKCircleViewSliderMaxValueKey] doubleValue];
        // Adjust because value not rise up to the maxValue
        self.maxValue += 1;
    }
    if ([options objectForKey:ORKCircleViewSliderMinValueKey]) {
        self.minValue = [options[ORKCircleViewSliderMinValueKey] doubleValue];
        self.value = self.minValue;
    }
    if ([options objectForKey:ORKCircleViewSliderSliderEnabledKey]) {
        self.sliderEnabled = [options[ORKCircleViewSliderSliderEnabledKey] boolValue];
    }
    if ([options objectForKey:ORKCircleViewSliderViewInsetKey]) {
        self.viewInset = [options[ORKCircleViewSliderViewInsetKey] doubleValue];
    }
    if ([options objectForKey:ORKCircleViewSliderMinMaxSwitchTresholdKey]) {
        self.minMaxSwitchTreshold = [options[ORKCircleViewSliderMinMaxSwitchTresholdKey] doubleValue];
    }
}

- (void)layoutWithDegree:(CGFloat)degree {
    if (self.trackLayer && self.thumbView) {
        self.trackLayer.degree = degree;
        self.thumbView.center = [self thumbCenterFromDegree:degree];
        self.thumbView.transform = CGAffineTransformMakeRotation([ORKCircleViewMath degreesToRadiansWithAngle:degree]);
        [self.trackLayer setNeedsDisplay];
    }
}

- (CGPoint)thumbCenterFromDegree:(CGFloat)degree {
    CGFloat radius = (CGRectInset(self.bounds, self.thumbView.bounds.size.width / 2, self.thumbView.bounds.size.width / 2).size.width * 0.5) - (self.barWidth * 0.5) + 5;
    return [ORKCircleViewMath pointFromAngle:degree frame:self.frame radius:radius];
}

@end
