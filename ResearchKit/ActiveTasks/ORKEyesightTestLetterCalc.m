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

#import "ORKEyesightTestLetterCalc.h"
#import "ORKSkin.h"

CGFloat pixelPerInchIphoneX = 458;

CGFloat pixelPerInchIphonePlus = 401;

CGFloat pixelPerInchIphone = 326;

CGFloat inchPerMm = 25.4;

@interface ORKEyesightTestScreenCalc : NSObject

@end

@implementation ORKEyesightTestScreenCalc

+ (CGFloat)pixelsPerMm {
    return [[self class] pixelsPerInch] / inchPerMm;
}

+ (CGFloat)pixelsPerInch {
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    ORKScreenType screenType = ORKGetVerticalScreenTypeForWindow(window);
    if (screenType == ORKScreenTypeiPhone6Plus) {
        return pixelPerInchIphonePlus;
    } else if (screenType == ORKScreenTypeiPhoneX) {
        return pixelPerInchIphoneX;
    } else {
        return pixelPerInchIphone;
    }
}

@end

@interface ORKEyesightTestLetterCalc ()
@end

@implementation ORKEyesightTestLetterCalc

+ (NSArray<NSNumber *> *)letterMmSizes {
    static NSArray *_letterMmSizes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _letterMmSizes = @[@5.82, @4.65, @3.72, @2.91, @2.33, @1.86, @1.45, @1.16, @0.93, @0.73, @0.58, @0.47, @0.37];
    });
    return _letterMmSizes;
}

+ (CGFloat)contrastAcuityLetterMmSize {
    return 20.0;
}

+ (NSArray<NSNumber *> *)contrastLevels {
    static NSArray *_contrastLevels;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _contrastLevels = @[@0.9, @0.92, @0.937, @0.95, @0.96, @0.968, @0.975, @0.98, @0.984, @0.9875, @0.99];
    });
    return _contrastLevels;
}

+ (NSArray<NSNumber *> *)stepsScores {
    static NSArray *_stepsCount;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _stepsCount = @[@50, @55, @60, @65, @70, @75, @80, @85, @90, @95, @100, @105, @110];
    });
    return _stepsCount;
}

+ (NSInteger)getStepsCountForMode:(ORKEyesightTestMode)mode {
    if (mode == ORKEyesightTestModeVisualAcuity) {
        return [[[self class] stepsScores] count];
    } else if (mode == ORKEyesightTestModeContrastAcuity) {
        return [[[self class] contrastLevels] count];
    }
    NSAssert(NO, @"Unknown mode");
    return 0;
}

+ (CGFloat)getSizeForStep:(NSInteger)step {
    return [[[[self class] letterMmSizes] objectAtIndex:step] doubleValue] * [ORKEyesightTestScreenCalc pixelsPerMm] / UIScreen.mainScreen.nativeScale;
}

+ (CGFloat)getSizeForContrastAcuity {
    return [[self class] contrastAcuityLetterMmSize] * [ORKEyesightTestScreenCalc pixelsPerMm] / UIScreen.mainScreen.nativeScale;
}

+ (CGFloat)getAlphaForStep:(NSInteger)step {
    return 1.0 - [[[[self class] contrastLevels] objectAtIndex:step] doubleValue];
}

+ (NSInteger)getScoreForStep:(NSInteger)step {
    return [[[[self class] stepsScores] objectAtIndex:step] integerValue];
}

@end
