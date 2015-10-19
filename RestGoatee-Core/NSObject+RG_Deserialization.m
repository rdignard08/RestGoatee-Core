/* Copyright (c) 6/10/14, Ryan Dignard
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
#import "NSObject+RG_SharedImpl.h"
#import "RGDeserializationDelegate.h"

FILE_START

@interface NSObject (RGForwardDeclarations)

+ (prefix_nonnull id) insertNewObjectForEntityForName:(prefix_nonnull NSString*)entityName inManagedObjectContext:(prefix_nonnull id)context;

@end

NSArray* rg_unpackArray(NSArray* json, id context) {
    NSMutableArray* ret = [NSMutableArray array];
    for (__strong id obj in json) {
        if (rg_isDataSourceClass([obj class])) {
            Class objectClass = NSClassFromString(obj[kRGSerializationKey]);
            obj = rg_isDataSourceClass(objectClass) || !objectClass ? obj : [objectClass objectFromDataSource:obj inContext:context];
        }
        [ret addObject:obj];
    }
    return [ret copy];
}

@implementation NSObject (RG_Deserialization)

+ (prefix_nonnull NSArray*) objectsFromArraySource:(prefix_nullable id<NSFastEnumeration>)source {
    return [self objectsFromArraySource:source inContext:nil];
}

+ (prefix_nonnull NSArray*) objectsFromArraySource:(prefix_nullable id<NSFastEnumeration>)source inContext:(prefix_nullable NSManagedObjectContext*)context {
    NSMutableArray* objects = [NSMutableArray new];
    for (NSDictionary* object in source) {
        if (rg_isDataSourceClass([object class])) {
            [objects addObject:[self objectFromDataSource:object inContext:context]];
        }
    }
    return [objects copy];
}

+ (prefix_nonnull instancetype) objectFromDataSource:(prefix_nullable id<RGDataSourceProtocol>)source {
    if ([self isSubclassOfClass:rg_sNSManagedObject]) {
        [NSException raise:NSGenericException format:@"Managed object subclasses must be initialized within a managed object context.  Use +objectFromJSON:inContext:"];
    }
    return [self objectFromDataSource:source inContext:nil];
}

+ (prefix_nonnull instancetype) objectFromDataSource:(prefix_nullable id<RGDataSourceProtocol>)source inContext:(prefix_nullable NSManagedObjectContext*)context {
    NSObject<RGDeserializationDelegate>* ret;
    if ([self isSubclassOfClass:rg_sNSManagedObject]) {
        context ? VOID_NOOP : [NSException raise:NSGenericException format:@"A subclass of NSManagedObject must be created within a valid NSManagedObjectContext."];
        ret = [rg_sNSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];
    } else {
        ret = [self new];
    }
    Class returnType = [ret class];
    NSDictionary* overrides = [returnType respondsToSelector:@selector(overrideKeysForMapping)] ? [returnType overrideKeysForMapping] : nil;
    NSMutableArray* intializedProperties = [NSMutableArray new];
    for (NSString* key in source) {
        /* default behavior self.key = json[key] (each `key` is compared in canonical form) */
        if (overrides[key]) continue;
        [ret rg_initCanonically:key withValue:source[key] inContext:context];
        [intializedProperties addObject:key.canonicalValue];
    }
    for (NSString* key in overrides) { /* The developer provided an override keypath */
        if ([intializedProperties containsObject:key.canonicalValue]) continue;
        id value = [source valueForKeyPath:key];
        if (!value) continue; // nil should not be pushed into the property
        @try {
            [ret rg_initProperty:overrides[key] withValue:value inContext:context];
            [intializedProperties addObject:key.canonicalValue];
        }
        @catch (NSException* e) { /* Should this fail the property is left alone */
            RGLog(@"initializing property %@ on type %@ failed: %@", overrides[key], [ret class], e);
        }
    }
    return ret;
}

- (void) rg_initCanonically:(prefix_nonnull NSString*)key withValue:(prefix_nullable id)value inContext:(prefix_nullable id)context {
    NSUInteger index = [self.__property_list__[kRGPropertyCanonicalName] indexOfObject:key.canonicalValue];
    if (index != NSNotFound) {
        if (topClassDeclaringPropertyNamed([self class], key.canonicalValue) != [NSObject class]) {
            @try {
                [self rg_initProperty:self.__property_list__[index][kRGPropertyName] withValue:value inContext:context];
            } @catch (NSException* e) { /* Should this fail the property is left alone */
                RGLog(@"initializing property %@ on type %@ failed: %@", self.__property_list__[index][kRGPropertyName], [self class], e);
            }
        }
    }
}

/**
 @abstract Coerces the JSONValue of the right-hand-side to match the type of the left-hand-side (rhs/lhs from this: self.property = jsonValue).
 
 @discussion JSON types when deserialized from NSData are: NSNull, NSNumber (number or boolean), NSString, NSArray, NSDictionary
 */
- (void) rg_initProperty:(prefix_nonnull NSString*)key withValue:(prefix_nullable id)value inContext:(prefix_nullable id)context {
    static NSDateFormatter* dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
    });
    
    /* first ask if there's a custom implementation */
    if ([self respondsToSelector:@selector(shouldTransformValue:forProperty:inContext:)]) {
        if (![(id<RGDeserializationDelegate>)self shouldTransformValue:value forProperty:key inContext:context]) {
            return;
        }
    }
    
    /* Can't initialize the value of a property if the property doesn't exist */
    if ([key isKindOfClass:[NSNull class]] || [key isEqual:kRGPropertyListProperty] || ![self rg_declarationForProperty:key]) {
        return;
    }
    
    if (!value || [value isKindOfClass:[NSNull class]]) {
        self[key] = [self rg_isPrimitive:key] ? @0 : nil;
        return;
    }
    
    Class propertyType = [self rg_classForProperty:key];
    
    if ([value isKindOfClass:[NSArray class]]) { /* If the array we're given contains objects which we can create, create those too */
        value = rg_unpackArray(value, context);
    }
    
    id mutableVersion = [value respondsToSelector:@selector(mutableCopyWithZone:)] ? [value mutableCopy] : nil;
    if ([mutableVersion isMemberOfClass:propertyType]) { /* if the target is a mutable of a immutable type we already have */
        self[key] = mutableVersion;
        return;
    } /* This is the one instance where we can quickly cast down the value */
    
    if ([value isKindOfClass:propertyType]) { /* NSValue */
        self[key] = value;
        return;
    } /* If JSONValue is already a subclass of propertyType theres no reason to coerce it */
    
    /* Otherwise... this mess */
    
    if (rg_isMetaClassObject(propertyType)) { /* the property's type is Meta-class so its a reference to Class */
        self[key] = NSClassFromString([value description]);
    } else if ([propertyType isSubclassOfClass:[NSDictionary class]] && ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[RGXMLNode class]])) { /* NSDictionary */
        if ([value isKindOfClass:[RGXMLNode class]]) @throw @"Sorry this hasn't been implemented yet"; // TODO
        self[key] = [[propertyType alloc] initWithDictionary:value];
    } else if (rg_isCollectionObject(propertyType) && ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[RGXMLNode class]])) { /* NSArray, NSSet, or NSOrderedSet */
        if ([value isKindOfClass:[RGXMLNode class]]) value = [value childNodes];
        self[key] = [[propertyType alloc] initWithArray:value];
    } else if ([propertyType isSubclassOfClass:[NSDecimalNumber class]] && ([value isKindOfClass:[NSNumber class]] ||
                                                                            [value isKindOfClass:[NSString class]] ||
                                                                            [value isKindOfClass:[RGXMLNode class]])) {
        /* NSDecimalNumber, subclasses must go first */
        if ([value isKindOfClass:[RGXMLNode class]]) value = [value innerXML];
        if ([value isKindOfClass:[NSNumber class]]) value = [value stringValue];
        self[key] = [propertyType decimalNumberWithString:value];
    } else if ([propertyType isSubclassOfClass:[NSNumber class]] && ([value isKindOfClass:[NSNumber class]] ||
                                                                     [value isKindOfClass:[NSString class]] ||
                                                                     [value isKindOfClass:[RGXMLNode class]])) {
        /* NSNumber */
        if ([value isKindOfClass:[RGXMLNode class]]) value = [value innerXML];
        if ([value isKindOfClass:[NSString class]]) value = @([value doubleValue]);
        self[key] = value; /* Note: setValue: will unwrap the value if the destination is a primitive */
    } else if ([propertyType isSubclassOfClass:[NSValue class]] && ([value isKindOfClass:[NSNumber class]] ||
                                                                    [value isKindOfClass:[NSString class]] ||
                                                                    [value isKindOfClass:[RGXMLNode class]])) {
        /* NSValue */
        if ([value isKindOfClass:[RGXMLNode class]]) value = [value innerXML];
        if ([value isKindOfClass:[NSString class]]) value = @([value doubleValue]);
        self[key] = value; /* This is an NSNumber, which is a subclass of NSValue hence it's a valid assignment */
    } else if (([propertyType isSubclassOfClass:[NSString class]] || [propertyType isSubclassOfClass:[NSURL class]]) && ([value isKindOfClass:[NSNumber class]] ||
                                                                                                                         [value isKindOfClass:[NSString class]] ||
                                                                                                                         [value isKindOfClass:[RGXMLNode class]] ||
                                                                                                                         [value isKindOfClass:[NSArray class]])) {
        /* NSString, NSURL */
        if ([value isKindOfClass:[RGXMLNode class]]) value = [value innerXML];
        if ([value isKindOfClass:[NSArray class]]) value = [value componentsJoinedByString:@","];
        if ([value isKindOfClass:[NSNumber class]]) value = [value stringValue];
        self[key] = [[propertyType alloc] initWithString:value];
    } else if ([propertyType isSubclassOfClass:[NSDate class]]) { /* NSDate */
        if ([value isKindOfClass:[RGXMLNode class]]) value = [value innerXML];
        NSString* dateFormat = [[self class] respondsToSelector:@selector(dateFormatForProperty:)] ? [[self class] dateFormatForProperty:key] : nil;
        if (dateFormat) {
            dateFormatter.dateFormat = dateFormat;
            self[key] = [dateFormatter dateFromString:value];
            return; /* Let's not second-guess the developer... */
        } else {
            for (NSString* predefinedFormat in rg_dateFormats()) {
                dateFormatter.dateFormat = predefinedFormat;
                self[key] = [dateFormatter dateFromString:value];
                if (self[key]) break;
            }
        }
        
    /* At this point we've exhausted the supported foundation classes for the LHS... these handle sub-objects */
    } else if (!rg_isInlineObject(propertyType) && !rg_isCollectionObject(propertyType) && ([value isKindOfClass:[NSDictionary class]] ||
                                                                                            [value isKindOfClass:[RGXMLNode class]])) {
        /* lhs is some kind of user defined object, since the source has keys, but doesn't match NSDictionary */
        self[key] = [propertyType objectFromDataSource:value inContext:context];
    } else if ([value isKindOfClass:[NSArray class]]) { /* single entry arrays are converted to an inplace object */
        [(NSArray*)value count] > 1 ? RGLog(@"Warning, data loss on property %@ on type %@", key, [self class]) : VOID_NOOP;
        id firstValue = [value firstObject];
        if (!firstValue || [firstValue isKindOfClass:propertyType]) {
            self[key] = value;
        }
    } else if ([propertyType isSubclassOfClass:[NSObject class]] && [value isKindOfClass:propertyType]) { /* if there is literally nothing else we know about the property */
        self[key] = value;
    }
    
    self[key] ? VOID_NOOP : RGLog(@"Warning, initialization failed on property %@ on type %@", key, [self class]);
}

- (prefix_nonnull instancetype) extendWith:(prefix_nullable NSObject<RGDataSourceProtocol>*)object inContext:(prefix_nullable NSManagedObjectContext*)context {
    NSDictionary* overrides = [[self class] respondsToSelector:@selector(overrideKeysForMapping)] ? [[self class] overrideKeysForMapping] : nil;
    NSMutableArray* intializedProperties = [NSMutableArray new];
    for (NSString* key in [object rg_keys]) {
        if (overrides[key]) continue;
        [self rg_initCanonically:key withValue:object[key] inContext:context];
        [intializedProperties addObject:key.canonicalValue];
    }
    for (NSString* key in overrides) { /* The developer provided an override keypath */
        if ([intializedProperties containsObject:key.canonicalValue]) continue;
        id value = [object valueForKeyPath:key];
        if (!value && rg_isDataSourceClass([object class])) continue; // empty dictionary entry doesn't get pushed
        @try {
            [self rg_initProperty:overrides[key] withValue:value inContext:context];
            [intializedProperties addObject:[overrides[key] canonicalValue]];
        } @catch (NSException* e) { /* Should this fail the property is left alone */
            RGLog(@"initializing property %@ on type %@ failed: %@", overrides[key], [self class], e);
        }
    }
    return self;
}

- (prefix_nonnull instancetype) extendWith:(prefix_nullable NSObject<RGDataSourceProtocol>*)object {
    return [self extendWith:object inContext:nil];
}

@end

FILE_END
