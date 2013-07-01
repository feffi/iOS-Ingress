//
//  BorderedTextField.m
//  Ingress
//
//  Created by Alex Studnička on 01.07.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "BorderedTextField.h"

@implementation BorderedTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
	CGRect rect = [super textRectForBounds:bounds];
	return CGRectInset(rect, 4, 4);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
	CGRect rect = [super editingRectForBounds:bounds];
	return CGRectInset(rect, 4, 4);
}

@end
