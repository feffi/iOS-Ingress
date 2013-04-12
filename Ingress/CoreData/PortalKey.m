//
//  PortalKey.m
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalKey.h"
#import "Portal.h"


@implementation PortalKey

@dynamic portal;

- (NSString *)description {
	return @"Portal Key";
}

- (NSString *)subtitle {
	if (self.portal.subtitle) {
		return self.portal.subtitle;
	}
	return nil;
}

@end
