/* Copyright (c) 10/19/15, Ryan Dignard
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

#import "NSObject+RG_SharedImpl.h"
#import "RGTestObject2.h"
#import <objc/runtime.h>

CATEGORY_SPEC(NSObject, RG_SharedImpl)

#pragma mark - rg_dateFormats
- (void) testDateFormatsNullability {
    XCTAssert(rg_dateFormats() != nil);
}

- (void) testDateFormatsNSDateParsable {
    NSDate* date = [NSDate new];
    NSDateFormatter* formatter = [NSDateFormatter new];
    BOOL foundAGoodOne = NO;
    for (NSString* format in rg_dateFormats()) {
        formatter.dateFormat = format;
        if ((int)date.timeIntervalSince1970 == (int)[formatter dateFromString:[date description]].timeIntervalSince1970) {
            foundAGoodOne = YES;
            break;
        }
        
    }
    XCTAssert(foundAGoodOne);
}

- (void) testDateFormatsISOParsable {
    NSDateFormatter* formatter = [NSDateFormatter new];
    NSDate* date;
    for (NSString* format in rg_dateFormats()) {
        formatter.dateFormat = format;
        NSDate* currentDate = [formatter dateFromString:@"2015-10-19T13:52:23-800"];
        if ((int)currentDate.timeIntervalSince1970 == 1445291543) {
            date = currentDate;
            break;
        }
    }
    XCTAssert(date);
}

#pragma mark - rg_isClassObject
- (void) testIsClassObject {
    XCTAssert(rg_isClassObject([NSString class]) == YES);
}

- (void) testIsClassRegularObject {
    XCTAssert(rg_isClassObject([NSObject new]) == NO);
}

- (void) testIsClassNSMetaClass {
    XCTAssert(rg_isClassObject(object_getClass([NSObject class])) == YES);
}

- (void) testIsClassRegMetaClass {
    XCTAssert(rg_isClassObject(object_getClass([NSString class])) == YES);
}

#pragma mark - rg_isMetaClassObject
- (void) testIsMetaClassObject {
    XCTAssert(rg_isMetaClassObject(object_getClass([NSString class])) == YES);
}

- (void) testIsMetaClassRegClass {
    XCTAssert(rg_isMetaClassObject([NSObject class]) == NO);
}

#pragma mark - rg_isInlineObject
- (void) testIsInlineNSObject {
    XCTAssert(rg_isInlineObject([NSObject class]) == NO);
}

- (void) testIsInlineDate {
    XCTAssert(rg_isInlineObject([NSDate class]) == YES);
}

- (void) testIsInlineString {
    XCTAssert(rg_isInlineObject([NSString class]) == YES);
}

- (void) testIsInlineData {
    XCTAssert(rg_isInlineObject([NSData class]) == YES);
}

- (void) testIsInlineNumber {
    XCTAssert(rg_isInlineObject([NSNumber class]) == YES);
}

- (void) testIsInlineNull {
    XCTAssert(rg_isInlineObject([NSNull class]) == YES);
}

- (void) testIsInlineValue {
    XCTAssert(rg_isInlineObject([NSValue class]) == YES);
}

- (void) testIsInlineURL {
    XCTAssert(rg_isInlineObject([NSURL class]) == YES);
}

- (void) testIsInlineArray {
    XCTAssert(rg_isInlineObject([NSArray class]) == NO);
}

- (void) testIsInlineDictionary {
    XCTAssert(rg_isInlineObject([NSDictionary class]) == NO);
}

#pragma mark - rg_isCollectionObject
- (void) testIsCollectionSet {
    XCTAssert(rg_isCollectionObject([NSSet class]) == YES);
}

- (void) testIsCollectionArray {
    XCTAssert(rg_isCollectionObject([NSArray class]) == YES);
}

- (void) testIsCollectionOrderedSet {
    XCTAssert(rg_isCollectionObject([NSOrderedSet class]) == YES);
}

- (void) testIsCollectionCountedSet {
    XCTAssert(rg_isCollectionObject([NSCountedSet class]) == YES);
}

- (void) testIsCollectionDictionary {
    XCTAssert(rg_isCollectionObject([NSDictionary class]) == NO);
}

#pragma mark - rg_isKeyedCollectionObject
- (void) testIsKeyedCollectionDictionary {
    XCTAssert(rg_isKeyedCollectionObject([NSDictionary class]) == YES);
}

- (void) testIsKeyedCollectionArray {
    XCTAssert(rg_isKeyedCollectionObject([NSArray class]) == NO);
}

#pragma mark - topClassDeclaringPropertyNamed
- (void) testTopClassIsClass {
    XCTAssert(topClassDeclaringPropertyNamed([NSObject class], STRING_SEL(description)) == [NSObject class]);
}

- (void) testTopClassIsSuperClass {
    XCTAssert(topClassDeclaringPropertyNamed([RGTestObject2 class], STRING_SEL(stringProperty)) == [RGTestObject1 class]);
}

- (void) testTopClassIsNotClass {
    XCTAssert(topClassDeclaringPropertyNamed([RGTestObject1 class], STRING_SEL(objectProperty)) == Nil);
}

#pragma mark - __property_list__
- (void) testPropertyList {
    NSArray* propertyList = [[RGTestObject2 class] __property_list__];
    XCTAssert([propertyList[kRGPropertyName] indexOfObject:STRING_SEL(stringProperty)] != NSNotFound);
    XCTAssert([propertyList[kRGPropertyName] indexOfObject:STRING_SEL(urlProperty)] != NSNotFound);
    XCTAssert([propertyList[kRGPropertyName] indexOfObject:STRING_SEL(numberProperty)] != NSNotFound);
    XCTAssert([propertyList[kRGPropertyName] indexOfObject:STRING_SEL(decimalProperty)] != NSNotFound);
    XCTAssert([propertyList[kRGPropertyName] indexOfObject:STRING_SEL(valueProperty)] != NSNotFound);
    XCTAssert([propertyList[kRGPropertyName] indexOfObject:STRING_SEL(idProperty)] != NSNotFound);
    XCTAssert([propertyList[kRGPropertyName] indexOfObject:STRING_SEL(classProperty)] != NSNotFound);
    XCTAssert([propertyList[kRGPropertyName] indexOfObject:STRING_SEL(arrayProperty)] != NSNotFound);
    XCTAssert([propertyList[kRGPropertyName] indexOfObject:STRING_SEL(dictionaryProperty)] != NSNotFound);
    XCTAssert([propertyList[kRGPropertyName] indexOfObject:STRING_SEL(objectProperty)] != NSNotFound);
    XCTAssert([propertyList[kRGPropertyName] indexOfObject:STRING_SEL(dateProperty)] != NSNotFound);
}

#pragma mark - rg_keys
- (void) testRGKeysObject {
    RGTestObject2* object = [RGTestObject2 new];
    NSArray* rgKeys = object.rg_keys;
    XCTAssert([rgKeys indexOfObject:STRING_SEL(stringProperty)] != NSNotFound);
    XCTAssert([rgKeys indexOfObject:STRING_SEL(urlProperty)] != NSNotFound);
    XCTAssert([rgKeys indexOfObject:STRING_SEL(numberProperty)] != NSNotFound);
    XCTAssert([rgKeys indexOfObject:STRING_SEL(decimalProperty)] != NSNotFound);
    XCTAssert([rgKeys indexOfObject:STRING_SEL(valueProperty)] != NSNotFound);
    XCTAssert([rgKeys indexOfObject:STRING_SEL(idProperty)] != NSNotFound);
    XCTAssert([rgKeys indexOfObject:STRING_SEL(classProperty)] != NSNotFound);
    XCTAssert([rgKeys indexOfObject:STRING_SEL(arrayProperty)] != NSNotFound);
    XCTAssert([rgKeys indexOfObject:STRING_SEL(dictionaryProperty)] != NSNotFound);
    XCTAssert([rgKeys indexOfObject:STRING_SEL(objectProperty)] != NSNotFound);
    XCTAssert([rgKeys indexOfObject:STRING_SEL(dateProperty)] != NSNotFound);
}

- (void) testRGKeysDictionary {
    NSDictionary* rgKeys = @{ @"abc" : @"def", @"123" : @"foobar" };
    XCTAssert([rgKeys.rg_keys isEqual:(@[ @"abc", @"123" ])]);
}

#pragma mark - rg_classForProperty:
- (void) testRGClassForProperty {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert([[object rg_classForProperty:STRING_SEL(stringProperty)] isEqual:[NSString class]]);
}

- (void) testRGClassForPropertyUnknown {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert([[object rg_classForProperty:STRING_SEL(rg_classForProperty:)] isEqual:[NSNumber class]]);
}

#pragma mark - rg_isPrimitive:
- (void) testIsPrimitiveString {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert([object rg_isPrimitive:STRING_SEL(stringProperty)] == NO);
}

- (void) testIsPrimitiveId {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert([object rg_isPrimitive:STRING_SEL(idProperty)] == NO);
}

- (void) testIsPrimitiveClass {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert([object rg_isPrimitive:STRING_SEL(classProperty)] == NO);
}

- (void) testIsPrimitiveNumber {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert([object rg_isPrimitive:STRING_SEL(numberProperty)] == NO);
}

- (void) testIsPrimitiveInt {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert([object rg_isPrimitive:STRING_SEL(intProperty)] == YES);
}

#pragma mark - rg_declarationForProperty:
- (void) testDeclarationExists {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert([[object class] rg_declarationForProperty:STRING_SEL(stringProperty)] != nil);
}

- (void) testDeclarationDoesNotExist {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert([[object class] rg_declarationForProperty:STRING_SEL(rg_declarationForProperty:)] == nil);
}

SPEC_END
