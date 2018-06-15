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

@import UIKit;

#import "ORKVerticalContainerView.h"
#import "ORKMultiInstructionStepViewController.h"
#import "ORKMultiInstructionStep.h"
#import "ORKInstructionStepViewController_Internal.h"
#import "ORKInstructionStep.h"
#import "ORKInstructionStepView.h"
#import "ORKTintedImageView.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKSkin.h"
#import "ORKStep.h"
#import "ORKStep_Private.h"

@class ORKInstructionStepView;

@implementation ORKMultiInstructionStepViewController {
    NSArray *_instructionViews;
    UIView *_viewsContainer;
    NSArray<NSLayoutConstraint *> *_constraints;
}

- (ORKMultiInstructionStep *)instructionStep {
    return (ORKMultiInstructionStep *)self.step;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    if (!self.step || ![self isViewLoaded]) {
        return;
    }
    
    if (_instructionViews != nil) {
        for (int i = 0; i < _instructionViews.count; i++) {
            UIView *_view = _instructionViews[i];
            [_view removeFromSuperview];
        }
    }
    
    if (_viewsContainer == nil) {
        _viewsContainer = [UIView new];
        _viewsContainer.translatesAutoresizingMaskIntoConstraints = NO;
        
        // layout margin
        CGFloat margin = ORKStandardHorizontalMarginForView(_viewsContainer);
        UIEdgeInsets layoutMargins = (UIEdgeInsets){.left = margin, .right = margin};
        _viewsContainer.layoutMargins = layoutMargins;
    } else {
        for (UIView *_view in _viewsContainer.subviews) {
            [_view removeFromSuperview];
        }
    }
    
    NSMutableArray *instructionViews = [NSMutableArray new];
    
    // add instruction step image
    if (self.instructionStep.image != nil) {
        UIView *instructionImageView = [self createImageViewWithAuxiliaryImage:self.instructionStep.image shouldApplyTint:self.instructionStep.shouldTintImages auxiliaryImage:self.instructionStep.auxiliaryImage];
        [_viewsContainer addSubview:instructionImageView];
        [instructionViews addObject:instructionImageView];
    }
    
    // add instruction items
    for (int i = 0; i < self.instructionStep.items.count; i++) {
        ORKMultiInstructionStepItem *instructionItem = self.instructionStep.items[i];
        UIView *instructionItemView = [self createViewForInstructionItem:instructionItem];
        [_viewsContainer addSubview:instructionItemView];
        [instructionViews addObject:instructionItemView];
    }
    
    _instructionViews = [instructionViews copy];
    
    self.stepView.stepView = _viewsContainer;
    
    [self setupContainerConstraints];
    
    // flash scroll indicators
    __weak ORKMultiInstructionStepViewController *wself = self;
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [wself.stepView flashScrollIndicators];
    });
}

- (void)setupContainerConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
        _constraints = nil;
    }
    
    NSMutableArray *tempConstraints = [NSMutableArray new];
    
    // views container
    
    [tempConstraints addObject:[NSLayoutConstraint constraintWithItem:_viewsContainer
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view.safeAreaLayoutGuide
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:0.0]];
    [tempConstraints addObject:[NSLayoutConstraint constraintWithItem:_viewsContainer
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view.safeAreaLayoutGuide
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:0.0]];
    
    // instruction views
    
    NSMutableDictionary *metrics = [@{@"viewHeight": @200,
                                      @"viewSpacing": @50,
                                      @"topSpacing": @8,
                                      @"bottomSpacing": @80
                                      } mutableCopy];
    
    if (self.instructionStep.metrics != nil) {
        for (id key in self.instructionStep.metrics.allKeys) {
            metrics[key] = self.instructionStep.metrics[key];
        }
    }
    
    NSString *prevViewKey = nil;
    
    NSMutableDictionary *_viewsDictionary = [NSMutableDictionary new];
    
    for (int i = 0; i < _instructionViews.count; i++) {
        UIView *instructionView = _instructionViews[i];
        NSString *instructionViewKey = [self viewIdentifierForIndex:i];
        instructionView.accessibilityIdentifier = instructionViewKey;
        _viewsDictionary[instructionViewKey] = instructionView;
        instructionView.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (i == 0) {
            // first view
            // constraint to top
            NSString *visualFormat = [NSString stringWithFormat:@"V:|-topSpacing-[%@]", instructionViewKey];
            [tempConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                                         options:0
                                                                                         metrics:metrics
                                                                                           views:_viewsDictionary]];
        } else {
            // constraint to prev
            NSString *visualFormat = [NSString stringWithFormat:@"V:[%@]-viewSpacing-[%@]", prevViewKey, instructionViewKey];
            [tempConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                                         options:0
                                                                                         metrics:metrics
                                                                                           views:_viewsDictionary]];
        }
        
        {
            // constraint to left and right
            NSString *visualFormat = [NSString stringWithFormat:@"H:|-[%@]-|", instructionViewKey];
            [tempConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                                         options:0
                                                                                         metrics:metrics
                                                                                           views:_viewsDictionary]];
        }
        {
            // height
            NSString *visualFormat = [NSString stringWithFormat:@"V:[%@(viewHeight@249)]", instructionViewKey];
            [tempConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                                         options:0
                                                                                         metrics:metrics
                                                                                           views:_viewsDictionary]];
        }
        if (i + 1 == _instructionViews.count) {
            // last view
            // constraint to bottom
            NSString *visualFormat = [NSString stringWithFormat:@"V:[%@]-bottomSpacing-|", instructionViewKey];
            [tempConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                                         options:0
                                                                                         metrics:metrics
                                                                                           views:_viewsDictionary]];
        }
        
        prevViewKey = instructionViewKey;
    }
    
    _constraints = [tempConstraints copy];
    
    [NSLayoutConstraint activateConstraints:_constraints];
    
    [self.view setNeedsUpdateConstraints];
}

- (UIView *)createViewForInstructionItem:(ORKMultiInstructionStepItem *)instructionItem {
    if ([instructionItem isKindOfClass:[ORKMultiInstructionStepItemImage class]]) {
        ORKMultiInstructionStepItemImage * imageInstruction = (ORKMultiInstructionStepItemImage *)instructionItem;
        return [self createImageViewWithAuxiliaryImage:imageInstruction.value shouldApplyTint:imageInstruction.shouldTintImage auxiliaryImage:imageInstruction.auxiliaryImage];
    }
    
    if ([instructionItem isKindOfClass:[ORKMultiInstructionStepItemText class]]) {
        ORKMultiInstructionStepItemText * textInstruction = (ORKMultiInstructionStepItemText *)instructionItem;
        NSMutableAttributedString *attributedInstruction = [[NSMutableAttributedString alloc] init];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setParagraphSpacingBefore:self.stepView.headerView.instructionLabel.font.lineHeight * 0.5];
        [style setAlignment:NSTextAlignmentLeft];
        
        NSAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:textInstruction.value
                                                                               attributes:@{NSParagraphStyleAttributeName: style}];
        [attributedInstruction appendAttributedString:attString];
        ORKSubheadlineLabel *labelView = [ORKSubheadlineLabel new];
        labelView.attributedText = attributedInstruction;
        labelView.numberOfLines = 0;
        [labelView sizeToFit];
        return labelView;
    }
    
    NSLog(@"instructionItem of %@ is invalid", NSStringFromClass([instructionItem class]));
    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSString *)viewIdentifierForIndex:(int)index {
    return [NSString stringWithFormat:@"view%d", index];
}

- (UIView *)createImageViewWithAuxiliaryImage:(UIImage *)image shouldApplyTint:(BOOL)shouldApplyTint auxiliaryImage:(UIImage * _Nullable)auxiliaryImage {
    
    // create image view
    ORKTintedImageView *imageView = [ORKTintedImageView new];
    imageView.image = image;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.shouldApplyTint = shouldApplyTint;
    
    if (auxiliaryImage == nil) {
        return imageView;
    }
    
    // create container
    UIView *containerView = [UIView new];
    
    [containerView addSubview:imageView];
    
    // create auxiliary image view
    ORKTintedImageView *auxiliaryImageView = [ORKTintedImageView new];
    auxiliaryImageView.image = auxiliaryImage;
    auxiliaryImageView.translatesAutoresizingMaskIntoConstraints = NO;
    auxiliaryImageView.contentMode = UIViewContentModeScaleAspectFit;
    auxiliaryImageView.tintColor = ORKColor(ORKAuxiliaryImageTintColorKey);
    auxiliaryImageView.shouldApplyTint = shouldApplyTint;
    
    // add views into container
    [containerView addSubview:auxiliaryImageView];
    
    // setup views constraints
    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:containerView
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:image.size.height / image.size.width
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:300.0]];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(imageView, auxiliaryImageView);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[auxiliaryImageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[auxiliaryImageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    return containerView;
}

@end
