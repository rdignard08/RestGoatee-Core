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
#import <objc/runtime.h>

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
 Returns the property name in as its canonical key.
 */
NSString* RG_SUFFIX_NONNULL const rg_canonical_form(const char* RG_SUFFIX_NONNULL const utf8Input) __attribute__((pure));

/**
 An object that encapsulates a property declaration, and enables object based introspection of a class.  It is a programmer error to invoke `-init`.
 */
@interface RGPropertyDeclaration : NSObject

/**
 The name of the property.
 */
@property RG_NONNULL_PROPERTY(nonatomic, strong, readonly) NSString* name;

/**
 The name of the property as used for key resolution.
 */
@property RG_NONNULL_PROPERTY(nonatomic, strong, readonly) NSString* canonicalName;

/**
 A `Class` object, an instance of which can contain the value of this property.  Primitive properties use `NSNumber` by default.
 */
@property RG_NONNULL_PROPERTY(nonatomic, strong, readonly) Class type;

/**
 The memory management semantics of the property.  The default is `assign` (`kRGPropertyAssign`).
 */
@property (nonatomic, assign, readonly) RGStorageSemantics storageSemantics;

/**
 Whether or not the property is a raw type (int, float, struct, union, etc.).  Default is `NO`.
 */
@property (nonatomic, assign, readonly) BOOL isPrimitive;

/**
 Whether or not the property is modifiable.  The default is `NO`.
 */
@property (nonatomic, assign, readonly) BOOL readOnly;

/**
 The designated initializer; it is a programmer error to invoke `-init`.
 */
- (RG_PREFIX_NONNULL instancetype) initWithProperty:(RG_PREFIX_NONNULL objc_property_t)property NS_DESIGNATED_INITIALIZER;

/**
 @warning Do not invoke this method.
 */
- (RG_PREFIX_NULLABLE instancetype) init NS_DESIGNATED_INITIALIZER;

@end
