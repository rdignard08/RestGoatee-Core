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

#import "RGXMLNode+RGDataSourceProtocol.h"
#import "NSObject+RG_KeyedSubscripting.h"
#import <objc/runtime.h>

FILE_START

@implementation RGXMLNode (_RGDataSourceProtocol)

- (prefix_nonnull NSArray*) keys {
    id ret = objc_getAssociatedObject(self, @selector(keys));
    if (!ret) {
        ret = [NSMutableArray new];
        [ret addObjectsFromArray:self.attributes.allKeys];
        for (RGXMLNode* child in self.childNodes) {
            [ret addObject:child.name];
        }
        objc_setAssociatedObject(self, @selector(keys), ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ret;
}

- (void) setKeys:(prefix_nullable NSArray*)keys {
    objc_setAssociatedObject(self, @selector(keys), keys, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation RGXMLNode (RGDataSourceProtocol)

- (prefix_nonnull NSArray*) allKeys {
    return self.keys;
}

- (NSUInteger) countByEnumeratingWithState:(prefix_nonnull NSFastEnumerationState*)state objects:(__unsafe_unretained id[])buffer count:(NSUInteger)len {
    NSUInteger ret = [self.keys countByEnumeratingWithState:state objects:buffer count:len];
    if (!ret) {
        self.keys = nil;
    }
    return ret;
}

- (prefix_nullable id) valueForKeyPath:(prefix_nonnull NSString*)string {
    NSRange range = [string rangeOfString:@"."];
    if (range.location == NSNotFound) {
        return [self valueForKey:string];
    }
    return [[self childrenNamed:[string substringToIndex:range.location]] valueForKeyPath:[string substringFromIndex:range.location + 1]];
}

#pragma mark - private
- (prefix_nullable id) valueForKey:(prefix_nonnull NSString*)key {
    return self.attributes[key] ?: [self childrenNamed:key] ?: self.innerXML;
}

@end

FILE_END
