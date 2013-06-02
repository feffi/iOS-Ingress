//
//  PortalKey.m
//  Ingress
//
//  Created by Alex Studnička on 30.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalKey.h"
#import "Portal.h"


@implementation PortalKey

@dynamic portalGuid;
@dynamic portal;

- (NSString *)description {
	return [NSString stringWithFormat:@"Portal Key: %@", self.portal.name];
}

@end
