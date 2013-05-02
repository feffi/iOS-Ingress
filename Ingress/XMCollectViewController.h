//
//  XMCollectViewController.h
//  Ingress
//
//  Created by Alex Studnička on 02.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMCollectViewController : UIViewController {
	__weak IBOutlet UILabel *energyCollectLabel;
	__weak IBOutlet UILabel *energyCollectNumberLabel;
	__weak IBOutlet UIStepper *energyCollectStepper;
}

+ (XMCollectViewController *)xmCollectView;

- (IBAction)energyCollectValueChanged:(UIStepper *)sender;

@end
