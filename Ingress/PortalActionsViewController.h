//
//  PortalInfoViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 20.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GUIButton.h"

@interface PortalActionsViewController : UIViewController <CLLocationManagerDelegate> {
	
//	__weak IBOutlet UIImageView *imageView;
	__weak IBOutlet UIActivityIndicatorView *imageActivityIndicator;
	__weak IBOutlet UILabel *portalTitleLabel;
	
	__weak IBOutlet UILabel *infoLabel1;
	__weak IBOutlet UILabel *infoLabel2;
	
	__weak IBOutlet GUIButton *hackButton;
	__weak IBOutlet GUIButton *rechargeButton;
	__weak IBOutlet GUIButton *linkButton;

}

@property (nonatomic, strong) Portal *portal;
@property (nonatomic, strong) UIImageView *imageView;

- (void)refresh;
- (IBAction)hack:(GUIButton *)sender;
- (IBAction)recharge:(GUIButton *)sender;
- (IBAction)link:(GUIButton *)sender;

@end
