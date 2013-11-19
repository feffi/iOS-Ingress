//
//  PortalUpgradeViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 20.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalInfoViewController.h"
#import "ResonatorView.h"

@implementation PortalInfoViewController

@synthesize portal = _portal;

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self refresh];
}

#pragma mark - Refresh

- (void)refresh {
	
	for (int i = 0; i < 8; i++) {
		
		UILabel *levelLabel = (UILabel *)[self.view viewWithTag:10+i];
		levelLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:14];
		levelLabel.text = @" "; // IMPORTANT This needs to be a space or alignment will not work for all resonators.
		
		UIImageView *resonatorImage = (UIImageView *)[self.view viewWithTag:30+i];
		[resonatorImage setHidden:YES];
        
		ResonatorView *resonatorView = (ResonatorView *)[self.view viewWithTag:40+i];
		UIImageView *progressView = resonatorView.imageView;
		if ([self.portal.controllingTeam isEqualToString:@"ALIENS"]) {
			progressView.image = [UIImage imageNamed:@"enl_res_energy_fill.png"];
		} else {
			progressView.image = [UIImage imageNamed:@"hum_res_energy_fill.png"];
		}

		[progressView setHidden:YES];
	}
     

	for (DeployedResonator *resonator in self.portal.resonators) {

		if (![resonator isKindOfClass:[NSNull class]]) {

			int slot = resonator.slot;
			int level = resonator.level;
			float energy = resonator.energy;
			float maxEnergy = (float)[Utilities maxEnergyForResonatorLevel:level];

			UILabel *levelLabel = (UILabel *)[self.view viewWithTag:10+slot];
			levelLabel.text = [NSString stringWithFormat:@"L%d", level];
			levelLabel.textColor = [Utilities colorForLevel:level];

			UIImageView *resonatorImage = (UIImageView *)[self.view viewWithTag:30+slot];
			[resonatorImage setHidden:NO];

			ResonatorView *resonatorView = (ResonatorView *)[self.view viewWithTag:40+slot];
			UIImageView *progressView = resonatorView.imageView;
			[progressView setHidden:NO];

			float currentEnergy = (energy/maxEnergy) * 44;
			CGRect rect = CGRectMake(0, 44 - currentEnergy, 7, currentEnergy);

			progressView.frame = rect;
		}
		
	}
	
}

@end
