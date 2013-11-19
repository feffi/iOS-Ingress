//
//  AppDelegate.h
//  Ingress
//
//  Created by Alex Studnicka on 08.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class ScannerViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) ScannerViewController *scannerViewController;

+ (AppDelegate *)instance;

@end
