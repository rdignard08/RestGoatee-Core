/* Copyright (c) 06/10/2014, Ryan Dignard
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

#import "RGDataSource.h"

@class NSManagedObjectContext;

/**
 This category provides generalized constructors for all domain model objects from a data source (these may be `NSDictionary` from JSON or `NSXMLParser` from XML or any custom class conforming to `RGDataSource`).
 */
@interface NSObject (RGDeserialization)

/**
 @abstract Construct an array of objects which is formed by invoking `+objectFromDataSource:inContext:` on the receiver with each input in the source.
 @param source Must be an iterable data source (i.e. `NSArray`, `NSSet`, `NSOrderedSet`, etc.).  For each entry, a new object is constructed.
 @param context Subclasses (or the properties thereof) typed `NSManagedObject` must provide a context all others may safely pass `nil`.
 @return an array of objects of the type of the receiver.  The return value is mutable, and you can mutate it to your heart's content.
 */
+ (RG_PREFIX_NONNULL NSMutableArray RG_GENERIC(id /* __kindof receiver */) *) objectsFromArraySource:(RG_PREFIX_NULLABLE id<NSFastEnumeration>)source inContext:(RG_PREFIX_NULLABLE NSManagedObjectContext*)context;

/**
 @abstract The receiver (the `Class` object) of this method will attempt to initialize an instance of itself with properties assigned from an `RGDataSource`.
 @param source For each key in the source, the key is interpreted to a property name, and the value on that key is coerced and assigned to the property.
 @param context Subclasses (or the properties thereof) typed `NSManagedObject` must provide a context all others may safely pass `nil`.
 @return an instance of the receiver; constructed with the values provided by `source`.
 */
+ (RG_PREFIX_NONNULL instancetype) objectFromDataSource:(RG_PREFIX_NULLABLE id<RGDataSource>)source inContext:(RG_PREFIX_NULLABLE NSManagedObjectContext*)context;

/**
 @abstract merges a data source into an existing object.  The return value is not a new object, but rather is the receiver augmented with the values in `object`.  Wherever they conflict, `source` takes precedence.
 @param source Can be of type `NSDictionary`, `RGXMLNode`, or any class conforming to `RGDataSource`.
 @param context Since there may be sub objects which are `NSManagedObject` subclasses, it may be necessary to provide an `NSManagedObjectContext` to contain them.
 @return the receiving object extended with `source`; any conflicts will take `source`'s value as precedent.
 */
- (RG_PREFIX_NONNULL instancetype) extendWith:(RG_PREFIX_NULLABLE id<RGDataSource>)source inContext:(RG_PREFIX_NULLABLE NSManagedObjectContext*)context;

@end
