//
//  AttriubtedStringCoderHelper.m
//  Ingress
//
//  Created by Alex Studnička on 12.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "AttributedStringCoderHelper.h"
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import "FontUtility.h"

@implementation AttributedStringCoderHelper

+(void)encodeAttributedStringAttributes:(NSDictionary*)attributes withKeyedArchiver:(NSKeyedArchiver*)archiver     {

	NSString *key = nil;

	for(key in attributes)
	{
		if([key isEqualToString:(NSString*)kCTFontAttributeName]) {
			CTFontRef font = (CTFontRef)[attributes objectForKey:key];
			NSData* fontData = (NSData*)CreateFlattenedFontData(font);
			[archiver encodeObject:fontData forKey:key];
			[fontData release];
		}
		else if([key isEqualToString:(NSString*)kCTForegroundColorFromContextAttributeName]
				//                    || [key isEqualToString:(NSString*)kCTVerticalFormsAttributeName]     // IPHONE_NA
				) {
			CFBooleanRef boolRef = (CFBooleanRef)[attributes objectForKey:key];
			[archiver encodeBool:((boolRef == kCFBooleanTrue) ? YES : NO)  forKey:key];
		}
		else if([key isEqualToString:(NSString*)kCTKernAttributeName]
				|| [key isEqualToString:(NSString*)kCTStrokeWidthAttributeName]
				) {
			CFNumberRef valueRef = (CFNumberRef)[attributes objectForKey:key];
			float floatValue;
			CFNumberGetValue(valueRef, kCFNumberFloatType, &floatValue);
			[archiver encodeFloat:floatValue forKey:key];
		}
		else if([key isEqualToString:(NSString*)kCTLigatureAttributeName]
				||[key isEqualToString:(NSString*)kCTSuperscriptAttributeName]
				) {
			CFNumberRef valueRef = (CFNumberRef)[attributes objectForKey:key];
			int value;
			CFNumberGetValue(valueRef, kCFNumberIntType, &value);
			[archiver encodeInteger:value forKey:key];
		}
		else if([key isEqualToString:(NSString*)kCTForegroundColorAttributeName]
				|| [key isEqualToString:(NSString*)kCTStrokeColorAttributeName]
				|| [key isEqualToString:(NSString*)kCTUnderlineColorAttributeName]
				) {
			CGColorRef color = (CGColorRef)[attributes objectForKey:key];
			[archiver encodeObject:[UIColor colorWithCGColor:color]  forKey:key];
		}
		else if([key isEqualToString:(NSString*)kCTParagraphStyleAttributeName]) {
			// CTParagraphStyleRef
			// TODO: need to encode the paragraph style
		}
		else if([key isEqualToString:(NSString*)kCTUnderlineStyleAttributeName]) {
			// CFNumberRef bytes matter
			// TODO: need to encode the underline style
		}
		else if([key isEqualToString:(NSString*)kCTGlyphInfoAttributeName]) {
			// CTGlyphInfoRef
			// TODO: need to encode the Glyph Info
		}
		else if([key isEqualToString:(NSString*)kCTCharacterShapeAttributeName]) {
			// CFNumberRef see kCharacterShapeType selector in <ATS/SFNTLayoutTypes.h>
			// TODO: look into encoding the character shape attribute
		}
		else if([key isEqualToString:(NSString*)kCTRunDelegateAttributeName]) {
			// CTRunDelegateRef
			// probably won't encode and decode well
		}
	}
}



+(NSDictionary*)decodeAttributedStringAttriubtes:(NSKeyedUnarchiver*)decoder {
	NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];

	if([decoder containsValueForKey:(NSString *)kCTFontAttributeName]) {
		NSData *fontData = [decoder decodeObjectForKey:(NSString*)kCTFontAttributeName];
		if(fontData) {
			CTFontRef font = CreateFontFromFlattenedFontData((CFDataRef)fontData);
			[attributes setObject:(id)font forKey:(NSString*)kCTFontAttributeName];
			CFRelease(font);
		}
	}

	if([decoder containsValueForKey:(NSString *)kCTForegroundColorFromContextAttributeName]) {
		BOOL boolValue = [decoder decodeBoolForKey:(NSString *)kCTForegroundColorFromContextAttributeName];
		[attributes setObject:(id)(boolValue == YES ? kCFBooleanTrue : kCFBooleanFalse) forKey:(NSString*)kCTForegroundColorFromContextAttributeName];
	}

	//     IPHONE_NA
	//     if([decoder containsValueForKey:(NSString *)kCTVerticalFormsAttributeName]) {
	//          BOOL boolValue = [decoder decodeBoolForKey:(NSString *)kCTVerticalFormsAttributeName];
	//          [attributes setObject:(id)(boolValue == YES ? kCFBooleanTrue : kCFBooleanFalse) forKey:(NSString*)kCTVerticalFormsAttributeName];
	//     }

	if([decoder containsValueForKey:(NSString*)kCTForegroundColorAttributeName]) {
		[attributes setObject:(id)((UIColor*)[decoder decodeObjectForKey:(NSString *)kCTForegroundColorAttributeName]).CGColor forKey:(NSString*)kCTForegroundColorAttributeName];
	}

	if([decoder containsValueForKey:(NSString*)kCTStrokeColorAttributeName]) {
		[attributes setObject:(id)((UIColor*)[decoder decodeObjectForKey:(NSString *)kCTStrokeColorAttributeName]).CGColor forKey:(NSString*)kCTStrokeColorAttributeName];
	}

	if([decoder containsValueForKey:(NSString*)kCTUnderlineColorAttributeName]) {
		[attributes setObject:(id)((UIColor*)[decoder decodeObjectForKey:(NSString *)kCTUnderlineColorAttributeName]).CGColor forKey:(NSString*)kCTUnderlineColorAttributeName];
	}

	if([decoder containsValueForKey:(NSString *)kCTKernAttributeName]) {
		float value = [decoder decodeFloatForKey:(NSString *)kCTKernAttributeName];
		CFNumberRef valueRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &value);
		[attributes setObject:(id)valueRef  forKey:(NSString*)kCTKernAttributeName];
		CFRelease(valueRef);
	}

	if([decoder containsValueForKey:(NSString *)kCTStrokeWidthAttributeName]) {
		float value = [decoder decodeFloatForKey:(NSString *)kCTStrokeWidthAttributeName];
		CFNumberRef valueRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &value);
		[attributes setObject:(id)valueRef  forKey:(NSString*)kCTStrokeWidthAttributeName];
		CFRelease(valueRef);
	}

	if([decoder containsValueForKey:(NSString *)kCTLigatureAttributeName]) {
		int value = [decoder decodeIntForKey:(NSString *)kCTLigatureAttributeName];
		CFNumberRef valueRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &value);
		[attributes setObject:(id)valueRef forKey:(NSString*)kCTLigatureAttributeName];
		CFRelease(valueRef);
	}

	if([decoder containsValueForKey:(NSString *)kCTSuperscriptAttributeName]) {
		int value = [decoder decodeIntForKey:(NSString *)kCTSuperscriptAttributeName];
		CFNumberRef valueRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &value);
		[attributes setObject:(id)valueRef forKey:(NSString*)kCTSuperscriptAttributeName];
		CFRelease(valueRef);
	}

	return attributes;
}


+(NSData*)encodeAttributedString:(NSAttributedString*)attributedString{
	if(attributedString == nil)
		return nil;

	NSMutableData *attributedStringData = [NSMutableData data];
	NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:attributedStringData];
	[coder encodeObject:attributedString.string forKey:@"keyString"];

	NSMutableArray *ranges = [[NSMutableArray alloc] initWithCapacity:1];
	NSInteger length = attributedString.length;
	NSInteger pos = 0;
	// walk the string and get the attributes
	while (pos < length) {
		NSRange range;
		NSDictionary *attributes = [attributedString attributesAtIndex:pos effectiveRange:&range];
		NSMutableData *attributeData = [NSMutableData data];
		NSKeyedArchiver *attributeCoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:attributeData];
		[AttributedStringCoderHelper encodeAttributedStringAttributes:attributes withKeyedArchiver:attributeCoder];
		[attributeCoder finishEncoding];
		[attributeCoder release];

		NSString *keyRange = NSStringFromRange(range);
		[coder encodeObject:attributeData forKey:keyRange];
		[ranges addObject:keyRange];


		pos += range.length;
	}

	[coder encodeObject:ranges forKey:@"keyRanges"];
	[ranges release];

	[coder finishEncoding];
	[coder release];

	return attributedStringData;
}

+(NSAttributedString*)decodeAttributedStringFromData:(NSData*)data {
	NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];

	NSString *string = [decoder decodeObjectForKey:@"keyString"];


//	NSArray *ranges = [decoder decodeObjectForKey:@"keyRanges"];


	NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];

//	for (NSString *keyRange in ranges) {
//		NSData *aData = [(NSData*)[decoder decodeObjectForKey:keyRange] retain];
//		NSKeyedUnarchiver *attributeDecoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:aData];
//		[aData release];
//
//		NSDictionary *attributes = [AttributedStringCoderHelper decodeAttributedStringAttriubtes:attributeDecoder];
//		[attributeDecoder finishDecoding];
//		[attributeDecoder release];
//
//		[attrString addAttributes:attributes range:NSRangeFromString(keyRange)];
//	}

	[decoder finishDecoding];
	[decoder release];

	NSAttributedString *result = [[attrString copy] autorelease];

	[attrString release];

	return result;
}

@end
