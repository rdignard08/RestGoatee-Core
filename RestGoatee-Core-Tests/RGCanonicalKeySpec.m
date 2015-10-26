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

#import "RestGoatee-Core.h"
#import "RGCanonicalKey.h"

CLASS_SPEC(RGCanonicalKey)

- (void) testIsEqualInstance {
    RGCanonicalKey* key1 = [[RGCanonicalKey alloc] initWithKey:@"AB_CD" withCanonicalName:@"abcd"];
    RGCanonicalKey* key2 = [[RGCanonicalKey alloc] initWithKey:@"AB_CD" withCanonicalName:@"aaaa"];
    XCTAssert([key1 isEqual:key2] == YES);
}

- (void) testIsNotEqualInstance {
    RGCanonicalKey* key1 = [[RGCanonicalKey alloc] initWithKey:@"AB_CD" withCanonicalName:@"abcd"];
    RGCanonicalKey* key2 = [[RGCanonicalKey alloc] initWithKey:@"AAAA" withCanonicalName:@"abcd"];
    XCTAssert([key1 isEqual:key2] == NO);
}

- (void) testIsEqualStringLiteral {
    RGCanonicalKey* key1 = [[RGCanonicalKey alloc] initWithKey:@"AB_CD" withCanonicalName:@"abcd"];
    XCTAssert([key1 isEqual:@"AB_CD"] == YES);
}

- (void) testIsEqualStringCanonical {
    RGCanonicalKey* key1 = [[RGCanonicalKey alloc] initWithKey:@"AB_CD" withCanonicalName:@"abcd"];
    XCTAssert([key1 isEqual:@"abcd"] == YES);
}

- (void) testIsNotEqualStringEither {
    RGCanonicalKey* key1 = [[RGCanonicalKey alloc] initWithKey:@"AB_CD" withCanonicalName:@"abcd"];
    XCTAssert([key1 isEqual:@"something"] == NO);
}

- (void) testIsNotEqualOther {
    RGCanonicalKey* key1 = [[RGCanonicalKey alloc] initWithKey:@"AB_CD" withCanonicalName:@"abcd"];
    XCTAssert([key1 isEqual:[NSObject new]] == NO);
}

- (void) testCopyIsEqual {
    RGCanonicalKey* key1 = [[RGCanonicalKey alloc] initWithKey:@"AB_CD" withCanonicalName:@"abcd"];
    XCTAssert([key1 isEqual:[key1 copy]] == YES);
}

SPEC_END
