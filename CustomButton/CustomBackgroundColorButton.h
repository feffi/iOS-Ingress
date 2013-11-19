//
//  CustomBackgroundColorButton.h
//  Ingress
//
//  Created by Alex Studnička on 20.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBackgroundColorButton : UIButton

@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *highlightedColor;
@property (nonatomic, strong) UIColor *disabledColor;

@end
