//
//  PlayerLocation.m
//  Ingress
//
//  Created by John Bekas Jr on 6/27/13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "SharedLocationManager.h"

@implementation SharedLocationManager

static CLLocationManager *_locationManager = nil;

#pragma mark - Singleton implementation
+ (CLLocationManager *)locationManager
{
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
		if ([_locationManager respondsToSelector:@selector(activityType)]) {
			_locationManager.activityType = CLActivityTypeFitness;
		}

	});
	return _locationManager;
}

@end
