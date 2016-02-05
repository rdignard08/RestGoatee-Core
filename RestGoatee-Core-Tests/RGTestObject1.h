/* Copyright (c) 02/04/2016, Ryan Dignard
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

@interface RGTestObject1 : NSObject

@property (nonatomic, strong) NSString* stringProperty;
@property (nonatomic, strong) NSMutableString* mutableProperty;
@property (nonatomic, strong) NSURL* urlProperty;
@property (nonatomic, strong) NSNumber* numberProperty;
@property (nonatomic, strong) NSDecimalNumber* decimalProperty;
@property (nonatomic, strong) NSValue* valueProperty;
@property (nonatomic, strong) id idProperty;
@property (nonatomic, strong) Class classProperty;
@property (nonatomic, strong) NSArray* arrayProperty;
@property (nonatomic, strong) NSDictionary* dictionaryProperty;
@property (nonatomic, assign) uint64_t longProperty;
@property (nonatomic, assign) double doubleProperty;
@property (nonatomic, assign) NSRange rangeProperty;

@end
