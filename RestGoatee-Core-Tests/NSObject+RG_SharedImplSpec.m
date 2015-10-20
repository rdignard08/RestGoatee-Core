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
#import <objc/runtime.h>

///**
// converts the raw property struct from the run-time system into an `NSDictionary`.
// */
//NSDictionary* rg_parsePropertyStruct(struct objc_property* property);
//
///**
// If the value of `str` has 2 '"' this function returns the contents between each '"'.
// */
//NSString* rg_trimLeadingAndTrailingQuotes(NSString* str);
//
///**
// Return the class object which is responsible for providing the implementation of a given `self.propertyName` invocation.
// 
// multiple classes may implement the same property, in this instance, only the top (i.e. the most subclass Class object) is returned.
// 
// @param currentClass is the object to test
// @param propertyName is the name of the property
// */
//Class topClassDeclaringPropertyNamed(Class currentClass, NSString* propertyName);
//
///**
// This is a private category which contains all the of the methods used jointly by the categories `RG_Deserialization` and `RG_Serialization`.
// */
//@interface NSObject (RG_SharedImpl)
//
///**
// This is a readonly property that describes the meta data of the given receiver's class.  It declares properties and instance variables in an object accessible manner.
// */
//@property nonnull_property(nonatomic, strong, readonly) NSArray* __property_list__;
//
///**
// This function returns the output keys of the receiver for use when determining what state information is present in the instance.
// */
//@property nonnull_property(nonatomic, strong, readonly) NSArray* rg_keys;
//
///**
// Returns a `Class` object which is the type of the property specified by `propertyName`; defaults to `NSNumber` if unknown.
// */
//- (prefix_nonnull Class) rg_classForProperty:(prefix_nonnull NSString*)propertyName;
//
///**
// Returns `YES` if the type of the property is an object type (as known by `NSClassFromString()`).
// */
//- (BOOL) rg_isPrimitive:(prefix_nonnull NSString*)propertyName;
//
///**
// Returns the metadata for the property specified by `propertyName`.
// */
//+ (prefix_nullable NSDictionary*) rg_declarationForProperty:(prefix_nonnull NSString*)propertyName;
//
///**
// The instance equivalent of `+[NSObject rg_declarationForProperty:]`.  No behavioral differences.
// */
//- (prefix_nullable NSDictionary*) rg_declarationForProperty:(prefix_nonnull NSString*)propertyName;
//
//@end

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

SPEC_END
