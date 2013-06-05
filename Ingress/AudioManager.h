//
//  AudioManager.h
//  Ingress
//
//  Created by Alex Studnička on 05.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	SoundTypeBackground,
	SoundTypeEffects,
	SoundTypeSpeech
} SoundType;

@interface AudioManager : NSObject

@property (nonatomic, strong) Sound *uiSuccessSound;
@property (nonatomic, strong) Sound *uiFailSound;
@property (nonatomic, strong) Sound *uiBackSound;


+ (instancetype)sharedInstance;

@end
