//
//  ScrollTextView.h
//  Ingress
//
//  Created by Alex Studnička on 05.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollTextView : UITextView

@property (nonatomic) NSTimeInterval scrollInterval;
@property (nonatomic) BOOL glowing;

- (void)startScrolling;
- (void)stopScrolling;

@end
