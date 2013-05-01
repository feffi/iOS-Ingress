//
//  ScoreViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 12.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ScoreViewController.h"

@implementation ScoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	GLViewController *glVC = self.childViewControllers[0];
	[glVC.view setBackgroundColor:[UIColor colorWithRed:16./255. green:32./255. blue:34./255. alpha:1]];
	
	int width = self.view.bounds.size.width;
	int height = self.view.bounds.size.height;
	
	pieChart = [[PCPieChart alloc] initWithFrame:CGRectMake(([self.view bounds].size.width-width)/2,([self.view bounds].size.height-height)/2,width,height)];
	[pieChart setShowArrow:NO];
	[pieChart setSameColorLabel:YES];
	[pieChart setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
	[pieChart setDiameter:250];
	pieChart.alpha = .25;
	[self.view addSubview:pieChart];
	
	//pieChart.titleFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:10];
	//pieChart.percentageFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
	
	PCPieComponent *component1 = [PCPieComponent pieComponentWithTitle:@"Enlightened" value:1.001];
	[component1 setColour:[API colorForFaction:@"ALIENS"]];
	PCPieComponent *component2 = [PCPieComponent pieComponentWithTitle:@"Resistance" value:1];
	[component2 setColour:[API colorForFaction:@"RESISTANCE"]];
	[pieChart setComponents:@[component2, component1]];
	
//	for (UIViewController *vc in self.childViewControllers) {
//		if ([vc isKindOfClass:[GLViewController class]]) {
//			[(GLViewController *)vc setModelID:1];
//			break;
//		}
//	}
	
	//[self refresh];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
	
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD.userInteractionEnabled = NO;
	//HUD.labelText = @"Loading...";
	//HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	[self.view addSubview:HUD];
	[HUD show:YES];
	
	[[API sharedInstance] loadScoreWithCompletionHandler:^(int alienScore, int resistanceScore) {
		
		[HUD hide:YES];
		
		PCPieComponent *component1 = [PCPieComponent pieComponentWithTitle:@"Enlightened" value:alienScore];
		[component1 setColour:[UIColor colorWithRed:40./255. green:244./255. blue:40./255. alpha:1]];
		PCPieComponent *component2 = [PCPieComponent pieComponentWithTitle:@"Resistance" value:resistanceScore];
		[component2 setColour:[UIColor colorWithRed:0 green:194./255. blue:1 alpha:1]];
		[pieChart setComponents:@[component2, component1]];
		
		[pieChart setNeedsDisplay];
		
	}];
	
}

@end
