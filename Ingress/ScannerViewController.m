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

	locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
	
	[locationManager startUpdatingLocation];
//	[locationManager startUpdatingHeading];

	if (YES) { // TODO: Free moving allowed for debug only
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			[locationManager stopUpdatingLocation];
			[_mapView setScrollEnabled:YES];
		});
	}

	[[AppDelegate instance] setMapView:_mapView];

	UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[_mapView addGestureRecognizer:recognizer];

//	rangeCircleView = [UIView new];
//	rangeCircleView.frame = CGRectMake(0, 0, 0, 0);
//	rangeCircleView.center = _mapView.center;
//	rangeCircleView.backgroundColor = [UIColor clearColor];
//	rangeCircleView.opaque = NO;
//	rangeCircleView.userInteractionEnabled = NO;
//	rangeCircleView.layer.cornerRadius = 0;
//	rangeCircleView.layer.masksToBounds = YES;
//	rangeCircleView.layer.borderWidth = 2;
//	rangeCircleView.layer.borderColor = [[[UIColor blueColor] colorWithAlphaComponent:0.25] CGColor];
//	[self.view addSubview:rangeCircleView];
//
//	[NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCircle) userInfo:nil repeats:YES];

//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
//		[_mapView setRegion:MKCoordinateRegionMakeWithDistance(_mapView.userLocation.location.coordinate, 150, 150) animated:NO];
//		[_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
//		[_mapView setShowsUserLocation:YES];
//	});

//	UILongPressGestureRecognizer *xmpLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(xmpLongPressGestureHandler:)];
//	[fireXmpButton addGestureRecognizer:xmpLongPressGesture];

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
	
//	[mapView.userLocation addObserver:self forKeyPath:@"location" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
	
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

//	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

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

//#pragma mark - Map Data Calc
//
//- (double)convertCenterLat:(CLLocationDegrees)centerLat {
//	return round(256 * 0.9999 * ABS(1 / cos(centerLat * (M_PI/180))));
//}
//
//- (double)calculateR:(double)convCenterLat {
//	return 1 << _mapView.zoomLevel - (int)round(convCenterLat / 256 - 1);
//}
//
//- (CGPoint)convertLatLngToPoint:(CLLocationCoordinate2D)latlng magic:(double)magic R:(double)R {
//	double x = (magic/2 + latlng.longitude * magic / 360)*R;
//	double l = sin(latlng.latitude * (M_PI/180));
//	double y =  (magic/2 + 0.5*log((1+l)/(1-l)) * -(magic / (2*M_PI)))*R;
//	return CGPointMake(floor(x/magic), floor(y/magic));
//}
//
//- (NSArray *)convertPointToLatLng:(CGPoint)point magic:(double)magic R:(double)R {
//
//	// orig function put together from all over the place
//	// lat: (2 * Math.atan(Math.exp((((y + 1) * magic / R) - (magic/ 2)) / (-1*(magic / (2 * Math.PI))))) - Math.PI / 2) / (Math.PI / 180),
//	// shortened version by your favorite algebra program.
//	CLLocationCoordinate2D sw = CLLocationCoordinate2DMake((360*atan(exp(M_PI - 2*M_PI*(point.y+1)/R)))/M_PI - 90, 360*point.x/R-180);
//	CLLocation *swLoc = [[CLLocation alloc] initWithLatitude:sw.latitude longitude:sw.longitude];
//
//	// lat: (2 * Math.atan(Math.exp(((y * magic / R) - (magic/ 2)) / (-1*(magic / (2 * Math.PI))))) - Math.PI / 2) / (Math.PI / 180),
//	CLLocationCoordinate2D ne = CLLocationCoordinate2DMake((360*atan(exp(M_PI - 2*M_PI*point.y/R)))/M_PI - 90, 360*(point.x+1)/R-180);
//	CLLocation *neLoc = [[CLLocation alloc] initWithLatitude:ne.latitude longitude:ne.longitude];
//
//	return @[swLoc, neLoc];
//
//}
//
//// calculates the quad key for a given point. The point is not(!) in lat/lng format.
//- (NSString *)pointToQuadKey:(CGPoint)point {
////	return [NSString stringWithFormat:@"%d_%.0f_%.0f", _mapView.zoomLevel-1, point.x, point.y];
//	NSMutableArray *quadkey = [NSMutableArray array];
//	for(int c = _mapView.zoomLevel-1; c > 0; c--) {
//		//  +-------+   quadrants are probably ordered like this
//		//  | 0 | 1 |
//		//  |---|---|
//		//  | 2 | 3 |
//		//  |---|---|
//		int quadrant = 0;
//		int e = 1 << c - 1;
//		((int)point.x & e) != 0 && quadrant++;               // push right
//		((int)point.y & e) != 0 && (quadrant++, quadrant++); // push down
//		[quadkey addObject:@(quadrant)];
//	}
//	return [quadkey componentsJoinedByString:@""];
//}
//
//// given quadkey and bounds, returns the format as required by the Ingress API to request map data.
//- (NSDictionary *)generateBoundsParams:(NSString *)quadkey bounds:(NSArray *)bounds {
//	return @{
//		@"id": quadkey,
//		@"qk": quadkey,
//		@"minLatE6": @(round([bounds[0] coordinate].latitude * 1E6)),
//		@"minLngE6": @(round([bounds[0] coordinate].longitude * 1E6)),
//		@"maxLatE6": @(round([bounds[1] coordinate].latitude * 1E6)),
//		@"maxLngE6": @(round([bounds[1] coordinate].longitude * 1E6))
//	};
//}



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

//#pragma mark - Circle
//
//- (void)updateCircle {
//	CGFloat diameter = 100/((_mapView.region.span.latitudeDelta * 111200) / _mapView.bounds.size.width);
//	rangeCircleView.frame = CGRectMake(0, 0, diameter, diameter);
//	rangeCircleView.center = _mapView.center;
//	rangeCircleView.layer.cornerRadius = diameter/2;
//}

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
	return YES;
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

			[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
			
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
	
	XMP *xmpItem = [XMP MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", level] andRetrieveAttributes:@[@"guid"]];

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
	HUD.labelText = [NSString stringWithFormat:@"Firing XMP of level: %d", level];
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
