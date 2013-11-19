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

- (id)init {
    self = [super init];
    if (self) {
        self.delayBetweenCharacters = 0.05;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delayBetweenCharacters = 0.05;
    }
    return self;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
	characterIndex = 0;
	newAttributedText = attributedText;
	if (!characterTimer) {
		characterTimer = [NSTimer scheduledTimerWithTimeInterval:self.delayBetweenCharacters target:self selector:@selector(addCharacter) userInfo:nil repeats:YES];
	}
}

- (void)addCharacter {
	
	NSAttributedString *currentChar = [newAttributedText attributedSubstringFromRange:NSMakeRange(0, characterIndex)];
	
	[super setAttributedText:currentChar];

	CGRect frame = self.frame;
	frame.size.width = 280;
	self.frame = frame;
	if (self.autoResizes) {
		[self sizeToFit];
	}

	characterIndex++;
	if (characterIndex > [newAttributedText length]) {
		[characterTimer invalidate];
		characterTimer = nil;
	}
	
}

@end
