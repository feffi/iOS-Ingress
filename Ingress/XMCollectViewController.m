//
//  XMCollectViewController.m
//  Ingress
//
//  Created by Alex Studnička on 02.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "XMCollectViewController.h"

@implementation XMCollectViewController

+ (XMCollectViewController *)xmCollectView {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	XMCollectViewController *xmCollectView = [storyboard instantiateViewControllerWithIdentifier:@"XMCollectViewController"];
	xmCollectView.view.frame = CGRectMake(0, 0, 240, 60);
	return xmCollectView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[energyCollectNumberLabel setText:[NSString stringWithFormat:@"%d / %d", [API sharedInstance].numberOfEnergyToCollect, [EnergyGlob MR_countOfEntities]]];
	[energyCollectStepper setValue:[API sharedInstance].numberOfEnergyToCollect];
	[energyCollectStepper setMaximumValue:[EnergyGlob MR_countOfEntities]];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)energyCollectValueChanged:(UIStepper *)sender {
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	//[energyCollectLabel setText:[NSString stringWithFormat:@"%d", (int)(sender.value)]];
	[API sharedInstance].numberOfEnergyToCollect = sender.value;
	[energyCollectNumberLabel setText:[NSString stringWithFormat:@"%d / %d", [API sharedInstance].numberOfEnergyToCollect, [EnergyGlob MR_countOfEntities]]];
}

@end
