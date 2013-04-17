//
//  ViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 08.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ScannerViewController.h"
#import "PortalDetailViewController.h"
#import "MKMapView+ZoomLevel.h"

#import "PortalOverlayView.h"
#import "MKPolyline+PortalLink.h"
#import "MKPolygon+ControlField.h"
#import "MKCircle+DeployedResonator.h"
#import "DeployedResonatorView.h"

#import "ColorOverlay.h"
#import "ColorOverlayView.h"

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[AppDelegate instance] setMapView:_mapView];

	//UILongPressGestureRecognizer *xmpLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(xmpLongPressGestureHandler:)];
	//[fireXmpButton addGestureRecognizer:xmpLongPressGesture];

//	if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
//#warning location
//		[_mapView setHidden:YES];
//		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
//		HUD.userInteractionEnabled = NO;
//		HUD.mode = MBProgressHUDModeCustomView;
//		HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
//		HUD.labelText = @"Please allow location services";
//		HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
//		[self.view addSubview:HUD];
//		[HUD show:YES];
//	}
	
	//[mapView.userLocation addObserver:self forKeyPath:@"location" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
	
	//[mapView setCenterCoordinate:CLLocationCoordinate2DMake(50.643389, 13.830139) animated:YES];
	
	
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
//		[_mapView setRegion:MKCoordinateRegionMakeWithDistance(_mapView.userLocation.location.coordinate, 150, 150) animated:YES]; //150m
//	});
//	
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
//		[_mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:NO];
//	});
	
	//[_mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(0, 0), 150, 150) animated:NO];
//	[_mapView setCenterCoordinate:CLLocationCoordinate2DMake(0, 0) zoomLevel:16 animated:NO];
//	[_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
	
	[[DB sharedInstance] addPortalsToMapView];
	
	//[self refresh];
	
//	UITapGestureRecognizer *mapViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
//	[_mapView addGestureRecognizer:mapViewGestureRecognizer];

//	[self refreshProfile];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
//	[[NSNotificationCenter defaultCenter] addObserverForName:@"ProfileUpdatedNotification" object:nil queue:[[API sharedInstance] notificationQueue] usingBlock:^(NSNotification *note) {
//		//NSLog(@"ProfileUpdatedNotification");
//		dispatch_async(dispatch_get_main_queue(), ^{
//			[self refreshProfile];
//		});
//	}];
	
	[[DB sharedInstance] addPortalsToMapView];

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
//	CALayer *layer = _mapView.layer;
//	CATransform3D transform = CATransform3DIdentity;
//	transform.m34 = -0.002;
//	transform = CATransform3DRotate(transform, 45 * M_PI / 180, 1, 0, 0);
//	transform = CATransform3DTranslate(transform, 0, 0, 100);
//	transform = CATransform3DScale(transform, 2, 2, 2);
//	layer.transform = transform;
//	layer.shouldRasterize = YES;
	
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh {
	
	//[mapView setRegion:MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, 1000, 1000) animated:NO];
	//[mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
	__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD.userInteractionEnabled = YES;
	HUD.dimBackground = YES;
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
	HUD.labelText = @"Loading...";
	[self.view addSubview:HUD];
	[HUD show:YES];
	
	__block int done = 0;
	
	[[API sharedInstance] getObjectsWithCompletionHandler:^{
		[[DB sharedInstance] addPortalsToMapView];
		done++;
		if (done == 2) { [HUD hide:YES]; }
	}];
	
	[[API sharedInstance] getInventoryWithCompletionHandler:^{
		done++;
		if (done == 2) { [HUD hide:YES]; }
	}];
	
}

- (void)refreshProfile {
	
	return;
	
	API *api = [API sharedInstance];
	
	int ap = [api.playerInfo[@"ap"] intValue];
	int level = [API levelForAp:ap];
	int lvlImg = [API levelImageForAp:ap];
	//int maxAp = [API maxApForLevel:level];
	int energy = [api.playerInfo[@"energy"] intValue];
	int maxEnergy = [API maxXmForLevel:level];
	
	NSMutableParagraphStyle *pStyle = [NSMutableParagraphStyle new];
	pStyle.alignment = NSTextAlignmentRight;
	
	UIColor *teamColor;
	
	if ([api.playerInfo[@"team"] isEqualToString:@"ALIENS"]) {
		
		levelImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"ap_icon_enl_%d.png", lvlImg]];
		teamColor = [UIColor colorWithRed:40./255. green:244./255. blue:40./255. alpha:1];
		
	} else {
		
		levelImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"ap_icon_hum_%d.png", lvlImg]];
		teamColor = [UIColor colorWithRed:0 green:194./255. blue:1 alpha:1];
		
	}
	
	levelLabel.text = [NSString stringWithFormat:@"%d", level];
	
	nicknameLabel.textColor = teamColor;
	nicknameLabel.text = api.playerInfo[@"nickname"];
	
	NSString *xmLabelStr = [NSString stringWithFormat:@"%d / %d XM", energy, maxEnergy];
	NSMutableAttributedString *xmLabelAtrStr = [[NSMutableAttributedString alloc] initWithString:xmLabelStr attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:235./255. green:188./255. blue:74./255. alpha:1], NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:13], NSParagraphStyleAttributeName: pStyle}];
	[xmLabelAtrStr setAttributes:@{NSForegroundColorAttributeName: teamColor, NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:13], NSParagraphStyleAttributeName: pStyle} range:NSMakeRange(0, [[NSString stringWithFormat:@"%d", energy] length])];
	xmLabel.attributedText = xmLabelAtrStr;
	
	//CGRect rect = xmIndicatorInner.frame;
	//rect.size.width = (energy/maxEnergy) * (xmIndicatorOuter.frame.size.width-2);
	//xmIndicatorInner.frame = rect;
	
	xmIndicator.progressTintColor = teamColor;
	[xmIndicator setProgress:(energy/maxEnergy) animated:YES];
	
}

//#pragma mark - KVO
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//	
//	if ([object isEqual:_mapView.userLocation] && [keyPath isEqualToString:@"location"]) {
//		MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_mapView.centerCoordinate, 200, 200);
//		if (!isnan(region.center.latitude)) {
//			[_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
//			[_mapView setRegion:region animated:YES];
//			[_mapView.userLocation removeObserver:self forKeyPath:@"location"];
//		}
//	}
//	
//}

#pragma mark - MKMapViewDelegate

//- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
//	
//}
//
//- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
////	bgImage.alpha = 0;
//}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	//NSLog(@"regionDidChangeAnimated");
	
	return;
	
	if (mapView.zoomLevel < 15) {
        [mapView setCenterCoordinate:mapView.centerCoordinate zoomLevel:15 animated:YES];
		return;
    }
	
	if (mapView.zoomLevel > 18) {
        [mapView setCenterCoordinate:mapView.centerCoordinate zoomLevel:18 animated:YES];
		return;
    }
	
	[_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:animated]; //WithHeading
	
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	[view setSelected:NO animated:YES];
	if ([view.annotation isKindOfClass:[Portal class]]) {
		currentPortal = (Portal *)view.annotation;
		[self performSegueWithIdentifier:@"PortalDetailSegue" sender:self];
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	
	if ([view.annotation isKindOfClass:[Item class]]) {
		
		__block Item *item = (Item *)view.annotation;
		
		__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
		HUD.labelText = @"Picking up...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		
		[[API sharedInstance] pickUpItemWithGuid:item.guid completionHandler:^(NSString *errorStr) {
			
			[HUD hide:YES];
			
			[mapView removeAnnotation:item];
			item.latitude = 0;
			item.longitude = 0;
			item.dropped = NO;
			[[DB sharedInstance] saveContext];
			
			if (errorStr) {
				
				HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
				HUD.userInteractionEnabled = YES;
				HUD.dimBackground = YES;
				HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
				HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:12];
				HUD.mode = MBProgressHUDModeCustomView;
				HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
				HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
				HUD.detailsLabelText = errorStr;
				[[AppDelegate instance].window addSubview:HUD];
				[HUD show:YES];
				[HUD hide:YES afterDelay:3];
				
			} else {
				
				[[SoundManager sharedManager] playSound:@"Sound/sfx_resource_pick_up.aif"];
				
			}
			
		}];
		
	}
	
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		
		return [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
		
		static NSString *AnnotationViewID = @"userLocationAnnotationView";
		
		MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
		if (annotationView == nil) {
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
			annotationView.canShowCallout = NO;
			annotationView.pinColor = MKPinAnnotationColorGreen;
		} else {
			annotationView.annotation = annotation;
		}
		
		return annotationView;
		
	} else if ([annotation isKindOfClass:[Portal class]]) {
		
		static NSString *AnnotationViewID = @"portalAnnotationView";
		
		MKAnnotationView *annotationView = /*(PortalAnnotationView *)*/[_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
		if (annotationView == nil) {
			annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
			annotationView.canShowCallout = NO;
		} else {
			annotationView.annotation = annotation;
		}

//		annotationView.image = nil;
		
		Portal *portal = (Portal *)annotation;
		annotationView.image = [[API sharedInstance] iconForPortal:portal];
		annotationView.alpha = .5;
		
		return annotationView;
	
	} else if ([annotation isKindOfClass:[Item class]]) {
		
		static NSString *AnnotationViewID = @"itemAnnotationView";
		
		MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
		if (annotationView == nil) {
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
			annotationView.canShowCallout = YES;
			annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			annotationView.pinColor = MKPinAnnotationColorPurple;
		} else {
			annotationView.annotation = annotation;
		}
		
		return annotationView;
		
	}
	
	return nil;

}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
	if ([overlay isKindOfClass:[Portal class]]) {
		PortalOverlayView *overlayView = [[PortalOverlayView alloc] initWithOverlay:overlay];
		return overlayView;
	} else if ([overlay isKindOfClass:[MKPolyline class]]) {
		MKPolyline *polyline = (MKPolyline *)overlay;
		MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:polyline];
		polylineView.strokeColor = [API colorForFaction:polyline.portalLink.controllingTeam];
		polylineView.lineWidth = 1;
		return polylineView;
	} else if ([overlay isKindOfClass:[MKPolygon class]]) {
		MKPolygon *polygon = (MKPolygon *)overlay;
		MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:polygon];
		polygonView.fillColor = [API colorForFaction:polygon.controlField.controllingTeam];
		polygonView.alpha = .1;
		return polygonView;
	} else if ([overlay isKindOfClass:[MKCircle class]]) {
		MKCircle *circle = (MKCircle *)overlay;
		DeployedResonatorView *circleView = [[DeployedResonatorView alloc] initWithCircle:circle];
		circleView.fillColor = [API colorForLevel:circle.deployedResonator.level];
		//circleView.alpha = .1;
		return circleView;
	} else if ([overlay isKindOfClass:[ColorOverlay class]]) {
		ColorOverlayView *overlayView = [[ColorOverlayView alloc] initWithOverlay:overlay];
		return overlayView;
	}
	return nil;
}

#pragma mark - Gestures

//- (void)mapTapped:(UITapGestureRecognizer *)recognizer {
//	MKMapView *mapView = (MKMapView *)recognizer.view;
//	id<MKOverlay> tappedOverlay = nil;
//	for (id<MKOverlay> overlay in mapView.overlays) {
//		MKOverlayView *view = [mapView viewForOverlay:overlay];
//		if (view) {
//			// Get view frame rect in the mapView's coordinate system
//			CGRect viewFrameInMapView = [view.superview convertRect:view.frame toView:mapView];
//			// Get touch point in the mapView's coordinate system
//			CGPoint point = [recognizer locationInView:mapView];
//			// Check if the touch is within the view bounds
//			if (CGRectContainsPoint(viewFrameInMapView, point)) {
//				tappedOverlay = overlay;
//				break;
//			}
//		}
//	}
//	
//	//NSLog(@"Tapped overlay: %@", tappedOverlay);
//	//NSLog(@"Tapped view: %@", [mapView viewForOverlay:tappedOverlay]);
//	
//	if ([tappedOverlay isKindOfClass:[PortalItem class]]) {
//		currentPortalItem = (PortalItem *)tappedOverlay;
//		[self performSegueWithIdentifier:@"PortalDetailSegue" sender:self];
//	}
//}

- (void)xmpLongPressGestureHandler:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateEnded) {

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.dimBackground = YES;
		HUD.showCloseButton = YES;
		
		_levelChooser = [LevelChooserViewController levelChooserWithTitle:@"Choose XMP burster level to fire" completionHandler:^(int level) {
			[HUD hide:YES];
			[self fireXMPOfLevel:level];
			_levelChooser = nil;
		}];
		HUD.customView = _levelChooser.view;
		
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		
	}
}

#pragma mark - Firing XMP

- (IBAction)fireXMP {

//	int ap = [[API sharedInstance].playerInfo[@"ap"] intValue];
//	int level = [API levelForAp:ap];
//	[self fireXMPOfLevel:level];
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
		
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.dimBackground = YES;
	HUD.showCloseButton = YES;
	
	_levelChooser = [LevelChooserViewController levelChooserWithTitle:@"Choose XMP burster level to fire" completionHandler:^(int level) {
		[HUD hide:YES];
		[self fireXMPOfLevel:level];
		_levelChooser = nil;
	}];
	HUD.customView = _levelChooser.view;
	
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];
	
}

- (void)fireXMPOfLevel:(int)level {
	
	XMP *xmpItem = [[DB sharedInstance] getRandomXMPOfLevel:level];
	
	NSLog(@"Firing: %@", xmpItem);
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_emp_power_up.aif"];
	
	if (!xmpItem) {
		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
		HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
		HUD.detailsLabelText = @"No XMP remaining!";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:3];
		return;
	}
	
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.dimBackground = YES;
	HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
	HUD.labelText = [NSString stringWithFormat:@"Firing XMP of level: %d", xmpItem.level];
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];
	
	[[API sharedInstance] fireXMP:xmpItem completionHandler:^(NSString *errorStr, NSDictionary *damages) {
		
		[HUD hide:YES];
		
		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
		
		if (damages) {
			
//			HUD.mode = MBProgressHUDModeText;
//			HUD.labelText = @"Damages";
//			HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:10];
			
			UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 240, 320)];
			textView.editable = NO;
			textView.backgroundColor = [UIColor clearColor];
			textView.opaque = NO;
			textView.textColor = [UIColor whiteColor];
			
			HUD.mode = MBProgressHUDModeCustomView;
			HUD.customView = textView;
			HUD.showCloseButton = YES;
			
			NSMutableString *damagesStr = [NSMutableString string];
			
			[damages enumerateKeysAndObjectsUsingBlock:^(NSString *portalGUID, NSArray *damagesArray, BOOL *stop) {
				
				Portal *portal = (Portal *)[[DB sharedInstance] getItemWithGuid:portalGUID];
				[damagesStr appendFormat:@"%@:\n", portal.subtitle];
				
				for (NSDictionary *damage in damagesArray) {
					int damageAmount = [damage[@"damageAmount"] intValue];
					int slot = [damage[@"targetSlot"] intValue];
					BOOL critical = [damage[@"criticalHit"] boolValue];
					BOOL destroyed = [damage[@"targetDestroyed"] boolValue];
					
					if (destroyed) {
						[[SoundManager sharedManager] playSound:@"Sound/sfx_explode_resonator.aif"];
					}
					
					DeployedResonator *resonator = [[DB sharedInstance] deployedResonatorForPortal:portal atSlot:slot shouldCreate:NO];
					int level = resonator.level;
					int maxEnergy = [API maxEnergyForResonatorLevel:level];
					
					[damagesStr appendFormat:@"  • %d: -%d/%d %@%@\n", slot, damageAmount, maxEnergy, (critical ? @" CRITICAL" : @""), (destroyed ? @" DESTROYED" : @"")];

					[[NSNotificationCenter defaultCenter] postNotificationName:@"ResonatorDamage" object:resonator userInfo:@{
					 @"damageAmount": @(damageAmount),
					 @"critical": @(critical),
					 @"destroyed": @(destroyed)
					}];
					
				}
				
				[damagesStr appendFormat:@"\n\n"];
				
			}];
			

			textView.text = damagesStr;
			
			//[[AppDelegate instance].window addSubview:HUD];
			//[HUD show:YES];

		} else {
			
			HUD.mode = MBProgressHUDModeCustomView;
			HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
			HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
			
			if (errorStr) {
				HUD.detailsLabelText = errorStr;
			} else {
				HUD.detailsLabelText = @"Unknown Error";
			}
			
			[[AppDelegate instance].window addSubview:HUD];
			[HUD show:YES];
			[HUD hide:YES afterDelay:3];
			
		}

	}];
	
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"PortalDetailSegue"]) {
		[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
		
		PortalDetailViewController *vc = segue.destinationViewController;
		vc.portal = currentPortal;
		vc.mapCenterCoordinate = _mapView.centerCoordinate;
		currentPortal = nil;
	}
}

@end
