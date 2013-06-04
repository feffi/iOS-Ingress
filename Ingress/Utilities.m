//
//  Utilities.m
//  Ingress
//
//  Created by Alex Studnička on 04.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (NSDictionary *)attributesWithShadow:(BOOL)shadow size:(CGFloat)size color:(UIColor *)color {

	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];

	attributes[NSFontAttributeName] = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:size];
	attributes[NSForegroundColorAttributeName] = color;

	if (shadow) {
		NSShadow *shadowObj = [NSShadow new];
		shadowObj.shadowOffset = CGSizeZero;
		shadowObj.shadowBlurRadius = size/5;
		shadowObj.shadowColor = color;
		attributes[NSShadowAttributeName] = shadowObj;
	}

	return attributes;

}

@end
