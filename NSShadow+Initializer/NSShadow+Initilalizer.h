//
//  NSShadow+Initilalizer.h
//  Ingress
//
//  Created by Alex Studnička on 06.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSShadow (Initilalizer)

+ (NSShadow *)shadowWithOffset:(CGSize)offset blurRadius:(CGFloat)blurRadius color:(id)color;

@end
