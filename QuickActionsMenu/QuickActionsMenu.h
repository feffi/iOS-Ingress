//
//  QuickActionsMenu.h
//  Ingress
//
//  Created by Alex Studnička on 25.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickActionsMenu : UIView

- (id)initWithSeletionHandler:(void (^)(int option))selectHandler;
- (void)showMenu:(UIGestureRecognizer *)gestureRecognizer;

@end
