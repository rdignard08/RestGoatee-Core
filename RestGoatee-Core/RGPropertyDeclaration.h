/* Copyright (c) 01/21/2016, Ryan Dignard
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

#import "RGConstants.h"

/**
 @brief Forward declaration from objc/runtime.h so the runtime doesn't appear in the public headers.
 */
typedef struct objc_property* rg_property;

/**
 @brief An object that encapsulates a property declaration, and enables object based introspection of a class.
   It is a programmer error to invoke `-init`.
 */
@interface RGPropertyDeclaration : NSObject

/**
 @brief The name of the property.
 */
@property RG_NONNULL_PROPERTY(nonatomic, strong, readonly) NSString* name;

/**
 @brief The name of the property as used for key resolution.
 */
@property RG_NONNULL_PROPERTY(nonatomic, strong, readonly) NSString* canonicalName;

/**
 @brief A `Class` object, an instance of which can contain the value of this property.
   Primitive properties use `NSNumber` by default.
 */
@property RG_NONNULL_PROPERTY(nonatomic, strong, readonly) Class type;

/**
 @brief The memory management semantics of the property.  The default is `assign` (`kRGPropertyAssign`).
 */
@property (nonatomic, assign, readonly) RGStorageSemantics storageSemantics;

/**
 @brief Whether or not the property is a raw type (int, float, struct, union, etc.).  Default is `NO`.
 */
@property (nonatomic, assign, readonly) BOOL isPrimitive;

/**
 @brief `YES` if the declared property is of type `float`, `double`, `long double`.  `NSNumber` excluded.
 */
@property (nonatomic, assign, readonly) BOOL isFloatingPoint;

/**
 @brief `YES` if the declared property is of type `char`, `short`, `int`, `long`, `long long`, 
 */
@property (nonatomic, assign, readonly) BOOL isIntegral;

/**
 @brief Whether or not the property is modifiable.  The default is `NO`.
 */
@property (nonatomic, assign, readonly) BOOL readOnly;

/**
 @brief The designated initializer; it is a programmer error to invoke `-init`.
 @param property the property structure to be used in the construction of this object.
 */
- (RG_PREFIX_NONNULL instancetype) initWithProperty:(RG_PREFIX_NONNULL rg_property)property NS_DESIGNATED_INITIALIZER;

/**
 @brief The `NSObject` designated initializer.
 @warning Do not invoke this method.
 */
- (RG_PREFIX_NULLABLE instancetype) init NS_DESIGNATED_INITIALIZER;

@end
