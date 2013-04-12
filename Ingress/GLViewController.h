//
//  EarthViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 27.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface GLViewController : GLKViewController {
	float _rotation;
}

@property (nonatomic) int modelID;

@end
