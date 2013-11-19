//
//  UIControl+Blocks.h
//  Ingress
//
//  Created by Alex Studnička on 25.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ActionBlock)();

@interface UIControl (Blocks)

- (void)handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock)block;
- (void)callActionBlock:(id)sender;

@end
