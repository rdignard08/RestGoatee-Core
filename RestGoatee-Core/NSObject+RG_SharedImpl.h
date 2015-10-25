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

FILE_START

/**
 forward declaration from <objc/runtime.h>
 */
struct objc_property;

/**
 forward declaration from <objc/runtime.h>
 */
struct objc_ivar;

/* Some notes on property attributes, declaration modifiers
    assign is exactly the same unsafe_unretained 
    retain is exactly the same as strong
    __block implies strong
    backing ivars are usually `_<propertyName>` however older compilers sometimes named them the same
 */

/* Property Description Keys */

/**
 The key associated with the name of one of the class's properties.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyName;

/**
 The key associated with the canonical name of one of the class's properties.
 
 canonical names are used to match disparate keys to the same meta key. This is to say that the keys "fooBar" and "foo_bar" share the same meta/canonical key and will be resolved to the same entry.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyCanonicalName;

/**
 The key associated with a property's storage qualifier (i.e. `assign`, `weak`, `strong`, `copy`, `unsafe_unretained`).
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyStorage;

/**
 The key associated with a property's atomic nature (i.e. `atomic`, `nonatomic`).
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyAtomicType;

/**
 The key associated with a property's public declaration (i.e. `readonly`, `readwrite`).
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyAccess;

/**
 The key associated with a property's backing instance variable (if any).  Pass through properties will appear to have no backing state for example.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyBacking;

/**
 The key associated with a property's getter method (if non-standard; for example on `fooBar`: `isFooBar`).
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyGetter;

/**
 The key associated with a property's setter method (if non-standard; for example on `fooBar`: `setIsFooBar`).
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertySetter;

/**
 This value on the key `kRGPropertyAccess` indicates the property is `readwrite`.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyReadwrite;

/**
 This value on the key `kRGPropertyAccess` indicates the property is `readonly`.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyReadonly;

/**
 This value on the key `kRGPropertyStorage` indicates the property is `assign`.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyAssign;

/**
 This value on the key `kRGPropertyStorage` indicates the property is `strong`.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyStrong;

/**
 This value on the key `kRGPropertyStorage` indicates the property is `copy`.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyCopy;

/**
 This value on the key `kRGPropertyStorage` indicates the property is `weak`.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyWeak;

/**
 The key associated with the class type of this property.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyClass;

/**
 The key associated with the general type of this property.  Represents structs, pointers, primitives, etc.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyRawType;

/**
 This value on the key `kRGPropertyBacking` indicates the property was declared `@dynamic`.  Mutually exclusive with the presence of a backing instance variable.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyDynamic;

/**
 This value on the key `kRGPropertyAtomicType` indicates the property is `atomic`.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyAtomic;

/**
 This value on the key `kRGPropertyAtomicType` indicates the property is `nonatomic`.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyNonatomic;

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
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGSerializationKey;

/**
 This key indicates the class meta data that the library uses for all other operations.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGPropertyListProperty;

/* Ivar Description Keys */

/**
 This key indicates the byte offset of the given instance variable into an instance of the class.
 
 Raw access can be accomplished with:
 `void* address = (unsigned char*)obj + [meta[kRGIvarOffset] unsignedLongLongValue];`
 Then use the value available on `kRGIvarSize` to deference and get the raw value.
 
 Granted you shouldn't do this. The run-time supports it, so it's not my place to artificially limit.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGIvarOffset;

/**
 This key indicates the byte size of the given instance variable.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGIvarSize;

/**
 This instance variable was marked `@private`.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGIvarPrivate;

/**
 This instance variable was marked `@protected`.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGIvarProtected;

/**
 This instance variable was marked `@public`.
 */
FOUNDATION_EXPORT NSString* suffix_nonnull const kRGIvarPublic;

/* These classes are used to dynamically link into coredata if present. */

/**
 Will be `[NSManagedObjectContext class]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class suffix_nullable rg_sNSManagedObjectContext;

/**
 Will be `[NSManagedObject class]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class suffix_nullable rg_sNSManagedObject;

/**
 Will be `[NSManagedObjectModel class]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class suffix_nullable rg_sNSManagedObjectModel;

/**
 Will be `[NSPersistentStoreCoordinator class]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class suffix_nullable rg_sNSPersistentStoreCoordinator;

/**
 Will be `[NSEntityDescription class]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class suffix_nullable rg_sNSEntityDescription;

/**
 Will be `[NSFetchRequest class]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class suffix_nullable rg_sNSFetchRequest;

/**
 Returns the built-in date formats the library supports. Contains: ISO, `-[NSDate description]`.
 */
NSArray GENERIC(NSString*) * suffix_nullable rg_dateFormats(void) __attribute__((pure));

/**
 Returns true if `Class cls = object;` is not a pointer type conversion.
 */
BOOL rg_isClassObject(id suffix_nullable object) __attribute__((pure));

/**
 Returns true if object has the same type as `NSObject`'s meta class.
 */
BOOL rg_isMetaClassObject(id suffix_nullable object) __attribute__((pure));

/**
 Returns true if the given type can be adequately represented by an `NSString`.
 */
BOOL rg_isInlineObject(Class suffix_nullable cls) __attribute__((pure));

/**
 Returns true if the given type can be adequately represented by an `NSArray`.
 */
BOOL rg_isCollectionObject(Class suffix_nullable cls) __attribute__((pure));

/**
 Returns true if the given type is a "key => value" type.  Thus it can be represented by an `NSDictionary`.
 */
BOOL rg_isKeyedCollectionObject(Class suffix_nullable cls) __attribute__((pure));

/**
 Returns true if the given class conforms to `RGDataSourceProtocol`.  Necessary due to some bug.
 */
BOOL rg_isDataSourceClass(Class suffix_nullable cls) __attribute__((pure));

/**
 converts the raw property struct from the run-time system into an `NSDictionary`.
 */
NSDictionary* suffix_nullable rg_parsePropertyStruct(struct objc_property* suffix_nonnull property) __attribute__((pure));

/**
 Return the class object which is responsible for providing the implementation of a given `self.propertyName` invocation.
 
 multiple classes may implement the same property, in this instance, only the top (i.e. the most subclass Class object) is returned.
 
 @param currentClass is the object to test
 @param propertyName is the name of the property
 */
Class suffix_nullable rg_topClassDeclaringPropertyNamed(Class suffix_nullable currentClass, NSString* suffix_nullable propertyName) __attribute__((pure));

/**
 This is a private category which contains all the of the methods used jointly by the categories `RG_Deserialization` and `RG_Serialization`.
 */
@interface NSObject (RG_SharedImpl)

/**
 This is describes the meta data of the given class.  It declares properties and instance variables in an object-oriented manner.
 */
+ (prefix_nonnull NSMutableArray GENERIC(NSMutableDictionary*) *) rg_propertyList;

/**
 This function returns the output keys of the receiver for use when determining what state information is present in the instance.
 */
@property nonnull_property(nonatomic, strong, readonly) NSArray* rg_keys;

/**
 Returns a `Class` object which is the type of the property specified by `propertyName`; defaults to `NSNumber` if unknown.
 */
- (prefix_nonnull Class) rg_classForProperty:(prefix_nonnull NSString*)propertyName;

/**
 Returns `YES` if the type of the property is an object type (as known by `NSClassFromString()`).
 */
- (BOOL) rg_isPrimitive:(prefix_nonnull NSString*)propertyName;

/**
 Returns the metadata for the property specified by `propertyName`.
 */
+ (prefix_nullable NSDictionary*) rg_declarationForProperty:(prefix_nonnull NSString*)propertyName;

@end

FILE_END
