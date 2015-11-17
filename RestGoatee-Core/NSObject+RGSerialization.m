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

#import "RestGoatee-Core.h"
#import "NSObject+RGSharedImpl.h"

RG_FILE_START

@implementation NSObject (RGSerialization)

- (PREFIX_NONNULL NSMutableDictionary GENERIC(NSString*, id) *) dictionaryRepresentation {
#ifdef DEBUG /* enabled when debugging so you can find your logic errors while building */
    if ([NSThread callStackSymbols].count > 1000) {
        [NSException raise:NSGenericException format:@"Too deep, probably have a cycle"];
    }
#endif
    id ret;
    if ([[self class] isSubclassOfClass:[NSNull class]]) {
        ret = self;
    } else if (rg_isInlineObject([self class]) || rg_isClassObject(self)) { /* classes can be stored as strings too */
        ret = [self description];
    } else if (rg_isCollectionObject([self class])) {
        ret = [NSMutableArray new];
        for (id object in (id<NSFastEnumeration>)self) {
            [ret addObject:[(NSObject*)object dictionaryRepresentation]];
        }
    } else if (rg_isKeyedCollectionObject([self class])) {
        ret = [NSMutableDictionary new];
        for (id key in (id<NSFastEnumeration>)self) {
            ret[key] = [(NSObject*)[self valueForKey:key] dictionaryRepresentation];
        }
        ret[kRGSerializationKey] = NSStringFromClass([self class]);
    } else {
        ret = [NSMutableDictionary new];
        NSArray* keys = [[self class] respondsToSelector:@selector(serializableKeys)] ? [[self class] serializableKeys] : [[self class] rg_propertyList].allKeys;
        for (NSString* propertyName in keys) {
            if ([rg_NSManagedObject instancesRespondToSelector:NSSelectorFromString(propertyName)] || [NSObject instancesRespondToSelector:NSSelectorFromString(propertyName)]) continue;
            ret[propertyName] = [(NSObject*)([self valueForKey:propertyName] ?: [NSNull null]) dictionaryRepresentation];
        }
        ret[kRGSerializationKey] = NSStringFromClass([self class]);
    }
    return ret;
}

@end

RG_FILE_END
