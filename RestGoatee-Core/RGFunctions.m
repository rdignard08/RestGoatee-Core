/* Copyright (c) 01/21/2016, Ryan Dignard
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

#import "RestGoatee-Core.h"
#import <objc/runtime.h>

static NSArray RG_GENERIC(NSString*) * _sDateFormats;
static NSArray RG_GENERIC(NSString*) * RG_SUFFIX_NONNULL rg_replacement_date_formats(void) {
    return _sDateFormats;
}

static NSArray RG_GENERIC(NSString*) * RG_SUFFIX_NONNULL rg_original_date_formats(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sDateFormats = @[ @"yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                           @"yyyy-MM-dd HH:mm:ss ZZZZZ",
                           @"yyyy-MM-dd'T'HH:mm:ssz",
                           @"yyyy-MM-dd" ];
        rg_date_formats = rg_replacement_date_formats;
    });
    return _sDateFormats;
}
NSArray RG_GENERIC(NSString*) * RG_SUFFIX_NONNULL (* RG_SUFFIX_NONNULL rg_date_formats)(void) = rg_original_date_formats;

static size_t rg_to_lower_and_strip(const char* RG_SUFFIX_NONNULL const utfName,
                                    size_t length,
                                    char* RG_SUFFIX_NONNULL canonicalBuffer) {
    size_t outputLength = 0;
    for (size_t i = 0; i < length; i++) {
        char letter = utfName[i];
        switch (letter) { //!OCLINT optimized
            case '0' ... '9':
            case 'a' ... 'z': /* a digit or lowercase character; no change */
                canonicalBuffer[outputLength++] = letter;
                break;
            case 'A' ... 'Z': /* an uppercase character; to lower */
                canonicalBuffer[outputLength++] = letter + (const int)('a' - 'A');
        } /* unicodes, symbols, spaces, etc. are completely skipped */
    }
    return outputLength;
}

static NSString* RG_SUFFIX_NONNULL const rg_malloc_based_canonical(const char* RG_SUFFIX_NONNULL const utfName,
                                                                   size_t length) {
    char* canonicalBuffer = malloc(length);
    size_t outputLength = rg_to_lower_and_strip(utfName, length, canonicalBuffer);
    return [[NSString alloc] initWithBytesNoCopy:canonicalBuffer
                                          length:outputLength
                                        encoding:NSUTF8StringEncoding
                                    freeWhenDone:YES];
}

static NSString* RG_SUFFIX_NONNULL const rg_static_based_canonical(const char* RG_SUFFIX_NONNULL const utfName,
                                                                   size_t length) {
    char canonicalBuffer[length];
    size_t outputLength = rg_to_lower_and_strip(utfName, length, canonicalBuffer);
    return [[NSString alloc] initWithBytes:canonicalBuffer length:outputLength encoding:NSUTF8StringEncoding];
}

NSString* RG_SUFFIX_NONNULL const rg_canonical_form(const char* RG_SUFFIX_NONNULL const utfName) {
    const size_t length = strlen(utfName);
    if (length >= kRGMaxAutoSize) {
        return rg_malloc_based_canonical(utfName, length);
    }
    return rg_static_based_canonical(utfName, length);
}

void rg_swizzle(Class RG_SUFFIX_NULLABLE cls, SEL RG_SUFFIX_NULLABLE original, SEL RG_SUFFIX_NULLABLE replacement) {
    IMP replacementImp = method_setImplementation(class_getInstanceMethod(cls, replacement),
                                                  class_getMethodImplementation(cls, original));
    // get the replacement IMP
    // we assume swizzle is called on the class with replacement, so we can safety force original onto replacement
    // set the original IMP on the replacement selector
    // try to add the replacement IMP directly to the class on original selector
    // if it succeeds then we're all good (the original before was located on the superclass)
    // if it doesn't then that means an IMP is already there so we have to overwrite it
    if (!class_addMethod(cls,
                         original,
                         replacementImp,
                         method_getTypeEncoding(class_getInstanceMethod(cls, replacement)))) {
        method_setImplementation(class_getInstanceMethod(cls, original), replacementImp);
    }
}

NSDateFormatter* RG_SUFFIX_NONNULL rg_threadsafe_formatter(void) {
    NSDateFormatter* currentFormatter = [NSThread currentThread].threadDictionary[kRGDateFormatterKey];
    if (!currentFormatter) {
        currentFormatter = [NSDateFormatter new];
        [NSThread currentThread].threadDictionary[kRGDateFormatterKey] = currentFormatter;
    }
    return currentFormatter;
}

NSNumberFormatter* RG_SUFFIX_NONNULL rg_number_formatter(void) {
    NSNumberFormatter* currentFormatter = [NSThread currentThread].threadDictionary[kRGNumberFormatKey];
    if (!currentFormatter) {
        currentFormatter = [NSNumberFormatter new];
        [NSThread currentThread].threadDictionary[kRGNumberFormatKey] = currentFormatter;
    }
    return currentFormatter;
}

BOOL rg_isClassObject(id RG_SUFFIX_NULLABLE object) {
    /* if the class of the meta-class == NSObject's meta-class; object was itself a Class object */
    /* object_getClass * object_getClass * <plain_nsobject> should not return true */
    Class currentType = object_getClass(object);
    return currentType != kRGNSObjectClass && object_getClass(currentType) == kRGNSObjectMetaClass;
}

BOOL rg_isMetaClassObject(id RG_SUFFIX_NULLABLE object) {
    return rg_isClassObject(object) && class_isMetaClass(object);
}

BOOL rg_isInlineObject(Class RG_SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSDate self]] || [cls isSubclassOfClass:[NSString self]] ||
           [cls isSubclassOfClass:[NSData self]] || [cls isSubclassOfClass:[NSNull self]] ||
           [cls isSubclassOfClass:[NSValue self]] || [cls isSubclassOfClass:[NSURL self]];
}

BOOL rg_isStringInitObject(Class RG_SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSString self]] || [cls isSubclassOfClass:[NSURL self]] ||
           [cls isSubclassOfClass:[NSDecimalNumber self]];
}

BOOL rg_isCollectionObject(Class RG_SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSSet self]] || [cls isSubclassOfClass:[NSArray self]] ||
           [cls isSubclassOfClass:[NSOrderedSet self]];
}

BOOL rg_isKeyedCollectionObject(Class RG_SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSDictionary self]] || [cls isSubclassOfClass:[RGXMLNode self]];
}

BOOL rg_isDataSourceClass(Class RG_SUFFIX_NULLABLE cls) {
    return [cls conformsToProtocol:@protocol(RGDataSource)] || [cls isSubclassOfClass:[NSDictionary self]];
}

BOOL rg_is_integral_encoding(const char* RG_SUFFIX_NONNULL const encoding, unsigned long length) {
    static const char* const types[] = { @encode(_Bool),
                                         @encode(char),
                                         @encode(unsigned char),
                                         @encode(short),
                                         @encode(unsigned short),
                                         @encode(int),
                                         @encode(unsigned int),
                                         @encode(long),
                                         @encode(unsigned long),
                                         @encode(long long),
                                         @encode(unsigned long long) };
    for (size_t i = 0; i < sizeof(types) / sizeof(const char* const); i++) {
        if (strncmp(types[i], encoding, length) == 0) {
            return YES;
        }
    }
    return NO;
}

BOOL rg_is_floating_encoding(const char* RG_SUFFIX_NONNULL const encoding, unsigned long length) {
    return strncmp(@encode(float), encoding, length) == 0 ||
           strncmp(@encode(double), encoding, length) == 0 ||
           strncmp(@encode(long double), encoding, length) == 0;
}

NSMutableArray* RG_SUFFIX_NONNULL rg_unpack_array(NSArray* RG_SUFFIX_NULLABLE target,
                                                  NSManagedObjectContext* RG_SUFFIX_NULLABLE context) {
    NSMutableArray* ret = [NSMutableArray new];
    for (NSUInteger i = 0; i < target.count; i++) {
        id object = target[i];
        NSString* serializationClass;
        if ([object isKindOfClass:[NSDictionary self]]) {
            serializationClass = object[kRGSerializationKey];
        } else if ([object isKindOfClass:[RGXMLNode self]]) {
            serializationClass = [object valueForKey:kRGSerializationKey];
        }
        if (serializationClass) {
            Class objectClass = NSClassFromString(serializationClass);
            if (objectClass && !rg_isDataSourceClass(objectClass)) {
                object = [objectClass objectFromDataSource:object inContext:context];
            }
        }
        [ret addObject:object];
    }
    return ret;
}

NSString* RG_SUFFIX_NULLABLE rg_to_string(id RG_SUFFIX_NULLABLE object) {
    if ([object isKindOfClass:[NSString self]]) {
        return object;
    } else if ([object isKindOfClass:[RGXMLNode self]]) {
        return [object innerXML];
    } else if ([object isKindOfClass:[NSNumber self]]) {
        return [object stringValue];
    }
    return nil;
}
