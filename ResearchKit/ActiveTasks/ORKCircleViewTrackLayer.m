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

#import "ORKCircleViewTrackLayer.h"
#import "ORKCircleViewMath.h"

@interface ORKCircleViewTrackLayerSetting ()

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat barWidth;
@property (nonatomic) UIColor *barColor;
@property (nonatomic) UIColor *trackingColor;

@end

@implementation ORKCircleViewTrackLayerSetting

- (instancetype)initWithStartAngle:(CGFloat)startAngle barWidth:(CGFloat)barWidth barColor:(UIColor *)barColor trackingColor:(UIColor *)trackingColor {
    self = [super init];
    if (self) {
        self.startAngle = startAngle;
        self.barWidth = barWidth;
        self.barColor = barColor;
        self.trackingColor = trackingColor;
    }
    return self;
}

@end


@interface ORKCircleViewTrackLayer ()

@property (nonatomic) ORKCircleViewTrackLayerSetting *setting;
@property (nonatomic, readonly) CGFloat hollowRadius;
@property (nonatomic, readonly) CGPoint currentCenter;
@property (nonatomic, readonly) CGRect hollowRect;

@end

@implementation ORKCircleViewTrackLayer

- (instancetype)initWithBounds:(CGRect)bounds setting:(ORKCircleViewTrackLayerSetting *)setting {
    self = [super init];
    if (self) {
        self.bounds = bounds;
        self.setting = setting;
        self.degree = 0;
        self.cornerRadius = self.bounds.size.width * 0.5;
        self.masksToBounds = YES;
        self.position = self.currentCenter;
        self.backgroundColor = self.setting.barColor.CGColor;
        [self updateMask];
    }
    return self;
}

- (CGFloat)hollowRadius {
    return (self.bounds.size.width * 0.5) - self.setting.barWidth;
}

- (CGPoint)currentCenter {
    return CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (CGRect)hollowRect {
    return CGRectMake(self.currentCenter.x - self.hollowRadius,
                      self.currentCenter.y - self.hollowRadius,
                      self.hollowRadius * 2.0,
                      self.hollowRadius * 2.0);
}

- (void)drawInContext:(CGContextRef)ctx {
    [self drawTrackInContext:ctx];
}

- (void)updateMask {
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.bounds = self.bounds;
    CGRect ovalRect = self.hollowRect;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
    [path appendPath:[UIBezierPath bezierPathWithRect:maskLayer.bounds]];
    maskLayer.path = path.CGPath;
    maskLayer.position = self.currentCenter;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    [self setMask:maskLayer];
}

- (void)drawTrackInContext:(CGContextRef)ctx {
    CGFloat adjustDegree = [ORKCircleViewMath adjustDegreeWithStartAngle:self.setting.startAngle degree:self.degree];
    CGFloat centerX = self.currentCenter.x;
    CGFloat centerY = self.currentCenter.y;
    CGFloat radius = MIN(centerX, centerY);
    CGContextSetFillColorWithColor(ctx, self.setting.trackingColor.CGColor);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, centerX, centerY);
    CGContextAddArc(ctx,
                    centerX,
                    centerY,
                    radius,
                    [ORKCircleViewMath degreesToRadiansWithAngle:self.setting.startAngle],
                    [ORKCircleViewMath degreesToRadiansWithAngle:adjustDegree],
                    NO);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

@end
