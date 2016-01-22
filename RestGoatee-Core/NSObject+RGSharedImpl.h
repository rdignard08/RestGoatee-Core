/* Copyright (c) 02/05/2015, Ryan Dignard
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
#import "RGXMLNode.h"
#import "RGPropertyDeclaration.h"
#import "RGDataSource.h"
#import <objc/runtime.h>

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
 Will be `objc_getClass("NSObject")` i.e. `[NSObject self]`.
 */
FOUNDATION_EXPORT Class RG_SUFFIX_NONNULL rg_NSObjectClass;

/**
 Will be `objc_getMetaClass("NSObject")`.
 */
FOUNDATION_EXPORT Class RG_SUFFIX_NONNULL rg_NSObjectMetaClass;

/* These classes are used to dynamically link into coredata if present. */

/**
 Will be `[NSManagedObject self]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class RG_SUFFIX_NULLABLE rg_NSManagedObject;

/**
 Will be `[NSEntityDescription self]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class RG_SUFFIX_NULLABLE rg_NSEntityDescription;

/**
 Returns the built-in date formats the library supports. Contains: ISO, `-[NSDate description]`.
 */
NSArray RG_GENERIC(NSString*) * RG_SUFFIX_NULLABLE rg_dateFormats(void) __attribute__((pure));

/**
 Returns `YES` if `Class cls = object;` is not a pointer type conversion.
 */
BOOL inline __attribute__((pure, always_inline, warn_unused_result)) rg_isClassObject(id RG_SUFFIX_NULLABLE object) {
    /* if the class of the meta-class == NSObject's meta-class; object was itself a Class object */
    /* object_getClass * object_getClass * <plain_nsobject> should not return true */
    Class currentType = object_getClass(object);
    return currentType != rg_NSObjectClass && object_getClass(currentType) == rg_NSObjectMetaClass;
}

/**
 Returns `YES` if object has the same type as `NSObject`'s meta class.
 */
BOOL inline __attribute__((pure, always_inline, warn_unused_result)) rg_isMetaClassObject(id RG_SUFFIX_NULLABLE object) {
    return rg_isClassObject(object) && class_isMetaClass(object);
}

/**
 Returns `YES` if the given type can be adequately represented by an `NSString`.
 */
BOOL inline __attribute__((pure, always_inline, warn_unused_result)) rg_isInlineObject(Class RG_SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSDate self]] || [cls isSubclassOfClass:[NSString self]] || [cls isSubclassOfClass:[NSData self]] || [cls isSubclassOfClass:[NSNull self]] || [cls isSubclassOfClass:[NSValue self]] || [cls isSubclassOfClass:[NSURL self]];
}

/**
 Returns `YES` if the given type can be adequately represented by an `NSArray`.
 */
BOOL inline __attribute__((pure, always_inline, warn_unused_result)) rg_isCollectionObject(Class RG_SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSSet self]] || [cls isSubclassOfClass:[NSArray self]] || [cls isSubclassOfClass:[NSOrderedSet self]];
}

/**
 Returns `YES` if the given type is a "key => value" type.  Thus it can be represented by an `NSDictionary`.
 */
BOOL inline __attribute__((pure, always_inline, warn_unused_result)) rg_isKeyedCollectionObject(Class RG_SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSDictionary self]] || [cls isSubclassOfClass:[RGXMLNode self]];
}

/**
 Returns `YES` if the given class conforms to `RGDataSource`.  Necessary due to some bug (the 2nd clause).
 */
BOOL inline __attribute__((pure, always_inline, warn_unused_result)) rg_isDataSourceClass(Class RG_SUFFIX_NULLABLE cls) {
    return [cls conformsToProtocol:@protocol(RGDataSource)] || [cls isSubclassOfClass:[NSDictionary self]];
}

/**
 This is a private category which contains all the of the methods used jointly by the categories `RGDeserialization` and `RGSerialization`.
 */
@interface NSObject (RGSharedImpl)

/**
 This is describes the meta data of the given class.  It declares the properties in an object-oriented manner.  The keys are the names of the properties keyed to their declaration.
 */
+ (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(NSString*, RGPropertyDeclaration*) *) rg_propertyList;

/**
 This describes the meta data of the class.  The keys are the canonical representation of the property name mapped to an `RGPropertyDeclaration` object.
 */
+ (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(NSString*, RGPropertyDeclaration*) *) rg_canonicalPropertyList;

@end
