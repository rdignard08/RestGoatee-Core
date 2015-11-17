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

FILE_START

/**
 rg_swizzle is a basic implementation of swizzling.  It does not clobber the super class if the method is not on the subclass.
 */
void rg_swizzle(Class SUFFIX_NULLABLE cls, SEL SUFFIX_NULLABLE original, SEL SUFFIX_NULLABLE replacement) __attribute__((cold));

/**
 The `rg_log` function is the backing debug function of `RGLog`.  It logs the file name & line number of the call site.
 */
void rg_log(NSString* SUFFIX_NULLABLE format, ...) __attribute__((cold));
#ifndef RGLog
    #ifdef DEBUG
        #define RGLog(format, ...)                                      \
            rg_log(format, ({                                           \
                char* ret = __FILE__;                                   \
                for (char* string = __FILE__; string[0]; string++) {    \
                    if (string[0] == '/') {                             \
                        ret = string + 1;                               \
                    }                                                   \
                }                                                       \
                ret;                                                    \
            }), (long)__LINE__, ##__VA_ARGS__)
    #else
        /* we define out with `VOID_NOOP` generally this is `NULL` to allow constructs like `condition ?: RGLog(@"Blah")`. */
        #define RGLog(...) VOID_NOOP
    #endif
#endif

FILE_END
