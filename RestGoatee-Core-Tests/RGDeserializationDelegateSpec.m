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

#import "NSObject+RG_Deserialization.h"
#import "RGTestObject2.h"

@interface RGTestObject4 : RGTestObject2 <RGDeserializationDelegate>

@end

@implementation RGTestObject4

+ (prefix_nullable NSDictionary*) overrideKeysForMapping {
    return @{ STRING_SEL(stringProperty) : STRING_SEL(numberProperty) };
}

+ (prefix_nullable NSString*) dateFormatForProperty:(prefix_nonnull NSString* __unused)propertyName {
    return @"dd/MM/yyyy";
}

- (BOOL) shouldTransformValue:(prefix_nullable __unused id)value forProperty:(prefix_nonnull NSString*)propertyName inContext:(prefix_nullable __unused NSManagedObjectContext*)context {
    if ([propertyName isEqual:STRING_SEL(idProperty)]) {
        self.idProperty = @"foobaz";
        return NO;
    }
    return YES;
}

@end

CLASS_SPEC(RGDeserializationDelegate)

- (void) testOverrides {
    RGTestObject4* object = [RGTestObject4 objectFromDataSource:@{ STRING_SEL(stringProperty) : @"123" }];
    XCTAssert([object.numberProperty isEqual:@123]);
    XCTAssert(object.stringProperty == nil);
}

- (void) testDateFormat {
    RGTestObject4* object = [RGTestObject4 objectFromDataSource:@{ STRING_SEL(dateProperty) : @"18/10/2015" }];
    XCTAssert(object.dateProperty.timeIntervalSince1970 >= (1445151600.0 - 24 * 60 * 60) && object.dateProperty.timeIntervalSince1970 <= (1445151600.0 + 24 * 60 * 60));
}

- (void) testTransform {
    RGTestObject4* object = [RGTestObject4 objectFromDataSource:@{ STRING_SEL(idProperty) : @"foobar" }];
    XCTAssert([object.idProperty isEqual:@"foobaz"]);
}

SPEC_END
