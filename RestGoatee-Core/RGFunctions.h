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

/**
 @return the built-in date formats the library supports. Contains: ISO, `-[NSDate description]`.
 */
NSArray RG_GENERIC(NSString*) * RG_SUFFIX_NONNULL rg_dateFormats(void) __attribute__((pure, returns_nonnull));

/**
 @return a per thread instance of `NSDateFormatter`.  Never pass the returned object between threads.
   Always set the objects properties (`dateFormat`, `locale`, `timezone`, etc.) before use.
 */
NSDateFormatter* RG_SUFFIX_NONNULL rg_threadsafe_formatter(void) __attribute__((hot, returns_nonnull));

/**
 @param utf8Input a `\0` terminated C string.  With unicodes must be UTF-8 encoded.  May not be `NULL`.
 @return the property name in its canonical form.
 */
NSString* RG_SUFFIX_NONNULL const rg_canonical_form(const char* RG_SUFFIX_NONNULL const utf8Input)
    __attribute__((pure, nonnull, returns_nonnull));

/**
 @brief This function implements method swizzling.  Replaces the implementation identified by the selector `original`
   with the implementation identified by selector `replacement`.  Does not clobber the superclass's implementation of
   `original` if `cls` does not implement `original`.
 @param cls the class onto which the replacement method selector should be grafted.  Technically allows `Nil`.
 @param original the current selector whose associated implementation is the target of being changed.  Allows `NULL`
   which places no implementation on the selector identified by `replacement`.
 @param replacement the replacement selector which will provide the new implementation for the original method.
   Allows `NULL` which places no implementation on the selector identified by `original`.
 */
void rg_swizzle(Class RG_SUFFIX_NULLABLE cls,
                SEL RG_SUFFIX_NULLABLE original,
                SEL RG_SUFFIX_NULLABLE replacement) __attribute__((cold));

/**
 @brief This function is the backing debug function of the `RGLog()` macro.  It logs the file name & line number.
 @param format the format string of the arguments _after_ lineNumber.  It is a programmer error to pass `nil`.
 @param file the name of the file where the log was called.
 @param line the line number of the log call.
 @param ... values that will be called with `format` to generate the output.
 */
void rg_log(NSString* RG_SUFFIX_NONNULL format,
            const char* RG_SUFFIX_NONNULL const file,
            unsigned long line,
            ...) __attribute__((cold, format(__NSString__, 1, 4), nonnull(1, 2)));

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
