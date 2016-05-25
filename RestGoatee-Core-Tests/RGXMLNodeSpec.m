/* Copyright (c) 10/11/2015, Ryan Dignard
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

#import "RGXMLNode.h"
#import "RGConstants.h"

@implementation NSObject (RGBadInit)

- (id)override_init {
    return nil;
}

@end

/**
 Represents the data
 
 <xml>
    <child1 attribute="value"></child1>
    <child2>some data</child2>
    <child1>
        <child4/>
    </child1>
 </xml>
 */
CLASS_SPEC(RGXMLNode)

static RGXMLNode* parentNode;
static RGXMLNode* childNode1;
static RGXMLNode* childNode2;
static RGXMLNode* childNode3;
static RGXMLNode* childNode4;

- (void) setUp {
    [super setUp];
    parentNode = [[RGXMLNode alloc] initWithName:@"xml"];
    childNode1 = [[RGXMLNode alloc] initWithName:@"child1"];
    childNode1.attributes[@"attribute"] = @"value";
    childNode1.innerXML = @"";
    [parentNode addChildNode:childNode1];
    childNode2 = [[RGXMLNode alloc] initWithName:@"child2"];
    childNode2.innerXML = @"some data";
    [parentNode addChildNode:childNode2];
    childNode3 = [[RGXMLNode alloc] initWithName:@"child1"]; // same as childNode1
    [parentNode addChildNode:childNode3];
    childNode4 = [[RGXMLNode alloc] initWithName:@"child4"];
    [childNode3 addChildNode:childNode4];
}

- (void) testInit {
    XCTAssertThrows([RGXMLNode new]);
}

- (void) testBadInit {
    rg_swizzle([NSObject self], @selector(init), @selector(override_init));
    RGXMLNode* declaration = [[RGXMLNode alloc] initWithName:@"aName"];
    XCTAssert(declaration == nil);
    rg_swizzle([NSObject self], @selector(init), @selector(override_init));
}

- (void) testParentNode {
    XCTAssert(parentNode.parentNode == nil);
    XCTAssert(childNode1.parentNode == parentNode);
    XCTAssert(childNode2.parentNode == parentNode);
    XCTAssert(childNode3.parentNode == parentNode);
    XCTAssert(childNode4.parentNode == childNode3);
}

- (void) testAttributes {
    XCTAssert([childNode1.attributes[@"attribute"] isEqual:@"value"]);
    XCTAssert(childNode2.attributes != nil);
    XCTAssert(childNode2.attributes.count == 0);
    childNode1.attributes = nil;
    XCTAssert([childNode1.attributes isEqual:@{}]);
}

- (void) testName {
    XCTAssert([parentNode.name isEqual:@"xml"]);
    XCTAssert([childNode1.name isEqual:@"child1"]);
    XCTAssert([childNode2.name isEqual:@"child2"]);
}

- (void) testInnerXML {
    XCTAssert(parentNode.innerXML == nil);
    XCTAssert([childNode1.innerXML isEqual:@""]);
    XCTAssert([childNode2.innerXML isEqual:@"some data"]);
    XCTAssert(childNode3.innerXML == nil);
    XCTAssert(childNode4.innerXML == nil);
}

- (void) testChildNodes {
    XCTAssert([parentNode.childNodes isEqual:(@[ childNode1, childNode2, childNode3 ])]);
    XCTAssert(childNode1.childNodes != nil);
    XCTAssert(childNode1.childNodes.count == 0);
    XCTAssert(childNode2.childNodes != nil);
    XCTAssert(childNode2.childNodes.count == 0);
}

- (void) testDictionaryRepresentation {
    NSDictionary* representation = [parentNode dictionaryRepresentation];
    XCTAssert([representation[@"child1"] isKindOfClass:[NSArray class]]);
    XCTAssert([representation[@"child2"] isEqual:(@{ kRGInnerXMLKey : @"some data" })]);
    XCTAssert([[childNode1 dictionaryRepresentation][@"attribute"] isEqual:@"value"]);
    XCTAssert([[childNode3 dictionaryRepresentation][@"child4"] isEqual:(@{})]);
    XCTAssert([[childNode4 dictionaryRepresentation] isEqual:(@{})]);
}

- (void) testChildrenNamed {
    XCTAssert([[parentNode childrenNamed:@"child1"] isEqual:(@[ childNode1, childNode3 ])]);
    XCTAssert([parentNode childrenNamed:@"child2"] == childNode2);
    XCTAssert([parentNode childrenNamed:@"child4"] == nil);
    XCTAssert([childNode3 childrenNamed:@"child4"] == childNode4);
}

- (void) testAddChildNode {
    RGXMLNode* childNode5 = [[RGXMLNode alloc] initWithName:@"child5"];
    [parentNode addChildNode:childNode5];
    XCTAssert([parentNode childrenNamed:@"child5"] == childNode5);
    XCTAssert(childNode5.parentNode == parentNode);
    XCTAssert([parentNode.childNodes isEqual:(@[ childNode1, childNode2, childNode3, childNode5 ])]);
}

SPEC_END
