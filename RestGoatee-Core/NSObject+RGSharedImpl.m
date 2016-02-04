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

#import "NSObject+RGSharedImpl.h"
#import "RestGoatee-Core.h"
#import "RGPropertyDeclaration.h"
#include <objc/runtime.h>

@implementation NSObject (RGSharedImpl)

+ (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(NSString*, RGPropertyDeclaration*) *) rg_propertyList {
    NSMutableDictionary* rg_propertyList = objc_getAssociatedObject(self, @selector(rg_propertyList));
    if (!rg_propertyList) {
        rg_propertyList = [NSMutableDictionary new];
        NSMutableDictionary* canonicalList = [NSMutableDictionary new];
        [rg_propertyList addEntriesFromDictionary:[[self superclass] rg_propertyList]];
        [canonicalList addEntriesFromDictionary:[[self superclass] rg_canonicalPropertyList]];
        unsigned int count;
        objc_property_t* properties = class_copyPropertyList(self, &count);
        for (unsigned int i = 0; i < count; i++) {
            RGPropertyDeclaration* declaration = [[RGPropertyDeclaration alloc] initWithProperty:properties[i]];
            rg_propertyList[declaration.name] = declaration;
            canonicalList[declaration.canonicalName] = declaration;
        }
        free(properties);
        objc_setAssociatedObject(self, @selector(rg_propertyList), rg_propertyList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self,
                                 @selector(rg_canonicalPropertyList),
                                 canonicalList,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return rg_propertyList;
}

+ (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(NSString*, RGPropertyDeclaration*) *) rg_canonicalPropertyList {
    NSAssert(objc_getAssociatedObject(self, @selector(rg_propertyList)), @"rg_canonicalPropertyList was invoked before"
             @"rg_propertyList, there's a logic error somewhere");
    return objc_getAssociatedObject(self, @selector(rg_canonicalPropertyList));
}

@end
