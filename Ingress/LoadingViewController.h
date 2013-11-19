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
#import "StretchableBackgroundButton.h"
#import "GlowingLabel.h"
#import "GUIButton.h"
#import "TypeWriterLabel.h"
#import "CustomBackgroundColorButton.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SelectingButton.h"

@interface LoadingViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate> {
	
	NSURL *handshakeURL;
	UIWebView *_webView;
	BOOL loginProcess;

	__weak IBOutlet GUIButton *retryHandshakeButton;

	BOOL activationStarted;
	__weak IBOutlet UIView *activationView;
	__weak IBOutlet UILabel *activationErrorLabel;
	__weak IBOutlet UITextField *activationCodeField;
	__weak IBOutlet CustomBackgroundColorButton *activationButton;

	__weak IBOutlet UIView *termsView;
	__weak IBOutlet UILabel *termsWarningLabel;
	__weak IBOutlet UILabel *termsDescriptionLabel;
	__weak IBOutlet UILabel *termsLabel;
	__weak IBOutlet SelectingButton *termsCheckboxButton;
	__weak IBOutlet StretchableBackgroundButton *termsConfirmButton;

	__weak IBOutlet TPKeyboardAvoidingScrollView *createCodenameScrollview;
	__weak IBOutlet UILabel *createCodenameLabel;
	__weak IBOutlet UITextField *createCodenameField;
	__weak IBOutlet CustomBackgroundColorButton *createCodenameButton;

	__weak IBOutlet UIView *codenameErrorView;
	__weak IBOutlet UILabel *codenameErrorLabel;
	__weak IBOutlet StretchableBackgroundButton *codenameErrorRetryButton;

	NSString *codenameToConfirm;
	__weak IBOutlet UIView *codenameConfirmView;
	__weak IBOutlet TypeWriterLabel *codenameConfirmLabel;
	__weak IBOutlet StretchableBackgroundButton *codenameConfirmButton;
	__weak IBOutlet StretchableBackgroundButton *codenameConfirmRetryButton;

	__weak IBOutlet UIView *typewriterView;
	__weak IBOutlet TypeWriterLabel *typewriterLabel;

	__weak IBOutlet UIView *introView;
	__weak IBOutlet UITextView *introTextView;

	__weak IBOutlet GlowingLabel *label;
//	__weak IBOutlet UIImageView *innerWheel;
//	__weak IBOutlet UIImageView *outerWheel;
	__weak IBOutlet WheelActivityIndicatorView *wheelActivityIndicatorView;
	
}

- (IBAction)retryHandshake;
- (IBAction)activate;
- (IBAction)termsCheckboxChanged;
- (IBAction)termsConfirm;
- (IBAction)createCodename;
- (IBAction)codenameRetry;
- (IBAction)codenameConfirm;

@end
