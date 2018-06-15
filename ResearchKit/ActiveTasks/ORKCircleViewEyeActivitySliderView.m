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

#import "ORKCircleViewEyeActivitySliderView.h"
#import "ORKTintedImageView.h"
#import "ORKStep_Private.h"
#import "ORKCircleViewSlider.h"
#import "ORKCircleViewMath.h"

CGFloat contentGap = 20.0;
CGFloat toleranceAngle = 22.5;
CGFloat fontSize = 16.0;
CGFloat labelMargin = 30.0;

@interface ORKCircleViewEyeActivitySliderView ()

@property (nonatomic) CGFloat letterAngle;
@property (nonatomic, readonly) UIImageView *letterImageView;
@property (nonatomic) UILabel *textLabel;
@property (nonatomic) ORKCircleViewSlider *slider;

@end

@implementation ORKCircleViewEyeActivitySliderView
@synthesize letterImageView = _letterImageView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(self.bounds.size.width == self.bounds.size.height, @"width and height should have the same length");
        
        self.letterAngle = -90.f;
        self.letterSize = 60.0;
        
        [self addSubview:self.letterImageView];
        
        UIImage *thumbImage = [UIImage imageNamed:@"eyesightTestDialPointerWithShadow" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        UIImage *thumbImageTinted = [thumbImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(thumbImage.size, NO, thumbImageTinted.scale);
        [self.tintColor set];
        [thumbImageTinted drawInRect:CGRectMake(0, 0, thumbImage.size.width, thumbImageTinted.size.height)];
        thumbImageTinted = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.slider = [[ORKCircleViewSlider alloc] initWithFrame:self.bounds options:@{
                                                                                       ORKCircleViewSliderBarColorKey: [NSKeyedArchiver archivedDataWithRootObject: self.tintColor],
                                                                                       ORKCircleViewSliderBarWidthKey: @3.0,
                                                                                       ORKCircleViewSliderTrackingColorKey: [NSKeyedArchiver archivedDataWithRootObject: UIColor.clearColor],
                                                                                       ORKCircleViewSliderStartAngleKey: @0.f,
                                                                                       ORKCircleViewSliderMaxValueKey: @360.f,
                                                                                       ORKCircleViewSliderMinValueKey: @0.f,
                                                                                       ORKCircleViewSliderThumbImageKey: thumbImageTinted
                                                                                       }];
        [self addSubview:self.slider];
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        self.textLabel.text = @"";
        self.textLabel.textColor = UIColor.lightGrayColor;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self.textLabel setHidden:YES];
        self.textLabel.userInteractionEnabled = NO;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.textLabel];
    }
    return self;
}

+ (NSArray<NSNumber *> *)letterAngles {
    static NSArray *_letterAngles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _letterAngles = @[@0.f, @45.f, @90.f, @135.f, @180.f, @225.f, @270.f, @315.f];
    });
    return _letterAngles;
}

- (CGFloat)letterAlpha {
    return self.letterImageView.alpha;
}

- (void)setLetterAlpha:(CGFloat)letterAlpha {
    self.letterImageView.alpha = letterAlpha;
}

- (void)setState:(EyeActivitySliderState)state {
    _state = state;
    [self update];
}

- (UIImageView *)letterImageView {
    if (_letterImageView) {
        return _letterImageView;
    }
    _letterImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eyesightTestLetterC" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    return _letterImageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.letterImageView.transform = CGAffineTransformIdentity;
    
    self.letterImageView.frame = CGRectMake(0, 0, self.letterSize, self.letterSize);
    self.letterImageView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    self.letterImageView.transform = CGAffineTransformMakeRotation([ORKCircleViewMath degreesToRadiansWithAngle:self.letterAngle]);
    
    if (!CGRectEqualToRect(self.slider.frame, self.bounds)) {
        self.slider.frame = self.bounds;
        [self.slider setNeedsLayout];
    }

    CGRect frame = [self contentFrame];
    frame.origin.x += labelMargin;
    frame.origin.y += labelMargin;
    frame.size.width -= labelMargin * 2;
    frame.size.height -= labelMargin * 2;
    self.textLabel.frame = frame;
}

- (void)update {
    switch (self.state) {
        case EyeActivitySliderStateLetter:
        {
            NSInteger randomIndex = arc4random_uniform(7);
            self.letterAngle = [[[[self class] letterAngles] objectAtIndex:randomIndex] doubleValue];
            self.slider.value = 0;
            [self.slider setUserInteractionEnabled:NO];
            [self.textLabel setHidden:YES];
            [self setNeedsLayout];
        }
            break;
        case EyeActivitySliderStateActive:
            [self.slider setUserInteractionEnabled:YES];
            [self.textLabel setHidden:NO];
            break;
    }
}

- (void)setHiddenLetterImageViewForState:(EyeActivitySliderState)state {
    [self.letterImageView setHidden:state != EyeActivitySliderStateLetter];
}

- (CGRect)contentFrame {
    CGFloat sideLength = MIN(self.bounds.size.width, self.bounds.size.height) - contentGap;
    CGRect contentFrame = CGRectMake((self.bounds.size.width - sideLength) / 2,
                                     (self.bounds.size.height - sideLength) / 2,
                                     sideLength,
                                     sideLength);
    return contentFrame;
}

- (BOOL)getResult {
    CGFloat sliderValue = self.slider.value;
    CGFloat leftMargin = self.letterAngle - toleranceAngle;
    CGFloat rightMargin = self.letterAngle + toleranceAngle;
    
    return sliderValue > leftMargin && sliderValue < rightMargin;
}

@end
