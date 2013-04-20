//
//  StatsViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 11.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "EXF.h"
#import "EXFUtils.h"

@interface ProfileViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
	
	__weak IBOutlet UILabel *levelLabel;
	__weak IBOutlet UIImageView *levelImage;
	__weak IBOutlet UILabel *nicknameLabel;
	__weak IBOutlet UILabel *apLabel;
	__weak IBOutlet UILabel *xmLabel;
	__weak IBOutlet UIProgressView *xmIndicator;
	
	__weak IBOutlet UIView *passcodeContainerView;
	__weak IBOutlet UITextField *passcodeTextField;
	__weak IBOutlet UIButton *submitPasscodeButton;
	
	NSData *imageData;
	
	//__weak IBOutlet UILabel *availabileEnergyLabel;
	__weak IBOutlet UILabel *energyCollectLabel;
	__weak IBOutlet UIStepper *energyCollectStepper;
	
}

- (IBAction)refreshInventory;

- (IBAction)actionSheet;
- (IBAction)submitPasscode;

- (IBAction)energyCollectValueChanged:(UIStepper *)sender;

@end
