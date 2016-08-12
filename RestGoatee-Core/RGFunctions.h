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

#import "RGConstants.h"
#import "RGXMLNode.h"

/* These functions are subject to change and should not be used directly */

@class NSManagedObjectContext;

/**
 @brief invoking returns the built-in date formats the library supports. Contains: ISO, `-[NSDate description]`.
 */
FOUNDATION_EXPORT NSArray RG_GENERIC(NSString*) * RG_SUFFIX_NONNULL (* RG_SUFFIX_NONNULL rg_date_formats)(void);

/**
 @return a per thread instance of `NSDateFormatter`.  Never pass the returned object between threads.
   Always set and restore the object's properties (`dateFormat`, `locale`, `timezone`, etc.) before use.
 */
NSDateFormatter* RG_SUFFIX_NONNULL rg_threadsafe_formatter(void) __attribute__((hot, returns_nonnull));

/**
 @return a per thread instance of `NSNumberFormatter`.  Never pass the returned object between threads.
   Always set and restore the object's properties (`numberStyle`, `locale`, `formatterBehavior`, etc.) before use.
 */
NSNumberFormatter* RG_SUFFIX_NONNULL rg_number_formatter(void) __attribute__((hot, returns_nonnull));

/**
 @param utf8Input a `\0` terminated C string.  With unicodes must be UTF-8 encoded.  May not be `NULL`.
 @return the property name in its canonical form.
 */
NSString* RG_SUFFIX_NONNULL rg_canonical_form(const char* RG_SUFFIX_NONNULL const utf8Input)
    __attribute__((pure, nonnull, returns_nonnull));

/**
 @param object may be any type of object including `nil`.
 @return `YES` if the parameter `object` is of type `Class` but _not_ a meta-class.
 */
BOOL rg_isClassObject(id RG_SUFFIX_NULLABLE object) __attribute__((pure, always_inline, warn_unused_result));

/**
 @param object may be any type of object including `nil`.
 @return `YES` if object has the same type as `NSObject`'s meta class.
 */
BOOL rg_isMetaClassObject(id RG_SUFFIX_NULLABLE object) __attribute__((pure, always_inline, warn_unused_result));

/**
 @param cls the type to be tested for `NSString` similarity.
 @return `YES` if the given type can be adequately represented by an `NSString`.
 */
BOOL rg_isInlineObject(Class RG_SUFFIX_NULLABLE cls) __attribute__((pure, always_inline, warn_unused_result));

/**
 @param cls the type to be tested for an `NSString` initializer.
 @return `YES` if the object responds "correctly" to `initWithString:`.
 */
BOOL rg_isStringInitObject(Class RG_SUFFIX_NULLABLE cls) __attribute__((pure, always_inline, warn_unused_result));

/**
 @param cls the type to be tested for `NSArray` similarity.
 @return `YES` if the given type can be adequately represented by an `NSArray`.
 */
BOOL rg_isCollectionObject(Class RG_SUFFIX_NULLABLE cls) __attribute__((pure, always_inline, warn_unused_result));

/**
 @param cls the type to be tested for `NSDictionary` similarity.
 @return `YES` if the given type is a "key => value" type.  Thus it can be represented by an `NSDictionary`.
 */
BOOL rg_isKeyedCollectionObject(Class RG_SUFFIX_NULLABLE cls) __attribute__((pure, always_inline, warn_unused_result));

/**
 @param cls the type to be tested for conformance to `RGDataSource`.  Just `RGXMLNode` and `NSDictionary` by default.
 @return `YES` if the given class conforms to `RGDataSource`.  Necessary due to some bug (the 2nd clause).
 */
BOOL rg_isDataSourceClass(Class RG_SUFFIX_NULLABLE cls) __attribute__((pure, always_inline, warn_unused_result));

/**
 @param encoding a string representing an Objective-C type encoding.
 @param length the length of the input string, C strings pass `strlen(encoding)`.
 @return `YES` if the given string matches any of the encodings of a primitive integral type.
 */
BOOL rg_is_integral_encoding(const char* RG_SUFFIX_NONNULL const encoding, unsigned long length)
    __attribute__((pure, always_inline, warn_unused_result));

/**
 @param encoding a string representing an Objective-C type encoding.
 @param length the length of the input string, C strings pass `strlen(encoding)`.
 @return `YES` if the given string matches any of the encodings of a primitive floating point type.
 */
BOOL rg_is_floating_encoding(const char* RG_SUFFIX_NONNULL const encoding, unsigned long length)
    __attribute__((pure, always_inline, warn_unused_result));

/**
 @param array the array object to unpack.
 @param context the new context for use with any unpacked object(s).
 @return A new array with each sub object which was unpackable unpacked.
 */
NSMutableArray* RG_SUFFIX_NONNULL rg_unpack_array(NSArray* RG_SUFFIX_NULLABLE array,
                                                  NSManagedObjectContext* RG_SUFFIX_NULLABLE context);

/**
 @param object the object to represent as a string if possible.
 @return An `NSString` representation of `object` or `nil` if no such representation could be formed.
 */
NSString* RG_SUFFIX_NULLABLE rg_to_string(id RG_SUFFIX_NULLABLE object);

/**
 @brief returns the currently set system severity.  When `DEBUG` is defined, defaults to `kRGLogSeverityDebug` otherwise
 defaults to `kRGLogSeverityNone`.
 */
RGLogSeverity rg_logging_severity(void);

/**
 @brief provide the system logging level for subsequent log messages.
 */
void rg_set_logging_severity(RGLogSeverity severity);

/**
 @brief A complete `NSLog()` replacement.  It logs the file name & line number.
 @param severity the severity level of this log message
 @param format the format string of the arguments _after_ lineNumber.  It is a programmer error to pass `nil`.
 @param file the name of the file where the log was called.  Cannot be `NULL`.
 @param line the line number of the log call.
 @param ... values that will be called with `format` to generate the output.
 */
void rg_log_severity(RGLogSeverity severity,
                     NSString* RG_SUFFIX_NONNULL format,
                     const char* RG_SUFFIX_NONNULL const file,
                     unsigned long line,
                     ...);

#ifndef RGLog /* provide this to match the old behavior */
    #ifdef DEBUG
        #define RGLog(format, ...) RGLogs(kRGLogSeverityNone, format, ## __VA_ARGS__)
    #else
        #define RGLog(...) RG_VOID_NOOP
    #endif
#endif

#ifndef RGLogs /* new macro which takes a severity argument */
    #define RGLogs(severity, format, ...) rg_log_severity(severity, format, __FILE__, __LINE__, ## __VA_ARGS__)
#endif

