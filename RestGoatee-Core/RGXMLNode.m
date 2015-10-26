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

FILE_START

@implementation RGXMLNode
@synthesize parentNode = _parentNode;
@synthesize attributes = _attributes;
@synthesize childNodes = _childNodes;

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

- (void) addChildNode:(PREFIX_NONNULL RGXMLNode*)node {
    node->_parentNode = self;
    [(NSMutableArray*)self.childNodes addObject:node];
}

- (PREFIX_NONNULL NSMutableDictionary GENERIC(NSString*, id) *) dictionaryRepresentation {
    NSMutableDictionary* ret = [self.attributes mutableCopy];
    ret[kRGInnerXMLKey] = self.innerXML; /* if nil, uses NSObject+RG_KeyedSubscripting */
    NSMutableArray* handledNames = [NSMutableArray new];
    for (RGXMLNode* childNode in self.childNodes) {
        NSAssert(childNode.name, @"%@ name: %@ has a child without a name", self, self.name);
        if (![handledNames containsObject:childNode.name]) {
            [handledNames addObject:childNode.name];
            id children = [self childrenNamed:childNode.name];
            if ([children isKindOfClass:[NSArray class]]) {
                NSMutableArray* replacementContainer = [NSMutableArray new];
                for (RGXMLNode* node in children) {
                    [replacementContainer addObject:[node dictionaryRepresentation]];
                }
                ret[childNode.name] = replacementContainer;
            } else if ([children isKindOfClass:[RGXMLNode class]]) {
                NSMutableDictionary* value = [(RGXMLNode*)children attributes];
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
    NSMutableArray* ret = [NSMutableArray new];
    for (RGXMLNode* child in self.childNodes) {
        if ([child.name isEqual:name]) {
            [ret addObject:child];
        }
    }
    return ret.count > 1 ? ret : ret.lastObject;
}

@end

FILE_END
