//
//  FlipCard.m
//  Ingress
//
//  Created by Alex Studnička on 22.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "FlipCard.h"


@implementation FlipCard

@dynamic type;

- (NSString *)description {
	if ([self.type isEqualToString:@"ADA"]) {
		return @"ADA Refactor";
	} else if ([self.type isEqualToString:@"JARVIS"]) {
		return @"Jarvis Virus";
	}
	return [super description];
}

@end
