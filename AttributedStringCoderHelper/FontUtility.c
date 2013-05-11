//
//  FontUtility.c
//  Ingress
//
//  Created by Alex Studnička on 12.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#include "FontUtility.h"
#include <assert.h>
#include <AssertMacros.h>

CTFontDescriptorRef CreateFontDescriptorFromName(CFStringRef iPostScriptName, CGFloat iSize)
{
    assert(iPostScriptName != NULL);
    return CTFontDescriptorCreateWithNameAndSize(iPostScriptName, iSize);
}

CTFontDescriptorRef CreateFontDescriptorFromFamilyAndTraits(CFStringRef iFamilyName, CTFontSymbolicTraits iTraits, CGFloat iSize)
{
    CTFontDescriptorRef descriptor = NULL;
    CFMutableDictionaryRef attributes;

    assert(iFamilyName != NULL);


    // Create a mutable dictionary to hold our attributes.
    attributes = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    check(attributes != NULL);

    if (attributes != NULL) {
        CFMutableDictionaryRef traits;
        CFNumberRef symTraits;

        // Add a family name to our attributes.
        CFDictionaryAddValue(attributes, kCTFontFamilyNameAttribute, iFamilyName);

        // Create the traits dictionary.
        symTraits = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &iTraits);

        check(symTraits != NULL);

        if (symTraits != NULL) {
            // Create a dictionary to hold our traits values.
            traits = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

            check(traits != NULL);

            if (traits != NULL) {
                // Add the symbolic traits value to the traits dictionary.
                CFDictionaryAddValue(traits, kCTFontSymbolicTrait, symTraits);

                // Add the traits attribute to our attributes.
                CFDictionaryAddValue(attributes, kCTFontTraitsAttribute, traits);

                CFRelease(traits);
            }

            CFRelease(symTraits);
        }

        // Create the font descriptor with our attributes and input size.
        descriptor = CTFontDescriptorCreateWithAttributes(attributes);
        check(descriptor != NULL);

        CFRelease(attributes);
    }

    // Return our font descriptor.
    return descriptor;
}

CTFontRef CreateFont(CTFontDescriptorRef iFontDescriptor, CGFloat iSize)
{
    check(iFontDescriptor != NULL);

    // Create the font from the font descriptor and input size. Pass
    // NULL for the matrix parameter to use the default matrix (identity).
    return CTFontCreateWithFontDescriptor(iFontDescriptor, iSize, NULL);

}

CTFontRef CreateBoldFont(CTFontRef iFont, Boolean iMakeBold)
{
    CTFontSymbolicTraits desiredTrait = 0;
    CTFontSymbolicTraits traitMask;

    // If we are trying to make the font bold, set the desired trait
    // to be bold.

    if (iMakeBold)
		desiredTrait = kCTFontBoldTrait;

    // Mask off the bold trait to indicate that it is the only trait
    // desired to be modified. As CTFontSymbolicTraits is a bit field,
    // we could choose to change multiple traits if we desired.
    traitMask = kCTFontBoldTrait;

    // Create a copy of the original font with the masked trait set to the
    // desired value. If the font family does not have the appropriate style,
    // this will return NULL.
    return CTFontCreateCopyWithSymbolicTraits(iFont, 0.0, NULL, desiredTrait, traitMask);
}

CFDataRef CreateFlattenedFontData(CTFontRef iFont)
{
    CFDataRef           result = NULL;
    CTFontDescriptorRef descriptor;
    CFDictionaryRef     attributes;

    check(iFont != NULL);


    // Get the font descriptor for the font.
    descriptor = CTFontCopyFontDescriptor(iFont);
    check(descriptor != NULL);

    if (descriptor != NULL) {
        // Get the font attributes from the descriptor. This should be enough
        // information to recreate the descriptor and the font later.
        attributes = CTFontDescriptorCopyAttributes(descriptor);
        check(attributes != NULL);

        if (attributes != NULL) {
            // If attributes are a valid property list, directly flatten
            // the property list. Otherwise we may need to analyze the attributes
            // and remove or manually convert them to serializable forms.
            // This is left as an exercise for the reader.
			if (CFPropertyListIsValid(attributes, kCFPropertyListXMLFormat_v1_0)) {
                result = CFPropertyListCreateXMLData(kCFAllocatorDefault, attributes);

                check(result != NULL);
			}
			CFRelease(attributes);
        }
		CFRelease(descriptor);
    }

    return result;
}


CTFontRef CreateFontFromFlattenedFontData(CFDataRef iData)
{
    CTFontRef           font = NULL;
    CFDictionaryRef     attributes;
    CTFontDescriptorRef descriptor;

    check(iData != NULL);

    // Create our font attributes from the property list. We will create
    // an immutable object for simplicity, but if you needed to massage
    // the attributes or convert certain attributes from their serializable
    // form to the Core Text usable form, you could do it here.

    attributes =
	(CFDictionaryRef)CFPropertyListCreateFromXMLData(kCFAllocatorDefault, iData, kCFPropertyListImmutable, NULL);

    check(attributes != NULL);

    if (attributes != NULL) {
        // Create the font descriptor from the attributes.
        descriptor = CTFontDescriptorCreateWithAttributes(attributes);
        check(descriptor != NULL);

        if (descriptor != NULL) {
            // Create the font from the font descriptor. We will use
            // 0.0 and NULL for the size and matrix parameters. This
            // causes the font to be created with the size and/or matrix
            // that exist in the descriptor, if present. Otherwise default
            // values are used.
            font = CTFontCreateWithFontDescriptor(descriptor, 0.0, NULL);
            check(font != NULL);

            CFRelease(descriptor);
        }


		CFRelease(attributes);
    }
	
    return font;
}
