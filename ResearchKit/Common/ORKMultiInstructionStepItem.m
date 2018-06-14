//
//  ORKMultiInstructionStepItem.m
//  ResearchKit
//
//  Created by Eugene Kallaur on 6/13/18.
//  Copyright © 2018 researchkit.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORKMultiInstructionStepItem.h"


@implementation ORKMultiInstructionStepItem {
}
   
@end


@implementation ORKMultiInstructionStepItemText {
}

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        self.value = text;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.value, castObject.value));
}

- (NSUInteger)hash {
    return _value.hash;
}

@end


@implementation ORKMultiInstructionStepItemImage {
}

- (instancetype)initWithImage:(UIImage *)image shouldTintImage:(BOOL)shouldTintImage auxiliaryImage:(UIImage * _Nullable)auxiliaryImage {
    self = [super init];
    if (self) {
        self.value = image;
        self.shouldTintImage = shouldTintImage;
        self.auxiliaryImage = auxiliaryImage;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.value, castObject.value)
            && ORKEqualObjects(self.auxiliaryImage, castObject.auxiliaryImage)
            && self.shouldTintImage == castObject.shouldTintImage);
}

- (NSUInteger)hash {
    return _value.hash ^ _auxiliaryImage.hash ^ (_shouldTintImage ? 0xf : 0x0);
}

@end
