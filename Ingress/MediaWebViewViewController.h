//
//  MediaWebViewViewController.h
//  Ingress
//
//  Created by Alex Studnička on 10.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaWebViewViewController : UIViewController <UIActionSheetDelegate> {
	
	__weak IBOutlet UIWebView *_webView;
}

@property (nonatomic, strong) Media *media;

- (IBAction)close;
- (IBAction)action;

@end
