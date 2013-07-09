//
//  UIControl+Blocks.m
//  Ingress
//
//  Created by Alex Studnička on 25.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "UIControl+Blocks.h"

#import <objc/runtime.h>

static char UIButtonBlockKey;

@implementation UIControl (Blocks)

- (void)handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock)block {
    objc_setAssociatedObject(self, &UIButtonBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
}


- (void)callActionBlock:(id)sender {
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, &UIButtonBlockKey);
    if (block) {
        block();
    }
}

@end
