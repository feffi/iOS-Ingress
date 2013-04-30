//
//  PortalKey.h
//  Ingress
//
//  Created by Alex Studnička on 30.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class Portal;

@interface PortalKey : Item

@property (nonatomic, retain) NSString * portalGuid;
@property (nonatomic, retain) Portal *portal;

@end
