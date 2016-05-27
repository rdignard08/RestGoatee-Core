/* Copyright (c) 01/13/2016, Ryan Dignard
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
#import "RGTestObject2.h"
#import "RGTestObject5.h"

CATEGORY_SPEC(NSObject, RGSerialization)

#pragma mark - dictionaryRepresentation
- (void)testDictionaryRepresentationBasic {
    RGTestObject2* obj = [RGTestObject2 new];
    obj.dictionaryProperty = @{ @"aKey" : @"aValue" };
    obj.arrayProperty = @[ @"aValue" ];
    NSDictionary* dictionaryRepresentation = [obj dictionaryRepresentation];
    XCTAssert([dictionaryRepresentation[RG_STRING_SEL(dictionaryProperty)] isEqual:obj.dictionaryProperty]);
    XCTAssert([dictionaryRepresentation[RG_STRING_SEL(arrayProperty)] isEqual:obj.arrayProperty]);
    XCTAssert([dictionaryRepresentation[kRGSerializationKey] isEqual:NSStringFromClass([RGTestObject2 class])]);
}

- (void)testRGSerializable {
    NSEntityDescription* entity = [NSEntityDescription new];
    entity.name = NSStringFromClass([RGTestObject5 self]);
    entity.managedObjectClassName = entity.name;
    NSAttributeDescription *stringProperty = [NSAttributeDescription new];
    stringProperty.name = RG_STRING_SEL(stringProperty);
    stringProperty.attributeType = NSStringAttributeType;
    NSAttributeDescription *arrayProperty = [NSAttributeDescription new];
    arrayProperty.name = RG_STRING_SEL(arrayProperty);
    arrayProperty.attributeType = NSTransformableAttributeType;
    NSAttributeDescription *numberProperty = [NSAttributeDescription new];
    numberProperty.name = RG_STRING_SEL(numberProperty);
    numberProperty.attributeType = NSFloatAttributeType;
    NSAttributeDescription *classProperty = [NSAttributeDescription new];
    classProperty.name = RG_STRING_SEL(classProperty);
    classProperty.attributeType = NSTransformableAttributeType;
    entity.properties = @[ stringProperty, arrayProperty, numberProperty, classProperty ];
    NSManagedObjectModel* model = [NSManagedObjectModel new];
    model.entities = @[ entity ];
    NSPersistentStoreCoordinator* store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = store;
    RGTestObject5* obj = [RGTestObject5 objectFromDataSource:nil inContext:context];
    obj.stringProperty = @"abcd";
    obj.arrayProperty = @[ @"aValue" ];
    obj.numberProperty = @3;
    obj.classProperty = [NSObject self];
    NSDictionary* dictionary = [obj dictionaryRepresentation];
    XCTAssert([dictionary[RG_STRING_SEL(stringProperty)] isEqual:@"abcd"]);
    XCTAssert(dictionary[RG_STRING_SEL(arrayProperty)] == nil);
    XCTAssert([dictionary[RG_STRING_SEL(numberProperty)] isEqual:@"3"]);
    XCTAssert([dictionary[RG_STRING_SEL(classProperty)] isEqual:@"NSObject"]);
}

SPEC_END
