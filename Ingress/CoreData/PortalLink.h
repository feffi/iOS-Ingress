//
//  PortalLink.h
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Portal, User;

@interface PortalLink : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * controllingTeam;
@property (nonatomic, retain) Portal *originPortal;
@property (nonatomic, retain) Portal *destinationPortal;
@property (nonatomic, retain) User *creator;

@property (nonatomic, readonly) MKPolyline *polyline;

@end
