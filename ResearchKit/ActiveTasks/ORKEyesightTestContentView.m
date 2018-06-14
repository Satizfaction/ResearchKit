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

#import "ORKEyesightTestContentView.h"

#import "ORKActiveStepQuantityView.h"

#import "ORKSkin.h"

@implementation ORKEyesightTestContentView {
    UIView *_continueView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _sliderView = [ORKCircleViewEyeActivitySliderView new];
        _sliderView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_sliderView];
        
        _continueView = [UIView new];
        _continueView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_continueView];
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setButtonItem:(ORKBorderedButton *)buttonItem {
    _buttonItem = buttonItem;
    if (buttonItem) {
        buttonItem.contentEdgeInsets = (UIEdgeInsets){.top = 15, .bottom = 15, .left = 35, .right = 35};
        buttonItem.translatesAutoresizingMaskIntoConstraints = NO;
        [_continueView addSubview:buttonItem];
        [[NSLayoutConstraint constraintWithItem:_buttonItem
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_continueView
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0
                                       constant:0.0] setActive:YES];
        [[NSLayoutConstraint constraintWithItem:_buttonItem
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:_continueView
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0
                                       constant:0.0] setActive:YES];
    }
    else {
        [_buttonItem removeFromSuperview];
    }
    
    _continueView.hidden = (buttonItem == nil);
}


- (void)updateMargins {
    CGFloat margin = ORKStandardHorizontalMarginForView(self);
    self.layoutMargins = (UIEdgeInsets){.left = margin, .right = margin};
    _continueView.layoutMargins = self.layoutMargins;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateMargins];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateMargins];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_sliderView, _continueView);
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_sliderView]-(>=0)-[_continueView(50)]-(20)-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    NSLayoutConstraint *sliderViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_sliderView
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1.0
                                                                                 constant:ORKScreenMetricMaxDimension];
    sliderViewHeightConstraint.priority = UILayoutPriorityDefaultLow - 1;
    [constraints addObject:sliderViewHeightConstraint];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_sliderView]-|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_continueView]|"
                                                                             options:(NSLayoutFormatOptions)0
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_sliderView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_sliderView
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    NSLayoutConstraint *maxWidthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.0
                                                                           constant:ORKScreenMetricMaxDimension];
    maxWidthConstraint.priority = UILayoutPriorityRequired - 1;
    [constraints addObject:maxWidthConstraint];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end
