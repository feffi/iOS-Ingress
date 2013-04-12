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

@interface LoadingViewController : UIViewController <UIWebViewDelegate, UITabBarControllerDelegate> {
	
	NSURL *handshakeURL;
	UIWebView *_webView;
	BOOL loginProcess;
	
	__weak IBOutlet UILabel *label;
//	__weak IBOutlet UIImageView *innerWheel;
//	__weak IBOutlet UIImageView *outerWheel;
	__weak IBOutlet WheelActivityIndicatorView *wheelActivityIndicatorView;
	
	UITabBarController *_tabBarController;
    UIImageView *_tabBarArrow;
	
}

@end
