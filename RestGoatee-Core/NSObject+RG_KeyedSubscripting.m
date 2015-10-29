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

FILE_START

#ifndef STRICT_KVC
    #define STRICT_KVC 0
#endif

@implementation NSObject (RG_KeyedSubscripting)

- (PREFIX_NULLABLE id) objectForKeyedSubscript:(PREFIX_NONNULL id<NSCopying, NSObject>)key {
#if !(STRICT_KVC)
    @try {
#endif
        return [self valueForKeyPath:key.description];
#if !(STRICT_KVC)
    } @catch (NSException* e) {
        RGLog(@"Unknown property %@ on type %@: %@", key.description, [self class], e);
        return nil;
    }
#endif
}

- (void) setObject:(PREFIX_NULLABLE id)obj forKeyedSubscript:(PREFIX_NONNULL id<NSCopying, NSObject>)key {
#if !(STRICT_KVC)
    @try {
#endif
        [self setValue:obj forKeyPath:key.description];
#if !(STRICT_KVC)
    } @catch (NSException* e) {
        RGLog(@"Unknown property %@ on type %@: %@", key.description, [self class], e);
    }
#endif
}

@end

@implementation NSMutableDictionary (RG_KeyedSubscripting)

/* fuck you apple */
- (void) setObject:(PREFIX_NULLABLE id)obj forKeyedSubscript:(PREFIX_NONNULL id<NSCopying, NSObject>)key {
    if (obj) {
        [self setObject:obj forKey:key];
    } else {
        [self removeObjectForKey:key];
    }
}

@end

FILE_END
