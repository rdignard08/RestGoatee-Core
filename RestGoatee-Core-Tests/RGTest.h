/* Copyright (c) 02/10/2016, Ryan Dignard
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

#import "RGDefines.h"

void rg_compare_performance(void(^ RG_SUFFIX_NONNULL firstFunction)(void),
                            void(^ RG_SUFFIX_NONNULL secondFunction)(void),
                            unsigned long long iterations,
                            void* RG_SUFFIX_NONNULL performanceKey);

/**
 @brief This function implements method swizzling.  Replaces the implementation identified by the selector `original`
 with the implementation identified by selector `replacement`.  Does not clobber the superclass's implementation of
 `original` if `cls` does not implement `original`.
 @param cls the class onto which the replacement method selector should be grafted.  Technically allows `Nil`.
 @param original the current selector whose associated implementation is the target of being changed.  Allows `NULL`
 which places no implementation on the selector identified by `replacement`.
 @param replacement the replacement selector which will provide the new implementation for the original method.
 Allows `NULL` which places no implementation on the selector identified by `original`.
 */
void rg_swizzle(Class RG_SUFFIX_NULLABLE cls,
                SEL RG_SUFFIX_NULLABLE original,
                SEL RG_SUFFIX_NULLABLE replacement) __attribute__((cold));
