//
//  NSAttributedStringValueTransformer.m
//  Ingress
//
//  Created by Alex Studnička on 12.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "NSAttributedStringValueTransformer.h"
#import "AttributedStringCoderHelper.h"

@implementation NSAttributedStringValueTransformer

+(void)initialize {
	[NSValueTransformer setValueTransformer:[[self alloc] init] forName:@"NSAttributedStringValueTransformer"];
}

+(BOOL)allowsReverseTransformation {
	return YES;
}

-(id)transformedValue:(NSAttributedString*)value {
	return [AttributedStringCoderHelper encodeAttributedString:value];
}

-(id)reverseTransformedValue:(NSData*)value {
	return [AttributedStringCoderHelper decodeAttributedStringFromData:value];
}

@end
