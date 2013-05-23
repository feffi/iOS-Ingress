//
//  Item.h
//  Ingress
//
//  Created by Alex Studnicka on 25.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSString * guid;
@property (nonatomic) BOOL dropped;
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) NSTimeInterval timestamp;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (CLLocationDistance)distanceFromCoordinate:(CLLocationCoordinate2D)coordinate;

@end
