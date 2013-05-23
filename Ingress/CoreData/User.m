//
//  User.m
//  Ingress
//
//  Created by Alex Studnička on 23.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "User.h"
#import "ControlField.h"
#import "DeployedMod.h"
#import "DeployedResonator.h"
#import "Plext.h"
#import "Portal.h"
#import "PortalLink.h"


@implementation User

@dynamic guid;
@dynamic nickname;
@dynamic team;
@dynamic capturedPortals;
@dynamic createdControlFields;
@dynamic createdLinks;
@dynamic deployedMods;
@dynamic deployedResonators;
@dynamic sentPlexts;

//- (NSString *)nickname {
//    [self willAccessValueForKey:@"nickname"];
//    NSString *nickname = [self primitiveValueForKey:@"nickname"];
//    [self didAccessValueForKey:@"nickname"];
//	if (!nickname || [nickname isEqual:[NSNull null]]) {
//		return @"Loading...";
//	}
//    return nickname;
//}
//
//- (void)setNickname:(NSString *)nickname {
//    [self willAccessValueForKey:@"nickname"];
//	[self setPrimitiveValue:nickname forKey:@"nickname"];
//    [self didAccessValueForKey:@"nickname"];
//}

@end
