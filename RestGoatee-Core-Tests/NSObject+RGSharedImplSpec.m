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

#import "NSObject+RGSharedImpl.h"
#import "RestGoatee-Core.h"
#import "RGTestObject2.h"
#import <objc/runtime.h>

CATEGORY_SPEC(NSObject, RGSharedImpl)

#pragma mark - rg_dateFormats
- (void) testDateFormatsNullability {
    XCTAssert(rg_date_formats() != nil);
}

- (void) testDateFormatsNSDateParsable {
    NSDate* date = [NSDate new];
    NSDateFormatter* formatter = [NSDateFormatter new];
    BOOL foundAGoodOne = NO;
    for (NSString* format in rg_date_formats()) {
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
    for (NSString* format in rg_date_formats()) {
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

#pragma mark - rg_propertyList
- (void) testPropertyList {
    NSDictionary* propertyList = [[RGTestObject2 class] rg_propertyList];
    XCTAssert(propertyList[RG_STRING_SEL(stringProperty)] != nil);
    XCTAssert(propertyList[RG_STRING_SEL(urlProperty)] != nil);
    XCTAssert(propertyList[RG_STRING_SEL(numberProperty)] != nil);
    XCTAssert(propertyList[RG_STRING_SEL(decimalProperty)] != nil);
    XCTAssert(propertyList[RG_STRING_SEL(valueProperty)] != nil);
    XCTAssert(propertyList[RG_STRING_SEL(idProperty)] != nil);
    XCTAssert(propertyList[RG_STRING_SEL(classProperty)] != nil);
    XCTAssert(propertyList[RG_STRING_SEL(arrayProperty)] != nil);
    XCTAssert(propertyList[RG_STRING_SEL(dictionaryProperty)] != nil);
    XCTAssert(propertyList[RG_STRING_SEL(objectProperty)] != nil);
    XCTAssert(propertyList[RG_STRING_SEL(dateProperty)] != nil);
}

#pragma mark - rg_classForProperty:
- (void) testRGClassForProperty {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert([[(RGPropertyDeclaration*)[[object class] rg_propertyList][RG_STRING_SEL(stringProperty)] type] isEqual:[NSString class]]);
}

#pragma mark - rg_isPrimitive:
- (void) testIsPrimitiveString {
    RGTestObject2* object = [RGTestObject2 new];
    RGPropertyDeclaration* declaration = [[object class] rg_propertyList][RG_STRING_SEL(stringProperty)];
    XCTAssert(declaration.isPrimitive == NO);
}

- (void) testIsPrimitiveId {
    RGTestObject2* object = [RGTestObject2 new];
    RGPropertyDeclaration* declaration = [[object class] rg_propertyList][RG_STRING_SEL(idProperty)];
    XCTAssert(declaration.isPrimitive == NO);
}

- (void) testIsPrimitiveClass {
    RGTestObject2* object = [RGTestObject2 new];
    RGPropertyDeclaration* declaration = [[object class] rg_propertyList][RG_STRING_SEL(classProperty)];
    XCTAssert(declaration.isPrimitive == NO);
}

- (void) testIsPrimitiveNumber {
    RGTestObject2* object = [RGTestObject2 new];
    RGPropertyDeclaration* declaration = [[object class] rg_propertyList][RG_STRING_SEL(numberProperty)];
    XCTAssert(declaration.isPrimitive == NO);
}

- (void) testIsPrimitiveInt {
    RGTestObject2* object = [RGTestObject2 new];
    RGPropertyDeclaration* declaration = [[object class] rg_propertyList][RG_STRING_SEL(intProperty)];
    XCTAssert(declaration.isPrimitive == YES);
}

#pragma mark - rg_declarationForProperty:
- (void) testDeclarationExists {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert([[object class] rg_propertyList][RG_STRING_SEL(stringProperty)] != nil);
}

- (void) testDeclarationDoesNotExist {
    RGTestObject2* object = [RGTestObject2 new];
    XCTAssert([[object class] rg_propertyList][RG_STRING_SEL(rg_propertyList)] == nil);
}

SPEC_END
