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

@implementation RGPropertyDeclaration

- (RG_PREFIX_NULLABLE instancetype) init {
    [NSException raise:NSGenericException format:@"-init is not a valid initializer of %@", [self class]];
    return [super init];
}

- (RG_PREFIX_NONNULL instancetype) initWithProperty:(RG_PREFIX_NONNULL objc_property_t)property {
    self = [super init];
    if (self) {
        [self initializeName:property];
        const char* RG_SUFFIX_NONNULL const attributeString = property_getAttributes(property);
        unsigned long quoteIndex = 0;
        unsigned long typeIndex = 0;
        BOOL parsingType = NO;
        char byte = *attributeString;
        for (unsigned long i = 0; byte; byte = attributeString[++i]) {
            if (!parsingType) {
                switch (byte) {
                case '&':
                    self->_storageSemantics = kRGPropertyStrong;
                    break;
                case 'C':
                    self->_storageSemantics = kRGPropertyCopy;
                    break;
                case 'W':
                    self->_storageSemantics = kRGPropertyWeak;
                    break;
                case 'T':
                    parsingType = YES;
                    typeIndex = i + 1;
                    break;
                case 'R':
                    self->_isReadOnly = YES;
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
            }
        }
    }
    return self;
}

- (void) initializeName:(RG_PREFIX_NULLABLE objc_property_t)property {
    const char* utfName = property_getName(property);
    self->_name = @(utfName);
    self->_canonicalName = rg_canonical_form(utfName);
}

- (void) initializeType:(const char*)value andLength:(unsigned long)length {
    BOOL isClass = strncmp(@encode(Class), value, length) == 0;
    if (isClass || strncmp(@encode(id), value, length) == 0) {
        self->_type = isClass ? kRGNSObjectMetaClass : kRGNSObjectClass;
        self->_isPrimitive = NO;
        return;
    }
    char* buffer = calloc(length, 1);
    memcpy(buffer, value, length);
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
}

@end
