//
//  MKPolyline+PortalLink.m
//  Ingress
//
//  Created by Alex Studnicka on 25.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <objc/runtime.h>
#import "MKPolyline+PortalLink.h"

static char PORTAL_LINK_KEY;

@implementation MKPolyline (PortalLink)

- (void)setPortalLink:(PortalLink *)portalLink {
    objc_setAssociatedObject(self, &PORTAL_LINK_KEY, portalLink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PortalLink *)portalLink {
    return (PortalLink *)objc_getAssociatedObject(self, &PORTAL_LINK_KEY);
}

@end
