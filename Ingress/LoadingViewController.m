//
//  LoadingViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 09.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <objc/objc.h>

#import "LoadingViewController.h"

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
		
	[label setFont:[UIFont fontWithName:@"Coda-Regular" size:20]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[wheelActivityIndicatorView startAnimating];
	
	[SoundManager sharedManager].allowsBackgroundMusic = NO;

    [[SoundManager sharedManager] prepareToPlay];
	
	[[SoundManager sharedManager] playMusic:@"Sound/sfx_throbbing_wheels.aif" looping:YES];
	
	[self performHandshake];

}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[wheelActivityIndicatorView stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performHandshake {

	NSDictionary *jsonDict = @{
	//@"nemesisSoftwareVersion": @"2013-01-15T22:12:53Z ae145d098fc5 op",
	//@"nemesisSoftwareVersion": @"2013-01-24T11:26:38Z bfb6a817656f opt",
	//@"nemesisSoftwareVersion": @"2013-03-13T22:49:05Z 40d223faeed9 opt",		// 1.21.3
	@"nemesisSoftwareVersion": @"2013-04-08T20:23:14Z 10b76085f06d opt",		// 1.23.1
	@"deviceSoftwareVersion": @"4.1.1",
	//@"activationCode": @"XXXXXXXX",
	//@"tosAccepted": @"1",
	};
	
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
	if (error) { NSLog(@"JSON Error: %@", error); }
	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) jsonString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));

	handshakeURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://m-dot-betaspike.appspot.com/handshake?json=%@", escapedString]];
	loginProcess = NO;

	_webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	[_webView setDelegate:self];
	[_webView setUserInteractionEnabled:NO];
	[_webView setAlpha:0];
	[self.view addSubview:_webView];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:handshakeURL];
	[_webView loadRequest:request];
	
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	//NSLog(@"shouldStartLoadWithRequest: %@", request);
	
	if (![request.URL isEqual:handshakeURL]) {
		loginProcess = YES;
		[webView setUserInteractionEnabled:YES];
		[webView setHidden:NO];
		[UIView animateWithDuration:.5 animations:^{
			[webView setAlpha:1];
		}];
	} else {
		[UIView animateWithDuration:.5 animations:^{
			[webView setAlpha:0];
		} completion:^(BOOL finished) {
			[webView setHidden:YES];
			[webView setUserInteractionEnabled:NO];
		}];
	}
	
	if (loginProcess && [request.URL isEqual:handshakeURL]) {
		loginProcess = NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	if (loginProcess) { return; }

    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [sharedHTTPCookieStorage cookiesForURL:handshakeURL];
	for (NSHTTPCookie *cookie in cookies) {
		if ([cookie.name isEqualToString:@"SACSID"]) {

			//NSLog(@"SACSID: %@", cookie.value);
			[[API sharedInstance] setSACSID:cookie.value];

			NSString *jsonString = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
			[[API sharedInstance] processHandshakeData:jsonString completionHandler:^(NSString *errorStr) {
				if (!errorStr) {
					[self performSegueWithIdentifier:@"LoadingCompletedSegue" sender:self];
				} else {
					[label setText:errorStr];
				}
			}];

			return;
			
		}
	}

	//Error getting SACSID
	[label setText:@"Login Error"];

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController {
//	[UIView animateWithDuration:.2 animations:^{
//		CGRect frame = _tabBarArrow.frame;
//		frame.origin.x = [self horizontalLocationFor:_tabBarController.selectedIndex];
//		_tabBarArrow.frame = frame;
//	}];
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
}

//#pragma mark - Animated Tab Bar
//
//- (CGFloat)horizontalLocationFor:(NSUInteger)tabIndex {
//	// A single tab item's width is the entire width of the tab bar divided by number of items
//	CGFloat tabItemWidth = _tabBarController.tabBar.frame.size.width / _tabBarController.tabBar.items.count;
//	// A half width is tabItemWidth divided by 2 minus half the width of the arrow
//	CGFloat halfTabItemWidth = (tabItemWidth / 2.0) - (_tabBarArrow.frame.size.width / 2.0);
//	
//	// The horizontal location is the index times the width plus a half width
//	return (tabIndex * tabItemWidth) + halfTabItemWidth;
//}
//
//- (void)addTabBarArrow {
//	UIImage *tabBarArrowImage = [UIImage imageNamed:@"TabBarNipple.png"];
//	_tabBarArrow = [[UIImageView alloc] initWithImage:tabBarArrowImage];
//	// To get the vertical location we start at the bottom of the window, go up by height of the tab bar, go up again by the height of arrow and then come back down 2 pixels so the arrow is slightly on top of the tab bar.
//	CGFloat verticalLocation = [AppDelegate instance].window.frame.size.height - _tabBarController.tabBar.frame.size.height - tabBarArrowImage.size.height + 2;
//	_tabBarArrow.frame = CGRectMake([self horizontalLocationFor:2], verticalLocation, tabBarArrowImage.size.width, tabBarArrowImage.size.height);
//	
//	[[AppDelegate instance].window addSubview:_tabBarArrow];
//}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"LoadingCompletedSegue"]) {
		_tabBarController = (UITabBarController *)segue.destinationViewController;
		_tabBarController.delegate = self;
//		[self addTabBarArrow];
	}
}

@end
