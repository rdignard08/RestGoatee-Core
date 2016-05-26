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
        unsigned int attributeCount = 0;
        
//NSArray*attributes=[[NSString stringWithUTF8String:property_getAttributes(property)]componentsSeparatedByString:@","];
        
        objc_property_attribute_t* attributes = property_copyAttributeList(property, &attributeCount);
        for (unsigned int i = 0; i < attributeCount; i++) {
            objc_property_attribute_t attribute = attributes[i];
            /* The first character is the type encoding; the other field is a value of some kind (if anything)
               library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html */
            switch (attribute.name[0]) {
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
                    [self initializeType:attribute.value];
                    break;
                case 'R':
                    self->_isReadOnly = YES;
                    break;
                default:
                    break;
            }
        }
        free(attributes);
    }
    return self;
}

- (void) initializeName:(RG_PREFIX_NULLABLE objc_property_t)property {
    const char* utfName = property_getName(property);
    self->_name = @(utfName);
    self->_canonicalName = rg_canonical_form(utfName);
}

- (void) initializeType:(const char*)value {
    BOOL isClass = strcmp(@encode(Class), value) == 0;
    if (isClass || strcmp(@encode(id), value) == 0) {
        self->_type = isClass ? kRGNSObjectMetaClass : kRGNSObjectClass;
        self->_isPrimitive = NO;
        return;
    }
    const size_t typeLength = strlen(value);
    size_t outputLength = 0;
    char* buffer = malloc(typeLength);
    BOOL foundFirst = NO;
    for (size_t j = 0; j != typeLength; j++) {
        char letter = value[j];
        if (foundFirst) {
            if (letter == '"') {
                break;
            } else {
                buffer[outputLength++] = letter;
            }
        } else if (letter == '"') {
            foundFirst = YES;
        }
    } /* there should be 2 '"' on each end, the class is in the middle */
    buffer[outputLength] = '\0';
    Class propertyType = objc_getClass(buffer);
    free(buffer);
    self->_type = propertyType ?: [NSNumber self];
    self->_isPrimitive = !propertyType;
    if (self->_isPrimitive) {
        self->_isIntegral = rg_is_integral_encoding(value);
        if (!self->_isIntegral) {
            self->_isFloatingPoint = rg_is_floating_encoding(value);
        }
    }
}

@end
