/* Copyright (c) 09/01/2015, Ryan Dignard
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

#import "NSObject+RGStringValue.h"

@implementation NSObject (RGStringValue)

- (RG_PREFIX_NONNULL NSString*) rg_stringValue {
    return self.description; /* placeholder implementation as catch all */
}

@end

@implementation NSString (RGStringValue)

- (RG_PREFIX_NONNULL NSString*) rg_stringValue { /* should be the same but mutable string is tricky */
    return [self copy];
}

@end

@implementation NSData (RGStringValue)

- (RG_PREFIX_NONNULL NSString*) rg_stringValue { /* description has <...> */
    return (NSString* RG_SUFFIX_NONNULL)[[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

@end

@implementation NSNumber (RGStringValue)

- (RG_PREFIX_NONNULL NSString*) rg_stringValue {
    return self.stringValue;
}

@end

@implementation NSURL (RGStringValue)

- (RG_PREFIX_NONNULL NSString*) rg_stringValue { /* don't trust base vs relative */
    return (NSString* RG_SUFFIX_NONNULL)self.absoluteString;
}

@end
