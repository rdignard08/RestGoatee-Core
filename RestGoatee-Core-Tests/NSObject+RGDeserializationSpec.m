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

#import "RestGoatee-Core.h"
#import "RGTestObject2.h"
#import "RGPropertyDeclaration.h"
#import "RGTestManagedObject.h"
#import "RGBartStation.h"
#import "NSObject+RGSharedImpl.h"

@interface NSObject (_RGForwardDecl)

+ (NSDictionary*) rg_propertyList;
- (void) rg_initProperty:(RG_PREFIX_NONNULL RGPropertyDeclaration*)property withValue:(RG_PREFIX_NULLABLE id)value inContext:(RG_PREFIX_NULLABLE id)context;

@end

CATEGORY_SPEC(NSObject, RGDeserialization)

#pragma mark - objectsFromArraySource:inContext: (XML)
- (void) testXMLArraySource {
    NSData* xmlData = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                       @"<root>"
                         @"<uri><![CDATA[http://api.bart.gov/api/stn.aspx?cmd=stns]]></uri>"
                         @"<stations>"
                           @"<station>"
                             @"<name>12th St. Oakland City Center</name>"
                             @"<abbr>12TH</abbr>"
                             @"<gtfs_latitude>37.803664</gtfs_latitude>"
                             @"<gtfs_longitude>-122.271604</gtfs_longitude>"
                             @"<address>1245 Broadway</address>"
                             @"<city>Oakland</city>"
                             @"<county>alameda</county>"
                             @"<state>CA</state>"
                             @"<zipcode>94612</zipcode>"
                           @"</station>"
                           @"<station>"
                             @"<name>16th St. Mission</name>"
                             @"<abbr>16TH</abbr>"
                             @"<gtfs_latitude>37.765062</gtfs_latitude>"
                             @"<gtfs_longitude>-122.419694</gtfs_longitude>"
                             @"<address>2000 Mission Street</address>"
                             @"<city>San Francisco</city>"
                             @"<county>sanfrancisco</county>"
                             @"<state>CA</state>"
                             @"<zipcode>94110</zipcode>"
                             @"<dummy value=\"false\"/>"
                           @"</station>"
                         @"</stations>"
                       @"</root>" dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:xmlData];
    RGXMLSerializer* serializer = [[RGXMLSerializer alloc] initWithParser:parser];
    RGXMLNode* rootNode = serializer.rootNode;
    RGXMLNode* innerRoot = [rootNode valueForKey:@"root"];
    NSArray* stations = [rootNode valueForKeyPath:@"root.stations.station"];
    NSArray* parsedStations = [RGBartStation objectsFromArraySource:stations inContext:nil];
    RGBartStation* firstStation = parsedStations.firstObject;
    XCTAssert([firstStation.name isEqual:@"12th St. Oakland City Center"]);
    XCTAssert([firstStation.abbr isEqual:@"12TH"]);
    XCTAssert([firstStation.address isEqual:@"1245 Broadway"]);
    XCTAssert(parsedStations.count == 2);
    XCTAssert(innerRoot == rootNode.childNodes.firstObject);
    XCTAssert([[(RGXMLNode*)[innerRoot valueForKey:@"uri"] innerXML] isEqual:@"http://api.bart.gov/api/stn.aspx?cmd=stns"]);
    XCTAssert([[innerRoot valueForKey:@"uri"] valueForKey:kRGInnerXMLKey]);
}


#pragma mark - objectsFromArraySource:inContext:
- (void) testArraySourceNormal {
    NSArray* output = [RGTestObject2 objectsFromArraySource:@[
                                                              @{ RG_STRING_SEL(stringProperty) : @"abcd" },
                                                              @{ RG_STRING_SEL(numberProperty) : @2 }
                                                              ] inContext:nil];
    XCTAssert([[output.firstObject stringProperty] isEqual:@"abcd"]);
    XCTAssert([output.firstObject numberProperty] == nil);
    XCTAssert([output.lastObject stringProperty] == nil);
    XCTAssert([[output.lastObject numberProperty] isEqual:@2]);
}

#pragma mark - objectFromDataSource:inContext NSManagedObject
- (void) testBadContext {
    XCTAssertThrows([RGTestManagedObject objectFromDataSource:nil inContext:nil]);
}

- (void) testGoodContext {
    NSEntityDescription* entity = [NSEntityDescription new];
    entity.name = NSStringFromClass([RGTestManagedObject self]);
    NSManagedObjectModel* model = [NSManagedObjectModel new];
    model.entities = @[ entity ];
    NSPersistentStoreCoordinator* store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = store;
    RGTestManagedObject* object = [RGTestManagedObject objectFromDataSource:nil inContext:context];
    XCTAssert(object != nil);
}

#pragma mark - rg_initProperty:withValue:inContext: NSDate
- (void) testXMLtoDate {
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:@"date"];
    node.innerXML = @"2016-01-17T16:13:00-0800";
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(dateProperty)] withValue:node inContext:nil];
    XCTAssert(object.dateProperty.timeIntervalSince1970 == 1453075980.0);
}

- (void) testBadXMLtoDate {
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:@"date"];
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(dateProperty)] withValue:node inContext:nil];
    XCTAssert(object.dateProperty.timeIntervalSince1970 == 0.0);
}

- (void) testStringToDate {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(dateProperty)] withValue:@"2016-01-17T16:13:00-0800" inContext:nil];
    XCTAssert(object.dateProperty.timeIntervalSince1970 == 1453075980.0);
}

#pragma mark - rg_initProperty:withValue:inContext: Unknown Types
- (void) testDictionaryToSubObject {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(subObject)] withValue:@{ @"stringProperty" : @"foobar" } inContext:nil];
    XCTAssert([object.subObject.stringProperty isEqual:@"foobar"]);
}

- (void) testArrayToSubObjects {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(arrayOfSubObj)] withValue:
  @[
    @{
      kRGSerializationKey : NSStringFromClass([RGTestObject2 self]),
      RG_STRING_SEL(stringProperty) : @"foobar"
    }, @{
      kRGSerializationKey : NSStringFromClass([RGTestObject2 self]),
      RG_STRING_SEL(stringProperty) : @"baz"
    }] inContext:nil];
    XCTAssert([[object.arrayOfSubObj.firstObject stringProperty] isEqual:@"foobar"]);
    XCTAssert([[object.arrayOfSubObj.lastObject stringProperty] isEqual:@"baz"]);
}

#pragma mark - rg_initProperty:withValue:inContext: Mutable
- (void) testStringToMutableString {
    RGTestObject1* object = [RGTestObject1 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject1 rg_propertyList][RG_STRING_SEL(mutableProperty)] withValue:@"foobar" inContext:nil];
    [object.mutableProperty appendString:@"baz"];
    XCTAssert([object.mutableProperty isEqual:@"foobarbaz"]);
}

#pragma mark - rg_initProperty:withValue:inContext: with NSString
- (void) testStringToString {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(stringProperty)] withValue:@"foobar" inContext:nil];
    XCTAssert([object.stringProperty isEqual:@"foobar"]);
}

- (void) testStringToURL {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(urlProperty)] withValue:@"http://google.com" inContext:nil];
    XCTAssert([object.urlProperty isEqual:[NSURL URLWithString:@"http://google.com"]]);
}

- (void) testStringToNumber {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(numberProperty)] withValue:@"10" inContext:nil];
    XCTAssert([object.numberProperty isEqual:@10]);
}

- (void) testStringToDecimal {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(decimalProperty)] withValue:@"10.00" inContext:nil];
    XCTAssert([object.decimalProperty isEqual:[NSDecimalNumber decimalNumberWithString:@"10.00"]]);
}

- (void) testStringToValue {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(valueProperty)] withValue:@"1231" inContext:nil];
    XCTAssert([object.valueProperty isEqual:@1231]);
}

- (void) testStringToId {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(idProperty)] withValue:@"abcd" inContext:nil];
    XCTAssert([object.idProperty isEqual:@"abcd"]);
}

- (void) testStringToObject {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(objectProperty)] withValue:@"abc" inContext:nil];
    XCTAssert([object.objectProperty isEqual:@"abc"]);
}

- (void) testStringToClass {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(classProperty)] withValue:@"NSObject" inContext:nil];
    XCTAssert([object.classProperty isEqual:[NSObject class]]);
}

- (void) testStringToArray {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(arrayProperty)] withValue:@"acde" inContext:nil];
    XCTAssert(object.arrayProperty == nil);
}

- (void) testStringToDictionary {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(dictionaryProperty)] withValue:@"abcs" inContext:nil];
    XCTAssert(object.dictionaryProperty == nil);
}

#pragma mark - rg_initProperty:withValue:inContext: with NSNull
- (void) testNullToString {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(stringProperty)] withValue:[NSNull null] inContext:nil];
    XCTAssert(object.stringProperty == nil);
}

- (void) testNullToURL {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(urlProperty)] withValue:[NSNull null] inContext:nil];
    XCTAssert(object.urlProperty == nil);
}

- (void) testNullToNumber {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(numberProperty)] withValue:[NSNull null] inContext:nil];
    XCTAssert(object.numberProperty == nil);
}

- (void) testNullToDecimal {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(decimalProperty)] withValue:[NSNull null] inContext:nil];
    XCTAssert(object.decimalProperty == nil);
}

- (void) testNullToValue {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(valueProperty)] withValue:[NSNull null] inContext:nil];
    XCTAssert(object.valueProperty == nil);
}

- (void) testNullToId {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(idProperty)] withValue:[NSNull null] inContext:nil];
    XCTAssert(object.idProperty == nil);
}

- (void) testNullToObject {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(objectProperty)] withValue:[NSNull null] inContext:nil];
    XCTAssert(object.objectProperty == nil);
}

- (void) testNullToClass {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(classProperty)] withValue:[NSNull null] inContext:nil];
    XCTAssert(object.classProperty == nil);
}

- (void) testNullToArray {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(arrayProperty)] withValue:[NSNull null] inContext:nil];
    XCTAssert(object.arrayProperty == nil);
}

- (void) testNullToDictionary {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(dictionaryProperty)] withValue:[NSNull null] inContext:nil];
    XCTAssert(object.dictionaryProperty == nil);
}

- (void) testNullToPrimitive {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(intProperty)] withValue:[NSNull null] inContext:nil];
    XCTAssert(object.intProperty == 0);
}

#pragma mark - rg_initProperty:withValue:inContext: with NSArray
- (void) testArrayToString {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(stringProperty)] withValue:@[ @"abc", @"def" ] inContext:nil];
    XCTAssert([object.stringProperty isEqual:@"abc,def"]);
}

- (void) testArrayToURL {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(urlProperty)] withValue:@[ @"abc", @"def" ] inContext:nil];
    XCTAssert([object.urlProperty isEqual:[NSURL URLWithString:@"abc,def"]]);
}

- (void) testArrayToNumber {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(numberProperty)] withValue:@[ @"abc", @"def" ] inContext:nil];
    XCTAssert(object.numberProperty == nil);
}

- (void) testArrayToDecimal {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(decimalProperty)] withValue:@[ @"abc", @"def" ] inContext:nil];
    XCTAssert(object.decimalProperty == nil);
}

- (void) testArrayToValue {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(valueProperty)] withValue:@[ @"abc", @"def" ] inContext:nil];
    XCTAssert(object.valueProperty == nil);
}

- (void) testArrayToId {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(idProperty)] withValue:@[ @"abc", @"def" ] inContext:nil];
    XCTAssert([object.idProperty isEqual:(@[ @"abc", @"def" ])]);
}

- (void) testArrayToObject {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(objectProperty)] withValue:@[ @"abc", @"def" ] inContext:nil];
    XCTAssert([object.objectProperty isEqual:(@[ @"abc", @"def" ])]);
}

- (void) testArrayToClass {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(classProperty)] withValue:@[ @"abc", @"def" ] inContext:nil];
    XCTAssert(object.classProperty == nil);
}

- (void) testArrayToArray {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(arrayProperty)] withValue:@[ @"abc", @"def" ] inContext:nil];
    XCTAssert([object.arrayProperty isEqual:(@[ @"abc", @"def" ])]);
}

- (void) testArrayToDictionary {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(dictionaryProperty)] withValue:@[ @"abc", @"def" ] inContext:nil];
    XCTAssert(object.dictionaryProperty == nil);
}

#pragma mark - rg_initProperty:withValue:inContext: with NSDictionary
- (void) testDictionaryToString {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(stringProperty)] withValue:@{ @"abc" : @"def" } inContext:nil];
    XCTAssert(object.stringProperty == nil);
}

- (void) testDictionaryToURL {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(urlProperty)] withValue:@{ @"abc" : @"def" } inContext:nil];
    XCTAssert(object.urlProperty == nil);
}

- (void) testDictionaryToNumber {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(numberProperty)] withValue:@{ @"abc" : @"def" } inContext:nil];
    XCTAssert(object.numberProperty == nil);
}

- (void) testDictionaryToDecimal {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(decimalProperty)] withValue:@{ @"abc" : @"def" } inContext:nil];
    XCTAssert(object.decimalProperty == nil);
}

- (void) testDictionaryToValue {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(valueProperty)] withValue:@{ @"abc" : @"def" } inContext:nil];
    XCTAssert(object.valueProperty == nil);
}

- (void) testDictionaryToId {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(idProperty)] withValue:@{ @"abc" : @"def" } inContext:nil];
    XCTAssert([object.idProperty isEqual:(@{ @"abc" : @"def" })]);
}

- (void) testDictionaryToObject {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(objectProperty)] withValue:@{ @"abc" : @"def" } inContext:nil];
    XCTAssert([object.objectProperty isEqual:(@{ @"abc" : @"def" })]);
}

- (void) testDictionaryToClass {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(classProperty)] withValue:@{ @"abc" : @"def" } inContext:nil];
    XCTAssert(object.classProperty == nil);
}

- (void) testDictionaryToArray {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(arrayProperty)] withValue:@{ @"abc" : @"def" } inContext:nil];
    XCTAssert(object.arrayProperty == nil);
}

- (void) testDictionaryToDictionary {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(dictionaryProperty)] withValue:@{ @"abc" : @"def" } inContext:nil];
    XCTAssert([object.dictionaryProperty isEqual:(@{ @"abc" : @"def" })]);
}

#pragma mark - rg_initProperty:withValue:inContext: with NSNumber
- (void) testIntegerNumberToString {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(stringProperty)] withValue:@123 inContext:nil];
    XCTAssert([object.stringProperty isEqual:@"123"]);
}

- (void) testDoubleNumberToString {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(stringProperty)] withValue:@12.12 inContext:nil];
    XCTAssert([object.stringProperty isEqual:@"12.12"]);
}

- (void) testNumberToURL {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(urlProperty)] withValue:@12.12 inContext:nil];
    XCTAssert([object.urlProperty isEqual:[NSURL URLWithString:@"12.12"]]);
}

- (void) testNumberToNumber {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(numberProperty)] withValue:@12.12 inContext:nil];
    XCTAssert([object.numberProperty isEqual:@12.12]);
}

- (void) testNumberToDecimal {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(decimalProperty)] withValue:@12.12 inContext:nil];
    XCTAssert([object.decimalProperty isEqual:[NSDecimalNumber decimalNumberWithString:@"12.12"]]);
}

- (void) testNumberToValue {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(valueProperty)] withValue:@12.12 inContext:nil];
    XCTAssert([object.valueProperty isEqual:@12.12]);
}

- (void) testNumberToId {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(idProperty)] withValue:@12.12 inContext:nil];
    XCTAssert([object.idProperty isEqual:@12.12]);
}

- (void) testNumberToObject {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(objectProperty)] withValue:@12.12 inContext:nil];
    XCTAssert([object.objectProperty isEqual:@12.12]);
}

- (void) testNumberToClass {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(classProperty)] withValue:@12.12 inContext:nil];
    XCTAssert(object.classProperty == nil);
}

- (void) testNumberToArray {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(arrayProperty)] withValue:@12.12 inContext:nil];
    XCTAssert(object.arrayProperty == nil);
}

- (void) testNumberToDictionary {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(dictionaryProperty)] withValue:@12.12 inContext:nil];
    XCTAssert(object.dictionaryProperty == nil);
}

#pragma mark - rg_initProperty:withValue:inContext: with nil
- (void) testNilToString {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(stringProperty)] withValue:nil inContext:nil];
    XCTAssert(object.stringProperty == nil);
}

- (void) testNilToURL {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(urlProperty)] withValue:nil inContext:nil];
    XCTAssert(object.urlProperty == nil);
}

- (void) testNilsToNumber {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(numberProperty)] withValue:nil inContext:nil];
    XCTAssert(object.numberProperty == nil);
}

- (void) testNilToDecimal {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(decimalProperty)] withValue:nil inContext:nil];
    XCTAssert(object.decimalProperty == nil);
}

- (void) testNilToValue {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(valueProperty)] withValue:nil inContext:nil];
    XCTAssert(object.valueProperty == nil);
}

- (void) testNilToId {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(idProperty)] withValue:nil inContext:nil];
    XCTAssert(object.idProperty == nil);
}

- (void) testNilToObject {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(objectProperty)] withValue:nil inContext:nil];
    XCTAssert(object.objectProperty == nil);
}

- (void) testNilToClass {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(classProperty)] withValue:nil inContext:nil];
    XCTAssert(object.classProperty == nil);
}

- (void) testNilToArray {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(arrayProperty)] withValue:nil inContext:nil];
    XCTAssert(object.arrayProperty == nil);
}

- (void) testNilToDictionary {
    RGTestObject2* object = [RGTestObject2 new];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(dictionaryProperty)] withValue:nil inContext:nil];
    XCTAssert(object.dictionaryProperty == nil);
}

#pragma mark - rg_initProperty:withValue:inContext: with RGXMLNode
- (void) testNodeToString {
    RGTestObject2* object = [RGTestObject2 new];
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:@""];
    node.innerXML = @"a string";
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(stringProperty)] withValue:node inContext:nil];
    XCTAssert([object.stringProperty isEqual:@"a string"]);
}

- (void) testNodeToURL {
    RGTestObject2* object = [RGTestObject2 new];
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:@""];
    node.innerXML = @"http://google.com";
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(urlProperty)] withValue:node inContext:nil];
    XCTAssert([object.urlProperty isEqual:[NSURL URLWithString:@"http://google.com"]]);
}

- (void) testNodeToNumber {
    RGTestObject2* object = [RGTestObject2 new];
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:@""];
    node.innerXML = @"2";
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(numberProperty)] withValue:node inContext:nil];
    XCTAssert([object.numberProperty isEqual:@2]);
}

- (void) testNodeToDecimal {
    RGTestObject2* object = [RGTestObject2 new];
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:@""];
    node.innerXML = @"2.00";
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(decimalProperty)] withValue:node inContext:nil];
    XCTAssert([object.decimalProperty isEqual:[NSDecimalNumber decimalNumberWithString:@"2.00"]]);
}

- (void) testNodeToValue {
    RGTestObject2* object = [RGTestObject2 new];
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:@""];
    node.innerXML = @"2";
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(valueProperty)] withValue:node inContext:nil];
    XCTAssert([object.valueProperty isEqual:@2]);
}

- (void) testNodeToId {
    RGTestObject2* object = [RGTestObject2 new];
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:@""];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(idProperty)] withValue:node inContext:nil];
    XCTAssert(object.idProperty == node);
}

- (void) testNodeToObject {
    RGTestObject2* object = [RGTestObject2 new];
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:@""];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(objectProperty)] withValue:node inContext:nil];
    XCTAssert(object.objectProperty == node);
}

- (void) testNodeToClass {
    RGTestObject2* object = [RGTestObject2 new];
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:@""];
    node.innerXML = @"NSObject";
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(classProperty)] withValue:node inContext:nil];
    XCTAssert(object.classProperty == [NSObject class]);
}

- (void) testNodeToArray {
    RGTestObject2* object = [RGTestObject2 new];
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:@""];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(arrayProperty)] withValue:node inContext:nil];
    XCTAssert([object.arrayProperty isEqual:(@[])]);
}

- (void) testNodeToDictionary {
    RGTestObject2* object = [RGTestObject2 new];
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:@"name1"];
    node.attributes[@"name2"] = @"value2";
    node.innerXML = @"value1";
    RGXMLNode* childNode = [[RGXMLNode alloc] initWithName:@"child"];
    [node addChildNode:childNode];
    [object rg_initProperty:(id RG_SUFFIX_NONNULL)[RGTestObject2 rg_propertyList][RG_STRING_SEL(dictionaryProperty)] withValue:node inContext:nil];
    XCTAssert([object.dictionaryProperty isEqual:(@{ kRGInnerXMLKey : @"value1", @"child" : @{}, @"name2" : @"value2" })]);
}

#pragma mark - objectFromDataSource:
- (void) testStringProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ RG_STRING_SEL(stringProperty) : @"foobar" } inContext:nil];
    XCTAssert([object.stringProperty isEqual:@"foobar"]);
}

- (void) testURLProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ RG_STRING_SEL(urlProperty) : @"http://google.com" } inContext:nil];
    XCTAssert([object.urlProperty isEqual:[NSURL URLWithString:@"http://google.com"]]);
}

- (void) testNumberProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ RG_STRING_SEL(numberProperty) : @1 } inContext:nil];
    XCTAssert([object.numberProperty isEqual:@1]);
}

- (void) testDecimalProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ RG_STRING_SEL(decimalProperty) : @"10.0" } inContext:nil];
    XCTAssert([object.decimalProperty isEqual:[NSDecimalNumber decimalNumberWithString:@"10.0"]]);
}

- (void) testValueProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ RG_STRING_SEL(valueProperty) : @1 } inContext:nil];
    XCTAssert([object.valueProperty isEqual:@1]);
}

- (void) testIdProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ RG_STRING_SEL(idProperty) : @"foobar" } inContext:nil];
    XCTAssert([object.idProperty isEqual:@"foobar"]);
}

- (void) testObjectProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ RG_STRING_SEL(objectProperty) : @"123" } inContext:nil];
    XCTAssert([object.objectProperty isEqual:@"123"]);
}

- (void) testClassProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ RG_STRING_SEL(classProperty) : @"NSObject" } inContext:nil ];
    XCTAssert([object.classProperty isEqual:[NSObject class]]);
}

- (void) testArrayProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ RG_STRING_SEL(arrayProperty) : @[ @"foo", @"bar" ] } inContext:nil];
    XCTAssert([object.arrayProperty isEqual:(@[ @"foo", @"bar" ])]);
}

- (void) testDictionaryProperty {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:@{ RG_STRING_SEL(dictionaryProperty) : @{ @"foo" : @"bar" } } inContext:nil];
    XCTAssert([object.dictionaryProperty isEqual:(@{ @"foo" : @"bar" })]);
}

SPEC_END
