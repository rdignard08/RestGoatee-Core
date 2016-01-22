/* Copyright (c) 02/05/2015, Ryan Dignard
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
#import "RGXMLNode.h"
#import "RGPropertyDeclaration.h"
#import "RGDataSource.h"
#import <objc/runtime.h>

/**
 This is a private category which contains all the of the methods used jointly by the categories `RGDeserialization` and `RGSerialization`.
 */
@interface NSObject (RGSharedImpl)

/**
 This is describes the meta data of the given class.  It declares the properties in an object-oriented manner.  The keys are the names of the properties keyed to their declaration.
 */
+ (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(NSString*, RGPropertyDeclaration*) *) rg_propertyList;

/**
 This describes the meta data of the class.  The keys are the canonical representation of the property name mapped to an `RGPropertyDeclaration` object.
 */
+ (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(NSString*, RGPropertyDeclaration*) *) rg_canonicalPropertyList;

@end
