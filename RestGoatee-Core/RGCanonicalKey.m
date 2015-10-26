/* Copyright (c) 6/25/14, Ryan Dignard
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

#import "RGCanonicalKey.h"
#import "NSString+RGCanonicalValue.h"

FILE_START

@interface RGCanonicalKey ()

@property NULLABLE_PROPERTY(nonatomic, strong) NSString* rg_baseKey;
@property NULLABLE_PROPERTY(nonatomic, strong) NSString* rg_canonicalKey;

@end

@implementation RGCanonicalKey

- (PREFIX_NONNULL instancetype) initWithKey:(PREFIX_NULLABLE NSString*)baseKey withCanonicalName:(PREFIX_NULLABLE NSString*)canonicalKey {
    self = [super init];
    if (self) {
        _rg_baseKey = baseKey;
        _rg_canonicalKey = canonicalKey;
    }
    return self;
}

#pragma mark - NSObject
- (BOOL) isEqual:(id)object {
    if ([object isKindOfClass:[RGCanonicalKey class]]) {
        return [self.rg_baseKey isEqual:[(RGCanonicalKey*)object rg_baseKey]];
    } else if ([object isKindOfClass:[NSString class]]) {
        return [self.rg_baseKey isEqual:object] || [self.rg_canonicalKey isEqual:[object rg_canonicalValue]];
    }
    return NO;
}

- (NSUInteger) hash {
    return self.rg_baseKey.hash;
}

#pragma mark - NSCopying
- (PREFIX_NONNULL instancetype) copyWithZone:(PREFIX_NULLABLE __unused NSZone*)zone {
    return [[RGCanonicalKey alloc] initWithKey:self.rg_baseKey withCanonicalName:self.rg_canonicalKey];
}

@end

FILE_END
