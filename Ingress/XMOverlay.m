//
//  XMOverlay.m
//  Ingress
//
//  Created by Alex Studnička on 11.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "XMOverlay.h"

@implementation XMOverlay {
	MKMapRect _boundingMapRect;
}

@synthesize globs = _globs;

- (id)initWithGlobs:(NSArray *)globs {
    if (self = [super init]) {
        _globs = [globs copy];

        NSUInteger polyCount = [_globs count];
        if (polyCount) {
            _boundingMapRect = [_globs[0] boundingMapRect];
            NSUInteger i;
            for (i = 1; i < polyCount; i++) {
                _boundingMapRect = MKMapRectUnion(_boundingMapRect, [_globs[i] boundingMapRect]);
            }
        }
    }
    return self;
}

- (MKMapRect)boundingMapRect {
    return _boundingMapRect;
}

- (CLLocationCoordinate2D)coordinate {
    return MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(_boundingMapRect), MKMapRectGetMidY(_boundingMapRect)));
}

@end
