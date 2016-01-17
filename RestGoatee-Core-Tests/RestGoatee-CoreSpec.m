
/* Copyright (c) 11/19/15, Ryan Dignard
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

@interface RGBaseObject : NSObject

- (NSString*) method;

@end

@implementation RGBaseObject

- (NSString*) method {
    return @"foo";
}

@end

@interface RGDerivedObject1 : RGBaseObject @end
@implementation RGDerivedObject1

- (NSString*) method {
    return @"bar";
}

- (NSString*) override_method {
    return @"baz";
}

@end

@interface RGDerivedObject2 : RGBaseObject @end
@implementation RGDerivedObject2

- (NSString*) override_method {
    return @"baz";
}

@end

CLASS_SPEC(RestGoatee_Core)

#pragma mark - rg_log
- (void) testRGLogNormal {
    @try {
        RGLog(@"hello");
    } @catch (NSException* e) {
        XCTAssert(NO, @"exception raised when it shouldn't be");
    }
}

- (void) testRGLogNil {
    @try {
        RGLog(nil);
    } @catch (NSException* e) {
        XCTAssert(NO, @"exception raised when it shouldn't be");
    }
}

#pragma mark - rg_swizzle
- (void) testRGSwizzlePresent {
    RGDerivedObject1* derivedObject = [RGDerivedObject1 new];
    RGBaseObject* baseObject = [RGBaseObject new];
    XCTAssert([derivedObject.method isEqual:@"bar"]);
    XCTAssert([baseObject.method isEqual:@"foo"]);
    rg_swizzle([RGDerivedObject1 class], @selector(method), @selector(override_method));
    XCTAssert([derivedObject.method isEqual:@"baz"]);
    XCTAssert([baseObject.method isEqual:@"foo"]);
}

- (void) testRGSwizzleNotPresent {
    RGDerivedObject2* derivedObject = [RGDerivedObject2 new];
    RGBaseObject* baseObject = [RGBaseObject new];
    XCTAssert([derivedObject.method isEqual:@"foo"]);
    XCTAssert([baseObject.method isEqual:@"foo"]);
    rg_swizzle([RGDerivedObject2 class], @selector(method), @selector(override_method));
    XCTAssert([derivedObject.method isEqual:@"baz"]);
    XCTAssert([baseObject.method isEqual:@"foo"]);
}

#pragma mark - rg_threadsafe_formatter
- (void) testRGThreadSafeFormatterSame {
    NSDateFormatter* formatter = rg_threadsafe_formatter();
    NSDateFormatter* anotherFormatter = rg_threadsafe_formatter();
    XCTAssert(formatter == anotherFormatter);
}

- (void) testRGThreadSafeFormatterDiffered {
    NSDateFormatter* formatter = rg_threadsafe_formatter();
    __block NSDateFormatter* anotherFormatter;
    dispatch_queue_t backgroundQueue = dispatch_queue_create("background", DISPATCH_QUEUE_SERIAL);
    dispatch_async(backgroundQueue, ^{
        anotherFormatter = rg_threadsafe_formatter();
    });
    dispatch_sync(backgroundQueue, ^{}); // apple's so smart dispatch_sync will lie.
    XCTAssert(formatter != anotherFormatter);
}

SPEC_END

