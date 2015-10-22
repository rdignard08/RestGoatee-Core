/* Copyright (c) 10/12/15, Ryan Dignard
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

CATEGORY_SPEC(NSString, RGCanonicalValue)

- (void) testSpaces {
    XCTAssert([@"          ".rg_canonicalValue isEqual:@""]);
}

- (void) testNumbers {
    XCTAssert([@"1234add1234".rg_canonicalValue isEqual:@"1234add1234"]);
}

- (void) testCapitals {
    XCTAssert([@"ABCDE".rg_canonicalValue isEqual:@"abcde"]);
}

- (void) testSymbols {
    XCTAssert([@"!@#$abcde&*!@#".rg_canonicalValue isEqual:@"abcde"]);
}

- (void) testUnicode {
    NSString* str = @"abc💅bcd";
    XCTAssert([str.rg_canonicalValue isEqual:@"abcbcd"]);
}

- (void) testShortString {
    XCTAssert([@"".rg_canonicalValue isEqual:@""]);
}

- (void) testLongString {
    NSString* str = @"sjkdfslkhasajskhdl2746981237JAgkHKJSGFKJHSKJSFHKJAGSd jdksdhflk sdklfh lksdjf l!&#^*&!%$)(!)$*@&@&@&@$&@*$^JKgsdajdajsdhaskdahr";
    XCTAssert([str.rg_canonicalValue isEqual:@"sjkdfslkhasajskhdl2746981237jagkhkjsgfkjhskjsfhkjagsdjdksdhflksdklfhlksdjfljkgsdajdajsdhaskdahr"]);
}

- (void) testSideEffects { // tests that the output value is stored so it's not being recalculated
    NSString* str = @"abcde";
    [str rg_canonicalValue];
    XCTAssert([objc_getAssociatedObject(str, @selector(rg_canonicalValue)) isEqual:str]);
}

- (void) testMutableString {
    NSMutableString* str = [NSMutableString stringWithString:@"ab---cde"];
    XCTAssert([str.rg_canonicalValue isEqual:@"abcde"]);
    [str replaceCharactersInRange:NSMakeRange(str.length - 1, 1) withString:@""];
    str.rg_canonicalValue = nil;
    XCTAssert([str.rg_canonicalValue isEqual:@"abcd"]);
}

SPEC_END
