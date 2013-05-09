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
#import "LevelChooserViewController.h"
#import "GlowingLabel.h"
#import "APView.h"

@interface ScannerViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate> {
	
	__weak IBOutlet MKMapView *_mapView;
	__weak IBOutlet UIImageView *playerArrowImage;
	
	__weak IBOutlet UIButton *fireXmpButton;
	LevelChooserViewController *_levelChooser;
	
	__weak IBOutlet UIImageView *bgImage;
	
	__weak IBOutlet UILabel *levelLabel;
//	__weak IBOutlet UIImageView *levelImage;
	__weak IBOutlet APView *apView;
	__weak IBOutlet UILabel *nicknameLabel;
	__weak IBOutlet GlowingLabel *apLabel;
	__weak IBOutlet GlowingLabel *xmLabel;
	__weak IBOutlet UIProgressView *xmIndicator;
	
}

- (IBAction)showAP;
- (IBAction)showXM;

- (void)refresh;
- (void)fireXMP;

@end
