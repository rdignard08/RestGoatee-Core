/* Copyright (c) 10/18/2015, Ryan Dignard
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

#import "RGXMLSerializer.h"
#import "RestGoatee-Core.h"

CLASS_SPEC(RGXMLSerializer)

- (void) testInit {
    XCTAssertNoThrow([RGXMLSerializer new]);
}

- (void) testXMLDeserialize {
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:(NSData* RG_SUFFIX_NONNULL)[@"<xml><child1 attribute=\"value\"></child1><child2>some data</child2><child1><child4/></child1></xml>" dataUsingEncoding:NSUTF8StringEncoding]];
    RGXMLSerializer* serializer = [[RGXMLSerializer alloc] initWithParser:parser];
    RGXMLNode* rootNode = serializer.rootNode.childNodes.firstObject;
    XCTAssert([rootNode.name isEqual:@"xml"]);
    XCTAssert(rootNode.childNodes.count == 3);
    XCTAssert([[rootNode.childNodes.firstObject valueForKey:@"attribute"] isEqual:@"value"]);
    XCTAssert([(NSArray*)[rootNode childrenNamed:@"child1"] count] == 2);
}

- (void) testXMLFailure {
    RGXMLSerializer* serializer = [[RGXMLSerializer alloc] initWithParser:nil];
    XCTAssert(serializer.rootNode.childNodes.count == 0);
}

- (void) testCDATA {
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:(NSData* RG_SUFFIX_NONNULL)[@"<xml><child1><![CDATA[abcdefg]]></child1></xml>" dataUsingEncoding:NSUTF8StringEncoding]];
    RGXMLSerializer* serializer = [[RGXMLSerializer alloc] initWithParser:parser];
    RGXMLNode* rootNode = serializer.rootNode.childNodes.firstObject;
    XCTAssert([rootNode.name isEqual:@"xml"]);
    XCTAssert(rootNode.childNodes.count == 1);
    XCTAssert([[rootNode.childNodes.firstObject innerXML] isEqual:@"abcdefg"]);
}

SPEC_END
