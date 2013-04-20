//
//  TypeWriterLabel.m
//  Ingress
//
//  Created by Alex Studnička on 17.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "TypeWriterLabel.h"

@implementation TypeWriterLabel {
	NSAttributedString *newAttributedText;
	NSTimer *characterTimer;
	int characterIndex;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
	characterIndex = 0;
	newAttributedText = attributedText;
	if (!characterTimer) {
		characterTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(addCharacter) userInfo:nil repeats:YES];
	}
}

- (void)addCharacter {
	
	NSAttributedString *currentChar = [newAttributedText attributedSubstringFromRange:NSMakeRange(0, characterIndex)];
	
	[super setAttributedText:currentChar];

	CGRect frame = self.frame;
	frame.size.width = 280;
	self.frame = frame;
//	[self sizeToFit];

	characterIndex++;
	if (characterIndex > [newAttributedText length]) {
		[characterTimer invalidate];
		characterTimer = nil;
	}
	
}

@end
