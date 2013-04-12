//
//  Resonator.m
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "Resonator.h"


@implementation Resonator

@dynamic level;

- (NSString *)description {
	return [NSString stringWithFormat:@"L%d Resonator", self.level];
}

@end
