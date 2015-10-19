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

#import "RGDataSourceProtocol.h"
#import "RGTestObject2.h"

@interface RGTestObject3 : RGTestObject2 <RGDataSourceProtocol>

@end

@implementation RGTestObject3

- (prefix_nullable id) valueForKeyPath:(prefix_nonnull NSString*)string {
    if ([string isEqual:@"stringProperty"]) {
        return @"abd";
    } else if ([string isEqual:@"idProperty"]) {
        return [NSObject class];
    }
    return nil;
}

- (prefix_nonnull NSArray*) allKeys {
    return @[ @"stringProperty", @"idProperty" ];
}

- (NSUInteger) countByEnumeratingWithState:(prefix_nonnull NSFastEnumerationState*)state objects:(__unsafe_unretained id[])buffer count:(NSUInteger)len {
    return [self.allKeys countByEnumeratingWithState:state objects:buffer count:len];
}

- (prefix_nullable id) valueForKey:(prefix_nonnull NSString*)key {
    return [self valueForKeyPath:key];
}

@end

CLASS_SPEC(RGDataSourceProtocol)

- (void)testDataSource {
    RGTestObject2* object = [RGTestObject2 objectFromDataSource:[RGTestObject3 new]];
    XCTAssert([object.stringProperty isEqual:@"abd"]);
    XCTAssert([object.idProperty isEqual:[NSObject class]]);
}

SPEC_END
