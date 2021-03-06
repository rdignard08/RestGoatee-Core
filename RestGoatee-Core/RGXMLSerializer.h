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

#import "RGDefines.h"

@class RGXMLNode;

/**
 @brief This class takes an `NSXMLParser*` and returns a built network of `RGXMLNode*`.  
   You may reuse an instance of this class by assigning a new `parser`.
 */
@interface RGXMLSerializer : NSObject

/**
 @brief Provide the `NSXMLParser` obtained from AFNetworking's `AFXMLParserResponseSerializer`.
 */
@property RG_NULLABLE_PROPERTY(nonatomic, strong) NSXMLParser* parser;

/**
 @brief Triggers the parsing to execute when accessed the first time.
 */
@property RG_NULL_RESETTABLE_PROPERTY(nonatomic, strong, readonly) RGXMLNode* rootNode;

/**
 @brief Designated initializer.
 @param parser the `NSXMLParser` as provided by the XML API.
 */
- (RG_PREFIX_NONNULL instancetype) initWithParser:(RG_PREFIX_NULLABLE NSXMLParser*)parser NS_DESIGNATED_INITIALIZER;

@end
