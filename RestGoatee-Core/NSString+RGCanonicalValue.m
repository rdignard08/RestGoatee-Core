/* Copyright (c) 10/14/15, Ryan Dignard
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

#import "NSString+RGCanonicalValue.h"
#import <objc/runtime.h>

FILE_START

@implementation NSString (RGCanonicalValue)

- (void) setRg_canonicalValue:(prefix_nullable NSString*)canonicalValue {
    @synchronized (self) {
        objc_setAssociatedObject(self, @selector(rg_canonicalValue), canonicalValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (prefix_nonnull NSString*) rg_canonicalValue {
    @synchronized (self) {
        NSString* canonicalValue = objc_getAssociatedObject(self, @selector(rg_canonicalValue));
        if (!canonicalValue) {
            NSString* immutableCopy = [self copy];
            const NSUInteger inputLength = [immutableCopy lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            NSUInteger i = 0, j = 0;
            char* outBuffer = malloc(inputLength);
            const char* inBuffer = immutableCopy.UTF8String;
            for (; i != inputLength; i++) {
                char c = inBuffer[i];
                if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z')) { /* a digit or lowercase character; no change */
                    outBuffer[j++] = c;
                } else if (c >= 'A' && c <= 'Z') { /* an uppercase character; to lower */
                    outBuffer[j++] = c + (const int)('a' - 'A'); /* 'a' - 'A' == 32 */
                } /* unicodes, symbols, spaces, etc. are completely skipped */
            }
            canonicalValue = [[NSString alloc] initWithBytesNoCopy:outBuffer length:j encoding:NSUTF8StringEncoding freeWhenDone:YES];
            objc_setAssociatedObject(self, @selector(rg_canonicalValue), canonicalValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return canonicalValue;
    }
}

@end

FILE_END
