//
//  LoadingViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 09.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "WheelActivityIndicatorView.h"

@interface LoadingViewController : UIViewController <UIWebViewDelegate, UITabBarControllerDelegate, UITextFieldDelegate> {
	
	NSURL *handshakeURL;
	UIWebView *_webView;
	BOOL loginProcess;

	BOOL activationStarted;
	__weak IBOutlet UIView *activationView;
	__weak IBOutlet UILabel *activationErrorLabel;
	__weak IBOutlet UITextField *activationCodeField;
	__weak IBOutlet UIButton *activationButton;

	__weak IBOutlet UIView *codenameConfirmView;
	__weak IBOutlet UILabel *codenameConfirmLabel;
	
	__weak IBOutlet UILabel *label;
//	__weak IBOutlet UIImageView *innerWheel;
//	__weak IBOutlet UIImageView *outerWheel;
	__weak IBOutlet WheelActivityIndicatorView *wheelActivityIndicatorView;
	
	UITabBarController *_tabBarController;
    UIImageView *_tabBarArrow;
	
}

- (IBAction)activate;

@end
