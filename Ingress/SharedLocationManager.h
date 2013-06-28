//
//  PlayerLocation.h
//  Ingress
//
//  Created by John Bekas Jr on 6/27/13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedLocationManager : NSObject

+ (CLLocationManager *)locationManager; // Singleton method

@end