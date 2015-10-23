/* Copyright (c) 6/22/14, Ryan Dignard
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

#import "NSObject+RGLocking.h"
#import "RestGoatee-Core.h"
#import <objc/runtime.h>

@implementation NSObject (RGLocking)

+ (void) load {
    rg_swizzle(object_getClass(self), @selector(initialize), @selector(rg_override_initialize));
}

+ (void) rg_override_initialize {
    [self rg_override_initialize];
    objc_setAssociatedObject(self, @selector(rg_classLock), [NSLock new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSLock*) rg_classLock {
    NSLock* ret = objc_getAssociatedObject(self, @selector(rg_classLock));
    NSAssert(ret, @"Class %@ implemented +initialize but did not call through to super, and then attempted to obtain the class lock", self);
    return ret;
}

@end
