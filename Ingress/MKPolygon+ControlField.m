//
//  MKPolygon+ControlField.m
//  Ingress
//
//  Created by Alex Studnicka on 25.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <objc/runtime.h>
#import "MKPolygon+ControlField.h"

static char CONTROL_FIELD_KEY;

@implementation MKPolygon (ControlField)

- (void)setControlField:(ControlField *)controlField {
    objc_setAssociatedObject(self, &CONTROL_FIELD_KEY, controlField, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ControlField *)controlField {
    return (ControlField *)objc_getAssociatedObject(self, &CONTROL_FIELD_KEY);
}

@end
