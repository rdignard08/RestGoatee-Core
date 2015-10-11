/* Copyright (c) 6/10/14, Ryan Dignard
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
NS_ASSUME_NONNULL_BEGIN

@class NSManagedObjectContext;

/**
 Class objects which are passed to `RGAPIClient` methods may (but are not required) to conform to this protocol.  You may return non-standard data formats for use with `NSDataFormatter` and a dictionary of response keys which map to property names.
 */
@protocol RestGoateeSerialization <NSObject>

@optional
/**
 @abstract Provide any overrides for default mapping behavior here.  The returned dictionary should have keys and values of type NSString and should be read left-to-right JSON source to target key.  Any unspecified key(s) will use the default behavior for mapping.  Can return `nil` (say you're overriding a class that implements this).
 */
+ (nullable NSDictionary*) overrideKeysForMapping;

/**
 @abstract Provide a custom date format for use with the given property `key`.  See documentation for NSDate for proper formats.  Can return `nil` (say you're overriding a class that implements this).
 */
+ (nullable NSString*) dateFormatForKey:(NSString*)key;

/**
 @abstract implement this method to provide custom logic on a given property.  Return the original value if this method is implemented and the default is desired.
 
 If the deserialization desired is an `NSManagedObject` subclass you may use the context parameter for construction.
 
 This method tends to be necessary for deserializing arrays that lack a metadata key indicating the type of the object.
 */
- (id) transformValue:(id)value forProperty:(NSString*)property inContext:(nullable NSManagedObjectContext*)context;

@end


/**
 This category provides generalized constructors for all objects from a response object (these may be `NSDictionary*` from JSON or `NSXMLParser*` from XML).
 
 You usually do not need to use these methods directly, since calls through the `RGAPIClient` will call the appropriate family of methods from this category.
 */
@interface NSObject (RG_Deserialization)

/**
 @abstract subclasses of `NSManagedObject` must use this method since they cannot be initialized without a context.
 */
+ (instancetype) objectFromDataSource:(id<RGDataSourceProtocol>)source inContext:(nullable NSManagedObjectContext*)context;

/**
 @abstract the receiver (the Class object) which receives this method will attempt to initialize an instance of this class with properties assigned from a data source.
 */
+ (instancetype) objectFromDataSource:(id<RGDataSourceProtocol>)source;

/**
 @abstract creates and returns an array of objects of the type of the receiver.  Need only be something iteratable.
 */
+ (NSArray*) objectsFromArraySource:(id<NSFastEnumeration>)source inContext:(nullable NSManagedObjectContext*)context;

/**
 @abstract creates and returns an array of objects of the type of the receiver.
 */
+ (NSArray*) objectsFromArraySource:(id<NSFastEnumeration>)source;

/**
 @abstract merges two objects into a single object.  The return value is not a new object, but rather is the receiver augmented with the values in `object`.
 @param object Can be of type NSDictionary, RGXMLNode, or a user defined type conforming to `RGDataSourceProtocol`.
 @return the receiving object extended with `object`; any conflicts will take `object`'s value as precedent.
 */
- (instancetype) extendWith:(NSObject<RGDataSourceProtocol>*)object;

/**
 Same as `-extendWith:` but since there may be sub objects which are `NSManagedObject` subclasses, it may be necessary to provide an `NSManagedObjectContext` to contain them.
 */
- (instancetype) extendWith:(NSObject<RGDataSourceProtocol>*)object inContext:(nullable NSManagedObjectContext*)context;

@end

NS_ASSUME_NONNULL_END
#pragma clang diagnostic pop
