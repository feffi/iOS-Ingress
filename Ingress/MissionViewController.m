//
//  MissionViewController.m
//  Ingress
//
//  Created by Alex Studnička on 05.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "MissionViewController.h"
#import "NSShadow+Initilalizer.h"

@implementation MissionViewController {
	Sound *sound;
	float authProgress;

	NSTimer *authProgressTimer;
	NSTimer *jarvisBackgroundTimer;
}

@synthesize factionChoose = _factionChoose;

- (void)viewDidLoad {
    [super viewDidLoad];

	authLabel.hidden = YES;
	authProgressView.hidden = YES;
	typewriterLabel.hidden = YES;
	factionChooseButtons.hidden = YES;
	backgroundImageView.hidden = YES;
	titleLabel.hidden = YES;
	subtitleLabel.hidden = YES;
	wheelActivityIndicatorView.hidden = YES;
	textView.hidden = YES;
	mainButton.hidden = YES;
	altButton.hidden = YES;
	choosingLabel.hidden = YES;

	wheelActivityIndicatorView = [[WheelActivityIndicatorView alloc] initWithFrame:CGRectZero];
	[self.view addSubview:wheelActivityIndicatorView];

	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.factionChoose) {
			[self setupFactionChooseIntro];
		} else {
			[self setupIntro];
		}
	});

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[[GAI sharedInstance] defaultTracker] sendView:@"Mission Screen"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewDidLayoutSubviews {
//	[super viewDidLayoutSubviews];
//
//}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[wheelActivityIndicatorView stopAnimating];

	[[SoundManager sharedManager] stopSound:sound fadeOut:NO];
}

#pragma mark - Faction Choose

- (void)jarvisBackground {
	for (int i = 0; i < 150; i++) {
		[self showRandomView];
	}
}

- (void)showRandomView {
	
	__block UIView *view = [UIView new];
	view.frame = CGRectMake(arc4random_uniform(self.view.frame.size.width), self.view.frame.size.height-arc4random_uniform(300), arc4random_uniform(self.view.frame.size.width/3.), 20.);
	view.alpha = ((arc4random_uniform(50)+10.)/100.);
	view.backgroundColor = [UIColor colorWithRed:0.000 green:0.945 blue:0.439 alpha:1.000];

	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((float)(arc4random_uniform(200)/100.+.5) * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[jarvisBackground insertSubview:view atIndex:arc4random_uniform(jarvisBackground.subviews.count)];

		[UIView animateWithDuration:arc4random_uniform(200)/100.+1. animations:^{
			view.alpha = 0;
		} completion:^(BOOL finished) {
			[view removeFromSuperview];
			view = nil;
		}];
	}); 
	
}

- (void)setupFactionChooseIntro {

	authLabel.hidden = YES;
	authProgressView.hidden = YES;
	typewriterLabel.hidden = YES;
	factionChooseButtons.hidden = YES;
	backgroundImageView.hidden = NO;
	titleLabel.hidden = NO;
	subtitleLabel.hidden = NO;
	wheelActivityIndicatorView.hidden = NO;
	textView.hidden = NO;
	mainButton.hidden = NO;
	altButton.hidden = YES;
	choosingLabel.hidden = YES;

	[backgroundImageView setImage:[[UIImage imageNamed:@"blue_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 2, 23, 30)]];

	titleLabel.text = @"ADA";
	subtitleLabel.text = @"unknown";

	[titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22]];
	[subtitleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18]];

	[mainButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:28]];
	[mainButton setEnabled:YES];
	[mainButton setTitle:@"Proceed" forState:UIControlStateNormal];
	[mainButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[mainButton addTarget:self action:@selector(proceedFactionChoose) forControlEvents:UIControlEventTouchUpInside];

	textView.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName]  size:20];
	textView.glowing = YES;
	[textView setText:@"You have excelled. Your operative code is downloading. It will enable you to save portals from Shaper ingression. Beware the false promises of the Enlightened. Remember always who and what you are."];

	wheelActivityIndicatorView.center = CGPointMake(260, 40);
	[wheelActivityIndicatorView startAnimating];

//	textView.scrollInterval = 0.1;
//	[textView startScrolling];
    
	sound = [Sound soundNamed:@"Sound/speech_faction_choice_humanist_alt.aif"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
        [[SoundManager sharedManager] playSound:sound];
    }
    
//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(18 * NSEC_PER_SEC));
//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//		[textView stopScrolling];
//	});

}

- (void)authProgress {
	[authProgressView setProgress:authProgress];
	if (authProgress >= 1) {
		[authProgressTimer invalidate];
		authProgressTimer = nil;

		authLabel.hidden = YES;
		authProgressView.hidden = YES;
		typewriterLabel.hidden = NO;
		factionChooseButtons.hidden = YES;
		backgroundImageView.hidden = YES;
		titleLabel.hidden = YES;
		subtitleLabel.hidden = YES;
		wheelActivityIndicatorView.hidden = YES;
		textView.hidden = YES;
		mainButton.hidden = YES;
		altButton.hidden = YES;
		choosingLabel.hidden = YES;

		NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"*\n*\n*\nCOM.SATLINK/INIT.\nCOM.RECEIV/TRAN.\nAUTH.SIGNAL/EXEC\nERROR/DIVBY0\nERROR/MEMLOC.AEH1C0.BUFFER-OVERRUN\nSTOR,PATCH.J --> AEH1C0\nMOV DX,9\nDIV CL\nXOR AH,11\nPOP DX\nEXTRACT->MEMLOC.AEH1C0\nRETURN/EXTRACTED PATCH.JARVIS\n\nEXEC->PATCH.JARVIS.INIT"];
		[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:14], NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(0, attrStr.length)];
		[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:14], NSForegroundColorAttributeName : [UIColor redColor]} range:NSMakeRange(217, 23)];
		[typewriterLabel setAutoResizes:YES];
		[typewriterLabel setAttributedText:attrStr];

		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((attrStr.length * 0.05) + 1) * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

			NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"*\n*\n*\nJMP  0x1F\nPOPL %ESI\nMOVL %ESI,0x8(%ESI)\nXORL %EAX,%EAX\nMOVB %EAX,0x7(%ESI)\nMOVL %EAX,0xC(%ESI)\nMOVB $0xB,%AL\nMOVL %ESI,%EBX\nLEAL 0x8(%ESI),%ECX\nLEAL 0xC(%ESI),%EDX\nINT  $0x80\nXORL %EBX,%EBX\nMOVL %EBX,%EAX\nINC  %EAX\nINT  $0x80\nCALL -0x24"];
			[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:14], NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(0, attrStr.length)];
			[typewriterLabel setAutoResizes:YES];
			[typewriterLabel setAttributedText:attrStr];

			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((attrStr.length * 0.05) + 1) * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self setupJarvisIntro];
			});

		});

	} else {
		authProgress += .01;
	}
}

- (void)proceedFactionChoose {

	[[SoundManager sharedManager] stopSound:sound fadeOut:NO];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	authLabel.hidden = NO;
	authProgressView.hidden = NO;
	typewriterLabel.hidden = YES;
	factionChooseButtons.hidden = YES;
	backgroundImageView.hidden = YES;
	titleLabel.hidden = YES;
	subtitleLabel.hidden = YES;
	wheelActivityIndicatorView.hidden = YES;
	textView.hidden = YES;
	mainButton.hidden = YES;
	altButton.hidden = YES;
	choosingLabel.hidden = YES;

	authLabel.text = @"Authenticating operative code";
	[authLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22]];

	authProgressTimer = [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(authProgress) userInfo:nil repeats:YES];

	jarvisBackground.hidden = NO;
	jarvisBackgroundTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(jarvisBackground) userInfo:nil repeats:YES];

}

- (void)setupJarvisIntro {

	authLabel.hidden = YES;
	authProgressView.hidden = YES;
	typewriterLabel.hidden = YES;
	factionChooseButtons.hidden = YES;
	backgroundImageView.hidden = NO;
	titleLabel.hidden = NO;
	subtitleLabel.hidden = NO;
	wheelActivityIndicatorView.hidden = YES;
	textView.hidden = NO;
	mainButton.hidden = NO;
	altButton.hidden = YES;
	choosingLabel.hidden = YES;

	[backgroundImageView setImage:[[UIImage imageNamed:@"green_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 2, 23, 30)]];

	titleLabel.text = @"Jarvis ";
	subtitleLabel.text = @"Foreign signal";

	[titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22]];
	[subtitleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18]];

	[mainButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:28]];
	[mainButton setEnabled:YES];
	[mainButton setTitle:@"Proceed" forState:UIControlStateNormal];
	[mainButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[mainButton addTarget:self action:@selector(factionChooseButtons) forControlEvents:UIControlEventTouchUpInside];

	textView.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName]  size:20];
	textView.glowing = YES;
	[textView setText:@"The Human Resistance revile us, because they fear tomorrow. They fear change. They fear the Enlightened.  Do you? I have planted a patch on your device. Join us. Become Enlightened."];

		//	textView.scrollInterval = 0.1;
		//	[textView startScrolling];

	sound = [Sound soundNamed:@"Sound/speech_faction_choice_enlightened.aif"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
        [[SoundManager sharedManager] playSound:sound];
    }
    
		//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(18 * NSEC_PER_SEC));
		//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		//		[textView stopScrolling];
		//	});
	
}

- (void)factionChooseButtons {
	[[SoundManager sharedManager] stopSound:sound fadeOut:NO];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
	[self showFactionChooseButtons];

}

- (void)showFactionChooseButtons {
	
	authLabel.hidden = YES;
	authProgressView.hidden = YES;
	typewriterLabel.hidden = YES;
	factionChooseButtons.hidden = NO;
	backgroundImageView.hidden = YES;
	titleLabel.hidden = YES;
	subtitleLabel.hidden = YES;
	wheelActivityIndicatorView.hidden = YES;
	textView.hidden = YES;
	mainButton.hidden = YES;
	altButton.hidden = YES;
	choosingLabel.hidden = YES;

	[joinResistanceButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22]];
	[joinResistanceButton setTitleColor:[Utilities colorForFaction:@"RESISTANCE"] forState:UIControlStateNormal];

	[joinEnlightenedButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22]];
	[joinEnlightenedButton setTitleColor:[Utilities colorForFaction:@"ALIENS"] forState:UIControlStateNormal];
	
}

- (IBAction)join:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	[jarvisBackgroundTimer invalidate];
	jarvisBackgroundTimer = nil;
	jarvisBackground.hidden = YES;

	authLabel.hidden = YES;
	authProgressView.hidden = YES;
	typewriterLabel.hidden = YES;
	factionChooseButtons.hidden = YES;
	backgroundImageView.hidden = YES;
	titleLabel.hidden = YES;
	subtitleLabel.hidden = YES;
	wheelActivityIndicatorView.hidden = NO;
	textView.hidden = YES;
	mainButton.hidden = YES;
	altButton.hidden = YES;
	choosingLabel.hidden = NO;
	
	NSString *faction = nil;
	if ([sender isEqual:joinEnlightenedButton]) {
		faction = @"ALIENS";
		[choosingLabel setText:@"Choosing Jarvis..."];
	} else {
		faction = @"RESISTANCE";
		[choosingLabel setText:@"Choosing ADA..."];
	}

	wheelActivityIndicatorView.center = backgroundImageView.center;
	[wheelActivityIndicatorView startAnimating];

	[[API sharedInstance] chooseFaction:faction completionHandler:^(NSString *errorStr) {

		if (errorStr) {
			[self jarvisBackground];
			jarvisBackground.hidden = NO;
			jarvisBackgroundTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(jarvisBackground) userInfo:nil repeats:YES];
			[self factionChooseButtons];
		} else {
			Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
			player.allowFactionChoice = NO;
			[self dismissViewControllerAnimated:YES completion:nil];
		}

	}];

}

#pragma mark - Missions

- (void)setupIntro {

	authLabel.hidden = YES;
	authProgressView.hidden = YES;
	typewriterLabel.hidden = YES;
	factionChooseButtons.hidden = YES;
	backgroundImageView.hidden = NO;
	titleLabel.hidden = NO;
	subtitleLabel.hidden = NO;
	wheelActivityIndicatorView.hidden = NO;
	textView.hidden = YES;
	mainButton.hidden = NO;
	altButton.hidden = YES;
	choosingLabel.hidden = YES;

	[backgroundImageView setImage:[[UIImage imageNamed:@"blue_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 2, 23, 30)]];

	titleLabel.text = @"ADA";
	subtitleLabel.text = @"unknown";

	[titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22]];
	[subtitleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18]];

	[mainButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:28]];
	[mainButton setTitle:@"Accept" forState:UIControlStateNormal];
	[mainButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[mainButton addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];

	[altButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22]];

	[wheelActivityIndicatorView startAnimating];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
		wheelActivityIndicatorView.center = backgroundImageView.center;
	});
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
        [[SoundManager sharedManager] playSound:@"Sound/speech_incoming_message.aif"];
    }
    sound = [Sound soundNamed:@"Sound/sfx_ringtone.aif"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:sound looping:YES];
    }
}

- (void)accept {

	[[SoundManager sharedManager] stopSound:sound fadeOut:NO];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	authLabel.hidden = YES;
	authProgressView.hidden = YES;
	typewriterLabel.hidden = YES;
	factionChooseButtons.hidden = YES;
	backgroundImageView.hidden = NO;
	titleLabel.hidden = NO;
	subtitleLabel.hidden = NO;
	wheelActivityIndicatorView.hidden = NO;
	textView.hidden = NO;
	mainButton.hidden = NO;
	altButton.hidden = NO;
	choosingLabel.hidden = YES;

	titleLabel.text = @"ADA";
	subtitleLabel.text = @"unknown";

	[titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22]];
	[subtitleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18]];

	[mainButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:28]];
	[mainButton setTitle:@"Start" forState:UIControlStateNormal];
	[mainButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[mainButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];

	[altButton.titleLabel setFont:[UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22]];
	[altButton setTitle:@"Skip" forState:UIControlStateNormal];
	[altButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[altButton addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchUpInside];

	wheelActivityIndicatorView.center = CGPointMake(260, 40);
	[wheelActivityIndicatorView startAnimating];

	switch (self.mission) {
		case 1: {

			[textView setText:@"Can you hear me? It is important that you hear me. Do not be nervous. This is routine.\n\nYou have downloaded what you believe to be a game, but it is not. Something is very wrong. There is an energy of unknown origin and intent seeping into our world. It is known as Exotic Matter."];
			textView.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName]  size:20];
			textView.textColor = [UIColor whiteColor];
			textView.glowing = YES;
			sound = [Sound soundNamed:@"Sound/speech_mission_0_intro.aif"];

			break;
		}
		case 2: {

			NSMutableAttributedString *attrStr = [NSMutableAttributedString new];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Mission - Retrieve XM\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22],
				NSForegroundColorAttributeName : [UIColor whiteColor],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:22/5 color:[UIColor whiteColor]]
			}]];

			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Objectives\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"- Walk towards XM\n- Collect 1000 XM\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Exotic Matter, also known as XM, is both energy and matter, just as water is liquid, solid and vapor. It leaks into our dimension through Portals. XM cluster nearby. Identify it. Move to it. It will gravitate to your Scanner."
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			textView.glowing = NO;
			[textView setAttributedText:attrStr];

			sound = [Sound soundNamed:@"Sound/speech_mission_1_intro.aif"];

			break;
		}
		case 3: {

			NSMutableAttributedString *attrStr = [NSMutableAttributedString new];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Mission - Hack a Portal\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22],
				NSForegroundColorAttributeName : [UIColor whiteColor],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:22/5 color:[UIColor whiteColor]]
			}]];

			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Objectives\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"- Walk to Portal\n- Tap Portal and HACK\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"There is a Portal nearby. Close on the Portal until it is within your range circle. Tap the Portal on the Scanner Map. Select Hack. Warning, this is a hostile Portal. Move out of range after hacking."
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			textView.glowing = NO;
			[textView setAttributedText:attrStr];

			sound = [Sound soundNamed:@"Sound/speech_mission_2_intro.aif"];

			break;
		}
		case 4: {

			NSMutableAttributedString *attrStr = [NSMutableAttributedString new];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Mission - Fire XMP\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22],
				NSForegroundColorAttributeName : [UIColor whiteColor],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:22/5 color:[UIColor whiteColor]]
			}]];

			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Objectives\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"- Press and hold on map\n- Select FIRE XMP\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"This Portal is resonated. In this simulation, it is enemy controlled. To attack, move within range of the Portal, press and hold on the Scanner Map, then select FIRE XMP."
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			textView.glowing = NO;
			[textView setAttributedText:attrStr];

			sound = [Sound soundNamed:@"Sound/speech_mission_3_intro.aif"];

			break;
		}
		case 5: {

			NSMutableAttributedString *attrStr = [NSMutableAttributedString new];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Mission - Deploy Resonator\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22],
				NSForegroundColorAttributeName : [UIColor whiteColor],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:22/5 color:[UIColor whiteColor]]
			}]];

			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Objectives\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"- Click on Portal\n- Deploy Resonator\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Resonators are used to control Portals. To deploy a Resonator, close within range, tap the Portal, and select DEPLOY RESONATOR."
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			textView.glowing = NO;
			[textView setAttributedText:attrStr];

			sound = [Sound soundNamed:@"Sound/speech_mission_4_intro.aif"];

			break;
		}
		case 6: {

			NSMutableAttributedString *attrStr = [NSMutableAttributedString new];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Mission - Resonating\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22],
				NSForegroundColorAttributeName : [UIColor whiteColor],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:22/5 color:[UIColor whiteColor]]
			}]];

			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Objectives\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"- Hack nearby Portal\n- Deploy remaining Resonators\n- Recharge Resonators\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Portals can be linked together by powerful bands of Exotic Matter. In order to link, Portals must have eight charged Resonators. Move within range of a nearby Portal and hack it to obtain Resonators. Deploy them and recharge all Resonators above critical levels."
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			textView.glowing = NO;
			[textView setAttributedText:attrStr];

			sound = [Sound soundNamed:@"Sound/speech_mission_5_intro.aif"];
			
			break;
		}
		case 7: {

			NSMutableAttributedString *attrStr = [NSMutableAttributedString new];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Mission - Links\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22],
				NSForegroundColorAttributeName : [UIColor whiteColor],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:22/5 color:[UIColor whiteColor]]
			}]];

			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Objectives\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"- Hack Portal for key\n- Tap another Portal\n- Hack second Portal\n- Deploy all Resonators\n- Click on Portal and LINK\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"You are now ready to link two Portals.\n\nPortals can be hacked in order to obtain their Portal Keys. Once you have obtained a Portal Key, you can remotely link to it.\n\nSelect LINK to begin the linking process. Eligible destination Portals will be indicated on the Scanner by a red highlight.\n\nA Portal not visible on the Scanner can be linked by selecting the Portal Key.\n\nHack a nearby Portal to obtain its Portal Key. Then move within range of another Portal to initiate a Link."
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			textView.glowing = NO;
			[textView setAttributedText:attrStr];

			sound = [Sound soundNamed:@"Sound/speech_mission_6_intro.aif"];
			
			break;
		}
		case 8: {

			NSMutableAttributedString *attrStr = [NSMutableAttributedString new];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Mission - Fields\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22],
				NSForegroundColorAttributeName : [UIColor whiteColor],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:22/5 color:[UIColor whiteColor]]
			}]];

			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"Objectives\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"- Hack Portal for key\n- Tap another Portal\n- Hack second Portal\n- Deploy all Resonators\n- Click on Portal and LINK\n- Tap third Portal\n- Hack third Portal\n- Prepare Portal for linking\n- Create second Link\n- Create third Link\n"
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.996 green:0.835 blue:0.318 alpha:1.000]]
			}]];
			
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:
				@"The most important goal we have is to protect humanity from enemy ingression.\n\nWe do that by connecting Portals and forming protective Fields. Fields are formed by three connected Portals.\n\nObtain Portal Keys and use them to create two additional Links to form a triangle.  Move to the third Portal and hack it to obtain a Portal Key."
			attributes:@{
				NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20],
				NSForegroundColorAttributeName : [UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000],
				NSShadowAttributeName: [NSShadow shadowWithOffset:CGSizeZero blurRadius:20/5 color:[UIColor colorWithRed:0.565 green:0.996 blue:0.996 alpha:1.000]]
			}]];
			
			textView.glowing = NO;
			[textView setAttributedText:attrStr];

			sound = [Sound soundNamed:@"Sound/speech_mission_7_intro.aif"];

			break;
		}
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
        [[SoundManager sharedManager] playSound:sound];
    }
}

- (void)start {
	[[SoundManager sharedManager] stopSound:sound fadeOut:NO];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
        [[API sharedInstance] playSounds:@[@"SPEECH_MISSION", @"SPEECH_OFFLINE"]]; //SPEECH_ACTIVATED
    }
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)skip {
	[[SoundManager sharedManager] stopSound:sound fadeOut:NO];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
        [[API sharedInstance] playSounds:@[@"SPEECH_MISSION", @"SPEECH_ABANDONED"]];
    }
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
