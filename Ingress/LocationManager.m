//
//  PlayerLocation.m
//  Ingress
//
//  Created by John Bekas Jr on 6/27/13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

#pragma mark - Singleton implementation

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LocationManager * __sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [self new];
    });
    return __sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        
        _delegates = [NSMutableArray array];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        if ([_locationManager respondsToSelector:@selector(activityType)]) {
            _locationManager.activityType = CLActivityTypeFitness;
        }
        _locationManager.delegate = self;
        
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];
        
    }
    return self;
}

#pragma mark - 

- (CLLocation *)playerLocation {
    CLLocationCoordinate2D coordinate = [AppDelegate instance].mapView.centerCoordinate;
    return [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//    return _locationManager.location;
}

- (void)addDelegate:(id)delegate {
    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id)delegate {
    [_delegates removeObject:delegate];
}

#pragma mark - CLLocationManagerDelegate

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (id delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
            [delegate locationManager:manager didUpdateLocations:locations];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    for (id delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
            [delegate locationManager:manager didUpdateHeading:newHeading];
        }
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return NO;
}

//- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
//    
//}

//- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
//    
//}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    for (id delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
            [delegate locationManager:manager didFailWithError:error];
        }
    }
}

//- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
//
//}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    for (id delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(locationManager:didChangeAuthorizationStatus:)]) {
            [delegate locationManager:manager didChangeAuthorizationStatus:status];
        }
    }
}

//- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
//    
//}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    for (id delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(locationManagerDidPauseLocationUpdates:)]) {
            [delegate locationManagerDidPauseLocationUpdates:manager];
        }
    }
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    for (id delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(locationManagerDidResumeLocationUpdates:)]) {
            [delegate locationManagerDidResumeLocationUpdates:manager];
        }
    }
}

//- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
//    
//}

@end
