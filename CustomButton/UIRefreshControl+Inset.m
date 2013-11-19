//
//  UIRefreshControl+Inset.m
//  Ingress
//
//  Created by Alex Studnička on 21.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "UIRefreshControl+Inset.h"

@implementation UIRefreshControl (Inset)

- (void)layoutSubviews {
    [super layoutSubviews];
	
	CGRect rect = self.frame;
	rect.origin.y = -44;
	self.frame = rect;
}

@end
