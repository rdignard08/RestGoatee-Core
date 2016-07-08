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

#import "RGPropertyDeclaration.h"
#import "RestGoatee-Core.h"
#include <objc/runtime.h>

static NSString* RG_SUFFIX_NONNULL rg_name_as_setter(NSString* RG_SUFFIX_NONNULL const name) {
    assert(name.length);
    unichar firstCharacter = [name characterAtIndex:0];
    firstCharacter = (unichar)toupper(firstCharacter);
    return [NSString stringWithFormat:@"set%c%@:", firstCharacter, [name substringFromIndex:1]];
}

@implementation RGPropertyDeclaration

- (RG_PREFIX_NULLABLE instancetype) init {
    [NSException raise:NSGenericException format:@"-init is not a valid initializer of %@", [self class]];
    return [super init];
}

- (RG_PREFIX_NONNULL instancetype) initWithProperty:(RG_PREFIX_NONNULL objc_property_t)property {
    self = [super init];
    if (self) {
        const char* utfName = property_getName(property);
        self->_name = @(utfName);
        self->_canonicalName = rg_canonical_form(utfName);
        self->_isAtomic = YES;
        self->_getter = NSSelectorFromString(self.name);
        self->_setter = NSSelectorFromString(rg_name_as_setter(self.name));
        [self parseAttributes:property_getAttributes(property)];
    }
    return self;
}

- (void) parseAttributes:(const char * RG_SUFFIX_NONNULL const)attributeString {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
    unsigned long quoteIndex = 0;
    unsigned long typeIndex = 0;
    unsigned long ivarIndex = 0;
    unsigned long getterIndex = 0;
    unsigned long setterIndex = 0;
    BOOL parsingType = NO;
    BOOL parsingIvar = NO;
    BOOL parsingGetter = NO;
    BOOL parsingSetter = NO;
    BOOL parsingUnknown = NO;
    char byte = *attributeString;
    unsigned long i = 0;
    for (; byte; byte = attributeString[++i]) {
        if (parsingUnknown) {
            if (byte == ',') {
                parsingUnknown = NO;
            }
        } else if (parsingType) {
            if (byte == '"' && quoteIndex) {
                [self initializeType:attributeString + quoteIndex andLength:i - quoteIndex];
                parsingType = NO;
            } else if (byte == '"') {
                quoteIndex = i + 1;
            } else if (byte == ',') {
                [self initializeType:attributeString + typeIndex andLength:i - typeIndex];
                parsingType = NO;
            }
        } else if (parsingIvar) {
            if (byte == ',') {
                self->_backingIvar = [[NSString alloc] initWithBytes:attributeString + ivarIndex
                                                              length:i - ivarIndex
                                                            encoding:NSUTF8StringEncoding];
                parsingIvar = NO;
            }
        } else if (parsingGetter) {
            if (byte == ',') {
                NSString* getter = [[NSString alloc] initWithBytes:attributeString + getterIndex
                                                            length:i - getterIndex
                                                          encoding:NSUTF8StringEncoding];
                self->_getter = NSSelectorFromString(getter);
                parsingGetter = NO;
            }
        } else if (parsingSetter) {
            if (byte == ',') {
                NSString* setter = [[NSString alloc] initWithBytes:attributeString + setterIndex
                                                            length:i - setterIndex
                                                          encoding:NSUTF8StringEncoding];
                self->_setter = NSSelectorFromString(setter);
                parsingSetter = NO;
            }
        } else if (byte == '&') {
            self->_storageSemantics = kRGPropertyStrong;
        } else if (byte == 'C') {
            self->_storageSemantics = kRGPropertyCopy;
        } else if (byte == 'W') {
            self->_storageSemantics = kRGPropertyWeak;
        } else if (byte == 'T') {
            parsingType = YES;
            typeIndex = i + 1;
        } else if (byte == 'R') {
            self->_isReadOnly = YES;
            self->_setter = NULL;
        } else if (byte == 'D') {
            self->_isDynamic = YES;
        } else if (byte == 'N') {
            self->_isAtomic = NO;
        } else if (byte == 'V') {
            parsingIvar = YES;
            ivarIndex = i + 1;
        } else if (byte == 'G') {
            parsingGetter = YES;
            getterIndex = i + 1;
        } else if (byte == 'S') {
            parsingSetter = YES;
            setterIndex = i + 1;
        } else if (byte == 'P') {
            self->_isGarbageCollectible = YES;
        } else if (byte != ',') {
            parsingUnknown = YES;
        }
    }
    if (parsingType) {
        [self initializeType:attributeString + typeIndex andLength:i - typeIndex];
    } else if (parsingIvar) {
        self->_backingIvar = [[NSString alloc] initWithBytes:attributeString + ivarIndex
                                                      length:i - ivarIndex
                                                    encoding:NSUTF8StringEncoding];
    } else if (parsingGetter) {
        NSString* getter = [[NSString alloc] initWithBytes:attributeString + getterIndex
                                                    length:i - getterIndex
                                                  encoding:NSUTF8StringEncoding];
        self->_getter = NSSelectorFromString(getter);
    } else if (parsingSetter) {
        NSString* setter = [[NSString alloc] initWithBytes:attributeString + setterIndex
                                                    length:i - setterIndex
                                                  encoding:NSUTF8StringEncoding];
        self->_setter = NSSelectorFromString(setter);
    }
#pragma clang diagnostic pop
}

- (void) initializeType:(const char*)value andLength:(unsigned long)length {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
    BOOL isClass = strncmp(@encode(Class), value, length) == 0;
    if (isClass || strncmp(@encode(id), value, length) == 0) {
        self->_type = isClass ? kRGNSObjectMetaClass : kRGNSObjectClass;
        self->_isPrimitive = NO;
        return;
    }
    char* buffer = malloc(length + 1);
    memcpy(buffer, value, length);
    buffer[length] = '\0';
    Class propertyType = objc_getClass(buffer);
    free(buffer);
    self->_type = propertyType ?: [NSNumber self];
    self->_isPrimitive = !propertyType;
    if (self->_isPrimitive) {
        self->_isIntegral = rg_is_integral_encoding(value, length);
        if (!self->_isIntegral) {
            self->_isFloatingPoint = rg_is_floating_encoding(value, length);
        }
    }
#pragma clang diagnostic pop
}

@end
