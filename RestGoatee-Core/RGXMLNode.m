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

#import "RGXMLNode.h"

NSString* SUFFIX_NONNULL const kRGInnerXMLKey = @"__innerXML__";

RG_FILE_START

@interface RGXMLNode ()

@property NULL_RESETTABLE_PROPERTY(nonatomic, strong) NSMutableArray GENERIC(NSString*) * keys;

@end

@implementation RGXMLNode
@synthesize parentNode = _parentNode;
@synthesize attributes = _attributes;
@synthesize childNodes = _childNodes;

#pragma mark - Properties
- (PREFIX_NONNULL NSMutableArray GENERIC(NSString*) *) keys {
    if (!_keys) {
        _keys = [self.attributes.allKeys mutableCopy];
        for (RGXMLNode* child in self.childNodes) {
            [_keys addObject:child.name];
        }
    }
    return _keys;
}

- (PREFIX_NONNULL NSArray GENERIC(RGXMLNode*) *) childNodes {
    if (!_childNodes) {
        _childNodes = [NSMutableArray new];
    }
    return _childNodes;
}

- (PREFIX_NONNULL NSMutableDictionary GENERIC(NSString*, NSString*) *) attributes {
    if (!_attributes) {
        _attributes = [NSMutableDictionary new];
    }
    return _attributes;
}

#pragma mark - Public Methods
- (void) addChildNode:(PREFIX_NONNULL RGXMLNode*)node {
    node->_parentNode = self;
    [(NSMutableArray*)self.childNodes addObject:node];
}

- (PREFIX_NONNULL NSMutableDictionary GENERIC(NSString*, id) *) dictionaryRepresentation {
    NSMutableDictionary GENERIC(NSString*, id) * ret = [self.attributes mutableCopy];
    if (self.innerXML) {
        ret[kRGInnerXMLKey] = self.innerXML;
    }
    NSMutableArray GENERIC(NSString*) * handledNames = [NSMutableArray new];
    for (RGXMLNode* childNode in self.childNodes) {
        NSAssert(childNode.name, @"%@ name: %@ has a child without a name", self, self.name);
        if (![handledNames containsObject:childNode.name]) {
            [handledNames addObject:childNode.name];
            id children = [self childrenNamed:childNode.name];
            if ([children isKindOfClass:[NSArray class]]) {
                NSMutableArray GENERIC(NSDictionary GENERIC(NSString*, id) *) * replacementContainer = [NSMutableArray new];
                for (RGXMLNode* node in children) {
                    [replacementContainer addObject:[node dictionaryRepresentation]];
                }
                ret[childNode.name] = replacementContainer;
            } else if ([children isKindOfClass:[RGXMLNode class]]) {
                NSMutableDictionary GENERIC(NSString*, NSString*) * value = [(RGXMLNode*)children attributes];
                [value addEntriesFromDictionary:[(RGXMLNode*)children dictionaryRepresentation]];
                ret[childNode.name] = value;
            } else {
                ret[childNode.name] = [NSNull null];
            }
        }
    }
    return ret;
}

- (PREFIX_NULLABLE id) childrenNamed:(PREFIX_NULLABLE NSString*)name {
    NSMutableArray GENERIC(RGXMLNode*) * ret = [NSMutableArray new];
    for (RGXMLNode* child in self.childNodes) {
        if ([child.name isEqual:name]) {
            [ret addObject:child];
        }
    }
    return ret.count > 1 ? ret : ret.lastObject;
}

#pragma mark - RGDataSource
- (PREFIX_NONNULL NSArray GENERIC(NSString*) *) allKeys {
    return self.keys;
}

- (NSUInteger) countByEnumeratingWithState:(PREFIX_NONNULL NSFastEnumerationState*)state objects:(__unsafe_unretained id[])buffer count:(NSUInteger)len {
    NSUInteger ret = [self.keys countByEnumeratingWithState:state objects:buffer count:len];
    if (!ret) {
        self.keys = nil;
    }
    return ret;
}

- (PREFIX_NULLABLE id) valueForKeyPath:(PREFIX_NONNULL NSString*)string {
    NSRange range = [string rangeOfString:@"."];
    if (range.location == NSNotFound) {
        return [self valueForKey:string];
    }
    return [[self childrenNamed:[string substringToIndex:range.location]] valueForKeyPath:[string substringFromIndex:range.location + 1]];
}

- (PREFIX_NULLABLE id) valueForKey:(PREFIX_NONNULL NSString*)key {
    return self.attributes[key] ?: [self childrenNamed:key] ?: self.innerXML;
}

@end

RG_FILE_END
