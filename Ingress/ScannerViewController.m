//
//  ViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 08.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ScannerViewController.h"
#import "PortalDetailViewController.h"
#import "MissionViewController.h"
#import "MKMapView+ZoomLevel.h"
#import "NewPortalViewController.h"

#import "PortalOverlayView.h"
#import "MKPolyline+PortalLink.h"
#import "MKPolygon+ControlField.h"
#import "MKCircle+Ingress.h"
#import "DeployedResonatorView.h"
#import "XMOverlayView.h"
#import "XMOverlay.h"

#define IG_RANGE_CIRCLE_VIEW_BORDER_WIDTH 2

@interface ScannerViewController ()

@property (nonatomic, strong) IBOutlet UIPopoverController *popover;

@end

@implementation ScannerViewController {

	Portal *currentPortal;
	Item *currentItem;

	UIImageView *rangeCircleImageView;
	UIImageView *playerArrowImage;
    
	CLLocation *lastLocation;
	BOOL firstRefreshProfile;
	BOOL firstLocationUpdate;
	BOOL portalDetailSegue;
	MBProgressHUD *locationAllowHUD;
    XMOverlay *_xmOverlay;
    XMOverlayView *_xmOverlayView;

	NSTimer *refreshTimer;

	NSMutableSet *mapGuids;
    
    UIImage *selectedPortalImage;
	CLLocation *selectedPortalLocation;
	
	NearbyPortalView *nearbyPortalView;
	
}

@synthesize virusToUse = _virusToUse;

- (void)viewDidLoad {
    [super viewDidLoad];

	[ControlField MR_truncateAll];
	[PortalLink MR_truncateAll];
	[Item MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"dropped = YES"]];
	[EnergyGlob MR_truncateAll];
	[DeployedResonator MR_truncateAll];
	[DeployedMod MR_truncateAll];

	mapGuids = [NSMutableSet set];

	[[AppDelegate instance] setMapView:_mapView];

	levelLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:32];
	nicknameLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
	apLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
	xmLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
	virusChoosePortalLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
    
    [opsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[opsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    opsButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18];
    opsButton.titleLabel.layer.shadowColor = [UIColor whiteColor].CGColor;

	apLabel.hidden = YES;
	xmLabel.hidden = YES;
	apLabel.alpha = 0;
	xmLabel.alpha = 0;

	firstRefreshProfile = YES;
	firstLocationUpdate = YES;

	[xmIndicator setProgressImage:[[UIImage imageNamed:@"progressImage-aliens.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)]];
	[xmIndicator setTrackImage:[[UIImage imageNamed:@"trackImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)]];

    [self validateLocationServicesAuthorization];

	CGFloat offset = 32;
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
	if ([Utilities isOS7]) {
        offset += 20;
    }
    #endif
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	commVC = [storyboard instantiateViewControllerWithIdentifier:@"CommViewController"];
	commVC.view.frame = CGRectMake(0, self.view.frame.size.height-offset, self.view.frame.size.width, 393);
	[self.view addSubview:commVC.view];
	[self addChildViewController:commVC];
	
	playerArrowImage = [UIImageView new];
	playerArrowImage.frame = CGRectMake(0, 0, 50, 50);
	playerArrowImage.center = _mapView.center;
	[self.view insertSubview:playerArrowImage belowSubview:commVC.view];
	
//	locationManager = [LocationManager locationManager];
//    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//	if ([locationManager respondsToSelector:@selector(activityType)]) {
//		locationManager.activityType = CLActivityTypeFitness;
//	}
//	
//	[locationManager startUpdatingLocation];
//	[locationManager startUpdatingHeading];
    
    [[LocationManager sharedInstance] addDelegate:self];

	UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[_mapView addGestureRecognizer:recognizer];

#if DEBUG
#warning Manual scrolling for debug purposes only!
	UITapGestureRecognizer *mapViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
	mapViewTapGestureRecognizer.numberOfTapsRequired = 2;
	[_mapView addGestureRecognizer:mapViewTapGestureRecognizer];
#endif

	UILongPressGestureRecognizer *mapViewLognPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapLongPress:)];
	[_mapView addGestureRecognizer:mapViewLognPressGestureRecognizer];

	#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000

	if ([_mapView respondsToSelector:@selector(isPitchEnabled)]) {
		_mapView.pitchEnabled = NO;
	}

	if ([_mapView respondsToSelector:@selector(isRotateEnabled)]) {
		_mapView.rotateEnabled = NO;
	}

	#endif

//	_mapView.scrollEnabled = YES;
//	_mapView.zoomEnabled = YES;

	for (UIView *view in _mapView.subviews) {
		if ([view isKindOfClass:NSClassFromString(@"MKAttributionLabel")]) {
			[view removeFromSuperview];
		}
	}
    
    self.alienPortalImage = [UIImage imageNamed:@"portal_aliens"];
    self.resistancePortalImage = [UIImage imageNamed:@"portal_resistance"];
    self.neutralPortalImage = [UIImage imageNamed:@"portal_neutral"];

    _xmOverlay = [XMOverlay new];
    [_mapView addOverlay:_xmOverlay];
    
    quickActionsMenu = [[QuickActionsMenu alloc] initWithSeletionHandler:^(int option) {

        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
        }
        
        switch (option) {
            case 1:
                [self fireXMP];
                break;
            case 2: {
                
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
				actionSheet.tag = 3;
				[actionSheet showInView:self.view.window];
                
                break;
            }
            case 3: {
            	[self refresh];
            	break;
            }
            case 4: {
                
                NSMutableArray *itemsToCollect = [NSMutableArray array];
                for (Item *droppedItem in [Item MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"dropped = YES"]]) {
                    if ([droppedItem distanceFromCoordinate:_mapView.centerCoordinate] <= SCANNER_RANGE) {
                        [itemsToCollect addObject:droppedItem];
                    }
                }
                
                if (itemsToCollect.count > 0) {
                    
                    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
                    HUD.removeFromSuperViewOnHide = YES;
                    HUD.userInteractionEnabled = YES;
                    HUD.mode = MBProgressHUDModeIndeterminate;
                    HUD.dimBackground = YES;
                    HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
                    HUD.labelText = @"Picking up...";
                    [[AppDelegate instance].window addSubview:HUD];
                    [HUD show:YES];
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                        [[API sharedInstance] playSound:@"SFX_RESOURCE_PICK_UP"];
                    }
                    
                    __block int completed = 0;
                    for (Item *droppedItem in itemsToCollect) {
                        
                        [[API sharedInstance] pickUpItemWithGuid:droppedItem.guid completionHandler:^(NSString *errorStr) {
                            
                            completed++;
                            
                            if (completed == itemsToCollect.count) {
                                [HUD hide:YES];
                            }
                            
                            [_mapView removeAnnotation:droppedItem];
                            
                            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                Item *item = (Item *)[localContext existingObjectWithID:droppedItem.objectID error:nil];
                                item.latitude = 0;
                                item.longitude = 0;
                                item.dropped = NO;
                            } completion:^(BOOL success, NSError *error) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"InventoryUpdatedNotification" object:nil];
                            }];
                            
                        }];
                        
                    }
                    
                }
                
                break;
            }
        }
        
    }];
    [self.view addSubview:quickActionsMenu];
    
	[[NSNotificationCenter defaultCenter] addObserverForName:@"DBUpdatedNotification" object:nil queue:nil usingBlock:^(NSNotification *note) {
        //if ([self isSelectedAndTopmost]) {
		[self refreshProfile];
        //}
	}];
}

- (void)viewWillLayoutSubviews {
	if ([Utilities isOS7]) {
		CGRect frame = self.view.frame;
		frame.origin.y = 20;
		frame.size.height = [UIScreen mainScreen].bounds.size.height-20;
		self.view.frame = frame;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:YES animated:YES];

	[[[GAI sharedInstance] defaultTracker] sendView:@"Scanner Screen"];

//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];

	//[self refreshProfile];

	if (self.virusToUse) {
		virusChoosePortalLabel.hidden = NO;
		virusChoosePortalCancelButton.hidden = NO;
	} else {
		virusChoosePortalLabel.hidden = YES;
		virusChoosePortalCancelButton.hidden = YES;
	}
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

	Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
	if (player.allowFactionChoice) {
		[self performSegueWithIdentifier:@"FactionChooseSegue" sender:self];
	}

}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (portalDetailSegue) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
}

- (BOOL)isSelectedAndTopmost {
    return ((self.tabBarController.selectedViewController == self.navigationController) &&
            (self.navigationController.visibleViewController == self));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

	_opsViewController = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Data Refresh

- (void)refresh {

//	if (refreshTimer) {
//		[refreshTimer invalidate];
//		refreshTimer = nil;
//	}
//	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(refresh) userInfo:nil repeats:NO];

    NSManagedObjectContext *context  = [NSManagedObjectContext MR_contextForCurrentThread];

	[[API sharedInstance] getObjectsWithCompletionHandler:^{

		[_mapView removeAnnotations:_mapView.annotations];

		NSMutableArray *overlays = [_mapView.overlays mutableCopy];
		[overlays removeObject:_xmOverlay];
		[_mapView removeOverlays:overlays];

		[context performBlock:^{

			NSArray *fetchedFields = [ControlField MR_findAllInContext:context];
			for (ControlField *controlField in fetchedFields) {
				if (MKMapRectIntersectsRect(_mapView.visibleMapRect, controlField.polygon.boundingMapRect)) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[_mapView addOverlay:controlField.polygon];
					});
				}
			}

			NSArray *fetchedLinks = [PortalLink MR_findAllInContext:context];
			for (PortalLink *portalLink in fetchedLinks) {
				if (MKMapRectIntersectsRect(_mapView.visibleMapRect, portalLink.polyline.boundingMapRect)) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[_mapView addOverlay:portalLink.polyline];
					});
				}
			}

			NSArray *fetchedItems = [Item MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"dropped = YES"] inContext:context];
			for (Item *item in fetchedItems) {
				//NSLog(@"adding item to map: %@ (%f, %f)", item, item.latitude, item.longitude);
				if (item.coordinate.latitude == 0 && item.coordinate.longitude == 0) { continue; }
				if (MKMapRectContainsPoint(_mapView.visibleMapRect, MKMapPointForCoordinate(item.coordinate))) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[_mapView addAnnotation:item];
					});
				}
			}
			
			// ---------------------------------------------------

			__block int addedPortals = 0;
			NSArray *fetchedPortals = [Portal MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"completeInfo = YES"] inContext:context];
			for (Portal *portal in fetchedPortals) {
				//NSLog(@"adding portal to map: %@ (%f, %f)", portal.subtitle, portal.latitude, portal.longitude);
				if (portal.coordinate.latitude == 0 && portal.coordinate.longitude == 0) { continue; }
				if (MKMapRectContainsPoint(_mapView.visibleMapRect, MKMapPointForCoordinate(portal.coordinate))) {
					addedPortals++;
					dispatch_async(dispatch_get_main_queue(), ^{
						[_mapView addAnnotation:portal];
						[_mapView addOverlay:portal];
					});
				}
			}
			
			if (addedPortals == 0) {
				[[API sharedInstance] findNearbyPortalsWithCompletionHandler:^(NSArray *portals) {
					if ([nearbyPortalView.portalGUID isEqualToString:portals[0][@"guid"]]) {
						[nearbyPortalView updateInformation];
					} else {
						if( nearbyPortalView ) {
							[nearbyPortalView removeFromSuperview];
							nearbyPortalView = nil;
						}
					
						nearbyPortalView = [[NearbyPortalView alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-140, 280, 80) portal:portals[0]];
						nearbyPortalView.alpha = 0;
						[self.view insertSubview:nearbyPortalView belowSubview:commVC.view];
		
						[UIView animateWithDuration:0.15 animations:^{
							nearbyPortalView.alpha = 1;
						}];
					}
				}];
			} else if( nearbyPortalView ) {
				[nearbyPortalView removeFromSuperview];
				nearbyPortalView = nil;
			}
			
			// ---------------------------------------------------

			NSArray *fetchedResonators = [DeployedResonator MR_findAllInContext:context];
			for (DeployedResonator *resonator in fetchedResonators) {
				//NSLog(@"adding resonator to map: %@ (%f, %f)", resonator, resonator.coordinate.latitude, resonator.coordinate.longitude);
				if (resonator.portal.coordinate.latitude == 0 && resonator.portal.coordinate.longitude == 0) { continue; }
				if (MKMapRectContainsPoint(_mapView.visibleMapRect, MKMapPointForCoordinate(resonator.portal.coordinate))) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[_mapView addOverlay:resonator.circle];
					});
				}
			}

			NSArray *fetchedEnergy = [EnergyGlob MR_findAllInContext:context];
			NSMutableArray *globs = [NSMutableArray arrayWithCapacity:fetchedEnergy.count];
			for (EnergyGlob *energyGlob in fetchedEnergy) {
				[globs addObject:@{@"location": [[CLLocation alloc] initWithLatitude:energyGlob.latitude longitude:energyGlob.longitude], @"amount": @(energyGlob.amount)}];
			}
			_xmOverlay.globs = globs;

			dispatch_async(dispatch_get_main_queue(), ^{
				[_xmOverlayView setNeedsDisplayInMapRect:_mapView.visibleMapRect];
			});

		}];

	}];
}

- (void)refreshProfile {

	Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];

	int ap = player.ap;
	int level = player.level;
	int maxAp = player.nextLevelAP;
	float energy = player.energy;
	float maxEnergy = player.maxEnergy;

	[apLabel setText:[NSString stringWithFormat:@"%d / %d AP", ap, maxAp]];
	[xmLabel setText:[NSString stringWithFormat:@"%d XM", (int)energy]];

	NSMutableParagraphStyle *pStyle = [NSMutableParagraphStyle new];
    pStyle.alignment = NSTextAlignmentRight;

	UIColor *teamColor = [Utilities colorForFaction:player.team];
	
	[apView setFaction:player.team];
	NSArray *maxAPs = @[@0, @10000, @30000, @70000, @150000, @300000, @600000, @1200000, @(INFINITY)];
	[apView setProgress:(maxAp == 0 ? 0 : ((ap - [maxAPs[level - 1] floatValue]) / ([maxAPs[level] floatValue] - [maxAPs[level - 1] floatValue])))];

	levelLabel.text = [NSString stringWithFormat:@"%d", level];

	nicknameLabel.textColor = teamColor;
	nicknameLabel.text = player.nickname;

	if ([player.team isEqualToString:@"RESISTANCE"]) {
		[xmIndicator setProgressImage:[[UIImage imageNamed:@"progressImage-resistance.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)]];
		[playerArrowImage setImage:[UIImage imageNamed:@"playerArrow_resistance.png"]];
	} else {
		[xmIndicator setProgressImage:[[UIImage imageNamed:@"progressImage-aliens.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)]];
		[playerArrowImage setImage:[UIImage imageNamed:@"playerArrow_aliens.png"]];
	}

	[xmIndicator setProgress:(energy/maxEnergy) animated:!firstRefreshProfile];

	firstRefreshProfile = NO;

}

#pragma mark - IBActions

- (IBAction)showAP {
	if (apLabel.hidden) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
        }
        
		[apLabel setHidden:NO];
		[UIView animateWithDuration:.5 animations:^{
			[apLabel setAlpha:1];
		}];
		[UIView animateWithDuration:.5 delay:2 options:0 animations:^{
			[apLabel setAlpha:0];
		} completion:^(BOOL finished) {
			[apLabel setHidden:YES];
		}];
	}
}

- (IBAction)showXM {
	if (xmLabel.hidden) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
        }
        
		[xmLabel setHidden:NO];
		[UIView animateWithDuration:.5 animations:^{
			[xmLabel setAlpha:1];
		}];
		[UIView animateWithDuration:.5 delay:2 options:0 animations:^{
			[xmLabel setAlpha:0];
		} completion:^(BOOL finished) {
			[xmLabel setHidden:YES];
		}];
	}
}

- (IBAction)virusChoosePortalCancel {    
	virusChoosePortalLabel.hidden = YES;
	virusChoosePortalCancelButton.hidden = YES;

	self.virusToUse = nil;
}

#pragma mark - Map Data Managing

- (void)insertObjectToMapView:(NSManagedObject *)object {

	MKMapRect mapRect = MKMapRectWorld; //MKMapRectOffset(_mapView.visibleMapRect, 1024, 1024);
	
	if ([object isKindOfClass:[Portal class]]) {
		Portal *portal = (Portal *)object;
		if (![mapGuids containsObject:portal.guid] && MKMapRectContainsPoint(mapRect, MKMapPointForCoordinate(portal.coordinate))) {
			[mapGuids addObject:portal.guid];
			dispatch_async(dispatch_get_main_queue(), ^{
				[_mapView addOverlay:portal];
				[_mapView addAnnotation:portal];
			});
		}
//	} else if ([object isKindOfClass:[EnergyGlob class]]) {
//		EnergyGlob *xm = (EnergyGlob *)object;
//		if (![mapGuids containsObject:xm.guid] && MKMapRectContainsPoint(mapRect, MKMapPointForCoordinate(xm.coordinate))) {
//			[mapGuids addObject:xm.guid];
////			NSLog(@"XM %@ (%d) adding", xm.guid, xm.amount);
//			dispatch_async(dispatch_get_main_queue(), ^{
//				[_mapView addOverlay:xm.circle];
//			});
//		}
	} else if ([object isKindOfClass:[Item class]] && ![object isKindOfClass:[EnergyGlob class]]) {
		Item *item = (Item *)object;
		if (![mapGuids containsObject:item.guid] && MKMapRectContainsPoint(mapRect, MKMapPointForCoordinate(item.coordinate))) {
			[mapGuids addObject:item.guid];
			dispatch_async(dispatch_get_main_queue(), ^{
				[_mapView addAnnotation:item];
			});
		}
	} else if ([object isKindOfClass:[PortalLink class]]) {
		PortalLink *portalLink = (PortalLink *)object;
		if (![mapGuids containsObject:portalLink.guid] && (MKMapRectIntersectsRect(mapRect, portalLink.polyline.boundingMapRect) || MKMapRectContainsRect(_mapView.visibleMapRect, portalLink.polyline.boundingMapRect))) {
			[mapGuids addObject:portalLink.guid];
			dispatch_async(dispatch_get_main_queue(), ^{
				[_mapView addOverlay:portalLink.polyline];
			});
		}
	} else if ([object isKindOfClass:[ControlField class]]) {
		ControlField *controlField = (ControlField *)object;
		if (![mapGuids containsObject:controlField.guid] && (MKMapRectIntersectsRect(mapRect, controlField.polygon.boundingMapRect) || MKMapRectContainsRect(_mapView.visibleMapRect, controlField.polygon.boundingMapRect))) {
			[mapGuids addObject:controlField.guid];
			dispatch_async(dispatch_get_main_queue(), ^{
				[_mapView addOverlay:controlField.polygon];
			});
		}
	} else if ([object isKindOfClass:[DeployedResonator class]]) {
		DeployedResonator *resonator = (DeployedResonator *)object;
		NSString *resonatorGuid = [NSString stringWithFormat:@"%@-%d", resonator.portal.guid, resonator.slot];
		if (![mapGuids containsObject:resonatorGuid] && MKMapRectContainsPoint(mapRect, MKMapPointForCoordinate(resonator.circle.coordinate))) {
			[mapGuids addObject:resonatorGuid];
			dispatch_async(dispatch_get_main_queue(), ^{
				[_mapView addOverlay:resonator.circle];
			});
		}
	}
	
}

- (void)removeObjectFromMapView:(NSManagedObject *)object {
	
	if ([object isKindOfClass:[Portal class]]) {
		Portal *portal = (Portal *)object;
		[mapGuids removeObject:portal.guid];
		dispatch_async(dispatch_get_main_queue(), ^{
			[_mapView removeOverlay:portal];
			[_mapView removeAnnotation:portal];
		});
//	} else if ([object isKindOfClass:[EnergyGlob class]]) {
//		EnergyGlob *xm = (EnergyGlob *)object;
//		[mapGuids removeObject:xm.guid];
//		NSLog(@"XM %@ (%d) removing", xm.guid, xm.amount);
//		dispatch_async(dispatch_get_main_queue(), ^{
//			[_mapView removeOverlay:xm.circle];
//		});
	} else if ([object isKindOfClass:[Item class]] && ![object isKindOfClass:[EnergyGlob class]]) {
		Item *item = (Item *)object;
		[mapGuids removeObject:item.guid];
		dispatch_async(dispatch_get_main_queue(), ^{
			[_mapView removeAnnotation:item];
		});
	} else if ([object isKindOfClass:[PortalLink class]]) {
		PortalLink *portalLink = (PortalLink *)object;
		[mapGuids removeObject:portalLink.guid];
		dispatch_async(dispatch_get_main_queue(), ^{
			[_mapView removeOverlay:portalLink.polyline];
		});
	} else if ([object isKindOfClass:[ControlField class]]) {
		ControlField *controlField = (ControlField *)object;
		[mapGuids removeObject:controlField.guid];
		dispatch_async(dispatch_get_main_queue(), ^{
			[_mapView removeOverlay:controlField.polygon];
		});
	} else if ([object isKindOfClass:[DeployedResonator class]]) {
		DeployedResonator *resonator = (DeployedResonator *)object;
		[mapGuids removeObject:[NSString stringWithFormat:@"%@-%d", resonator.portal.guid, resonator.slot]];
		dispatch_async(dispatch_get_main_queue(), ^{
			[_mapView removeOverlay:resonator.circle];
		});
	}
	
}

#pragma mark - NSManagedObjectContext Did Change

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification {
	NSArray *deletedObject = [notification.userInfo[NSDeletedObjectsKey] allObjects];
	for (NSManagedObject *object in deletedObject) {
		[self removeObjectFromMapView:object];
	}

	NSArray *insertedObject = [notification.userInfo[NSInsertedObjectsKey] allObjects];
	for (NSManagedObject *object in insertedObject) {
		[self insertObjectToMapView:object];
	}

	NSArray *updatedObject = [notification.userInfo[NSUpdatedObjectsKey] allObjects];
	for (NSManagedObject *object in updatedObject) {
		[self removeObjectFromMapView:object];
		[self insertObjectToMapView:object];
	}
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _xmOverlay.globs = [EnergyGlob MR_findAll];
        [_xmOverlayView setNeedsDisplayInMapRect:_mapView.visibleMapRect];
    });

}

#pragma mark - Update

- (void)validateLocationServicesAuthorization {
	if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
		if (!locationAllowHUD) {
			_mapView.hidden = YES;
			playerArrowImage.hidden = YES;
			locationAllowHUD = [[MBProgressHUD alloc] initWithView:self.view];
			locationAllowHUD.userInteractionEnabled = NO;
			locationAllowHUD.mode = MBProgressHUDModeCustomView;
			locationAllowHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
			locationAllowHUD.labelText = @"Please allow location services";
			locationAllowHUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
			locationAllowHUD.removeFromSuperViewOnHide = YES;
			__weak __block typeof(locationAllowHUD) weakLocationAllowHUD = locationAllowHUD;
			locationAllowHUD.completionBlock = ^{
				weakLocationAllowHUD = nil;
			};
			[self.view addSubview:locationAllowHUD];
			[locationAllowHUD show:YES];
		}
	} else {
		if (locationAllowHUD) {
			[locationAllowHUD hide:YES];
			_mapView.hidden = NO;
			playerArrowImage.hidden = NO;
		}
	}
    
    [self updateRangeCircleView];
}

- (void)updateRangeCircleView {
    
    // Create view on first update
    if (!rangeCircleImageView) {
		rangeCircleImageView = [UIImageView new];
        rangeCircleImageView.image = [UIImage imageNamed:@"compass_ring.png"];
        rangeCircleImageView.opaque = NO;
        rangeCircleImageView.userInteractionEnabled = NO;
        rangeCircleImageView.clipsToBounds = YES;
        [self.view addSubview:rangeCircleImageView];
    }
    
    // Hide view while no sensible data can be shown
    if (locationAllowHUD) {
        rangeCircleImageView.hidden = YES;
        return;
    }

	if (_mapView.bounds.size.width > 0 && _mapView.region.span.latitudeDelta > 0) {
		MKMapRect mRect = _mapView.visibleMapRect;
		MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
		MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
		CLLocationDistance altDistance = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
		CGFloat width = ((_mapView.frame.size.width * SCANNER_RANGE) / altDistance)*2;
		rangeCircleImageView.frame = CGRectMake(0, 0, width, width);
		rangeCircleImageView.center = _mapView.center;
	}

}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self validateLocationServicesAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
	[_mapView setCenterCoordinate:newLocation.coordinate animated:!firstLocationUpdate];
	if (firstLocationUpdate) firstLocationUpdate = NO;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    /* 
     Using CoreAnimation to improve performance here. Mad world... :)
     
     Changing UIView.transform matrix became very time consuming process after
     introduction of AutoLayout, so we do it less often, but animate
     transitions. This way it both looks reasonably responsive, and doesn't burn
     CPU and battery. Animation duration is a knob to fine-tune, since newer
     devices can probably get away with more frequent updates, but my vintage
     iPhone 4 is the only device i can run this project on.
     */
    
    #define INGRESS_SCANNER_BEARING_ANIMATION_DURATION 0.2
    
    if (!playerArrowImage.layer.animationKeys.count) {
        [UIView animateWithDuration:INGRESS_SCANNER_BEARING_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGAffineTransform transform = CGAffineTransformMakeRotation(GLKMathDegreesToRadians(newHeading.trueHeading));
            playerArrowImage.transform = transform;
			playerArrowImage.center = _mapView.center;
        } completion:nil];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	if (actionSheet.tag == 1 && buttonIndex == 0) {
		
		__block Item *item = currentItem;

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.removeFromSuperViewOnHide = YES;
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.labelText = @"Picking up...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

		[[API sharedInstance] pickUpItemWithGuid:item.guid completionHandler:^(NSString *errorStr) {

			[HUD hide:YES];

			[_mapView removeAnnotation:item];

			[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
				Item *item = (Item *)[localContext existingObjectWithID:currentItem.objectID error:nil];
				item.latitude = 0;
				item.longitude = 0;
				item.dropped = NO;
			} completion:^(BOOL success, NSError *error) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"InventoryUpdatedNotification" object:nil];
			}];

			if (errorStr) {
				[Utilities showWarningWithTitle:errorStr];
			} else {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                    [[API sharedInstance] playSound:@"SFX_RESOURCE_PICK_UP"];
                }
			}
			
		}];

	} else if (actionSheet.tag == 2 && buttonIndex == 0) {

		virusChoosePortalLabel.hidden = YES;
		virusChoosePortalCancelButton.hidden = YES;

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.removeFromSuperViewOnHide = YES;
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.labelText = @"Deploying Virus...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[API sharedInstance] playSound:@"SFX_FLIPCARD_SWIRL"];
            [[SoundManager sharedManager] playSound:@"Sound/sfx_flipcard_tugofwar.aif"];
        }
        
		[[API sharedInstance] flipPortal:currentPortal withFlipCard:self.virusToUse completionHandler:^(NSString *errorStr) {
			[HUD hide:YES];
			self.virusToUse = nil;
			if (errorStr) {
				[Utilities showWarningWithTitle:errorStr];
			} else {
				if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
					[[API sharedInstance] playSound:@"SFX_FLIPCARD_EXPLOSION"];
				}
				[self refresh];
			}
		}];
		
	} else if (actionSheet.tag == 3) {
    
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            UIImagePickerController *imagePickerVC = [UIImagePickerController new];
            
            if (buttonIndex == 0) {
				if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
                imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            } else if (buttonIndex == 1) {
                imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            
            imagePickerVC.delegate = self;
			
			if ([Utilities isPad]) {
				self.popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerVC];
				self.popover.popoverContentSize = CGSizeMake(320, 480);
				[self.popover presentPopoverFromRect:apView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			} else {
				imagePickerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
				[self presentViewController:imagePickerVC animated:YES completion:nil];
			}

        }
        
    }

}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

	if (mapView.zoomLevel < 15) {
		if ([Utilities isOS7]) {
//            [mapView setCenterCoordinate:mapView.centerCoordinate zoomLevel:15 animated:NO];
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
//				MKMapCamera *camera = [MKMapCamera camera];
//				camera.centerCoordinate = mapView.centerCoordinate;
//				camera.heading = 0;
//				camera.pitch = 0;
//				camera.altitude = 50;
//				NSLog(@"camera: %@", camera);
//				[mapView setCamera:camera animated:NO];
//#endif
		} else {
			[mapView setCenterCoordinate:mapView.centerCoordinate zoomLevel:15 animated:NO];
		}
		return;
    }

	Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];

	int energy = player.energy;
	int maxEnergy = player.maxEnergy;
	int collecting = 0;

	if (energy < maxEnergy) {
		[[[API sharedInstance] energyToCollect] removeAllObjects];
		for (EnergyGlob *xm in [EnergyGlob MR_findAll]) {
			if ([xm distanceFromCoordinate:_mapView.centerCoordinate] <= SCANNER_RANGE) {
				[[[API sharedInstance] energyToCollect] addObject:xm];
				collecting += xm.amount;
			}
			if (collecting >= (maxEnergy-energy)) {
				break;
			}
		}
		//NSLog(@"Collecting %d (%d) XM", [[[API sharedInstance] energyToCollect] count], collecting);
	}

	CLLocation *mapLocation = [[CLLocation alloc] initWithLatitude:_mapView.centerCoordinate.latitude longitude:_mapView.centerCoordinate.longitude];
	CLLocationDistance meters = [mapLocation distanceFromLocation:lastLocation];
	if (meters == -1 || meters >= 10 || isnan(meters)) {
		lastLocation = mapLocation;
		[self refresh];
	}

    [self updateRangeCircleView];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    [EAGLContext setCurrentContext:nil];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	[_mapView deselectAnnotation:view.annotation animated:NO];
	if ([view.annotation isKindOfClass:[Portal class]]) {
		currentPortal = (Portal *)view.annotation;
		if (self.virusToUse) {
			if ([currentPortal distanceFromCoordinate:_mapView.centerCoordinate] <= SCANNER_RANGE) {
				if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
					[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
				}

				UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Confirm Deployment" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Confirm", nil];
				actionSheet.tag = 2;
				[actionSheet showInView:self.view.window];
			}
		} else {
			[self performSegueWithIdentifier:@"PortalDetailSegue" sender:self];
		}
	} else if ([view.annotation isKindOfClass:[Item class]]) {
		if ([(Item *)(view.annotation) distanceFromCoordinate:_mapView.centerCoordinate] <= SCANNER_RANGE) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
            }
            
			currentItem = (Item *)view.annotation;
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:currentItem.title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Acquire", nil];
			actionSheet.tag = 1;
			[actionSheet showInView:self.view.window];
		}
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	if ([annotation isKindOfClass:[Portal class]]) {
		
		static NSString *AnnotationViewID = @"portalAnnotationView";
		
		MKAnnotationView *annotationView = /*(PortalAnnotationView *)*/[_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
		if (annotationView == nil) {
			annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
			annotationView.canShowCallout = NO;
		}
		
		annotationView.annotation = annotation;
		
		Portal *portal = (Portal *)annotation;
		annotationView.image = [Utilities iconForPortal:portal];
		//annotationView.alpha = 0;

		return annotationView;
	
	} else if ([annotation isKindOfClass:[Item class]]) {
		
		static NSString *AnnotationViewID = @"itemAnnotationView";
		
		MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
		if (annotationView == nil) {
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
			annotationView.canShowCallout = NO;
			annotationView.pinColor = MKPinAnnotationColorPurple;
		}
		
		annotationView.annotation = annotation;
		
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
		polylineView.strokeColor = [Utilities colorForFaction:polyline.portalLink.controllingTeam];
		polylineView.lineWidth = 1;
		return polylineView;
	} else if ([overlay isKindOfClass:[MKPolygon class]]) {
		MKPolygon *polygon = (MKPolygon *)overlay;
		MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:polygon];
		polygonView.fillColor = [Utilities colorForFaction:polygon.controlField.controllingTeam];
		polygonView.alpha = .1;
		return polygonView;
	} else if ([overlay isKindOfClass:[MKCircle class]]) {
		MKCircle *circle = (MKCircle *)overlay;
		if (circle.deployedResonator) {
			DeployedResonatorView *circleView = [[DeployedResonatorView alloc] initWithCircle:circle];
			circleView.fillColor = [Utilities colorForLevel:circle.deployedResonator.level];
			return circleView;
        }
	} else if ([overlay isKindOfClass:[XMOverlay class]]) {
        XMOverlayView *xmOverlayView = [[XMOverlayView alloc] initWithOverlay:overlay];
        _xmOverlayView = xmOverlayView;
        return xmOverlayView;
    }
	return nil;
}

#pragma mark - Zoom Level

- (NSUInteger)zoomLevelForRegion:(MKCoordinateRegion)region {
    double centerPixelX = [MKMapView longitudeToPixelSpaceX: region.center.longitude];
    double topLeftPixelX = [MKMapView longitudeToPixelSpaceX: region.center.longitude - region.span.longitudeDelta / 2];
    double scaledMapWidth = (centerPixelX - topLeftPixelX) * 2;
    CGSize mapSizeInPixels = _mapView.bounds.size;
    double zoomScale = scaledMapWidth / mapSizeInPixels.width;
    double zoomExponent = log(zoomScale) / log(2);
    double zoomLevel = 20 - zoomExponent;
    return zoomLevel;
}

#pragma mark - Gestures

- (void)handlePinch:(UIPinchGestureRecognizer*)recognizer {
    static MKCoordinateRegion originalRegion;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        originalRegion = _mapView.region;
    }

    double latdelta = originalRegion.span.latitudeDelta / recognizer.scale;
    double londelta = originalRegion.span.longitudeDelta / recognizer.scale;
    MKCoordinateSpan span = MKCoordinateSpanMake(latdelta, londelta);
	MKCoordinateRegion region = MKCoordinateRegionMake(originalRegion.center, span);

	if ([Utilities isOS7] || [self zoomLevelForRegion:region] >= 15) {
		[_mapView setRegion:region animated:NO];
	}
    
}

- (void)mapTapped:(UITapGestureRecognizer *)recognizer {

	if (_mapView.scrollEnabled) {
        [[LocationManager sharedInstance] addDelegate:self];
		[_mapView setScrollEnabled:NO];
	} else {
        [[LocationManager sharedInstance] removeDelegate:self];
		[_mapView setScrollEnabled:YES];
	}

//	MKMapView *mapView = (MKMapView *)recognizer.view;
//	id<MKOverlay> tappedOverlay = nil;
//	for (id<MKOverlay> overlay in mapView.overlays) {
//		if (![overlay isKindOfClass:[Portal class]]) { continue; }
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
////	NSLog(@"Tapped overlay: %@", tappedOverlay);
////	NSLog(@"Tapped view: %@", [mapView viewForOverlay:tappedOverlay]);
//
//	if ([tappedOverlay isKindOfClass:[Portal class]]) {
//		currentPortal = (Portal *)tappedOverlay;
//		[self performSegueWithIdentifier:@"PortalDetailSegue" sender:self];
//	}
	
}

- (void)mapLongPress:(UILongPressGestureRecognizer *)recognizer {
    [quickActionsMenu showMenu:recognizer];
    
//	if (recognizer.state == UIGestureRecognizerStateBegan) {
//
//		[self becomeFirstResponder];
//        CGPoint location = [recognizer locationInView:recognizer.view];
//        UIMenuController *menuController = [UIMenuController sharedMenuController];
//        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Fire XMP" action:@selector(fireXMP)];
//        [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
//        [menuController setTargetRect:CGRectMake(location.x, location.y, 0.0f, 0.0f) inView:recognizer.view];
//        [menuController setMenuVisible:YES animated:YES];
//
//	}
}

//#pragma mark - Actions
//
//- (BOOL)canBecomeFirstResponder {
//    return YES;
//}
//
//- (BOOL)canPerformAction:(SEL)selector withSender:(id) sender {
//    if (selector == @selector(fireXMP)) {
//        return YES;
//    }
//    return NO;
//}

#pragma mark - Firing XMP

- (void)fireXMP {

//	int ap = [[API sharedInstance].playerInfo[@"ap"] intValue];
//	int level = [API levelForAp:ap];
//	[self fireXMPOfLevel:level];
    
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
    HUD.removeFromSuperViewOnHide = YES;
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.dimBackground = YES;
	HUD.showCloseButton = YES;
	
	_levelChooser = [ChooserViewController levelChooserWithTitle:@"Choose XMP burster level to fire" completionHandler:^(int level) {
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

//	NSLog(@"Firing: %@", xmpItem);
	
	if (!xmpItem) {
		[Utilities showWarningWithTitle:@"No XMP remaining!"];
		return;
	} else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_emp_power_up.aif"];
        }
	}

	[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Fire XMP" withLabel:nil withValue:@(xmpItem.level)];
	
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.removeFromSuperViewOnHide = YES;
	HUD.userInteractionEnabled = YES;
	HUD.dimBackground = YES;
	HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	HUD.labelText = [NSString stringWithFormat:@"Firing XMP of level: %d", level];
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];
	
	[[API sharedInstance] fireXMP:xmpItem completionHandler:^(NSString *errorStr, NSDictionary *damages) {
		
		[HUD hide:YES];
		
		if (damages) {
			
			UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 240, 320)];
			textView.editable = NO;
			textView.backgroundColor = [UIColor clearColor];
			textView.opaque = NO;
			textView.textColor = [UIColor whiteColor];
			
			MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.removeFromSuperViewOnHide = YES;
			HUD.userInteractionEnabled = YES;
			HUD.dimBackground = YES;
			HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
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
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                            [[SoundManager sharedManager] playSound:@"Sound/sfx_explode_resonator.aif"];
                        }
					}
					
					DeployedResonator *resonator = [DeployedResonator MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", portal, slot]];
					int level = resonator.level;
					int maxEnergy = [Utilities maxEnergyForResonatorLevel:level];
					
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

			if (errorStr) {
				[Utilities showWarningWithTitle:errorStr];
			} else {
				[Utilities showWarningWithTitle:@"Unknown Error"];
			}
			
		}

	}];
	
}

#pragma mark - OPS & OpsViewControllerDelegate

- (OpsViewController *)opsViewController {
	if (!_opsViewController) {
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
		_opsViewController = [storyboard instantiateViewControllerWithIdentifier:@"OpsViewController"];
		_opsViewController.delegate = self;
	}
	return _opsViewController;
}

- (IBAction)openOPS {
	[self presentViewController:self.opsViewController animated:YES completion:NULL];
}

- (void)didDismissOpsViewController:(OpsViewController *)opsViewController {
//	_opsViewController = nil;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
	selectedPortalImage = nil;
	selectedPortalLocation = nil;
    
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
		selectedPortalImage = info[UIImagePickerControllerOriginalImage];
		NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
		if (url) {
			[[ALAssetsLibrary new] assetForURL:url resultBlock:^(ALAsset *asset) {
				CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
				if (location) {
					selectedPortalLocation = location;
					//[NSString stringWithFormat:@"lat=%g\nlng=%g\n", location.coordinate.latitude, location.coordinate.longitude];
				}
			} failureBlock:nil];
		}
	}
	
	if (!selectedPortalLocation) {
		selectedPortalLocation = [[LocationManager sharedInstance] playerLocation];
	}
    
	if ([Utilities isPad]) {
		[self.popover dismissPopoverAnimated:YES];
		[self openNewPortalVC];
	} else {
		[picker dismissViewControllerAnimated:YES completion:^{
			[self openNewPortalVC];
		}];
	}
    
}

- (void)openNewPortalVC {
	if (selectedPortalImage) {
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
		NewPortalViewController *newPortalVC = [storyboard instantiateViewControllerWithIdentifier:@"NewPortalViewController"];
		newPortalVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		newPortalVC.portalImage = selectedPortalImage;
		newPortalVC.portalLocation = selectedPortalLocation;
		[self presentViewController:newPortalVC animated:YES completion:NULL];
	} else {
		[Utilities showWarningWithTitle:@"Error getting photo"];
	}
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"PortalDetailSegue"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
        }
        
		portalDetailSegue = YES;
 
		PortalDetailViewController *vc = segue.destinationViewController;
		vc.portal = currentPortal;
		currentPortal = nil;
	} else if ([segue.identifier isEqualToString:@"FactionChooseSegue"]) {
		portalDetailSegue = NO;

		MissionViewController *vc = segue.destinationViewController;
		vc.factionChoose = YES;
	}
}

@end
