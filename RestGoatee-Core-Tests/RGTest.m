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

#import "RGTest.h"

void rg_compare_performance(void(^ RG_SUFFIX_NONNULL firstFunction)(void),
                            void(^ RG_SUFFIX_NONNULL secondFunction)(void),
                            unsigned long long iterations,
                            void* RG_SUFFIX_NONNULL performanceKey) {
    static dispatch_once_t onceToken;
    static NSMutableDictionary RG_GENERIC(NSValue*, NSNumber*) * testAverages;
    static NSMutableDictionary RG_GENERIC(NSValue*, NSNumber*) * testRuns;
    dispatch_once(&onceToken, ^{
        testAverages = [NSMutableDictionary new];
        testRuns = [NSMutableDictionary new];
    });
    NSValue* testKey = [NSValue valueWithPointer:performanceKey];
    double average = [testAverages[testKey] doubleValue];
    unsigned long long count = [testRuns[testKey] unsignedLongLongValue];
    clock_t testStart = clock();
    for (unsigned long long i = 0; i < iterations; i++) {
        firstFunction();
    }
    clock_t firstEnd = clock();
    for (unsigned long long i = 0; i < iterations; i++) {
        secondFunction();
    }
    clock_t testEnd = clock();
    double first = ((double)(firstEnd - testStart)) / CLOCKS_PER_SEC;
    double second = ((double)(testEnd - firstEnd)) / CLOCKS_PER_SEC;
    double speedup = (first - second) / first;
    average = (average * count + speedup) / (count + 1);
    count = count + 1;
    testAverages[testKey] = @(average);
    testRuns[testKey] = @(count);
    NSLog(@"speedup %+.5f (first over second) average %+.5f", speedup, average);
    
}
