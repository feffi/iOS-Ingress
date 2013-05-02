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
#import "MKCircle+Ingress.h"
#import "DeployedResonatorView.h"
#import "XMOverlayView.h"

#import "ColorOverlay.h"
#import "ColorOverlayView.h"

@implementation ScannerViewController {
	UIView *rangeCircleView;
	CLLocationManager *locationManager;
	CLLocation *lastLocation;
	BOOL firstRefreshProfile;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	levelLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:32];
	nicknameLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
	firstRefreshProfile = YES;

	[xmIndicator setProgressImage:[[UIImage imageNamed:@"progressImage-aliens.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)]];
	[xmIndicator setTrackImage:[[UIImage imageNamed:@"trackImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)]];

//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];

	locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
	
	[locationManager startUpdatingLocation];
	[locationManager startUpdatingHeading];

	if (YES) { // TODO: Free moving allowed for debug only
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			[locationManager stopUpdatingLocation];
			[_mapView setScrollEnabled:YES];
		});
	}

	[[AppDelegate instance] setMapView:_mapView];

	UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[_mapView addGestureRecognizer:recognizer];

	rangeCircleView = [UIView new];
	rangeCircleView.frame = CGRectMake(0, 0, 0, 0);
	rangeCircleView.center = _mapView.center;
	rangeCircleView.backgroundColor = [UIColor clearColor];
	rangeCircleView.opaque = NO;
	rangeCircleView.userInteractionEnabled = NO;
	rangeCircleView.layer.cornerRadius = 0;
	rangeCircleView.layer.masksToBounds = YES;
	rangeCircleView.layer.borderWidth = 2;
	rangeCircleView.layer.borderColor = [[[UIColor blueColor] colorWithAlphaComponent:0.25] CGColor];
	[self.view addSubview:rangeCircleView];

	[NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCircle) userInfo:nil repeats:YES];

//	if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
//#warning location
//		[_mapView setHidden:YES];
//		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
//		HUD.userInteractionEnabled = NO;
//		HUD.mode = MBProgressHUDModeCustomView;
//		HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
//		HUD.labelText = @"Please allow location services";
//		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
//		[self.view addSubview:HUD];
//		[HUD show:YES];
//	}

//	UITapGestureRecognizer *mapViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
//	[_mapView addGestureRecognizer:mapViewGestureRecognizer];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
//	[[NSNotificationCenter defaultCenter] addObserverForName:@"ProfileUpdatedNotification" object:nil queue:[[API sharedInstance] notificationQueue] usingBlock:^(NSNotification *note) {
//		//NSLog(@"ProfileUpdatedNotification");
//		dispatch_async(dispatch_get_main_queue(), ^{
//			[self refreshProfile];
//		});
//	}];
	
//	[[DB sharedInstance] addPortalsToMapView];

	[self refreshProfile];

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

#pragma mark - Data Refresh

- (IBAction)refresh {

//	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//		[ControlField MR_truncateAllInContext:localContext];
//		[PortalLink MR_truncateAllInContext:localContext];
//		[Item MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"dropped = YES"] inContext:localContext];
//		[EnergyGlob MR_truncateAllInContext:localContext];
//		[DeployedResonator MR_truncateAllInContext:localContext];
//		[DeployedMod MR_truncateAllInContext:localContext];
//	} completion:^(BOOL success, NSError *error) {
//		[[API sharedInstance] getObjectsWithCompletionHandler:^{ }];
//	}];

	[ControlField MR_truncateAll];
	[PortalLink MR_truncateAll];
	[Item MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"dropped = YES"]];
	[EnergyGlob MR_truncateAll];
	[DeployedResonator MR_truncateAll];
	[DeployedMod MR_truncateAll];

	__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD.userInteractionEnabled = YES;
	HUD.dimBackground = YES;
	HUD.mode = MBProgressHUDModeIndeterminate;
	[self.view addSubview:HUD];
	[HUD show:YES];

	[[API sharedInstance] getObjectsWithCompletionHandler:^{

		////////////////////////

		NSMutableArray *annotationsToRemove = [_mapView.annotations mutableCopy];
		[annotationsToRemove removeObject:_mapView.userLocation];
		[_mapView removeAnnotations:annotationsToRemove];

		[_mapView removeOverlays:_mapView.overlays];

		////////////////////////

		//[mapView addOverlay:[ColorOverlay new]];

		NSArray *fetchedFields = [ControlField MR_findAll];
		for (ControlField *controlField in fetchedFields) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[_mapView addOverlay:controlField.polygon];
			});
		}

		NSArray *fetchedLinks = [PortalLink MR_findAll];
		for (PortalLink *portalLink in fetchedLinks) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[_mapView addOverlay:portalLink.polyline];
			});
		}

		NSArray *fetchedItems = [Item MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"dropped = YES"]];
		for (Item *item in fetchedItems) {
			//NSLog(@"adding item to map: %@ (%f, %f)", item, item.latitude, item.longitude);
			if (item.coordinate.latitude == 0 && item.coordinate.longitude == 0) { continue; }
			dispatch_async(dispatch_get_main_queue(), ^{
				[_mapView addAnnotation:item];
			});
		}

		NSArray *fetchedXM = [EnergyGlob MR_findAll];
		for (EnergyGlob *xm in fetchedXM) {
			//NSLog(@"adding item to map: %@ (%f, %f)", item, item.latitude, item.longitude);
			if (xm.coordinate.latitude == 0 && xm.coordinate.longitude == 0) { continue; }
			dispatch_async(dispatch_get_main_queue(), ^{
				[_mapView addOverlay:xm.circle];
			});
		}

		NSArray *fetchedPortals = [Portal MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"completeInfo = YES"]];
		for (Portal *portal in fetchedPortals) {
			//NSLog(@"adding portal to map: %@ (%f, %f)", portal.subtitle, portal.latitude, portal.longitude);
			if (portal.coordinate.latitude == 0 && portal.coordinate.longitude == 0) { continue; }
			dispatch_async(dispatch_get_main_queue(), ^{
				[_mapView addAnnotation:portal];
				//[_mapView addOverlay:portal];
			});
		}

		NSArray *fetchedResonators = [DeployedResonator MR_findAll];
		for (DeployedResonator *resonator in fetchedResonators) {
			//NSLog(@"adding resonator to map: %@ (%f, %f)", resonator, resonator.coordinate.latitude, resonator.coordinate.longitude);
			if (resonator.portal.coordinate.latitude == 0 && resonator.portal.coordinate.longitude == 0) { continue; }
			dispatch_async(dispatch_get_main_queue(), ^{
				[_mapView addOverlay:resonator.circle];
			});
		}

		////////////////////////

		[HUD hide:YES];

	}];

}

- (void)refreshProfile {

	NSDictionary *playerInfo = [[API sharedInstance] playerInfo];

	int ap = [playerInfo[@"ap"] intValue];
	int level = [API levelForAp:ap];
	int lvlImg = [API levelImageForAp:ap];
	float energy = [playerInfo[@"energy"] floatValue];
	float maxEnergy = [API maxXmForLevel:level];

	NSMutableParagraphStyle *pStyle = [NSMutableParagraphStyle new];
    pStyle.alignment = NSTextAlignmentRight;

	UIColor *teamColor = [API colorForFaction:playerInfo[@"team"]];

	if ([playerInfo[@"team"] isEqualToString:@"ALIENS"]) {
		levelImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"ap_icon_enl_%d.png", lvlImg]];
	} else {
		levelImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"ap_icon_hum_%d.png", lvlImg]];
	}

	levelLabel.text = [NSString stringWithFormat:@"%d", level];

	nicknameLabel.textColor = teamColor;
	nicknameLabel.text = playerInfo[@"nickname"];

	if ([[API sharedInstance].playerInfo[@"team"] isEqualToString:@"RESISTANCE"]) {
		[xmIndicator setProgressImage:[[UIImage imageNamed:@"progressImage-resistance.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)]];
	} else {
		[xmIndicator setProgressImage:[[UIImage imageNamed:@"progressImage-aliens.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)]];
	}

	[xmIndicator setProgress:(energy/maxEnergy) animated:!firstRefreshProfile];

	firstRefreshProfile = NO;

}

#pragma mark - NSManagedObjectContext Did Change

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification {

	dispatch_async(dispatch_get_main_queue(), ^{
		for (NSManagedObject *object in notification.userInfo[NSDeletedObjectsKey]) {
			if ([object isKindOfClass:[Portal class]]) {
				Portal *portal = (Portal *)object;
				[_mapView removeAnnotation:portal];
//				[_mapView removeOverlay:portal];
			} else if ([object isKindOfClass:[EnergyGlob class]]) {
				EnergyGlob *xm = (EnergyGlob *)object;
				[_mapView removeOverlay:xm.circle];
			} else if ([object isKindOfClass:[Item class]]) {
				Item *item = (Item *)object;
				[_mapView removeAnnotation:item];
			} else if ([object isKindOfClass:[PortalLink class]]) {
				PortalLink *portalLink = (PortalLink *)object;
				[_mapView removeOverlay:portalLink.polyline];
			} else if ([object isKindOfClass:[ControlField class]]) {
				ControlField *controlField = (ControlField *)object;
				[_mapView removeOverlay:controlField.polygon];
			} else if ([object isKindOfClass:[DeployedResonator class]]) {
				DeployedResonator *resonator = (DeployedResonator *)object;
				[_mapView removeOverlay:resonator.circle];
			}
		}

		for (NSManagedObject *object in notification.userInfo[NSInsertedObjectsKey]) {
			if ([object isKindOfClass:[Portal class]]) {
				Portal *portal = (Portal *)object;
				[_mapView addAnnotation:portal];
//				[_mapView addOverlay:portal];
			} else if ([object isKindOfClass:[EnergyGlob class]]) {
				EnergyGlob *xm = (EnergyGlob *)object;
				[_mapView addOverlay:xm.circle];
			} else if ([object isKindOfClass:[Item class]]) {
				Item *item = (Item *)object;
				[_mapView addAnnotation:item];
			} else if ([object isKindOfClass:[PortalLink class]]) {
				PortalLink *portalLink = (PortalLink *)object;
				[_mapView addOverlay:portalLink.polyline];
			} else if ([object isKindOfClass:[ControlField class]]) {
				ControlField *controlField = (ControlField *)object;
				[_mapView addOverlay:controlField.polygon];
			} else if ([object isKindOfClass:[DeployedResonator class]]) {
				DeployedResonator *resonator = (DeployedResonator *)object;
				[_mapView addOverlay:resonator.circle];
			}
		}

		for (NSManagedObject *object in notification.userInfo[NSUpdatedObjectsKey]) {
			if ([object isKindOfClass:[Portal class]]) {
				Portal *portal = (Portal *)object;
				[_mapView removeAnnotation:portal];
				[_mapView addAnnotation:portal];
//				[_mapView removeOverlay:portal];
//				[_mapView addOverlay:portal];
			} else if ([object isKindOfClass:[EnergyGlob class]]) {
				EnergyGlob *xm = (EnergyGlob *)object;
				[_mapView removeOverlay:xm.circle];
				[_mapView addOverlay:xm.circle];
			} else if ([object isKindOfClass:[Item class]]) {
				Item *item = (Item *)object;
				[_mapView removeAnnotation:item];
				[_mapView addAnnotation:item];
			} else if ([object isKindOfClass:[PortalLink class]]) {
				PortalLink *portalLink = (PortalLink *)object;
				[_mapView removeOverlay:portalLink.polyline];
				[_mapView addOverlay:portalLink.polyline];
			} else if ([object isKindOfClass:[ControlField class]]) {
				ControlField *controlField = (ControlField *)object;
				[_mapView removeOverlay:controlField.polygon];
				[_mapView addOverlay:controlField.polygon];
			} else if ([object isKindOfClass:[DeployedResonator class]]) {
				DeployedResonator *resonator = (DeployedResonator *)object;
				[_mapView removeOverlay:resonator.circle];
				[_mapView addOverlay:resonator.circle];
			}
		}
	});

}

#pragma mark - Pinch Gesture

- (void)handlePinch:(UIPinchGestureRecognizer*)recognizer {
    static MKCoordinateRegion originalRegion;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        originalRegion = _mapView.region;
    }

    double latdelta = originalRegion.span.latitudeDelta / recognizer.scale;
    double londelta = originalRegion.span.longitudeDelta / recognizer.scale;
    MKCoordinateSpan span = MKCoordinateSpanMake(latdelta, londelta);

    [_mapView setRegion:MKCoordinateRegionMake(originalRegion.center, span) animated:NO];
}

#pragma mark - Circle

- (void)updateCircle {
	CGFloat diameter = 100/((_mapView.region.span.latitudeDelta * 111200) / _mapView.bounds.size.width);
	rangeCircleView.frame = CGRectMake(0, 0, diameter, diameter);
	rangeCircleView.center = _mapView.center;
	rangeCircleView.layer.cornerRadius = diameter/2;
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	[_mapView setCenterCoordinate:newLocation.coordinate animated:YES];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return NO;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	CGAffineTransform transform = CGAffineTransformMakeRotation(newHeading.trueHeading*(M_PI/180));
	playerArrowImage.transform = transform;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

	if (mapView.zoomLevel < 16) {
        [mapView setCenterCoordinate:_mapView.centerCoordinate zoomLevel:16 animated:NO];
		return;
    }

	CLLocation *mapLocation = [[CLLocation alloc] initWithLatitude:_mapView.centerCoordinate.latitude longitude:_mapView.centerCoordinate.longitude];
	CLLocationDistance meters = [mapLocation distanceFromLocation:lastLocation];
	if (meters == -1 || meters >= 10) {
		lastLocation = mapLocation;
		[self refresh];
	}

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
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.labelText = @"Picking up...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		
		[[API sharedInstance] pickUpItemWithGuid:item.guid completionHandler:^(NSString *errorStr) {
			
			[HUD hide:YES];
			
			[mapView removeAnnotation:item];
			item.latitude = 0;
			item.longitude = 0;
			item.dropped = NO;

			[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
			
			if (errorStr) {
				
				HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
				HUD.userInteractionEnabled = YES;
				HUD.dimBackground = YES;
				HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
				HUD.mode = MBProgressHUDModeCustomView;
				HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
				HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
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

		return nil;
		
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

		if (circle.deployedResonator) {
			DeployedResonatorView *circleView = [[DeployedResonatorView alloc] initWithCircle:circle];
			circleView.fillColor = [API colorForLevel:circle.deployedResonator.level];
			//circleView.alpha = .1;
			return circleView;
		} else if (circle.energyGlob) {
			XMOverlayView *circleView = [[XMOverlayView alloc] initWithCircle:circle];
			circleView.fillColor = [UIColor whiteColor];
			return circleView;
		}

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
//	if ([tappedOverlay isKindOfClass:[Portal class]]) {
//		currentPortal = (Portal *)tappedOverlay;
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

#pragma mark - Collecting XM

- (IBAction)collectXM {

	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.dimBackground = YES;
	HUD.showCloseButton = YES;
	_xmCollectView = [XMCollectViewController xmCollectView];
	HUD.customView = _xmCollectView.view;
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];

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
	
	XMP *xmpItem = [XMP MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", level]];

	NSLog(@"Firing: %@", xmpItem);
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_emp_power_up.aif"];
	
	if (!xmpItem) {
		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
		HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.detailsLabelText = @"No XMP remaining!";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:3];
		return;
	}
	
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.dimBackground = YES;
	HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	HUD.labelText = [NSString stringWithFormat:@"Firing XMP of level: %d", level];
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];
	
	[[API sharedInstance] fireXMP:xmpItem completionHandler:^(NSString *errorStr, NSDictionary *damages) {
		
		[HUD hide:YES];
		
		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		
		if (damages) {
			
//			HUD.mode = MBProgressHUDModeText;
//			HUD.labelText = @"Damages";
//			HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:10];
			
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

				Portal *portal = [Portal MR_findFirstByAttribute:@"guid" withValue:portalGUID];
				[damagesStr appendFormat:@"%@:\n", portal.subtitle];
				
				for (NSDictionary *damage in damagesArray) {
					int damageAmount = [damage[@"damageAmount"] intValue];
					int slot = [damage[@"targetSlot"] intValue];
					BOOL critical = [damage[@"criticalHit"] boolValue];
					BOOL destroyed = [damage[@"targetDestroyed"] boolValue];
					
					if (destroyed) {
						[[SoundManager sharedManager] playSound:@"Sound/sfx_explode_resonator.aif"];
					}
					
					DeployedResonator *resonator = [DeployedResonator MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", portal, slot]];
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
			HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
			
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
