/* Copyright (c) 02/05/2015, Ryan Dignard
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

@interface RGXMLSerializer () <NSXMLParserDelegate>

@property RG_NULLABLE_PROPERTY(nonatomic, weak) RGXMLNode* currentNode;
@property RG_NULL_RESETTABLE_PROPERTY(nonatomic, strong) NSMutableString* currentString;
@property RG_NULL_RESETTABLE_PROPERTY(nonatomic, strong, readwrite) RGXMLNode* rootNode;

@end

@implementation RGXMLSerializer

- (RG_PREFIX_NONNULL instancetype) init {
    return [self initWithParser:nil];
}

- (RG_PREFIX_NONNULL instancetype) initWithParser:(RG_PREFIX_NULLABLE NSXMLParser*)parser {
    self = [super init];
    self.parser = parser;
    return self;
}

- (RG_PREFIX_NONNULL RGXMLNode*) rootNode {
    if (!_rootNode) {
        _rootNode = [[RGXMLNode alloc] initWithName:kRGXMLRootNodeKey];
        self.currentNode = _rootNode;
#ifdef DEBUG
        BOOL parseResult =
#endif 
        [self.parser parse];
#ifdef DEBUG
        NSAssert(!self.parser || parseResult, @"XML Parsing failed");
#endif
    }
    return _rootNode;
}

- (RG_PREFIX_NONNULL NSMutableString*) currentString {
    if (!_currentString) {
        _currentString = [NSMutableString new];
    }
    return _currentString;
}

- (void) setParser:(RG_PREFIX_NULLABLE NSXMLParser*)parser {
    if (_parser != parser) {
        self.rootNode = nil;
        _parser = parser;
        _parser.delegate = self;
    }
}

#pragma mark - NSXMLParserDelegate
- (void) parser:(RG_PREFIX_NONNULL __unused id)parser
didStartElement:(RG_PREFIX_NONNULL NSString*)elementName
   namespaceURI:(RG_PREFIX_NULLABLE __unused id)namespaceURI
  qualifiedName:(RG_PREFIX_NULLABLE __unused id)qName
     attributes:(RG_PREFIX_NONNULL NSDictionary*)attributes {
    RGXMLNode* node = [[RGXMLNode alloc] initWithName:elementName];
    [node.attributes addEntriesFromDictionary:attributes];
    RGXMLNode* strongNode = self.currentNode;
    [strongNode addChildNode:node];
    self.currentNode = node;
}

- (void) parser:(RG_PREFIX_NONNULL __unused id)parser foundCharacters:(RG_PREFIX_NONNULL NSString*)string {
    [self.currentString appendString:string];
}

- (void) parser:(RG_PREFIX_NONNULL __unused id)parser
  didEndElement:(RG_PREFIX_NONNULL __unused NSString*)elementName
   namespaceURI:(RG_PREFIX_NULLABLE __unused id)namespaceURI
  qualifiedName:(RG_PREFIX_NULLABLE __unused id)qName {
    RGXMLNode* strongNode = self.currentNode;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wused-but-marked-unused"
    NSAssert([elementName isEqual:strongNode.name], @"Malformed XML");
#pragma clang diagnostic pop
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
    strongNode.innerXML = self->_currentString; /* intentionally using the ivar so that if nil, nil goes to innerXML */
#pragma clang diagnostic pop
    
    self.currentString = nil;
    self.currentNode = strongNode.parentNode; /* move up the parse tree */
}

- (void) parser:(RG_PREFIX_NONNULL __unused id)parser foundCDATA:(RG_PREFIX_NONNULL NSData*)CDATABlock {
    NSString* stringValue = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    NSAssert(stringValue, @"Malformed XML, CDATA block not valid UTF-8");
    [self.currentString appendString:stringValue];
}

@end
