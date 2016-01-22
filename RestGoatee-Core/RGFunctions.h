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
 Returns the built-in date formats the library supports. Contains: ISO, `-[NSDate description]`.
 */
NSArray RG_GENERIC(NSString*) * RG_SUFFIX_NULLABLE rg_dateFormats(void) __attribute__((pure));

/**
 `rg_threadsafe_formatter` returns a per thread instance of `NSDateFormatter`.  Never pass the returned object between threads.  Always set the objects properties (`dateFormat`, `locale`, `timezone`, etc.) before use.
 */
NSDateFormatter* RG_SUFFIX_NONNULL rg_threadsafe_formatter(void);

/**
 Returns the property name in as its canonical key.
 */
NSString* RG_SUFFIX_NONNULL const rg_canonical_form(const char* RG_SUFFIX_NONNULL const utf8Input) __attribute__((pure));

/**
 `rg_swizzle` is a basic implementation of swizzling.  It does not clobber the super class if the method is not on the subclass.
 */
void rg_swizzle(Class RG_SUFFIX_NULLABLE cls, SEL RG_SUFFIX_NULLABLE original, SEL RG_SUFFIX_NULLABLE replacement) __attribute__((cold));

/**
 The `rg_log` function is the backing debug function of `RGLog`.  It logs the file name & line number of the call site.
 */
void rg_log(NSString* RG_SUFFIX_NULLABLE format, ...) __attribute__((cold));

/**
 Returns `YES` if the parameter `object` is of type `Class` but _not_ a meta-class.
 */
BOOL __attribute__((pure, always_inline, warn_unused_result)) rg_isClassObject(id RG_SUFFIX_NULLABLE object);

/**
 Returns `YES` if object has the same type as `NSObject`'s meta class.
 */
BOOL __attribute__((pure, always_inline, warn_unused_result)) rg_isMetaClassObject(id RG_SUFFIX_NULLABLE object);

/**
 Returns `YES` if the given type can be adequately represented by an `NSString`.
 */
BOOL __attribute__((pure, always_inline, warn_unused_result)) rg_isInlineObject(Class RG_SUFFIX_NULLABLE cls);

/**
 Returns `YES` if the given type can be adequately represented by an `NSArray`.
 */
BOOL __attribute__((pure, always_inline, warn_unused_result)) rg_isCollectionObject(Class RG_SUFFIX_NULLABLE cls);

/**
 Returns `YES` if the given type is a "key => value" type.  Thus it can be represented by an `NSDictionary`.
 */
BOOL __attribute__((pure, always_inline, warn_unused_result)) rg_isKeyedCollectionObject(Class RG_SUFFIX_NULLABLE cls);

/**
 Returns `YES` if the given class conforms to `RGDataSource`.  Necessary due to some bug (the 2nd clause).
 */
BOOL __attribute__((pure, always_inline, warn_unused_result)) rg_isDataSourceClass(Class RG_SUFFIX_NULLABLE cls);
