/* Copyright (c) 10/12/15, Ryan Dignard
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

FILE_START

@class NSManagedObjectContext;

/**
 Domain model objects may (but are not required) to conform to this protocol.  You may return non-standard data formats for use with `NSDataFormatter` and a dictionary of response keys which map to property names.
 */
@protocol RGDeserializable <NSObject>

@optional
/**
 @abstract Provide any overrides for default mapping behavior here.  The returned dictionary should have keys and values of type NSString and should be read left-to-right JSON source to target key.  Any unspecified key(s) will use the default behavior for mapping.  Can return `nil` (say you're overriding a class that implements this).
 */
+ (PREFIX_NULLABLE NSDictionary*) overrideKeysForMapping;

/**
 @abstract Provide a custom date format for use with the given property `propertyName`.  See documentation for NSDate for proper formats.  Can return `nil` (say you're overriding a class that implements this).
 */
+ (PREFIX_NULLABLE NSString*) dateFormatForProperty:(PREFIX_NONNULL NSString*)propertyName;

/**
 Return the desired type to construct for the given property.  If `Nil` is returned (or this method is not implemented) the default behavior is used, which takes the declared type of the property.
 */
+ (PREFIX_NULLABLE Class) classForPropertyNamed:(NSString*)propertyName;

/**
 @abstract implement this method to provide custom logic on a given property.  Return the value `YES` if this method is implemented and the default is desired.
 
 If the deserialization target is an `NSManagedObject` subclass you may use the context parameter for construction.
 
 This method tends to be necessary for deserializing arrays that lack a metadata key indicating the type of the object.
 */
- (BOOL) shouldTransformValue:(PREFIX_NULLABLE id)value forProperty:(PREFIX_NONNULL NSString*)propertyName inContext:(PREFIX_NULLABLE NSManagedObjectContext*)context;

@end

FILE_END
