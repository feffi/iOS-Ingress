//
//  GUIButton.h
//  Ingress
//
//  Created by Alex Studnicka on 01.02.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GUIButton : UIButton

@property (nonatomic) BOOL disabled;
@property (nonatomic, assign) NSString *errorString;

@end
