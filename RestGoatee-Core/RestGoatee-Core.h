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
#import "RGDataSourceProtocol.h"
#import "RGDeserializationDelegate.h"
#import "RGXMLNode.h"
#import "RGXMLSerializer.h"
#import "RGXMLNode+RGDataSourceProtocol.h"
#import "NSObject+RG_KeyedSubscripting.h"
#import "NSObject+RG_Deserialization.h"
#import "NSObject+RG_Serialization.h"

FILE_START

/**
 rg_swizzle is a basic implementation of swizzling.  It does not clobber the super class if the method is not on the subclass.
 */
void rg_swizzle(Class suffix_nullable cls, SEL suffix_nullable original, SEL suffix_nullable replacement) __attribute__((cold));

/**
 The `RGLog` function is a debug only function (inactive in a live app).  It logs the file name & line number of the call site.
 */
void _RGLog(NSString* suffix_nullable format, ...) __attribute__((cold));
#ifdef DEBUG
    #define __SOURCE_FILE__ ({char* c = strrchr(__FILE__, '/'); c ? c + 1 : __FILE__;})
    #define RGLog(format, ...) _RGLog(format, __SOURCE_FILE__, (long)__LINE__, ##__VA_ARGS__)
#else
    /* we define out with `VOID_NOOP` generally this is `NULL` to allow constructs like `condition ?: RGLog(@"Blah")`. */
    #define RGLog(...) VOID_NOOP
#endif

FILE_END
