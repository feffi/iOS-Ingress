//
//  SelectingButton.m
//  Ingress
//
//  Created by Alex Studnička on 25.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "SelectingButton.h"

@implementation SelectingButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

		[self addTarget:self action:@selector(selectToggle) forControlEvents:UIControlEventTouchUpInside];
		
    }
    return self;
}

- (void)selectToggle {
	self.selected = !self.selected;
}

@end
