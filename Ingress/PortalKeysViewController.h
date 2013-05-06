//
//  PortalKeysViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 18.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PortalKeysViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) Portal *linkingPortal;

@end
