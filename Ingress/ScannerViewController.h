//
//  ViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 08.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreImage/CoreImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "ChooserViewController.h"
#import "CommViewController.h"
#import "OpsViewController.h"
#import "GlowingLabel.h"
#import "GUIButton.h"
#import "APView.h"
#import "QuickActionsMenu.h"
#import "NearbyPortalView.h"

@interface ScannerViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, OpsViewControllerDelegate> {
	
	__weak IBOutlet MKMapView *_mapView;
	
	CommViewController *commVC;
	ChooserViewController *_levelChooser;
    QuickActionsMenu *quickActionsMenu;
	
	__weak IBOutlet UIImageView *bgImage;
    __weak IBOutlet GUIButton *opsButton;
	__weak IBOutlet UILabel *levelLabel;
	__weak IBOutlet APView *apView;
	__weak IBOutlet UILabel *nicknameLabel;
	__weak IBOutlet GlowingLabel *apLabel;
	__weak IBOutlet GlowingLabel *xmLabel;
	__weak IBOutlet UIProgressView *xmIndicator;
	
	__weak IBOutlet GlowingLabel *virusChoosePortalLabel;
	__weak IBOutlet GUIButton *virusChoosePortalCancelButton;
	
}

@property (strong, nonatomic) UIImage *alienPortalImage;
@property (strong, nonatomic) UIImage *resistancePortalImage;
@property (strong, nonatomic) UIImage *neutralPortalImage;

@property (nonatomic, strong) FlipCard *virusToUse;

@property (nonatomic, strong) OpsViewController *opsViewController;

- (IBAction)showAP;
- (IBAction)showXM;

- (IBAction)virusChoosePortalCancel;

- (void)refresh;
- (void)fireXMP;

- (IBAction)openOPS;

@end
