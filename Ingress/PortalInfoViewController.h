//
//  PortalUpgradeViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 20.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PortalInfoViewController : UIViewController

@property (nonatomic, assign) Portal *portal;

- (void)refresh;

@end
