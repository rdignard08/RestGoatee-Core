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
 @abstract Provide any overrides for default mapping behavior here.  Any unspecified key(s) will use the default behavior for mapping.
 @return a dictionary with keys and values of type `NSString` which is read left-to-right: JSON source to target property name.  Can return `nil` (say you're overriding a class that implements this).
 */
+ (PREFIX_NULLABLE NSDictionary GENERIC(NSString*, NSString*) *) overrideKeysForMapping;

/**
 @abstract Provide a custom date format for use with the given property `propertyName`.  See documentation of `NSDate` for proper formats.
 @param propertyName The name of the property being set.
 @return a date format string to be used for the given property.  Can return `nil` (say you're overriding a class that implements this).
 */
+ (PREFIX_NULLABLE NSString*) dateFormatForProperty:(PREFIX_NONNULL NSString*)propertyName;

/**
 @abstract implement this method to provide custom logic on a given property.  This method tends to be necessary for deserializing arrays that lack a metadata key indicating the type of the object.
 @param value The raw input received from the data source.  The type of this object should always be checked before use.
 @param propertyName The name of the property being set.
 @param context If the deserialization target is an `NSManagedObject` subclass or contains one you may use the parameter `context` for its construction.
 @return `NO` if caller will handle assignment or `YES` if the default is desired.
 */
- (BOOL) shouldTransformValue:(PREFIX_NULLABLE id)value forProperty:(PREFIX_NONNULL NSString*)propertyName inContext:(PREFIX_NULLABLE NSManagedObjectContext*)context;

@end

FILE_END
