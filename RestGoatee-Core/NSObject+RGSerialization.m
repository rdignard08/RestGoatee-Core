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

#import "RestGoatee-Core.h"
#import "NSObject+RGSharedImpl.h"

@implementation NSObject (RGSerialization)

- (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(NSString*, id) *) dictionaryRepresentation {
    NSMutableDictionary* ret = [self rg_dictionaryHelper];
    NSAssert([ret isKindOfClass:[NSDictionary self]], @"Called `dictionaryRepresentation` on an object whose correct"
             @"representation is not a dictionary");
    return ret;
}

- (RG_PREFIX_NONNULL id) rg_dictionaryHelper {
    /* enabled when debugging so you can find your logic errors while building, on stack overflow gdb will fail */
    NSAssert([NSThread callStackSymbols].count < kRGMaxAutoSize, @"Too deep, probably have a cycle");
    if ([[self class] isSubclassOfClass:[NSNull self]] || [[self class] isSubclassOfClass:[NSString self]]) {
        return self;
    } else if (rg_isInlineObject([self class]) || rg_isClassObject(self)) { /* classes can be stored as strings too */
        return self.description;
    } else if (rg_isCollectionObject([self class])) {
        return [self rg_serializeArrayLike];
    } else if (rg_isKeyedCollectionObject([self class])) { /* a dictionary / RGXMLNode */
        return [self rg_serializeDictionaryLike];
    }
    return [self rg_serializeObject]; /* any old schleb object */
}

- (RG_PREFIX_NONNULL NSArray*) rg_serializeArrayLike {
    NSMutableArray* ret = [NSMutableArray new];
    NSEnumerator* enumerator = [self performSelector:@selector(objectEnumerator)];
    for (NSObject* object = enumerator.nextObject; object; object = enumerator.nextObject) {
        [ret addObject:[object rg_dictionaryHelper]];
    }
    return ret;
}

- (RG_PREFIX_NONNULL NSDictionary*) rg_serializeDictionaryLike {
    NSMutableDictionary RG_GENERIC(NSString*, id) * ret = [NSMutableDictionary new];
    NSArray* allKeys = [self performSelector:@selector(allKeys)];
    for (NSUInteger i = 0; i < allKeys.count; i++) {
        NSString* key = allKeys[i];
        NSObject* targetObject = [self valueForKey:key];
        ret[key] = [targetObject rg_dictionaryHelper];
    }
    return ret;
}

- (RG_PREFIX_NONNULL NSDictionary*) rg_serializeObject {
    NSMutableDictionary RG_GENERIC(NSString*, id) * ret = [NSMutableDictionary new];
    NSArray RG_GENERIC(NSString*) * keys;
    if ([[self class] respondsToSelector:@selector(serializableKeys)]) {
        keys = [[self class] serializableKeys];
    } else {
        keys = [[self class] rg_propertyList].allKeys;
    }
    for (NSUInteger i = 0; i < keys.count; i++) {
        NSString* propertyName = keys[i];
        SEL target = NSSelectorFromString(propertyName);
        if (![NSObject instancesRespondToSelector:target] && ![kRGNSManagedObject instancesRespondToSelector:target]) {
            NSObject* targetObject = [self valueForKey:propertyName] ?: [NSNull null];
            ret[propertyName] = [targetObject rg_dictionaryHelper];
        }
    }
    ret[kRGSerializationKey] = NSStringFromClass([self class]);
    return ret;
}

@end
