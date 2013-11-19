//
//  NSShadow+Initilalizer.m
//  Ingress
//
//  Created by Alex Studnička on 06.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "NSShadow+Initilalizer.h"

@implementation NSShadow (Initilalizer)

+ (NSShadow *)shadowWithOffset:(CGSize)offset blurRadius:(CGFloat)blurRadius color:(id)color {
	NSShadow *shadow = [NSShadow new];
	shadow.shadowOffset = offset;
	shadow.shadowBlurRadius = blurRadius;
	shadow.shadowColor = color;
	return shadow;
}

@end
