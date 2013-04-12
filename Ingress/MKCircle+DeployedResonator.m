//
//  MKCircle+DeployedResonator.m
//  Ingress
//
//  Created by Alex Studnicka on 27.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <objc/runtime.h>
#import "MKCircle+DeployedResonator.h"

static char DEPLOYED_RESONATOR_KEY;

@implementation MKCircle (DeployedResonator)

- (void)setDeployedResonator:(DeployedResonator *)deployedResonator {
    objc_setAssociatedObject(self, &DEPLOYED_RESONATOR_KEY, deployedResonator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DeployedResonator *)deployedResonator {
    return (DeployedResonator *)objc_getAssociatedObject(self, &DEPLOYED_RESONATOR_KEY);
}

@end
