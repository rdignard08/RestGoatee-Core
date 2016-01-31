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

NSArray RG_GENERIC(NSString*) * RG_SUFFIX_NONNULL rg_dateFormats(void) {
    static dispatch_once_t onceToken;
    static NSArray RG_GENERIC(NSString*) * _sDateFormats;
    dispatch_once(&onceToken, ^{
        _sDateFormats = @[ @"yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                           @"yyyy-MM-dd HH:mm:ss ZZZZZ",
                           @"yyyy-MM-dd'T'HH:mm:ssz",
                           @"yyyy-MM-dd" ];
    });
    return _sDateFormats;
}

static NSString* RG_SUFFIX_NONNULL const rg_malloc_based_canonical(const char* RG_SUFFIX_NONNULL const utfName,
                                                                   size_t length) {
    char* canonicalBuffer = malloc(length);
    size_t outputLength = 0;
    for (size_t i = 0; i != length; i++) {
        char c = utfName[i];
        if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z')) { /* a digit or lowercase character; no change */
            canonicalBuffer[outputLength++] = c;
        } else if (c >= 'A' && c <= 'Z') { /* an uppercase character; to lower */
            canonicalBuffer[outputLength++] = c + (const int)('a' - 'A'); /* 'a' - 'A' == 32 */
        } /* unicodes, symbols, spaces, etc. are completely skipped */
    }
    return [[NSString alloc] initWithBytesNoCopy:canonicalBuffer
                                          length:outputLength
                                        encoding:NSUTF8StringEncoding
                                    freeWhenDone:YES];
}

static NSString* RG_SUFFIX_NONNULL const rg_static_based_canonical(const char* RG_SUFFIX_NONNULL const utfName,
                                                                   size_t length) {
    char canonicalBuffer[length];
    size_t outputLength = 0;
    for (size_t i = 0; i != length; i++) {
        char c = utfName[i];
        if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z')) { /* a digit or lowercase character; no change */
            canonicalBuffer[outputLength++] = c;
        } else if (c >= 'A' && c <= 'Z') { /* an uppercase character; to lower */
            canonicalBuffer[outputLength++] = c + (const int)('a' - 'A'); /* 'a' - 'A' == 32 */
        } /* unicodes, symbols, spaces, etc. are completely skipped */
    }
    return [[NSString alloc] initWithBytes:canonicalBuffer length:outputLength encoding:NSUTF8StringEncoding];
}

NSString* RG_SUFFIX_NONNULL const rg_canonical_form(const char* RG_SUFFIX_NONNULL const utfName) {
    const size_t length = strlen(utfName);
    if (length >= kRGMaxAutoSize) {
        return rg_malloc_based_canonical(utfName, length);
    }
    return rg_static_based_canonical(utfName, length);
}

void rg_log(NSString* RG_SUFFIX_NONNULL format,
            const char* RG_SUFFIX_NONNULL const file,
            unsigned long line,
            ...) {
    va_list arguments;
    va_start(arguments, line);
    NSString* output = [[NSString alloc] initWithFormat:format arguments:arguments];
    fprintf(stderr, "[%s:%lu] %s\n", file, line, output.UTF8String);
    va_end(arguments);
}

void rg_swizzle(Class RG_SUFFIX_NULLABLE cls, SEL RG_SUFFIX_NULLABLE original, SEL RG_SUFFIX_NULLABLE replacement) {
    IMP replacementImplementation = method_setImplementation(class_getInstanceMethod(cls, replacement),
                                                             class_getMethodImplementation(cls, original));
    // get the replacement IMP
    // we assume swizzle is called on the class with replacement, so we can safety force original onto replacement
    // set the original IMP on the replacement selector
    // try to add the replacement IMP directly to the class on original selector
    // if it succeeds then we're all good (the original before was located on the superclass)
    // if it doesn't then that means an IMP is already there so we have to overwrite it
    if (!class_addMethod(cls,
                         original,
                         replacementImplementation,
                         method_getTypeEncoding(class_getInstanceMethod(cls, replacement)))) {
        method_setImplementation(class_getInstanceMethod(cls, original), replacementImplementation);
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

BOOL rg_isClassObject(id RG_SUFFIX_NULLABLE object) {
    /* if the class of the meta-class == NSObject's meta-class; object was itself a Class object */
    /* object_getClass * object_getClass * <plain_nsobject> should not return true */
    Class currentType = object_getClass(object);
    return currentType != rg_NSObjectClass && object_getClass(currentType) == rg_NSObjectMetaClass;
}

/**
 Returns `YES` if object has the same type as `NSObject`'s meta class.
 */
BOOL rg_isMetaClassObject(id RG_SUFFIX_NULLABLE object) {
    return rg_isClassObject(object) && class_isMetaClass(object);
}

/**
 Returns `YES` if the given type can be adequately represented by an `NSString`.
 */
BOOL rg_isInlineObject(Class RG_SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSDate self]] || [cls isSubclassOfClass:[NSString self]] ||
           [cls isSubclassOfClass:[NSData self]] || [cls isSubclassOfClass:[NSNull self]] ||
           [cls isSubclassOfClass:[NSValue self]] || [cls isSubclassOfClass:[NSURL self]];
}

/**
 Returns `YES` if the given type can be adequately represented by an `NSArray`.
 */
BOOL rg_isCollectionObject(Class RG_SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSSet self]] || [cls isSubclassOfClass:[NSArray self]] ||
           [cls isSubclassOfClass:[NSOrderedSet self]];
}

/**
 Returns `YES` if the given type is a "key => value" type.  Thus it can be represented by an `NSDictionary`.
 */
BOOL rg_isKeyedCollectionObject(Class RG_SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSDictionary self]] || [cls isSubclassOfClass:[RGXMLNode self]];
}

/**
 Returns `YES` if the given class conforms to `RGDataSource`.  Necessary due to some bug (the 2nd clause).
 */
BOOL rg_isDataSourceClass(Class RG_SUFFIX_NULLABLE cls) {
    return [cls conformsToProtocol:@protocol(RGDataSource)] || [cls isSubclassOfClass:[NSDictionary self]];
}
