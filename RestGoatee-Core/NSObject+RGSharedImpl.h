/* Copyright (c) 2/5/15, Ryan Dignard
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
#import "RGPropertyDeclaration.h"
#import <objc/runtime.h>

FILE_START

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
FOUNDATION_EXPORT NSString* SUFFIX_NONNULL const kRGSerializationKey;

/* These classes are used to dynamically link into coredata if present. */

/**
 Will be `[NSManagedObjectContext class]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class SUFFIX_NULLABLE rg_sNSManagedObjectContext;

/**
 Will be `[NSManagedObject class]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class SUFFIX_NULLABLE rg_sNSManagedObject;

/**
 Will be `[NSManagedObjectModel class]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class SUFFIX_NULLABLE rg_sNSManagedObjectModel;

/**
 Will be `[NSPersistentStoreCoordinator class]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class SUFFIX_NULLABLE rg_sNSPersistentStoreCoordinator;

/**
 Will be `[NSEntityDescription class]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class SUFFIX_NULLABLE rg_sNSEntityDescription;

/**
 Will be `[NSFetchRequest class]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class SUFFIX_NULLABLE rg_sNSFetchRequest;

/**
 Returns the built-in date formats the library supports. Contains: ISO, `-[NSDate description]`.
 */
NSArray GENERIC(NSString*) * SUFFIX_NULLABLE rg_dateFormats(void) __attribute__((pure));

/**
 Returns true if `Class cls = object;` is not a pointer type conversion.
 */
BOOL rg_isClassObject(id SUFFIX_NULLABLE object) __attribute__((pure));

/**
 Returns true if object has the same type as `NSObject`'s meta class.
 */
BOOL rg_isMetaClassObject(id SUFFIX_NULLABLE object) __attribute__((pure));

/**
 Returns true if the given type can be adequately represented by an `NSString`.
 */
BOOL rg_isInlineObject(Class SUFFIX_NULLABLE cls) __attribute__((pure));

/**
 Returns true if the given type can be adequately represented by an `NSArray`.
 */
BOOL rg_isCollectionObject(Class SUFFIX_NULLABLE cls) __attribute__((pure));

/**
 Returns true if the given type is a "key => value" type.  Thus it can be represented by an `NSDictionary`.
 */
BOOL rg_isKeyedCollectionObject(Class SUFFIX_NULLABLE cls) __attribute__((pure));

/**
 Returns true if the given class conforms to `RGDataSource`.  Necessary due to some bug.
 */
BOOL rg_isDataSourceClass(Class SUFFIX_NULLABLE cls) __attribute__((pure));

/**
 This is a private category which contains all the of the methods used jointly by the categories `RGDeserialization` and `RGSerialization`.
 */
@interface NSObject (RGSharedImpl)

/**
 This is describes the meta data of the given class.  It declares the properties in an object-oriented manner.  The keys are the names of the properties keyed to their declaration.
 */
+ (PREFIX_NONNULL NSMutableDictionary GENERIC(NSString*, RGPropertyDeclaration*) *) rg_propertyList;

/**
 This describes the meta data of the class.  The keys are the canonical representation of the property name mapped to an `RGPropertyDeclaration` object.
 */
+ (PREFIX_NONNULL NSMutableDictionary GENERIC(NSString*, RGPropertyDeclaration*) *) rg_canonicalPropertyList;

@end

FILE_END
