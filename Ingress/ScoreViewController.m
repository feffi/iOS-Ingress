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

	self.glViewController = self.childViewControllers[0];
	[self.glViewController.view setBackgroundColor:[UIColor colorWithRed:16./255. green:32./255. blue:34./255. alpha:1]];
	
	pieChart = [[PCPieChart alloc] initWithFrame:self.view.bounds];
	[pieChart setShowArrow:NO];
	[pieChart setSameColorLabel:YES];
	[pieChart setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
	[pieChart setDiameter:260];
	pieChart.alpha = .25;
	[self.view addSubview:pieChart];
	
	//pieChart.titleFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:10];
	//pieChart.percentageFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
	
	PCPieComponent *component1 = [PCPieComponent pieComponentWithTitle:@"Enlightened" value:1.001];
	[component1 setColour:[Utilities colorForFaction:@"ALIENS"]];
	PCPieComponent *component2 = [PCPieComponent pieComponentWithTitle:@"Resistance" value:1];
	[component2 setColour:[Utilities colorForFaction:@"RESISTANCE"]];
	[pieChart setComponents:@[component2, component1]];
	
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
	
	[[API sharedInstance] loadScoreWithCompletionHandler:^(int alienScore, int resistanceScore) {
		
		PCPieComponent *component1 = [PCPieComponent pieComponentWithTitle:@"Enlightened" value:alienScore];
		[component1 setColour:[UIColor colorWithRed:40./255. green:244./255. blue:40./255. alpha:1]];
		PCPieComponent *component2 = [PCPieComponent pieComponentWithTitle:@"Resistance" value:resistanceScore];
		[component2 setColour:[UIColor colorWithRed:0 green:194./255. blue:1 alpha:1]];
		[pieChart setComponents:@[component2, component1]];
		
		[pieChart setNeedsDisplay];
		
	}];
	
}

@end
