//
//  ResourcesViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 17.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResourcesViewController : UIViewController <UIActionSheetDelegate> {
	
	int actionResource;
	int actionLevel;
	
	__weak IBOutlet UIView *resonatorContainerView;
	__weak IBOutlet UIView *xmpContainerView;
	__weak IBOutlet UIView *shieldContainerView;
	
}

- (IBAction)action:(UIButton *)sender;

@end
