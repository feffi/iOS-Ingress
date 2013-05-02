//
//  DeviceViewController.h
//  Ingress
//
//  Created by Alex Studnička on 02.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "EXF.h"
#import "EXFUtils.h"

@interface DeviceViewController : UITableViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

- (IBAction)refreshInventory;
- (IBAction)actionSheet;

@end
