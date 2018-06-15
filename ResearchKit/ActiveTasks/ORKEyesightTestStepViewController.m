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
#import "ORKEyesightTestLetterCalc.h"

NSInteger countOfAttempts = 2;

@interface ORKEyesightTestStepViewController () <UIGestureRecognizerDelegate>
@end

@implementation ORKEyesightTestStepViewController {
    ORKEyesightTestContentView *_visualAcuityView;
    
    NSInteger score;
    NSInteger attempts;
    NSInteger currentStep;
    dispatch_block_t dispatchBlock;
}

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
    
    NSString *title = [self eyesightTestStep].eye == ORKEyesightTestEyeRight ? ORKLocalizedString(@"EYESIGHT_TEST_ACUITY_TASK_SLIDER_RIGHT_EYE", nil) : ORKLocalizedString(@"EYESIGHT_TEST_ACUITY_TASK_SLIDER_LEFT_EYE", nil);
    NSString *message = ORKLocalizedString(@"EYESIGHT_TEST_ACUITY_TASK_SLIDER_INFO_TEXT", nil);
    [self.activeStepView updateTitle:title text:message];
    
    if ([self eyesightTestStep].mode == ORKEyesightTestModeContrastAcuity) {
        _visualAcuityView.sliderView.letterSize = [ORKEyesightTestLetterCalc getSizeForContrastAcuity];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [_visualAcuityView.sliderView addGestureRecognizer:tapGesture];
    
    currentStep = 0;
    attempts = 1;
    score = 0;
    
    _visualAcuityView.buttonItem = [ORKBorderedButton new];
    [_visualAcuityView.buttonItem setTitle:ORKLocalizedString(@"BUTTON_NEXT", nil) forState:UIControlStateNormal];
    [_visualAcuityView.buttonItem addTarget:self action:@selector(goNext) forControlEvents:UIControlEventTouchUpInside];
    
    [self changeAcuity];
}

- (void)goNext {
    BOOL result = [self calculateResult];
    if (!result && attempts == countOfAttempts) {
        [self goForward];
        return;
    }
   
    if (result && attempts == countOfAttempts) {
        currentStep += 1;
        attempts = 1;
    } else {
        attempts += 1;
    }
    
    [self changeAcuity];
}

- (BOOL)calculateResult {
    BOOL correctResult = [_visualAcuityView.sliderView getResult];
    if (correctResult) {
        [self eyesightTestStep].score = [ORKEyesightTestLetterCalc getScoreForStep:currentStep];
    }
    return correctResult;
}

- (void)changeAcuity {
    ORKEyesightTestMode mode = [self eyesightTestStep].mode;
    if (currentStep >= [ORKEyesightTestLetterCalc getStepsCountForMode:mode]) {
        [self goForward];
        return;
    }
    
    switch (mode) {
        case ORKEyesightTestModeVisualAcuity:
            _visualAcuityView.sliderView.letterSize = [ORKEyesightTestLetterCalc getSizeForStep:currentStep];
            break;
        case ORKEyesightTestModeContrastAcuity:
            _visualAcuityView.sliderView.letterAlpha = [ORKEyesightTestLetterCalc getAlphaForStep:currentStep];
            break;
        default:
            break;
    }
    [self changeViewState];
}

- (void)changeViewState {
    _visualAcuityView.sliderView.state = EyeActivitySliderStateLetter;
    [_visualAcuityView.sliderView setHiddenLetterImageViewForState:EyeActivitySliderStateLetter];
    
    if (dispatchBlock != nil) {
        dispatch_block_cancel(dispatchBlock);
    }
    
    dispatchBlock = dispatch_block_create(0, ^{
        _visualAcuityView.sliderView.state = EyeActivitySliderStateActive;
        [_visualAcuityView.sliderView setHiddenLetterImageViewForState:EyeActivitySliderStateActive];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), dispatchBlock);
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
    eyesightTestResult.score = [self eyesightTestStep].score;
    parentResult.results = @[eyesightTestResult];
    
    return parentResult;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (_visualAcuityView.sliderView.state == EyeActivitySliderStateLetter) {
        _visualAcuityView.sliderView.state = EyeActivitySliderStateActive;
    }
    return true;
}

@end
