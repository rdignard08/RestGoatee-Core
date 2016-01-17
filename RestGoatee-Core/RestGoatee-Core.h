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

/* preprocessor */
#import "RGDefines.h"

/* protocols */
#import "RGDataSource.h"
#import "RGDeserializable.h"
#import "RGSerializable.h"

/* classes */
#import "RGXMLNode.h"
#import "RGXMLSerializer.h"

/* categories */
#import "NSDictionary+RGDataSource.h"
#import "NSObject+RGDeserialization.h"
#import "NSObject+RGSerialization.h"

RG_FILE_START

/**
 This is the key used interally to store the value returned by `rg_threadsafe_formatter()`.  You must not use this key with the dictionary at `-[NSThread threadDictionary]`.
 */
FOUNDATION_EXPORT NSString* RG_SUFFIX_NONNULL const kRGDateFormatterKey;

/**
 This is the largest memory allocation that will be made on the stack for a single identifer (VLA).
 */
FOUNDATION_EXPORT const size_t kRGMaxAutoSize;

/**
 `rg_swizzle` is a basic implementation of swizzling.  It does not clobber the super class if the method is not on the subclass.
 */
void rg_swizzle(Class RG_SUFFIX_NULLABLE cls, SEL RG_SUFFIX_NULLABLE original, SEL RG_SUFFIX_NULLABLE replacement) __attribute__((cold));

/**
 The `rg_log` function is the backing debug function of `RGLog`.  It logs the file name & line number of the call site.
 */
void rg_log(NSString* RG_SUFFIX_NULLABLE format, ...) __attribute__((cold));
#ifndef RGLog
    #ifdef DEBUG
        #define RGLog(format, ...)                          \
            rg_log(format, ({                               \
                const size_t length = sizeof(__FILE__) - 1; \
                char* ret = __FILE__ + length;              \
                while (ret != __FILE__) {                   \
                    char* replacement = ret - 1;            \
                    if (*replacement == '/') {              \
                        break;                              \
                    }                                       \
                    ret = replacement;                      \
                }                                           \
                ret;                                        \
            }), (unsigned long)__LINE__, ##__VA_ARGS__)
    #else
        /* we define out with `RG_VOID_NOOP` generally this is `NULL` to allow constructs like `condition ?: RGLog(@"Blah")`. */
        #define RGLog(...) RG_VOID_NOOP
    #endif
#endif

/**
 `rg_threadsafe_formatter` returns a per thread instance of `NSDateFormatter`.  Never pass the returned object between threads.  Always set the objects properties (`dateFormat`, `locale`, `timezone`, etc.) before use.
 */
NSDateFormatter* RG_SUFFIX_NONNULL rg_threadsafe_formatter(void);

RG_FILE_END
