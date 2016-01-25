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

#import "RGDataSource.h"
#import "RGSerializable.h"

/**
 @brief The `RGXMLNode` is the parse result of `NSXMLParser`.
 */
@interface RGXMLNode : NSObject <RGDataSource>

/**
 @brief Set when `-addChildNode:` is called.  A weak reference is made to the enclosing node.
 */
@property RG_NULLABLE_PROPERTY(nonatomic, weak, readonly) RGXMLNode* parentNode;

/**
 @brief Attributes come from `... id="123" name="cool"` and will equal @{ "id" : "123", "name" : "cool" }.  The value can be obtained through valueForKeyPath:, @"object.id", in this example.
 @discussion You may mutate the collection.
 */
@property RG_NULL_RESETTABLE_PROPERTY(nonatomic, strong) NSMutableDictionary RG_GENERIC(NSString*, NSString*) * attributes;

/**
 @brief The name of the tag.  "foobar" enclosed in angle brackets will have the value of `foobar` here.
 */
@property RG_NONNULL_PROPERTY(nonatomic, strong) NSString* name;

/**
 @brief The inner XML if any, including unwrapped CDATA.  self-closing nodes will have `nil`.  adjacent open and close tags will be the empty string.
 */
@property RG_NULLABLE_PROPERTY(nonatomic, strong) NSString* innerXML;

/**
 @brief This property contains any sub-nodes of this node.  Those sub-nodes have this node as the value of their `parentNode` property.
 @warning While this property is mutable, you must not mutate it directly.
 */
@property RG_NULL_RESETTABLE_PROPERTY(nonatomic, strong, readonly) NSMutableArray RG_GENERIC(RGXMLNode*) * childNodes;

/**
 @param name The name or identifier of this node.  Must not be `nil`.
 @return a node with the given name.  You must provide a `nonnull` name.  It is a programmer error to invoke `-init`.
 */
- (RG_PREFIX_NONNULL instancetype) initWithName:(RG_PREFIX_NONNULL NSString*)name NS_DESIGNATED_INITIALIZER;

/**
 @warning Do not invoke this method.  You must use `-initWithName:`.
 */
- (RG_PREFIX_NULLABLE instancetype) init NS_DESIGNATED_INITIALIZER;

/**
 @return the receiver and all of its children as a dictionary representation.  The `innerXML` of the node is returned on the key `kRGInnerXMLKey`.
 */
- (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(NSString*, id) *) dictionaryRepresentation;

/**
 @return either `NSMutableArray` or `nullable RGXMLNode`.  If there are multiple children with that name, the array is returned; otherwise a single node or `nil`.
 */
- (RG_PREFIX_NULLABLE id) childrenNamed:(RG_PREFIX_NULLABLE NSString*) name;

/**
 @brief Call this method to insert a new node into this object's `childNodes` property.
 */
- (void) addChildNode:(RG_PREFIX_NONNULL RGXMLNode*)node;

@end
