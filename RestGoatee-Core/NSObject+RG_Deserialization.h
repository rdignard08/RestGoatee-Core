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

#import "RGDefines.h"

FILE_START

@protocol RGDataSource;
@class NSManagedObjectContext;

/**
 This category provides generalized constructors for all domain model objects from a data source (these may be `NSDictionary*` from JSON or `NSXMLParser*` from XML or any custom `RGDataSourceProtocol`).
 */
@interface NSObject (RG_Deserialization)

/**
 The receiver (the `Class` object) of this method will attempt to initialize an instance of itself with properties assigned from an `RGDataSource`.
 Subclasses (or the properties thereof) typed `NSManagedObject` must provide a context all others may safely pass `nil`.
 
 */
+ (PREFIX_NONNULL instancetype) objectFromDataSource:(PREFIX_NULLABLE id<RGDataSource>)source inContext:(PREFIX_NULLABLE NSManagedObjectContext*)context;

/**
 Creates and returns an array of objects of the type of the receiver.  The method iterates over the provided collection and calls `+objectFromDataSource:inContext:` on each one.  The return value is mutable, and you can mutate it to your heart's content.
 */
+ (PREFIX_NONNULL NSMutableArray GENERIC(id /* __kindof receiver */) *) objectsFromArraySource:(PREFIX_NULLABLE id<NSFastEnumeration>)source inContext:(PREFIX_NULLABLE NSManagedObjectContext*)context;

/**
 @abstract merges two objects into a single object.  The return value is not a new object, but rather is the receiver augmented with the values in `object`.
 @param object Can be of type `NSDictionary`, `RGXMLNode`, or a user defined type conforming to `RGDataSource`.
 @param context Since there may be sub objects which are `NSManagedObject` subclasses, it may be necessary to provide an `NSManagedObjectContext` to contain them.
 @return the receiving object extended with `source`; any conflicts will take `source`'s value as precedent.
 */
- (PREFIX_NONNULL instancetype) extendWith:(PREFIX_NULLABLE id<RGDataSource>)source inContext:(PREFIX_NULLABLE NSManagedObjectContext*)context;

@end

FILE_END
