//
//  ScoreViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 12.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLViewController.h"
#import "PCPieChart.h"

@interface ScoreViewController : UIViewController {
	PCPieChart *pieChart;
}

@property (nonatomic, strong) GLViewController *glViewController;

@end
