//
//  LoadingViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 09.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <objc/objc.h>

#import "LoadingViewController.h"

@implementation LoadingViewController {
	NSMutableDictionary *jsonDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[label setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20]];

	[activationCodeField.layer setBorderWidth:1];
	[activationCodeField.layer setBorderColor:[[UIColor colorWithRed:116.0/255.0 green:251.0/255.0 blue:233.0/255.0 alpha:1.0] CGColor]];
	[activationCodeField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];

	[activationButton.titleLabel setFont:[UIFont fontWithName:@"Coda-Regular" size:18]];

	////////

	jsonDict = [@{
				//@"nemesisSoftwareVersion": @"2013-01-15T22:12:53Z ae145d098fc5 op",
				//@"nemesisSoftwareVersion": @"2013-01-24T11:26:38Z bfb6a817656f opt",
				//@"nemesisSoftwareVersion": @"2013-03-13T22:49:05Z 40d223faeed9 opt",		// 1.21.3
				@"nemesisSoftwareVersion": @"2013-04-08T20:23:14Z 10b76085f06d opt",		// 1.23.1
				@"deviceSoftwareVersion": @"4.1.1",
				} mutableCopy];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[wheelActivityIndicatorView startAnimating];
	
	[SoundManager sharedManager].allowsBackgroundMusic = NO;
    [[SoundManager sharedManager] prepareToPlay];
	
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

	[[SoundManager sharedManager] playMusic:@"Sound/sfx_throbbing_wheels.aif" looping:YES fadeIn:NO];
	[label setText:@"v1.23.1"]; //Loading...
	
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
		[[SoundManager sharedManager] stopMusic:YES];
		[UIView animateWithDuration:.5 animations:^{
			[webView setAlpha:1];
		}];
	} else {
		[[SoundManager sharedManager] playMusic:@"Sound/sfx_throbbing_wheels.aif" looping:YES fadeIn:YES];
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
					[[SoundManager sharedManager] stopMusic:YES];
					[self performSegueWithIdentifier:@"LoadingCompletedSegue" sender:self];
				} else {
					
					if ([errorStr isEqualToString:@"USER_REQUIRES_ACTIVATION"]) {

						[[SoundManager sharedManager] stopMusic:NO];

						if (activationStarted) {
							activationStarted = NO;
							[activationErrorLabel setHidden:NO];
						}

						[activationView setHidden:NO];
						[activationCodeField becomeFirstResponder];

					} else if ([errorStr isEqualToString:@"USER_MUST_ACCEPT_TOS"]) {

						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Terms of Service" message:@"Ingress Terms of Service\n\nLast Modified: November 14, 2012\n\nBy downloading, installing, or using the Ingress software, accessing or using the Ingress website (together, the \"Products\" or \"Services\"), or accessing or using any of the content available within the Products, you agree to be bound by the following: (1) the Google Terms of Service (the \"Universal Terms\"); (2) the Ingress Community Guidelines, both incorporated herein by reference, and; (3) the additional terms and conditions set forth below (the \"Additional Terms\"). You should read each of these three documents, as together they form a binding agreement between you and Google Inc. regarding your use of the Products. Collectively, the Universal Terms, the Community Guidelines, and the Additional Terms are referred to as the \"Terms.\"\n\n1. Ability to Accept the Terms. \nYou affirm that you are either more than 18 years of age, or an emancipated minor, and are fully able and competent to enter into the terms, conditions, obligations, affirmations, representations, and warranties set forth in these Terms, and to abide by and comply with these Terms. If you are not 18 years old, do not use the Products.\n\n2. Privacy \nAs a condition of downloading, accessing, or using the Products, you also agree to the terms of the Google Privacy Policy, incorporated here by reference. You understand and agree that by using the Products, you will be transmitting your device location to Google, and that location will be shared publicly with other users through the game along with your submitted screen name (your code name). For example, your code name and location will be shared with all other users when you visit certain locations, similar to a check in.\n\n3. Use of the Products - Permissions and Restrictions. \nSubject to these Terms, Google grants you a personal, non-commercial, non-exclusive, non-transferable license to download and use the Ingress mobile application software, to access and use the Ingress website and service, and to access the Content (as defined below) within the Products for your use.\n\n“Content” means the text, software, scripts, graphics, photos, sounds, music, videos, audiovisual combinations, interactive features and other materials you may view on, access through, or contribute to the Products, including content supplied by Google, its suppliers, or users.\n\nIn addition to the restrictions set out in the Google Terms of Service, unless you have received prior written authorization from Google (or, as applicable, from the provider of particular Content), you shall not:\n\n(a) copy, translate, modify, or make derivative works of the Products, the Content or any part thereof; \n(b) redistribute, sublicense, publish, sell, or in any other way make the Products or Content available to third parties; \n(c) access the Product or Content through any technology or means other than those provided by Google (including without limitation automation software, bots, spiders, or hacks or devices of any kind); \n(d) extract, scrape, or index the Products or Content (including information about users or game play); \n(e) create or maintain any unauthorized connection to the Products, including but not limited to any server that emulates or attempts to emulate the Products; \n(f) delete, obscure, or in any manner alter any attribution, warning, or link that appears in the Products or the Content; or \n(g) use the Products for any commercial purpose, including but not limited to (i) gathering in-Product items or resources for sale outside the Products, or (ii) performing services in the Products in exchange for payment outside the Product.\n\n4. Appropriate Conduct; Compliance with Law and Google Policies. You agree that you are responsible for your own conduct and content while using the Products, and for any consequences thereof. You agree to use the Products only for purposes that are lawful, proper and in accordance with the Terms, including the Community Guidelines, and any applicable policies or guidelines Google may make available.\n\nBy way of example, and not as a limitation, you agree that when using the Products or the Content, you shall not:\n\n(a) defame, abuse, harass, stalk, threaten or otherwise violate the legal rights (including the rights of privacy and publicity) of others; \n(b) upload, post, email, transmit or otherwise make available any unlawful, inappropriate, defamatory or obscene content or message; \n(c) trespass, or in any manner attempt to gain or gain access to any property or location where you do not have a right or permission to be; \n(d) upload, post, or otherwise make available commercial messages or advertisements, pyramid schemes, or other disruptive notices; \n(e) impersonate another person or entity; \n(f) promote or provide instructional information about illegal activities; \n(g) promote physical harm or injury against any group or individual; or \n(h) transmit any viruses, worms, defects, Trojan horses, or any items of a destructive nature.\n\n5. Content in the Products.\n\nYou understand and agree to the following:\n\n(a) Content, including location data, provided in the products is provided to you AS IS. It is intended for for entertainment and game play purposes only, and is not guaranteed to be accurate. You should exercise judgment in your use of the Products and Content. \n(b) You understand that when using the Products, you will be exposed to Content from a variety of sources, including other users, and that Google is not responsible for the accuracy, usefulness, safety, or intellectual property rights of or relating to the Content. \n(c) You may submit Content to the Products, including user comments. You understand that the Content will be displayed within the Product, and that Google does not guarantee confidentiality with respect to any Content you submit. You shall be solely responsible for your own Content.\n\n6. DISCLAIMER OF WARRANTIES\n\n(a) YOU AGREE THAT YOUR USE OF THE PRODUCTS SHALL BE AT YOUR SOLE RISK. GOOGLE MAKES NO WARRANTIES OR REPRESENTATIONS ABOUT THE ACCURACY OR COMPLETENESS OF THE PRODUCTS OR THE CONTENT. \n(b) TO THE FULLEST EXTENT PERMITTED BY LAW, GOOGLE, ITS OFFICERS, DIRECTORS, EMPLOYEES, AGENTS AND LICENSORS DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, IN CONNECTION WITH THE PRODUCTS, THE CONTENT AND YOUR USE THEREOF. \n(c) AS WITH THE PURCHASE OR USE OF A PRODUCT OR SERVICE THROUGH ANY MEDIUM OR IN ANY ENVIRONMENT, YOU SHOULD USE YOUR BEST JUDGMENT AND EXERCISE CAUTION WHERE APPROPRIATE.\n\n7. Limitation of Liability\n\nIN NO EVENT SHALL GOOGLE, ITS OFFICERS, DIRECTORS, EMPLOYEES OR AGENTS, OR LICENSORS BE LIABLE TO YOU FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES WHATSOEVER RESULTING FROM ANY (i) ERRORS, MISTAKES, OR INACCURACIES OF CONTENT, (ii) PERSONAL INJURY OR PROPERTY DAMAGE, OF ANY NATURE WHATSOEVER, RESULTING FROM YOUR ACCESS TO AND USE OF THE PRODUCTS OR CONTENT, (iii) ANY UNAUTHORIZED ACCESS TO OR USE OF OUR SECURE SERVERS AND/OR ANY AND ALL PERSONAL INFORMATION STORED THEREIN, or (iv) ANY ERRORS OR OMISSIONS IN ANY PRODUCTS OR CONTENT OR FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF YOUR USE OF THE PRODUCTS OR CONTENT WHETHER BASED ON WARRANTY, CONTRACT, TORT, OR ANY OTHER LEGAL THEORY, AND WHETHER OR NOT THE COMPANY IS ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. THE FOREGOING LIMITATION OF LIABILITY SHALL APPLY TO THE FULLEST EXTENT PERMITTED BY LAW IN THE APPLICABLE JURISDICTION." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Accept", nil];
						[alertView setTag:2];
						[alertView show];
						
					} else if ([errorStr isEqualToString:@"allowNicknameEdit"]) {
						
						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter a codename" message:@"Niantic software online.\nIncoming text transmission detected.\nOpening channel...\n\n> I need you help. The world needs your help. This chat is not secure.\n\nI need you to create a unique codename so that I can call you on a secure line.\n\nThis is the name other agents will know you by." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Transmit", nil];
						[alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
						[alertView setTag:3];
						[alertView show];
						
					} else {
						[label setText:errorStr];
					}
					
				}
			}];

			return;
			
		}
	}

	//Error getting SACSID
	[label setText:@"Login Error"];

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error { 
	[label setText:@"Connection Error"]; //[error localizedDescription]
}

#pragma mark - UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
	if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput) {
		UITextField *textField = [alertView textFieldAtIndex:0];
		return textField.text.length;
	}
	return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (alertView.tag) {
		case 2:
			
			if (buttonIndex == 1) {
				[jsonDict setValue:@"1" forKey:@"tosAccepted"];
				[self performHandshake];
				[jsonDict setValue:nil forKey:@"tosAccepted"];
			} else {
				[label setText:@"You must accept TOS"];
			}
			
			break;
			
		case 3: {
			
			UITextField *textField = [alertView textFieldAtIndex:0];
			[[API sharedInstance] validateNickname:textField.text completionHandler:^(NSString *errorStr) {
				
				if (errorStr) {
					
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wrong codename" message:errorStr delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
					[alertView setTag:4];
					[alertView show];
					
				} else {
					
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Codename valid. Please confirm." message:textField.text delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Confirm", nil];
					[alertView setTag:5];
					[alertView show];

//					codenameConfirmView.hidden = NO;
//					codenameConfirmLabel.text = @"test_codename";

				}
				
			}];
			
			break;
		}
			
		case 4:
			
			[self performHandshake];
			
			break;
			
		case 5:
			
			if (buttonIndex == 1) {
				[[API sharedInstance] persistNickname:alertView.message completionHandler:^(NSString *errorStr) {
				
					if (errorStr) {
						
						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wrong codename" message:errorStr delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
						[alertView setTag:4];
						[alertView show];
						
					} else {
						
						[self performSegueWithIdentifier:@"LoadingCompletedSegue" sender:self];
						
					}
					
				}];
			} else {
				[self performHandshake];
			}
			
			break;
			
		default:
			break;
	}
	
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField isEqual:activationCodeField]) {
		[self activate];
		return NO;
	}
	return NO;
}

- (void)textChanged:(UITextField *)textField {
	if ([textField isEqual:activationCodeField]) {
		if (textField.text.length > 0) {
			[activationErrorLabel setHidden:YES];
			[activationButton setEnabled:YES];
		} else {
			[activationButton setEnabled:NO];
		}
	}
}

#pragma mark - IBActions

- (IBAction)activate {
	activationStarted = YES;
	[activationCodeField resignFirstResponder];
	[jsonDict setValue:activationCodeField.text forKey:@"activationCode"];
	[self performHandshake];
	[jsonDict setValue:nil forKey:@"activationCode"];
	activationView.hidden = YES;
	activationCodeField.text = @"";
	activationButton.enabled = NO;
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
