/* Copyright (c) 10/18/15, Ryan Dignard
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

#import "RGXMLNode+RGDataSourceProtocol.h"

//- (prefix_nullable id) objectForKeyedSubscript:(prefix_nonnull id<NSCopying, NSObject>)key;
//
///**
// The data source must support `dataSource[@"key"] = value`.
// */
//- (void) setObject:(prefix_nullable id)object forKeyedSubscript:(prefix_nonnull id<NSCopying, NSObject>)key;
//
///**
// The data source must support `id value = dataSource[@"foo.bar"]`.
// */
//- (prefix_nullable id) valueForKeyPath:(prefix_nonnull NSString*)string;
//
///**
// Returns an array of the keys which are present in this data source (but NOT sub data sources).
// */
//- (prefix_nonnull NSArray*) allKeys;

CATEGORY_SPEC(RGXMLNode, RGDataSourceProtocol)

- (void) setUp {
    [super setUp];
}

- (void) testObjectForKey {
    
}

SPEC_END
