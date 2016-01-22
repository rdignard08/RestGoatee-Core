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

#import "RestGoatee-Core.h"
#import <objc/runtime.h>

const size_t kRGMaxAutoSize = 1 << 10;

NSString* RG_SUFFIX_NONNULL const kRGSerializationKey = @"__class";
NSString* RG_SUFFIX_NONNULL const kRGDateFormatterKey = @"kRGDateFormatterKey";
NSString* RG_SUFFIX_NONNULL const kRGXMLDocumentNodeKey = @"kRGDocument";
NSString* RG_SUFFIX_NONNULL const kRGInnerXMLKey = @"__innerXML__";

/* storage for extern'd class references */
Class RG_SUFFIX_NONNULL rg_NSObjectClass;
Class RG_SUFFIX_NONNULL rg_NSObjectMetaClass;
Class RG_SUFFIX_NULLABLE rg_NSManagedObject;
Class RG_SUFFIX_NULLABLE rg_NSEntityDescription;

@interface RGConstants : NSObject 

@end

@implementation RGConstants

+ (void) load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rg_NSObjectClass = objc_getClass("NSObject");
        rg_NSObjectMetaClass = objc_getMetaClass("NSObject");
        rg_NSManagedObject = objc_getClass("NSManagedObject");
        rg_NSEntityDescription = objc_getClass("NSEntityDescription");
    });
}

@end
