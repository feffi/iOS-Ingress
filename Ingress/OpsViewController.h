//
//  OpsViewController.h
//  Ingress
//
//  Created by Alex Studnička on 16.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSlidingPagesDataSource.h"

@interface OpsViewController : UIViewController <TTSlidingPagesDataSource>
#import "ScoreViewController.h"
@property (nonatomic, strong) ScoreViewController *scoreViewController;

- (IBAction)back;

@end