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

#import "RGDataSourceProtocol.h"

FILE_START

@class NSManagedObjectContext;

/**
 This category provides generalized constructors for all objects from a response object (these may be `NSDictionary*` from JSON or `NSXMLParser*` from XML).
 
 You usually do not need to use these methods directly, since calls through the `RGAPIClient` will call the appropriate family of methods from this category.
 */
@interface NSObject (RG_Deserialization)

/**
 @abstract subclasses of `NSManagedObject` must use this method since they cannot be initialized without a context.
 */
+ (prefix_nonnull instancetype) objectFromDataSource:(prefix_nullable id<RGDataSourceProtocol>)source inContext:(prefix_nullable NSManagedObjectContext*)context;

/**
 @abstract the receiver (the Class object) which receives this method will attempt to initialize an instance of this class with properties assigned from a data source.
 */
+ (prefix_nonnull instancetype) objectFromDataSource:(prefix_nullable id<RGDataSourceProtocol>)source;

/**
 @abstract creates and returns an array of objects of the type of the receiver.  Need only be something iteratable.
 */
+ (prefix_nonnull NSArray*) objectsFromArraySource:(prefix_nullable id<NSFastEnumeration>)source inContext:(prefix_nullable NSManagedObjectContext*)context;

/**
 @abstract creates and returns an array of objects of the type of the receiver.
 */
+ (prefix_nonnull NSArray*) objectsFromArraySource:(prefix_nullable id<NSFastEnumeration>)source;

/**
 @abstract merges two objects into a single object.  The return value is not a new object, but rather is the receiver augmented with the values in `object`.
 @param object Can be of type NSDictionary, RGXMLNode, or a user defined type conforming to `RGDataSourceProtocol`.
 @return the receiving object extended with `object`; any conflicts will take `object`'s value as precedent.
 */
- (prefix_nonnull instancetype) extendWith:(prefix_nullable NSObject<RGDataSourceProtocol>*)object;

/**
 Same as `-extendWith:` but since there may be sub objects which are `NSManagedObject` subclasses, it may be necessary to provide an `NSManagedObjectContext` to contain them.
 */
- (prefix_nonnull instancetype) extendWith:(prefix_nullable NSObject<RGDataSourceProtocol>*)object inContext:(prefix_nullable NSManagedObjectContext*)context;

@end

FILE_END
