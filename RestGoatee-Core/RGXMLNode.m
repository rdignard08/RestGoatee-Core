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

@interface RGXMLNode ()

@property RG_NULL_RESETTABLE_PROPERTY(nonatomic, strong) NSMutableArray RG_GENERIC(NSString*) * keys;

@end

@implementation RGXMLNode
@synthesize attributes = _attributes;
@synthesize childNodes = _childNodes;

- (RG_PREFIX_NULLABLE instancetype) init {
    [NSException raise:NSGenericException format:@"-init is not a valid initializer of %@", [self class]];
    return [super init];
}

- (RG_PREFIX_NONNULL instancetype) initWithName:(RG_PREFIX_NONNULL NSString*)name {
    self = [super init];
    if (self) {
        self->_name = name;
    }
    return self;
}

#pragma mark - Properties
- (RG_PREFIX_NONNULL NSMutableArray RG_GENERIC(NSString*) *) keys {
    if (!_keys) {
        _keys = [self.attributes.allKeys mutableCopy];
        for (RGXMLNode* child in self.childNodes) {
            [_keys addObject:child.name];
        }
    }
    return _keys;
}

- (RG_PREFIX_NONNULL NSMutableArray RG_GENERIC(RGXMLNode*) *) childNodes {
    if (!_childNodes) {
        _childNodes = [NSMutableArray new];
    }
    return _childNodes;
}

- (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(NSString*, NSString*) *) attributes {
    if (!_attributes) {
        _attributes = [NSMutableDictionary new];
    }
    return _attributes;
}

#pragma mark - Public Methods
- (void) addChildNode:(RG_PREFIX_NONNULL RGXMLNode*)node {
    node->_parentNode = self;
    [self.childNodes addObject:node];
}

- (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(NSString*, id) *) dictionaryRepresentation {
    NSMutableDictionary RG_GENERIC(NSString*, id) * ret = [self.attributes mutableCopy];
    if (self.innerXML) {
        ret[kRGInnerXMLKey] = self.innerXML;
    }
    NSMutableArray RG_GENERIC(NSString*) * handledNames = [NSMutableArray new];
    for (RGXMLNode* childNode in self.childNodes) {
        NSAssert(childNode.name, @"%@ name: %@ has a child without a name", self, self.name);
        if (![handledNames containsObject:childNode.name]) {
            [handledNames addObject:childNode.name];
            id children = [self childrenNamed:childNode.name];
            if ([children isKindOfClass:[NSArray self]]) {
                NSMutableArray RG_GENERIC(NSDictionary RG_GENERIC(NSString*, id) *) * replacementContainer = [NSMutableArray new];
                for (RGXMLNode* node in children) {
                    [replacementContainer addObject:[node dictionaryRepresentation]];
                }
                ret[childNode.name] = replacementContainer;
            } else if ([children isKindOfClass:[RGXMLNode self]]) {
                RGXMLNode* xmlChild = children;
                NSMutableDictionary RG_GENERIC(NSString*, NSString*) * value = [xmlChild.attributes mutableCopy];
                [value addEntriesFromDictionary:[xmlChild dictionaryRepresentation]];
                ret[childNode.name] = value;
            }
        }
    }
    return ret;
}

- (RG_PREFIX_NULLABLE id) childrenNamed:(RG_PREFIX_NULLABLE NSString*)name {
    NSMutableArray RG_GENERIC(RGXMLNode*) * ret = [NSMutableArray new];
    for (RGXMLNode* child in self.childNodes) {
        if ([child.name isEqual:name]) {
            [ret addObject:child];
        }
    }
    return ret.count > 1 ? ret : ret.lastObject;
}

#pragma mark - RGDataSource
- (RG_PREFIX_NONNULL NSArray RG_GENERIC(NSString*) *) allKeys {
    return self.keys;
}

- (NSUInteger) countByEnumeratingWithState:(RG_PREFIX_NONNULL NSFastEnumerationState*)state objects:(__unsafe_unretained id[])buffer count:(NSUInteger)len {
    NSUInteger ret = [self.allKeys countByEnumeratingWithState:state objects:buffer count:len];
    if (!ret) {
        self.keys = nil;
    }
    return ret;
}

- (RG_PREFIX_NULLABLE id) valueForKeyPath:(RG_PREFIX_NONNULL NSString*)string {
    NSRange range = [string rangeOfString:@"."];
    if (range.location == NSNotFound) {
        return [self valueForKey:string];
    }
    return [[self childrenNamed:[string substringToIndex:range.location]] valueForKeyPath:[string substringFromIndex:range.location + 1]];
}

- (RG_PREFIX_NULLABLE id) valueForKey:(RG_PREFIX_NONNULL NSString*)key {
    return [key isEqual:kRGInnerXMLKey] ? self.innerXML : (self.attributes[key] ?: [self childrenNamed:key]);
}

@end
