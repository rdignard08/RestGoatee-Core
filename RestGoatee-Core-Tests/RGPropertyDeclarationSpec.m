/* Copyright (c) 11/19/2015, Ryan Dignard
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
#import "NSObject+RGBadInit.h"
#include <objc/runtime.h>

@interface RGPropertyDeclaration ()

- (void) parseAttributes:(const char * RG_SUFFIX_NONNULL const)attributeString;

@end

CLASS_SPEC(RGPropertyDeclaration)

- (void) testInit {
    XCTAssertThrows([RGPropertyDeclaration new]);
}

- (void) testBadInit {
    rg_swizzle([NSObject self], @selector(init), @selector(override_init));
    objc_property_t* properties = class_copyPropertyList([RGTestObject1 self], NULL);
    RGPropertyDeclaration* declaration = [[RGPropertyDeclaration alloc] initWithProperty:*properties];
    free(properties);
    XCTAssert(declaration == nil);
    rg_swizzle([NSObject self], @selector(init), @selector(override_init));
}

- (void) testDealloc {
    objc_property_t* properties = class_copyPropertyList([RGTestObject1 self], NULL);
    RGPropertyDeclaration* declaration = [[RGPropertyDeclaration alloc] initWithProperty:*properties];
    free(properties);
    XCTAssert(declaration);
}

#pragma mark - arbitrary parseAttributes:
- (void) testBackingIvarAtFront {
    RGPropertyDeclaration* declaration = [RGPropertyDeclaration alloc];
    [declaration parseAttributes:"V_dateProperty,T@\"NSDate\",R"];
    XCTAssert([declaration.backingIvar isEqual:@"_dateProperty"]);
    XCTAssert(declaration.type == [NSDate self]);
    XCTAssert(declaration.isReadOnly == YES);
}

- (void) testGetterAtFront {
    RGPropertyDeclaration* declaration = [RGPropertyDeclaration alloc];
    [declaration parseAttributes:"Ggetter,T@\"NSDate\",R"];
    XCTAssert(declaration.getter == @selector(getter));
    XCTAssert(declaration.type == [NSDate self]);
    XCTAssert(declaration.isReadOnly == YES);
}

- (void) testSetterAtFront {
    RGPropertyDeclaration* declaration = [RGPropertyDeclaration alloc];
    [declaration parseAttributes:"SsetName:,T@\"NSDate\",&"];
    XCTAssert(declaration.setter == @selector(setName:));
    XCTAssert(declaration.type == [NSDate self]);
    XCTAssert(declaration.storageSemantics == kRGPropertyStrong);
}

- (void) testSetterAtEnd {
    RGPropertyDeclaration* declaration = [RGPropertyDeclaration alloc];
    [declaration parseAttributes:"T@,&,SsetName:"];
    XCTAssert(declaration.setter == @selector(setName:));
    XCTAssert(declaration.type == [NSObject self]);
    XCTAssert(declaration.storageSemantics == kRGPropertyStrong);
}

- (void) testUnknownPrefixes {
    RGPropertyDeclaration* declaration = [RGPropertyDeclaration alloc];
    [declaration parseAttributes:"Qhello,T@\"NSDate\",&,R,V_dateProperty,Enope1234,P"];
    XCTAssert(declaration.type == [NSDate self]);
    XCTAssert(declaration.storageSemantics == kRGPropertyStrong);
    XCTAssert(declaration.isReadOnly == YES);
    XCTAssert([declaration.backingIvar isEqual:@"_dateProperty"]);
    XCTAssert(declaration.isGarbageCollectible == YES);
}

#pragma mark - properties
- (void) testSimpleObject {
    NSDictionary* properties = [RGTestObject2 rg_propertyList];
    RGPropertyDeclaration* dateProperty = properties[RG_STRING_SEL(dateProperty)];
    XCTAssert([dateProperty.name isEqual:RG_STRING_SEL(dateProperty)]);
    XCTAssert([dateProperty.canonicalName isEqual:@"dateproperty"]);
    XCTAssert(dateProperty.type == [NSDate class]);
    XCTAssert(dateProperty.isPrimitive == NO);
    XCTAssert(dateProperty.isReadOnly == NO);
    XCTAssert(dateProperty.storageSemantics == kRGPropertyStrong);
    XCTAssert([dateProperty.backingIvar isEqual:@"_dateProperty"]);
    XCTAssert(dateProperty.isDynamic == NO);
    XCTAssert(dateProperty.isAtomic == NO);
    RGPropertyDeclaration* numberProperty = properties[RG_STRING_SEL(intProperty)];
    XCTAssert(numberProperty.type == [NSNumber class]);
    XCTAssert(numberProperty.isPrimitive == YES);
    XCTAssert(numberProperty.isIntegral == YES);
    XCTAssert(numberProperty.isFloatingPoint == NO);
    XCTAssert(numberProperty.isReadOnly == NO);
    XCTAssert(numberProperty.storageSemantics == kRGPropertyAssign);
    RGPropertyDeclaration* somethingProperty = properties[RG_STRING_SEL(weakProperty)];
    XCTAssert(somethingProperty.type == [NSString class]);
    XCTAssert(somethingProperty.isPrimitive == NO);
    XCTAssert(somethingProperty.isReadOnly == NO);
    XCTAssert(somethingProperty.storageSemantics == kRGPropertyWeak);
    RGPropertyDeclaration* readOnlyProperty = properties[RG_STRING_SEL(readOnlyProperty)];
    XCTAssert(readOnlyProperty.isReadOnly == YES);
    XCTAssert(readOnlyProperty.setter == NULL);
    XCTAssert(readOnlyProperty.isGarbageCollectible == NO);
    RGPropertyDeclaration* floatProperty = properties[RG_STRING_SEL(floatProperty)];
    XCTAssert(floatProperty.type == [NSNumber class]);
    XCTAssert(floatProperty.isPrimitive == YES);
    XCTAssert(floatProperty.isIntegral == NO);
    XCTAssert(floatProperty.isFloatingPoint == YES);
    XCTAssert(floatProperty.getter == @selector(floatProperty));
    XCTAssert(floatProperty.setter == @selector(setFloatProperty:));
}

- (void) testSynthesizing {
    NSDictionary* properties = [RGTestObject2 rg_propertyList];
    RGPropertyDeclaration* declaration = properties[RG_STRING_SEL(synthesizedDefault)];
    XCTAssert(declaration.isAtomic == YES);
    XCTAssert(declaration.setter == @selector(setValue:));
    XCTAssert(declaration.getter == @selector(synthesizedDefault));
    XCTAssert(declaration.storageSemantics == kRGPropertyCopy);
    XCTAssert([declaration.backingIvar isEqual:@"synthesizedDefault"]);
    XCTAssert(declaration.isDynamic == NO);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    declaration = properties[RG_STRING_SEL(synthesizedExplicit)];
#pragma clang diagnostic pop
    XCTAssert(declaration.isAtomic == YES);
    XCTAssert(declaration.setter == @selector(setSynthesizedExplicit:));
    XCTAssert(declaration.getter == @selector(synthesized));
    XCTAssert(declaration.storageSemantics == kRGPropertyWeak);
    XCTAssert([declaration.backingIvar isEqual:@"_synthesizedExplicit"]);
    XCTAssert(declaration.isDynamic == NO);
    declaration = properties[RG_STRING_SEL(dynamic)];
    XCTAssert(declaration.isAtomic == YES);
    XCTAssert(declaration.setter == @selector(setDynamic:));
    XCTAssert(declaration.getter == @selector(dynamic));
    XCTAssert(declaration.storageSemantics == kRGPropertyStrong);
    XCTAssert(declaration.backingIvar == nil);
    XCTAssert(declaration.isDynamic == YES);
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
    char* str = "sjkdfslkhasajskhdl2746981237JAgkHKJSGFKJHSKJSFHKJAGSd jdksdhflk sdklfh lksdjf l!&#^*&!%$)(!)$*@&@&@&@$"
                "&@*$^JKgsdajdajsdhaskdahr";
    XCTAssert([rg_canonical_form(str) isEqual:@"sjkdfslkhasajskhdl2746981237jagkhkjsgfkjhskjsfhkjagsdjdksdhflksdklfhlks"
                                              @"djfljkgsdajdajsdhaskdahr"]);
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
