
#import "RGXMLNode.h"

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
SPEC(RGXMLNode)

static RGXMLNode* parentNode;
static RGXMLNode* childNode1;
static RGXMLNode* childNode2;
static RGXMLNode* childNode3;
static RGXMLNode* childNode4;

- (void)setUp {
    [super setUp];
    parentNode = [RGXMLNode new];
    parentNode.name = @"xml";
    childNode1 = [RGXMLNode new];
    childNode1.name = @"child1";
    childNode1.attributes[@"attribute"] = @"value";
    childNode1.innerXML = @"";
    [parentNode addChildNode:childNode1];
    childNode2 = [RGXMLNode new];
    childNode2.name = @"child2";
    childNode2.innerXML = @"some data";
    [parentNode addChildNode:childNode2];
    childNode3 = [RGXMLNode new];
    childNode3.name = @"child1"; // same as childNode1
    [parentNode addChildNode:childNode3];
    childNode4 = [RGXMLNode new];
    childNode4.name = @"child4";
    [childNode3 addChildNode:childNode4];
}

- (void)testParentNode {
    XCTAssert(parentNode.parentNode == nil);
    XCTAssert(childNode1.parentNode == parentNode);
    XCTAssert(childNode2.parentNode == parentNode);
    XCTAssert(childNode3.parentNode == parentNode);
    XCTAssert(childNode4.parentNode == childNode3);
}

- (void)testAttributes {
    XCTAssert([childNode1.attributes[@"attribute"] isEqual:@"value"]);
    XCTAssert(childNode2.attributes != nil);
    XCTAssert(childNode2.attributes.count == 0);
}

- (void)testName {
    XCTAssert([parentNode.name isEqual:@"xml"]);
    XCTAssert([childNode1.name isEqual:@"child1"]);
    XCTAssert([childNode2.name isEqual:@"child2"]);
}

- (void)testInnerXML {
    XCTAssert(parentNode.innerXML == nil);
    XCTAssert([childNode1.innerXML isEqual:@""]);
    XCTAssert([childNode2.innerXML isEqual:@"some data"]);
    XCTAssert(childNode3.innerXML == nil);
    XCTAssert(childNode4.innerXML == nil);
}

- (void)testChildNodes {
    XCTAssert([parentNode.childNodes isEqual:(@[ childNode1, childNode2, childNode3 ])]);
    XCTAssert(childNode1.childNodes != nil);
    XCTAssert(childNode1.childNodes.count == 0);
    XCTAssert(childNode2.childNodes != nil);
    XCTAssert(childNode2.childNodes.count == 0);
}

- (void)testChildrenNamed {
    XCTAssert([[parentNode childrenNamed:@"child1"] isEqual:(@[ childNode1, childNode3 ])]);
    XCTAssert([parentNode childrenNamed:@"child2"] == childNode2);
    XCTAssert([parentNode childrenNamed:@"child4"] == nil);
    XCTAssert([childNode3 childrenNamed:@"child4"] == childNode4);
}

- (void)testAddChildNode {
    RGXMLNode* childNode5 = [RGXMLNode new];
    childNode5.name = @"child5";
    [parentNode addChildNode:childNode5];
    XCTAssert([parentNode childrenNamed:@"child5"] == childNode5);
    XCTAssert(childNode5.parentNode == parentNode);
    XCTAssert([parentNode.childNodes isEqual:(@[ childNode1, childNode2, childNode3, childNode5 ])]);
}

SPEC_END
