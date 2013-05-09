//
//  MissionViewController.h
//  Ingress
//
//  Created by Alex Studnička on 05.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelActivityIndicatorView.h"
#import "StretchableBackgroundButton.h"
#import "ScrollTextView.h"
#import "GlowingLabel.h"
#import "TypeWriterLabel.h"
#import "GUIButton.h"

@interface MissionViewController : UIViewController {

	__weak IBOutlet UIView *jarvisBackground;
	__weak IBOutlet UIImageView *backgroundImageView;

	__weak IBOutlet GlowingLabel *titleLabel;
	__weak IBOutlet GlowingLabel *subtitleLabel;

	WheelActivityIndicatorView *wheelActivityIndicatorView;

	__weak IBOutlet ScrollTextView *textView;

	__weak IBOutlet StretchableBackgroundButton *mainButton;
	__weak IBOutlet StretchableBackgroundButton *altButton;

	__weak IBOutlet GlowingLabel *authLabel;
	__weak IBOutlet UIProgressView *authProgressView;
	__weak IBOutlet TypeWriterLabel *typewriterLabel;

	__weak IBOutlet UIView *factionChooseButtons;
	__weak IBOutlet GlowingLabel *factionChooseButtonsLabel;
	__weak IBOutlet GUIButton *joinResistanceButton;
	__weak IBOutlet GUIButton *joinEnlightenedButton;

	__weak IBOutlet GlowingLabel *choosingLabel;

}

@property (nonatomic) BOOL factionChoose;
@property (nonatomic) int mission;

- (IBAction)join:(id)sender;

@end
