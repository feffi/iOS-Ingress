//
//  MissionViewController.m
//  Ingress
//
//  Created by Alex Studnička on 05.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "MissionViewController.h"

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

	self.factionChoose = NO;

	wheelActivityIndicatorView = [[WheelActivityIndicatorView alloc] initWithFrame:CGRectZero];
	[self.view addSubview:wheelActivityIndicatorView];

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

- (void)setFactionChoose:(BOOL)factionChoose {
	_factionChoose = factionChoose;

	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.factionChoose) {
			[self setupFactionChooseIntro];
		} else {
			[self setupIntro];
		}
	});
	
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

	[mainButton.titleLabel setFont:[UIFont fontWithName:[[[UIButton appearance] font] fontName] size:28]];
	[mainButton setEnabled:YES];
	[mainButton setTitle:@"Proceed" forState:UIControlStateNormal];
	[mainButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[mainButton addTarget:self action:@selector(proceedFactionChoose) forControlEvents:UIControlEventTouchUpInside];

	textView.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName]  size:20];
	[textView setText:@"You have excelled. Your operative code is downloading. It will enable you to save portals from Shaper ingression. Beware the false promises of the Enlightened. Remember always who and what you are."];

	wheelActivityIndicatorView.center = CGPointMake(260, 40);
	[wheelActivityIndicatorView startAnimating];

//	textView.scrollInterval = 0.1;
//	[textView startScrolling];

	sound = [Sound soundNamed:@"Sound/speech_faction_choice_humanist_alt.aif"];
	[[SoundManager sharedManager] playSound:sound];

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
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

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

	[mainButton.titleLabel setFont:[UIFont fontWithName:[[[UIButton appearance] font] fontName] size:28]];
	[mainButton setEnabled:YES];
	[mainButton setTitle:@"Proceed" forState:UIControlStateNormal];
	[mainButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[mainButton addTarget:self action:@selector(factionChooseButtons) forControlEvents:UIControlEventTouchUpInside];

	textView.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName]  size:20];
	[textView setText:@"The Human Resistance revile us, because they fear tomorrow. They fear change. They fear the Enlightened.  Do you? I have planted a patch on your device. Join us. Become Enlightened."];

		//	textView.scrollInterval = 0.1;
		//	[textView startScrolling];

	sound = [Sound soundNamed:@"Sound/speech_faction_choice_enlightened.aif"];
	[[SoundManager sharedManager] playSound:sound];

		//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(18 * NSEC_PER_SEC));
		//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		//		[textView stopScrolling];
		//	});
	
}

- (void)factionChooseButtons {

	[[SoundManager sharedManager] stopSound:sound fadeOut:NO];
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

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

	[joinResistanceButton.titleLabel setFont:[UIFont fontWithName:[[[UIButton appearance] font] fontName] size:22]];
	[joinResistanceButton setTitleColor:[API colorForFaction:@"RESISTANCE"] forState:UIControlStateNormal];

	[joinEnlightenedButton.titleLabel setFont:[UIFont fontWithName:[[[UIButton appearance] font] fontName] size:22]];
	[joinEnlightenedButton setTitleColor:[API colorForFaction:@"ALIENS"] forState:UIControlStateNormal];
	
}

- (IBAction)join:(id)sender {

	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

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
			[[API sharedInstance] playerInfo][@"allowFactionChoice"] = @NO;
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

	[mainButton.titleLabel setFont:[UIFont fontWithName:[[[UIButton appearance] font] fontName] size:28]];
	[mainButton setTitle:@"Accept" forState:UIControlStateNormal];
	[mainButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[mainButton addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];

	[altButton.titleLabel setFont:[UIFont fontWithName:[[[UIButton appearance] font] fontName] size:22]];
 
	wheelActivityIndicatorView.center = backgroundImageView.center;
	[wheelActivityIndicatorView startAnimating];

	[[SoundManager sharedManager] playSound:@"Sound/speech_incoming_message.aif"];

	sound = [Sound soundNamed:@"Sound/sfx_ringtone.aif"];
	[[SoundManager sharedManager] playSound:sound looping:YES];

}

- (void)accept {

	[[SoundManager sharedManager] stopSound:sound fadeOut:NO];
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

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

	[mainButton.titleLabel setFont:[UIFont fontWithName:[[[UIButton appearance] font] fontName] size:28]];
	[mainButton setEnabled:NO];
	[mainButton setTitle:@"Start" forState:UIControlStateNormal];
	[mainButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[mainButton addTarget:self action:@selector(proceed) forControlEvents:UIControlEventTouchUpInside];

	[altButton.titleLabel setFont:[UIFont fontWithName:[[[UIButton appearance] font] fontName] size:22]];
	[altButton setTitle:@"Skip" forState:UIControlStateNormal];
	[altButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
	[altButton addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchUpInside];

	textView.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName]  size:20];
	[textView setText:@"Can you hear me? It is important that you hear me. Do not be nervous. This is routine.\n\nYou have downloaded what you believe to be a game, but it is not. Something is very wrong. There is an energy of unknown origin and intent seeping into our world. It is known as Exotic Matter.\n\n"];

	wheelActivityIndicatorView.center = CGPointMake(260, 40);
	[wheelActivityIndicatorView startAnimating];

//	textView.scrollInterval = 0.1;
//	[textView startScrolling];

	sound = [Sound soundNamed:@"Sound/speech_mission_0_intro.aif"];
	[[SoundManager sharedManager] playSound:sound];

//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(18 * NSEC_PER_SEC));
//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//		[textView stopScrolling];
//	});

}

- (void)proceed {
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)skip {
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
