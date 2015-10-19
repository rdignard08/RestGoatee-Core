/* Copyright (c) 10/18/15, Ryan Dignard
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

#import "NSObject+RG_KeyedSubscripting.h"
#import "RGTestObject2.h"

CATEGORY_SPEC(NSObject, RG_KeyedSubscripting)

- (void) testReadValue {
    RGTestObject2* object = [RGTestObject2 new];
    object.stringProperty = @"abcd";
    XCTAssert([object[STRING_SEL(stringProperty)] isEqual:@"abcd"]);
}

- (void) testReadNonExistent {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert(object[@"unknownProperty"] == nil);
}

- (void) testAssignValue {
    RGTestObject2* object = [RGTestObject2 new];
    object[STRING_SEL(stringProperty)] = @"abc";
    XCTAssert([object.stringProperty isEqual:@"abc"]);
}

- (void) testAssignNonExistent {
    RGTestObject2* object = [RGTestObject2 new];
    @try {
        object[@"unknownProperty"] = @"abcd";
    } @catch (NSException* e) {
        XCTFail(@"exception raised");
    } @finally {
        XCTAssert(YES);
    }
}

- (void) testAssignNilDictionary {
    NSMutableDictionary* dict = [NSMutableDictionary new];
    dict[@"abcd"] = @"abc";
    dict[@"abcd"] = nil;
    XCTAssert(dict[@"abcd"] == nil);
}

SPEC_END
