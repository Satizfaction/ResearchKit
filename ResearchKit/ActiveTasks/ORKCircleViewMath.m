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

#import "ORKCircleViewMath.h"

@implementation ORKCircleViewMath

+ (CGFloat)degreesToRadiansWithAngle:(CGFloat)angle {
    return angle / 180 * M_PI;
}

+ (CGPoint)pointFromAngle:(CGFloat)angle
                    frame:(CGRect)frame
                   radius:(CGFloat)radius {
    CGFloat radian = [self degreesToRadiansWithAngle:angle];
    CGFloat x = CGRectGetMidX(frame) + cos(radian) * radius;
    CGFloat y = CGRectGetMidY(frame) + sin(radian) * radius;
    return CGPointMake(x, y);
}

+ (CGFloat)pointPairToBearingDegreesWithStartPoint:(CGPoint)startPoint
                                          endPoint:(CGPoint)endPoint {
    CGPoint originPoint = CGPointMake(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    CGFloat bearingRadians = atan2(originPoint.y, originPoint.x);
    CGFloat bearingDegrees = bearingRadians * (180.0 / M_PI);
    bearingDegrees = bearingDegrees > 0.0 ? bearingDegrees : 360.0 + bearingDegrees;
    return bearingDegrees;
}

+ (CGFloat)adjustValueWithStartAngle:(CGFloat)startAngle
                              degree:(CGFloat)degree
                            maxValue:(CGFloat)maxValue
                            minValue:(CGFloat)minValue {
    CGFloat ratio = (maxValue - minValue) / 360.0;
    CGFloat ratioStart = ratio * startAngle;
    CGFloat ratioDegree = ratio * degree;
    CGFloat adjustValue;
    if (startAngle < 0.0) {
        adjustValue = (360.0 + startAngle) > degree ? (ratioDegree - ratioStart) : (ratioDegree - ratioStart) - (360.0 * ratio);
    } else {
        adjustValue = (360.0 - (360.0 - startAngle)) < degree ? (ratioDegree - ratioStart) : (ratioDegree - ratioStart) + (360.0 * ratio);
    }
    return adjustValue + minValue;
}

+ (CGFloat)adjustDegreeWithStartAngle:(CGFloat)startAngle
                               degree:(CGFloat)degree {
    return (360.0 + startAngle) > degree ? degree : -(360.0 - degree);
}

+ (CGFloat)degreeFromValueWithStartAngle:(CGFloat)startAngle
                                   value:(CGFloat)value
                                maxValue:(CGFloat)maxValue
                                minValue:(CGFloat)minValue {
    CGFloat ratio = (maxValue - minValue) / 360.0;
    CGFloat angle = value / ratio;
    return angle + startAngle - (minValue / ratio);
}

@end
