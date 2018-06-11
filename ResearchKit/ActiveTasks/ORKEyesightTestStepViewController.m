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


#import "ORKActiveStepTimer.h"
#import "ORKActiveStepView.h"
#import "ORKStepViewController_Internal.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKNavigationContainerView.h"
#import "ORKStep_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKResult_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKBorderedButton.h"
#import "ORKEyesightTestStepViewController.h"
#import "ORKEyesightTestContentView.h"
#import "ORKEyesightTestStep.h"
#import "ORKEyesightTestResult.h"

@interface ORKEyesightTestStepViewController () {
    ORKEyesightTestContentView *_visualAcuityView;
}

@end

@implementation ORKEyesightTestStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = YES;
    }
    return self;
}

- (ORKEyesightTestStep *)eyesightTestStep {
    return (ORKEyesightTestStep *)self.step;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _visualAcuityView = [ORKEyesightTestContentView new];
    _visualAcuityView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activeStepView.activeCustomView = _visualAcuityView;
    self.activeStepView.stepViewFillsAvailableSpace = YES;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapRecognizer addTarget:self action:@selector(stopTest:)];
    [_visualAcuityView addGestureRecognizer:tapRecognizer];
    
    // Turn the dial to where the gap in the ring was.
    // ORKLocalizedString(@"EYESIGHT_TEST_ACUITY_TASK_SLIDER_INFO_TEXT", nil)
    
    [self setupContraints];
}

- (void)stopTest:(id)button {
    [self finish];
}

- (void)setupContraints {
    NSArray *constraints = @[
                             
                             [NSLayoutConstraint constraintWithItem:_visualAcuityView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:self.view.bounds.size.width],
                             [NSLayoutConstraint constraintWithItem:_visualAcuityView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:self.view.bounds.size.height],
                             [NSLayoutConstraint constraintWithItem:_visualAcuityView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0],
                             [NSLayoutConstraint constraintWithItem:_visualAcuityView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]
                             ];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait + UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (ORKStepResult *)result {
    
    ORKStepResult *parentResult = [super result];
    
    // TODO: populate result
    ORKEyesightTestResult *eyesightTestResult = [[ORKEyesightTestResult alloc] init];
    eyesightTestResult.identifier = self.eyesightTestStep.identifier;
    eyesightTestResult.mode = [self eyesightTestStep].mode;
    eyesightTestResult.eye = [self eyesightTestStep].eye;
    parentResult.results = @[eyesightTestResult];
    
    return parentResult;
}

@end
