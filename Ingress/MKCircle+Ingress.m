//
//  MKCircle+DeployedResonator.m
//  Ingress
//
//  Created by Alex Studnicka on 27.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <objc/runtime.h>
#import "MKCircle+Ingress.h"

static char DEPLOYED_RESONATOR_KEY;
static char ENERGY_GLOB_KEY;

@implementation MKCircle (Ingress)

- (void)setDeployedResonator:(DeployedResonator *)deployedResonator {
    objc_setAssociatedObject(self, &DEPLOYED_RESONATOR_KEY, deployedResonator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DeployedResonator *)deployedResonator {
    return (DeployedResonator *)objc_getAssociatedObject(self, &DEPLOYED_RESONATOR_KEY);
}

- (void)setEnergyGlob:(EnergyGlob *)energyGlob {
    objc_setAssociatedObject(self, &ENERGY_GLOB_KEY, energyGlob, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (EnergyGlob *)energyGlob {
    return (EnergyGlob *)objc_getAssociatedObject(self, &ENERGY_GLOB_KEY);
}

@end
