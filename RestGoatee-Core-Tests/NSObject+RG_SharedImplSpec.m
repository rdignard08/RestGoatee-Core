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

///**
// Returns true if `Class cls = object;` is not a pointer type conversion.
// */
//BOOL rg_isClassObject(id object);
//
///**
// Returns true if object has the same type as `NSObject`'s meta class.
// */
//BOOL rg_isMetaClassObject(id object);
//
///**
// Returns true if the given type can be adequately represented by an `NSString`.
// */
//BOOL rg_isInlineObject(Class cls);
//
///**
// Returns true if the given type can be adequately represented by an `NSArray`.
// */
//BOOL rg_isCollectionObject(Class cls);
//
///**
// Returns true if the given type is a "key => value" type.  Thus it can be represented by an `NSDictionary`.
// */
//BOOL rg_isKeyedCollectionObject(Class cls);
//
///**
// Returns true if the given class conforms to `RGDataSourceProtocol`.  Necessary due to some bug.
// */
//BOOL rg_isDataSourceClass(Class cls);
//
///**
// Returns a `Class` object (i.e. an Objective-C object type), from the given type string.
// */
//Class rg_classForTypeString(NSString* str);
//
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

SPEC_END
