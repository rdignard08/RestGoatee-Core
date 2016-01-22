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

#import "RGDefines.h"

/**
 Defines an enumeration that describes a given property's storage semantics.  unsafe_unretained == assign, retain == strong.
 */
typedef NS_ENUM(NSUInteger, RGStorageSemantics) {
    kRGPropertyAssign = 0x00,
    kRGPropertyWeak = 0x01,
    kRGPropertyStrong = 0x10,
    kRGPropertyCopy = 0x11
};

/**
 This is the largest memory allocation that will be made on the stack for a single identifer (VLA).
 */
FOUNDATION_EXPORT const size_t kRGMaxAutoSize;

/**
 This key is inserted into `NSDictionary*` instances which are serialized by this library.  It facilitates easier reconversion back to the original type.  Usage:
 ```
 FooBar* fooBar = ...;
 ...
 NSDictionary* serialized = [fooBar dictionaryRepresentation];
 ...
 id originalObject = [NSClassFromString(serialized[kRGSerializationKey]) objectFromDataSource:serialized];
 ```
 */
FOUNDATION_EXPORT NSString* RG_SUFFIX_NONNULL const kRGSerializationKey;

/**
 This is the key used interally to store the value returned by `rg_threadsafe_formatter()`.  You must not use this key with the dictionary at `-[NSThread threadDictionary]`.
 */
FOUNDATION_EXPORT NSString* RG_SUFFIX_NONNULL const kRGDateFormatterKey;

/**
 This constant is used to identify the implicit document node.
 */
FOUNDATION_EXPORT NSString* RG_SUFFIX_NONNULL const kRGXMLDocumentNodeKey;

/**
 When serialized to an NSDictionary, the `innerXML` of the node will appear on this key.
 */
FOUNDATION_EXPORT NSString* RG_SUFFIX_NONNULL const kRGInnerXMLKey;

/**
 Will be `objc_getClass("NSObject")` i.e. `[NSObject self]`.
 */
FOUNDATION_EXPORT Class RG_SUFFIX_NONNULL rg_NSObjectClass;

/**
 Will be `objc_getMetaClass("NSObject")`.
 */
FOUNDATION_EXPORT Class RG_SUFFIX_NONNULL rg_NSObjectMetaClass;

/**
 Will be `[NSManagedObject self]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class RG_SUFFIX_NULLABLE rg_NSManagedObject;

/**
 Will be `[NSEntityDescription self]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class RG_SUFFIX_NULLABLE rg_NSEntityDescription;
