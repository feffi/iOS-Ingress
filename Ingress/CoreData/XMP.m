//
//  XMP.m
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "XMP.h"


@implementation XMP

@dynamic level;

- (NSString *)description {
	return [NSString stringWithFormat:@"L%d XMP Burster", self.level];
}

@end
