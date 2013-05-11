//
//  FontUtility.h
//  Ingress
//
//  Created by Alex Studnička on 12.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>

CTFontDescriptorRef CreateFontDescriptorFromName(CFStringRef iPostScriptName, CGFloat iSize);
CTFontDescriptorRef CreateFontDescriptorFromFamilyAndTraits(CFStringRef iFamilyName, CTFontSymbolicTraits iTraits, CGFloat iSize);
CTFontRef CreateFont(CTFontDescriptorRef iFontDescriptor, CGFloat iSize);
CTFontRef CreateBoldFont(CTFontRef iFont, Boolean iMakeBold);
CFDataRef CreateFlattenedFontData(CTFontRef iFont);
CTFontRef CreateFontFromFlattenedFontData(CFDataRef iData);