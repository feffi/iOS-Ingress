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

//function $e(a) { //8823, 5510
//	for(var b = [], c = ZOOM_LEVEL;c > 0;c--) {
//		var d = 0, e = 1 << c - 1;
//		(a.x & e) != 0 && d++;
//		(a.y & e) != 0 && (d++, d++);
//		b.push(d)
//	}
//	return b.join("")
//}

//- (NSString *)e:(CLLocationCoordinate2D)a {
//	
//	NSMutableArray *b = [NSMutableArray array];
//	
//	for (int c = 16; c > 0; c--) {
//		
//		int d = 0;
//		int e = 1 << c - 1;
//		((int)a.latitude & e) != 0 && d++;
//		((int)a.longitude & e) != 0 && (d++, d++);
//		
//		[b addObject:@(d)];
//		
//	}
//	
//	return [b componentsJoinedByString:@""];
//	
//}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[wheelActivityIndicatorView startAnimating];
	
	[SoundManager sharedManager].allowsBackgroundMusic = NO;

    [[SoundManager sharedManager] prepareToPlay];
	
	[[SoundManager sharedManager] playMusic:@"Sound/sfx_throbbing_wheels.aif" looping:YES];
	
	[self performHandshake];
	
//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//		[self performSegueWithIdentifier:@"LoadingCompletedSegue" sender:self];
//	});
	
//	return;
//
//	UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
//	[webView setDelegate:self];
//	[webView setUserInteractionEnabled:NO];
//	[webView setAlpha:0];
//	[self.view addSubview:webView];
//	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
//	[webView loadRequest:request];
//	
//	CLLocationCoordinate2D neLoc = CLLocationCoordinate2DMake(50.64601929058625, 13.84268054053473);
//	CLLocationCoordinate2D swLoc = CLLocationCoordinate2DMake(50.63809963027642, 13.809120741340394);
//
//	float x = round(256 * 0.9999 * fabsf(1 / cos(neLoc.latitude * (M_PI / 180)))); //404
//	
//	CLLocationCoordinate2D Ob = CLLocationCoordinate2DMake(x/2, x/2); // {202, 202}
//	float Pb = x / 360; //1.1222222222222222
//	float Qb = x / (2 * M_PI); //64.29859700912571
//	float R = (float)(1 << (int)(16 - (x / 256 - 1))); //32768
//	
//	/////////////////////////
//	
////	NSLog(@"1: %@", [webView stringByEvaluatingJavaScriptFromString:@"function T(a,b){this.x=a;this.y=b}"]);
////	NSLog(@"1: %@", [webView stringByEvaluatingJavaScriptFromString:@"var d = new T((202+13.84268054053473*1.1222222222222222),0)"]);
////	NSLog(@"1: %@", [webView stringByEvaluatingJavaScriptFromString:@"d"]);
////	NSLog(@"1: %@", [webView stringByEvaluatingJavaScriptFromString:@"d.x"]);
//	
//	CLLocationCoordinate2D d;
//	d.longitude = Ob.longitude + neLoc.longitude * Pb;
//	float e = sinf(neLoc.latitude * (M_PI / 180));
//	e = MAX(e, -0.9999);
//	e = MIN(e, 0.9999);
//	d.latitude = Ob.latitude + 0.5 * logf((1 + e) / (1 - e)) * -Qb;
//	NSLog(@"d.lat: %f, d.lng: %f", d.latitude, d.longitude); // = { x: 217.57375160467728, y: 135.87756580181085 }
//	
//	d = CLLocationCoordinate2DMake(d.longitude * R, d.latitude * R);
//	NSLog(@"d.lat: %f, d.lng: %f", d.latitude, d.longitude); //= { x: 7128167.06046446, y: 4452537.590702042 }
//
//	d = CLLocationCoordinate2DMake(floor(d.longitude / x), floor(d.latitude / x));
//	NSLog(@"d.lat: %f, d.lng: %f", d.latitude, d.longitude); //= { x: 17643, y: 11021 }
//	
//	/////////////////////////
//	
//	CLLocationCoordinate2D c;
//	c.longitude = Ob.longitude + swLoc.longitude * Pb;
//	e = sinf(swLoc.latitude * (M_PI / 180));
//	e = MAX(e, -0.9999);
//	e = MIN(e, 0.9999);
//	c.latitude = Ob.latitude + 0.5 * logf((1 + e) / (1 - e)) * -Qb;
//	NSLog(@"c.lat: %f, c.lng: %f", c.latitude, c.longitude); //= { x: 217.496902165282, y: 135.89296880003485 }
//	
//	c = CLLocationCoordinate2DMake(c.longitude * R, c.latitude * R);
//	NSLog(@"c.lat: %f, c.lng: %f", c.latitude, c.longitude); //= { x: 7126938.49015196, y: 4452940.801639542 }
//	
//	c = CLLocationCoordinate2DMake(floor(c.longitude / x), floor(c.latitude / x));
//	NSLog(@"c.lat: %f, c.lng: %f", c.latitude, c.longitude); //= { x: 17640, y: 11022 }
//	
//	/////////////////////////
//
//	float i = fabsf(c.longitude - d.longitude);
//	float j = fabsf(c.latitude - d.latitude);
//	
//	NSLog(@"i: %f", i); //3
//	NSLog(@"j: %f", j); //1
//	
//	NSMutableArray *f = [NSMutableArray array];
//	
//	for (int g = 0; g <= i; g++) {
//		
//		float k = fabsf(d.longitude - g);
//		float l = d.latitude;
//		CLLocationCoordinate2D m = CLLocationCoordinate2DMake(k, l);
//		
//		NSLog(@"m.lat: %f, m.lng: %f", m.latitude, m.longitude); //= { 17643, y: 11021 }
//		
//		NSString *q = [self e:m];
//		
//		[f addObject:@{@"bounds": @"bf({Ob,Qb,Pb,R}, m)", @"quadkey": q}];
//
//		for(int o = 1; o <= j; o++) {
//			
//			float g = d.latitude + o;
//			CLLocationCoordinate2D h = CLLocationCoordinate2DMake(k, g);
//			
//			NSString *z = [self e:h];
//			
//			[f addObject:@{@"bounds": @"bf({Ob,Qb,Pb,R}, h)", @"quadkey": z}];
//			
//		}
//		
//	}
//	
//	NSLog(@"f: %@", f);

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
	//@"activationCode": @"B3XDFBAP",
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
			
			//NSLog(@"Got SACSID");
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

#pragma mark - Animated Tab Bar

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
