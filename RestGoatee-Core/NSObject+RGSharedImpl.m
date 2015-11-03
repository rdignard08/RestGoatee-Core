/* Copyright (c) 2/5/15, Ryan Dignard
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

FILE_START

NSString* SUFFIX_NONNULL const kRGSerializationKey = @"__class";

/* storage for extern'd class references */
Class SUFFIX_NONNULL rg_NSObjectClass;
Class SUFFIX_NONNULL rg_NSObjectMetaClass;
Class SUFFIX_NULLABLE rg_NSManagedObjectContext;
Class SUFFIX_NULLABLE rg_NSManagedObject;
Class SUFFIX_NULLABLE rg_NSManagedObjectModel;
Class SUFFIX_NULLABLE rg_NSEntityDescription;
Class SUFFIX_NULLABLE rg_NSFetchRequest;

NSArray GENERIC(NSString*) * SUFFIX_NONNULL __attribute__((pure)) rg_dateFormats(void) {
    static dispatch_once_t onceToken;
    static NSArray GENERIC(NSString*) * _sDateFormats;
    dispatch_once(&onceToken, ^{
        _sDateFormats = @[ @"yyyy-MM-dd'T'HH:mm:ssZZZZZ", @"yyyy-MM-dd HH:mm:ss ZZZZZ", @"yyyy-MM-dd'T'HH:mm:ssz", @"yyyy-MM-dd" ];
    });
    return _sDateFormats;
}

@implementation NSObject (RGSharedImpl)

+ (void) load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rg_NSObjectClass = objc_getClass("NSObject");
        rg_NSObjectMetaClass = objc_getMetaClass("NSObject");
        rg_NSManagedObjectContext = objc_getClass("NSManagedObjectContext");
        rg_NSManagedObject = objc_getClass("NSManagedObject");
        rg_NSManagedObjectModel = objc_getClass("NSManagedObjectModel");
        rg_NSEntityDescription = objc_getClass("NSEntityDescription");
        rg_NSFetchRequest = objc_getClass("NSFetchRequest");
    });
}

+ (PREFIX_NONNULL NSMutableDictionary GENERIC(NSString*, RGVariableDeclaration*) *) rg_propertyList {
    NSMutableDictionary* rg_propertyList = objc_getAssociatedObject(self, @selector(rg_propertyList));
    if (!rg_propertyList) {
        rg_propertyList = [NSMutableDictionary new];
        NSMutableDictionary* rg_canonicalPropertyList = [NSMutableDictionary new];
        [rg_propertyList addEntriesFromDictionary:[[self superclass] rg_propertyList]];
        [rg_canonicalPropertyList addEntriesFromDictionary:[[self superclass] rg_canonicalPropertyList]];
        objc_property_t* properties = class_copyPropertyList(self, NULL);
        for (uint32_t i = 0; properties + i && properties[i]; i++) {
            RGPropertyDeclaration* declaration = [[RGPropertyDeclaration alloc] initWithProperty:properties[i]];
            rg_propertyList[declaration.name] = declaration;
            rg_canonicalPropertyList[declaration.canonicalName] = declaration;
        }
        objc_setAssociatedObject(self, @selector(rg_propertyList), rg_propertyList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, @selector(rg_canonicalPropertyList), rg_canonicalPropertyList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return rg_propertyList;
}

+ (PREFIX_NONNULL NSMutableDictionary GENERIC(NSString*, RGVariableDeclaration*) *) rg_canonicalPropertyList {
    NSAssert(objc_getAssociatedObject(self, @selector(rg_propertyList)), @"rg_canonicalPropertyList was invoked before rg_propertyList, there's a logic error somewhere");
    return objc_getAssociatedObject(self, @selector(rg_canonicalPropertyList));
}

@end

FILE_END
