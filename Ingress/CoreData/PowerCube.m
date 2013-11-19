//
//  PowerCube.m
//  Ingress
//
//  Created by Alex Studnička on 16.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PowerCube.h"


@implementation PowerCube

@dynamic level;

- (NSString *)description {
	return [NSString stringWithFormat:@"L%d Power Cube", self.level];
}

@end
