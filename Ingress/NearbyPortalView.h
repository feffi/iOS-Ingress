//
//  NearbyPortalView.h
//  Ingress
//
//  Created by Alex Studnička on 03.07.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearbyPortalView : UIView

@property NSString *portalGUID;

- (id)initWithFrame:(CGRect)frame portal:(NSDictionary *)portal;

- (void)updateInformation;

@end
