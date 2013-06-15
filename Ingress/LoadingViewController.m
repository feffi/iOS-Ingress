//
//  LoadingViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 09.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <objc/objc.h>

#import "LoadingViewController.h"
#import "DAKeyboardControl.h"
#import "GLViewController.h"

@implementation LoadingViewController {
	NSMutableDictionary *jsonDict;
	NSTimer *introScrollerTimer;
	NSString *versionString;
}

- (void)setDefaults {
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:DeviceSoundLevel]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DeviceSoundLevel];
	}

	if (![[NSUserDefaults standardUserDefaults] objectForKey:DeviceSoundToggleBackground]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:DeviceSoundToggleBackground];
	}

	if (![[NSUserDefaults standardUserDefaults] objectForKey:DeviceSoundToggleEffects]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:DeviceSoundToggleEffects];
	}

	if (![[NSUserDefaults standardUserDefaults] objectForKey:DeviceSoundToggleSpeech]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:DeviceSoundToggleSpeech];
	}

	if (![[NSUserDefaults standardUserDefaults] objectForKey:MilesOrKM]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:MilesOrKM];
	}

	[[NSUserDefaults standardUserDefaults] synchronize];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[self setDefaults];

	[label setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20]];

	[activationCodeField.layer setBorderWidth:1];
	[activationCodeField.layer setBorderColor:[[UIColor colorWithRed:116.0/255.0 green:251.0/255.0 blue:233.0/255.0 alpha:1.0] CGColor]];
	[activationCodeField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
	[activationButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18]];

	createCodenameLabel.font = [UIFont fontWithName:[[[UITextField appearance] font] fontName] size:14];
	[createCodenameField.layer setBorderWidth:1];
	[createCodenameField.layer setBorderColor:[[UIColor colorWithRed:255.0/255.0 green:214.0/255.0 blue:82.0/255.0 alpha:1.0] CGColor]];
	[createCodenameField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
	[createCodenameButton.layer setBorderWidth:1];
	[createCodenameButton.layer setBorderColor:[[UIColor colorWithRed:255.0/255.0 green:214.0/255.0 blue:82.0/255.0 alpha:1.0] CGColor]];
	[createCodenameButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18]];

	[createCodenameScrollview addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) { }];

	GLViewController *glVC = self.childViewControllers[0];
	[glVC.view setBackgroundColor:[UIColor blackColor]];
	introTextView.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName]  size:22];

	termsWarningLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	termsDescriptionLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	termsLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];

	codenameErrorLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];

	////////

	jsonDict = [@{
				@"nemesisSoftwareVersion": @"2013-06-07T16:49:41Z 63e36378f5e8 opt",
				@"deviceSoftwareVersion": @"4.1.1",
	} mutableCopy];

	versionString = @"v1.28.1";
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[[GAI sharedInstance] defaultTracker] sendView:@"Loading Screen"];

	[wheelActivityIndicatorView startAnimating];
	
	[SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
	[SoundManager sharedManager].soundVolume = 1;
	[SoundManager sharedManager].musicVolume = 1;

	[self performHandshake];

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

}

- (void)autoscrollTimerFired {
	CGPoint scrollPoint = introTextView.contentOffset;
    [introTextView setContentOffset:CGPointMake(scrollPoint.x, scrollPoint.y + 1) animated:NO];
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
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleBackground]) {
        [[SoundManager sharedManager] playMusic:@"Sound/sfx_throbbing_wheels.aif" looping:YES fadeIn:NO];
    }
	[label setText:[NSString stringWithFormat:@"%@ (%@)", versionString, [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]]];
	
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
	[request setValue:@"Nemesis (gzip)" forHTTPHeaderField:@"User-Agent"];
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
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleBackground]) {
            [[SoundManager sharedManager] playMusic:@"Sound/sfx_throbbing_wheels.aif" looping:YES fadeIn:YES];
        }
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

						if (activationStarted) {
							activationStarted = NO;
							[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Player Activated" withLabel:nil withValue:@(0)];
						}

						typewriterView.hidden = NO;

						NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Booting Niantic Software %@.....\n\n*\n*\n*\n*\nJMP 0x1F\nPOPL %%ESI\nMOVL %%ESI,0x8(%%ESI)\nXORL %%EAX,%%EAX\nMOVB %%EAX,0x7(%%ESI)\nMOVL %%EAX,0xC(%%ESI)\nMOVB $0xB,%%AL\nMOVL %%ESI,&EBX\nLEAL 0x8(%%ESI),%%ECX\n*\n*\n*\n*", versionString]];
						[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:14], NSForegroundColorAttributeName : [UIColor colorWithRed:45.0/255.0 green:239.0/255.0 blue:249.0/255.0 alpha:1.0]} range:NSMakeRange(0, versionString.length+30)];
						[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:14], NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(versionString.length+30, attrStr.length-(versionString.length+30))];
						[typewriterLabel setAutoResizes:YES];
						[typewriterLabel setAttributedText:attrStr];

						dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((attrStr.length * 0.05) + 2) * NSEC_PER_SEC));
						dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
							termsView.hidden = NO;
							typewriterView.hidden = YES;
							termsConfirmButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:28];
						});
						
					} else if ([errorStr isEqualToString:@"allowNicknameEdit"]) {

						[[SoundManager sharedManager] stopMusic:NO];
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                            [[SoundManager sharedManager] playSound:@"Sound/sfx_typing.aif"];
                        }
                        
						createCodenameScrollview.hidden = NO;

						NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"Niantic software online.\nIncoming text transmission detected.\nOpening channel...\n\n> I need your help. The world needs your help. This chat is not secure.\n\nI need you to create a unique codename so that I can call you on a secure line.\n\nThis is the name other agents will know you by."];
						[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16], NSForegroundColorAttributeName : [UIColor colorWithRed:45.0/255.0 green:239.0/255.0 blue:249.0/255.0 alpha:1.0]} range:NSMakeRange(0, 80)];
						[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16], NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(80, 202)];

						[createCodenameScrollview setContentSize:self.view.frame.size];

						TypeWriterLabel *createCodenameAnimatedLabel = [TypeWriterLabel new];
						createCodenameAnimatedLabel.backgroundColor = [UIColor blackColor];
						createCodenameAnimatedLabel.opaque = YES;
						createCodenameAnimatedLabel.numberOfLines = 0;
						createCodenameAnimatedLabel.frame = CGRectMake(20, 20, 280, 385);
						[createCodenameScrollview addSubview:createCodenameAnimatedLabel];
						[createCodenameAnimatedLabel setAutoResizes:YES];
						[createCodenameAnimatedLabel setDelayBetweenCharacters:0.03];
						[createCodenameAnimatedLabel setAttributedText:attrStr];

						dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((attrStr.length + 10) * 0.03 * NSEC_PER_SEC));
						dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
							[createCodenameLabel setHidden:NO];
							[createCodenameField setHidden:NO];
							[createCodenameButton setHidden:NO];
							[createCodenameField becomeFirstResponder];
						});

					} else if ([errorStr isEqualToString:@"CLIENT_MUST_UPGRADE"]) {
						[label setText:@"You have to update app to play"];
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
	retryHandshakeButton.hidden = NO;

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error { 
	[label setText:@"Connection Error"]; //[error localizedDescription]
	retryHandshakeButton.hidden = NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField isEqual:activationCodeField]) {
		[self activate];
		return NO;
	} else if ([textField isEqual:createCodenameField]) {
		[self createCodename];
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
	} else if ([textField isEqual:createCodenameField]) {
		if (textField.text.length > 0) {
			[createCodenameButton setEnabled:YES];
		} else {
			[createCodenameButton setEnabled:NO];
		}
	}
}

#pragma mark - IBActions

- (IBAction)retryHandshake {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	[self performHandshake];

	retryHandshakeButton.hidden = YES;
}

- (IBAction)activate {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	activationStarted = YES;
	[activationCodeField resignFirstResponder];
	[jsonDict setValue:activationCodeField.text forKey:@"activationCode"];
	[self performHandshake];
	[jsonDict setValue:nil forKey:@"activationCode"];
	activationView.hidden = YES;
	activationCodeField.text = @"";
	activationButton.enabled = NO;
	
}

- (IBAction)termsCheckboxChanged {
	termsConfirmButton.enabled = termsCheckboxButton.selected;
}

- (IBAction)termsConfirm {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	[jsonDict setValue:@"1" forKey:@"tosAccepted"];
	[self performHandshake];
	[jsonDict setValue:nil forKey:@"tosAccepted"];

	termsView.hidden = YES;
	termsCheckboxButton.selected = NO;
	termsConfirmButton.enabled = NO;

}

- (IBAction)createCodename {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	[createCodenameField resignFirstResponder];
	createCodenameScrollview.hidden = YES;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleBackground]) {
        [[SoundManager sharedManager] playMusic:@"Sound/sfx_throbbing_wheels.aif" looping:YES fadeIn:NO];
    }
    
	[[API sharedInstance] validateNickname:createCodenameField.text completionHandler:^(NSString *errorStr) {

		[[SoundManager sharedManager] stopMusic:NO];

		if (errorStr) {

			[codenameErrorRetryButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22]];
			if ([errorStr isEqualToString:@"CANNOT_EDIT"]) {
				[codenameErrorRetryButton setTitle:@"Skip" forState:UIControlStateNormal];
				[codenameErrorRetryButton removeTarget:self	action:@selector(codenameRetry) forControlEvents:UIControlEventTouchUpInside];
				[codenameErrorRetryButton addTarget:self action:@selector(playIntro) forControlEvents:UIControlEventTouchUpInside];
			} else {
				[codenameErrorRetryButton setTitle:@"Retry" forState:UIControlStateNormal];
				[codenameErrorRetryButton removeTarget:self action:@selector(playIntro) forControlEvents:UIControlEventTouchUpInside];
				[codenameErrorRetryButton addTarget:self action:@selector(codenameRetry) forControlEvents:UIControlEventTouchUpInside];
			}
			codenameErrorLabel.text = errorStr;
			codenameErrorView.hidden = NO;

		} else {

			codenameConfirmLabel.text = @"";
			[codenameConfirmButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:28]];
			[codenameConfirmRetryButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22]];

			codenameConfirmView.hidden = NO;
			codenameToConfirm = createCodenameField.text;

			NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Codename valid. Please confirm.\n%@", codenameToConfirm]];
			[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16], NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:214.0/255.0 blue:82.0/255.0 alpha:1.0]} range:NSMakeRange(0, attrStr.length)];
			[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16], NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(32, codenameToConfirm.length)];
			[codenameConfirmLabel setAttributedText:attrStr];
			
		}
		
	}];
	
}

- (IBAction)codenameConfirm {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	codenameConfirmView.hidden = YES;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleBackground]) {
        [[SoundManager sharedManager] playMusic:@"Sound/sfx_throbbing_wheels.aif" looping:YES fadeIn:NO];
    }
    
	[[API sharedInstance] persistNickname:codenameToConfirm completionHandler:^(NSString *errorStr) {

		[[SoundManager sharedManager] stopMusic:NO];

		if (errorStr) {

			[codenameErrorRetryButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22]];
			if ([errorStr isEqualToString:@"CANNOT_EDIT"]) {
				[codenameErrorRetryButton setTitle:@"Skip" forState:UIControlStateNormal];
				[codenameErrorRetryButton removeTarget:self	action:@selector(codenameRetry) forControlEvents:UIControlEventTouchUpInside];
				[codenameErrorRetryButton addTarget:self action:@selector(playIntro) forControlEvents:UIControlEventTouchUpInside];
			} else {
				[codenameErrorRetryButton setTitle:@"Retry" forState:UIControlStateNormal];
				[codenameErrorRetryButton removeTarget:self action:@selector(playIntro) forControlEvents:UIControlEventTouchUpInside];
				[codenameErrorRetryButton addTarget:self action:@selector(codenameRetry) forControlEvents:UIControlEventTouchUpInside];
			}
			codenameErrorLabel.text = errorStr;
			codenameErrorView.hidden = NO;

		} else {

//			[API sharedInstance].playerInfo = [@{@"nickname": codenameToConfirm} mutableCopy];

			typewriterLabel.text = @"";

			typewriterView.hidden = NO;

			NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Creating encryption keys...\n\nID confirmed. %@ Access granted.\n\nProgram initiated...", codenameToConfirm]];
			[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16], NSForegroundColorAttributeName : [UIColor colorWithRed:45.0/255.0 green:239.0/255.0 blue:249.0/255.0 alpha:1.0]} range:NSMakeRange(0, attrStr.length)];
			[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16], NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(43, codenameToConfirm.length)];
			[typewriterLabel setAutoResizes:YES];
			[typewriterLabel setAttributedText:attrStr];

			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((attrStr.length * 0.05) + 2) * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self playIntro];
			});

//			popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((attrStr.length * 0.05) + 3) * NSEC_PER_SEC));
//			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//				introScrollerTimer = [NSTimer scheduledTimerWithTimeInterval:(0.04) target:self selector:@selector(autoscrollTimerFired) userInfo:nil repeats:YES];
//				[[SoundManager sharedManager] playSound:@"Sound/speech_zoomdown_intro.aif"];
//			});
//
//			popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((attrStr.length * 0.05) + 3) + 40 * NSEC_PER_SEC));
//			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//				[introScrollerTimer invalidate];
//				introScrollerTimer = nil;
//				//introView.hidden = YES;
//				[self performSegueWithIdentifier:@"LoadingCompletedSegue" sender:self];
//			});

		}

		codenameToConfirm = nil;

	}];

}

- (IBAction)codenameRetry {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	codenameConfirmView.hidden = YES;
	codenameErrorView.hidden = YES;

	createCodenameScrollview.hidden = NO;
	createCodenameLabel.hidden = NO;
	createCodenameField.hidden = NO;
	createCodenameButton.hidden = NO;
	createCodenameLabel.text = @"Try a different codename.";
	createCodenameField.text = @"";
	createCodenameButton.enabled = NO;
	[createCodenameField becomeFirstResponder];
	
}

#pragma mark - Intro

- (void)playIntro {

	introView.hidden = NO;

	createCodenameScrollview.hidden = YES;
	codenameConfirmButton.hidden = YES;
	codenameErrorView.hidden = YES;
	typewriterView.hidden = YES;

	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		introScrollerTimer = [NSTimer scheduledTimerWithTimeInterval:(0.04) target:self selector:@selector(autoscrollTimerFired) userInfo:nil repeats:YES];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
            [[SoundManager sharedManager] playSound:@"Sound/speech_zoomdown_intro.aif"];
        }
	});

	popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 + 40 * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[introScrollerTimer invalidate];
		introScrollerTimer = nil;
		//introView.hidden = YES;
		[self performSegueWithIdentifier:@"LoadingCompletedSegue" sender:self];
	});

}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController {
//	[UIView animateWithDuration:.2 animations:^{
//		CGRect frame = _tabBarArrow.frame;
//		frame.origin.x = [self horizontalLocationFor:_tabBarController.selectedIndex];
//		_tabBarArrow.frame = frame;
//	}];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
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
		[[AppDelegate instance] setTabBarVC:_tabBarController];

//		[self addTabBarArrow];

//		for (UINavigationController *navC in _tabBarController.viewControllers) {
//			navC.topViewController.view.hidden = NO;
//		}

		[_tabBarController setSelectedIndex:2];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleBackground]) {
            [[SoundManager sharedManager] playMusic:@"Sound/sfx_ambient_scanner_base.aif" looping:YES];
        }
	}
}

@end
