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

#import "NSObject+RG_Deserialization.h"
#import "RGTestObject2.h"

CATEGORY_SPEC(NSObject, RG_Deserialization)

- (void)testStringProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ @"stringProperty" : @"foobar" }];
    XCTAssert([object.stringProperty isEqual:@"foobar"]);
}

- (void)testNumberProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ @"numberProperty" : @1 }];
    XCTAssert([object.numberProperty isEqual:@1]);
}

- (void)testDecimalProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ @"decimalProperty" : @"10.0" }];
    XCTAssert([object.decimalProperty isEqual:[NSDecimalNumber decimalNumberWithString:@"10.0"]]);
}

- (void)testValueProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ @"valueProperty" : @1 }];
    XCTAssert([object.valueProperty isEqual:@1]);
}

- (void)testIdProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ @"idProperty" : @"foobar" }];
    XCTAssert([object.idProperty isEqual:@"foobar"]);
}

- (void)testClassProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ @"classProperty" : @"NSObject" }];
    XCTAssert([object.classProperty isEqual:[NSObject class]]);
}

- (void)testArrayProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ @"arrayProperty" : @[ @"foo", @"bar" ] }];
    XCTAssert([object.arrayProperty isEqual:(@[ @"foo", @"bar" ])]);
}

- (void)testDictionaryProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ @"dictionaryProperty" : @{ @"foo" : @"bar" } }];
    XCTAssert([object.dictionaryProperty isEqual:(@{ @"foo" : @"bar" })]);
}

SPEC_END
