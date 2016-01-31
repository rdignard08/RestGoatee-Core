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

#import "RGPropertyDeclaration.h"
#import "RestGoatee-Core.h"
#import "RGTestObject2.h"
#import "NSObject+RGSharedImpl.h"

CLASS_SPEC(RGPropertyDeclaration)

- (void) testInit {
    XCTAssertThrows([RGPropertyDeclaration new]);
}

- (void) testDealloc {
    objc_property_t* properties = class_copyPropertyList([RGTestObject1 class], NULL);
    RGPropertyDeclaration* declaration = [[RGPropertyDeclaration alloc] initWithProperty:*properties];
    free(properties);
    NSLog(@"%@ exists", declaration);
}

#pragma mark - properties
- (void) testSimpleObject {
    NSDictionary* properties = [RGTestObject2 rg_propertyList];
    RGPropertyDeclaration* stringProperty = properties[RG_STRING_SEL(dateProperty)];
    XCTAssert([stringProperty.name isEqual:RG_STRING_SEL(dateProperty)]);
    XCTAssert([stringProperty.canonicalName isEqual:@"dateproperty"]);
    XCTAssert(stringProperty.type == [NSDate class]);
    XCTAssert(stringProperty.isPrimitive == NO);
    XCTAssert(stringProperty.readOnly == NO);
    XCTAssert(stringProperty.storageSemantics == kRGPropertyStrong);
    RGPropertyDeclaration* numberProperty = properties[RG_STRING_SEL(intProperty)];
    XCTAssert(numberProperty.type == [NSNumber class]);
    XCTAssert(numberProperty.isPrimitive == YES);
    XCTAssert(numberProperty.readOnly == NO);
    XCTAssert(numberProperty.storageSemantics == kRGPropertyAssign);
    RGPropertyDeclaration* somethingProperty = properties[RG_STRING_SEL(weakProperty)];
    XCTAssert(somethingProperty.type == [NSString class]);
    XCTAssert(somethingProperty.isPrimitive == NO);
    XCTAssert(somethingProperty.readOnly == NO);
    XCTAssert(somethingProperty.storageSemantics == kRGPropertyWeak);
    RGPropertyDeclaration* readOnlyProperty = properties[RG_STRING_SEL(readOnlyProperty)];
    XCTAssert(readOnlyProperty.readOnly == YES);
}

#pragma mark - rg_canonical
- (void) testSpeed {
    unsigned char* characters = calloc(256, 1);
    for (unsigned char i = 0; i < 255; i++) {
        characters[i] = i + 1;
    }
    [self measureBlock:^{
        for (int i = 0; i < 10000; i++) {
            NSString* foo = rg_canonical_form((char*)characters);
            XCTAssert(foo);
        }
    }];
    free(characters);
}

- (void) testSpaces {
    XCTAssert([rg_canonical_form("          ") isEqual:@""]);
}

- (void) testNumbers {
    XCTAssert([rg_canonical_form("1234add1234") isEqual:@"1234add1234"]);
}

- (void) testCapitals {
    XCTAssert([rg_canonical_form("ABCDE") isEqual:@"abcde"]);
}

- (void) testSymbols {
    XCTAssert([rg_canonical_form("!@#$abcde&*!@#") isEqual:@"abcde"]);
}

- (void) testUnicode {
    XCTAssert([rg_canonical_form("abc💅bcd") isEqual:@"abcbcd"]);
}

- (void) testShortString {
    XCTAssert([rg_canonical_form("") isEqual:@""]);
}

- (void) testLongString {
    char* str = "sjkdfslkhasajskhdl2746981237JAgkHKJSGFKJHSKJSFHKJAGSd jdksdhflk sdklfh lksdjf l!&#^*&!%$)(!)$*@&@&@&@$&@*$^JKgsdajdajsdhaskdahr";
    XCTAssert([rg_canonical_form(str) isEqual:@"sjkdfslkhasajskhdl2746981237jagkhkjsgfkjhskjsfhkjagsdjdksdhflksdklfhlksdjfljkgsdajdajsdhaskdahr"]);
}

- (void) testMallocBasedString {
    char str[] = "sjkdfslkhasajskhdl2746981237JAgkHKJSGFKJ" \
                "HSKJSFHKJAGSd jdksdhflk sdklfh lksdjf l!" \
                "&#^*&!%$)(!)$*@&@&@&@$&@*$^JKgsdajdajsdh" \
                "askdahr012345678901234567890QWERTYUIOP{}" \
                "ASDFGHJKL:'ZXCVBNM<>?!@#4%^&*()_+‚€‹›‡⁄°" \
                "àßfrëasdghdkajsahdasdaskldjasdkjlasdskdj" \
                "sjkdfslkhasajskhdl2746981237JAgkHKJSGFKJ" \
                "HSKJSFHKJAGSd jdksdhflk sdklfh lksdjf l!" \
                "&#^*&!%$)(!)$*@&@&@&@$&@*$^JKgsdajdajsdh" \
                "askdahr012345678901234567890QWERTYUIOP{}" \
                "ASDFGHJKL:'ZXCVBNM<>?!@#4%^&*()_+‚€‹›‡⁄°" \
                "àßfrëasdghdkajsahdasdaskldjasdkjlasdskdj" \
                "sjkdfslkhasajskhdl2746981237JAgkHKJSGFKJ" \
                "HSKJSFHKJAGSd jdksdhflk sdklfh lksdjf l!" \
                "&#^*&!%$)(!)$*@&@&@&@$&@*$^JKgsdajdajsdh" \
                "askdahr012345678901234567890QWERTYUIOP{}" \
                "ASDFGHJKL:'ZXCVBNM<>?!@#4%^&*()_+‚€‹›‡⁄°" \
                "àßfrëasdghdkajsahdasdaskldjasdkjlasdskdj" \
                "sjkdfslkhasajskhdl2746981237JAgkHKJSGFKJ" \
                "HSKJSFHKJAGSd jdksdhflk sdklfh lksdjf l!" \
                "&#^*&!%$)(!)$*@&@&@&@$&@*$^JKgsdajdajsdh" \
                "askdahr012345678901234567890QWERTYUIOP{}" \
                "ASDFGHJKL:'ZXCVBNM<>?!@#4%^&*()_+‚€‹›‡⁄°" \
                "àßfrëasdghdkajsahdasdaskldjasdkjlasdskdj" \
                "sjkdfslkhasajskhdl2746981237JAgkHKJSGFKJ" \
                "HSKJSFHKJAGSd jdksdhflk sdklfh lksdjf l!" \
                "&#^*&!%$)(!)$*@&@&@&@$&@*$^JKgsdajdajsdh" \
                "askdahr012345678901234567890QWERTYUIOP{}" \
                "ASDFGHJKL:'ZXCVBNM<>?!@#4%^&*()_+‚€‹›‡⁄°" \
                "àßfrëasdghdkajsahdasdaskldjasdkjlasdskdj";
    XCTAssert(sizeof(str) > kRGMaxAutoSize);
    
    XCTAssert([rg_canonical_form(str) isEqual:
               @"sjkdfslkhasajskhdl2746981237jagkhkjsgfkj" \
                "hskjsfhkjagsdjdksdhflksdklfhlksdjfljkgsd" \
                "ajdajsdhaskdahr012345678901234567890qwer" \
                "tyuiopasdfghjklzxcvbnm4frasdghdkajsahdas" \
                "daskldjasdkjlasdskdjsjkdfslkhasajskhdl27" \
                "46981237jagkhkjsgfkjhskjsfhkjagsdjdksdhf" \
                "lksdklfhlksdjfljkgsdajdajsdhaskdahr01234" \
                "5678901234567890qwertyuiopasdfghjklzxcvb" \
                "nm4frasdghdkajsahdasdaskldjasdkjlasdskdj" \
                "sjkdfslkhasajskhdl2746981237jagkhkjsgfkj" \
                "hskjsfhkjagsdjdksdhflksdklfhlksdjfljkgsd" \
                "ajdajsdhaskdahr012345678901234567890qwer" \
                "tyuiopasdfghjklzxcvbnm4frasdghdkajsahdas" \
                "daskldjasdkjlasdskdjsjkdfslkhasajskhdl27" \
                "46981237jagkhkjsgfkjhskjsfhkjagsdjdksdhf" \
                "lksdklfhlksdjfljkgsdajdajsdhaskdahr01234" \
                "5678901234567890qwertyuiopasdfghjklzxcvb" \
                "nm4frasdghdkajsahdasdaskldjasdkjlasdskdj" \
                "sjkdfslkhasajskhdl2746981237jagkhkjsgfkj" \
                "hskjsfhkjagsdjdksdhflksdklfhlksdjfljkgsd" \
                "ajdajsdhaskdahr012345678901234567890qwer" \
                "tyuiopasdfghjklzxcvbnm4frasdghdkajsahdas" \
                "daskldjasdkjlasdskdj"]);
}

SPEC_END
