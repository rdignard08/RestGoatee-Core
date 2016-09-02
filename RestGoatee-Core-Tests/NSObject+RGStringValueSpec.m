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

#import "RestGoatee-Core.h"

CATEGORY_SPEC(NSObject, RGStringValue)

- (void) testNormal {
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:1410000000];
    XCTAssert([date.rg_stringValue isEqual:@"2014-09-06 10:40:00 +0000"]);
}

- (void) testString {
    NSMutableString* string = [@"myString" mutableCopy];
    XCTAssert([string.rg_stringValue isEqual:string]);
    XCTAssert(string.rg_stringValue != string);
}

- (void) testData {
    NSData* data = [@"abew" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssert([data.rg_stringValue isEqual:@"abew"]);
}

- (void) testNumber {
    NSNumber* number = @3333.14;
    XCTAssert([number.rg_stringValue isEqual:@"3333.14"]);
    number = @1234;
    XCTAssert([number.rg_stringValue isEqual:@"1234"]);
}

- (void) testURL {
    NSURL* baseURL = [NSURL URLWithString:@"https://www.google.com/"];
    NSURL* url = [NSURL URLWithString:@"/hello" relativeToURL:baseURL];
    XCTAssert([url.rg_stringValue isEqual:@"https://www.google.com/hello"]);
    url = [NSURL URLWithString:@"https://www.google.com/hello2"];
    XCTAssert([url.rg_stringValue isEqual:@"https://www.google.com/hello2"]);
}

SPEC_END
