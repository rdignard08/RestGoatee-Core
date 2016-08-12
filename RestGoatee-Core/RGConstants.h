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

/**
 @brief Defines an enumeration that describes a given property's storage semantics.
 */
typedef NS_ENUM(NSUInteger, RGStorageSemantics) {
/**
 @brief The value passed to the setter is assigned primitively.  Does not retain the assigned object.
   Does not become `nil` when there are no strong references.  Equivalent to `unsafe_unretained` for object pointers.
*/
    kRGPropertyAssign = 0,
/**
 @brief The value passed to the setter is assigned weakly.  Does not retain the assigned object.
   The return value is `nil` when there are no strong references.
*/
    kRGPropertyWeak = 1,
/**
 @brief The value passed to the setter is sent `-retain` before being assigned to the backing ivar.
   Equivalent to `retain`.
*/
    kRGPropertyStrong = 2,
/**
 @brief The value passed to the setter is sent `-copy` before being assigned to the backing ivar.
 */
    kRGPropertyCopy = 3
};

/**
 @brief Provides levels of logging suitable for different build environments.  Messages with severity greater than or
   equal to the current system severity will be logged.
 */
typedef NS_ENUM(int32_t, RGLogSeverity) {
    /**
     @brief Entire set of logging appropriate for debugging the library itself.
     */
    kRGLogSeverityTrace = 0,
    
    /**
     @brief Log messages useful for general debug and test builds.
     */
    kRGLogSeverityDebug = 1,
    
    /**
     @brief Log messages which might indicate something wrong.
     */
    kRGLogSeverityWarning = 2,
    
    /**
     @brief Log messages which indicate the system entered an error state.
     */
    kRGLogSeverityError = 3,
    
    /**
     @brief Log messages which indicate an assertion or interrupt should happen.
     */
    kRGLogSeverityFatal = 4,
    
    /**
     @brief Log level appropriate for messages which should always appear.
     */
    kRGLogSeverityNone = 5
};

/**
 @brief This is the largest memory allocation that will be made on the stack for a single identifer (VLA).
 */
FOUNDATION_EXPORT const size_t kRGMaxAutoSize;

/**
 @brief This key is inserted into `NSDictionary` instances which are serialized by this library.
   It facilitates easier reconversion back to the original type.  For example:
 @code
 FooBar* fooBar = ...;
 ...
 NSDictionary* serialized = [fooBar dictionaryRepresentation];
 ...
 id originalObject = [NSClassFromString(serialized[kRGSerializationKey]) objectFromDataSource:serialized];
 @endcode
 */
FOUNDATION_EXPORT NSString* RG_SUFFIX_NONNULL const kRGSerializationKey;

/**
 @brief This is the key used internally to store the value returned by `rg_threadsafe_formatter()`.
   You must not use this key with the dictionary at `-[NSThread threadDictionary]`.
 */
FOUNDATION_EXPORT NSString* RG_SUFFIX_NONNULL const kRGDateFormatterKey;

/**
 @brief This is the key used internally to store the value returned by `rg_number_formatter()`.
 You must not use this key with the dictionary at `-[NSThread threadDictionary]`.
 */
FOUNDATION_EXPORT NSString* RG_SUFFIX_NONNULL const kRGNumberFormatKey;

/**
 @brief This constant is used to identify the implicit document node.
 */
FOUNDATION_EXPORT NSString* RG_SUFFIX_NONNULL const kRGXMLRootNodeKey;

/**
 @brief When serialized to an `NSDictionary`, the `innerXML` of the node will appear on this key.
 */
FOUNDATION_EXPORT NSString* RG_SUFFIX_NONNULL const kRGInnerXMLKey;

/**
 @brief Will be `objc_getClass("NSObject")` i.e. `[NSObject self]`.
 */
FOUNDATION_EXPORT Class RG_SUFFIX_NONNULL kRGNSObjectClass;

/**
 @brief Will be `objc_getMetaClass("NSObject")`.
 */
FOUNDATION_EXPORT Class RG_SUFFIX_NONNULL kRGNSObjectMetaClass;

/**
 @brief Will be `[NSManagedObject self]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class RG_SUFFIX_NULLABLE kRGNSManagedObject;

/**
 @brief Will be `[NSEntityDescription self]` or `Nil` (if not linked/available).
 */
FOUNDATION_EXPORT Class RG_SUFFIX_NULLABLE kRGNSEntityDescClass;
