/* Copyright (c) 06/10/2014, Ryan Dignard
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
#import "NSObject+RGSharedImpl.h"

@interface NSObject (RGForwardDeclarations) <RGDeserializable>

+ (RG_PREFIX_NONNULL id) insertNewObjectForEntityForName:(RG_PREFIX_NONNULL NSString*)entityName
                                  inManagedObjectContext:(RG_PREFIX_NONNULL NSManagedObjectContext*)context;

@end

@implementation NSObject (RGDeserialization)

+ (RG_PREFIX_NONNULL NSMutableArray RG_GENERIC(__kindof NSObject*) *)
    objectsFromArraySource:(RG_PREFIX_NULLABLE id<NSFastEnumeration>)source
                 inContext:(RG_PREFIX_NULLABLE NSManagedObjectContext*)context {
    NSMutableArray RG_GENERIC(__kindof NSObject*) * objects = [NSMutableArray new];
    for (id<RGDataSource> object in source) {
        if (rg_isDataSourceClass([object class])) {
            [objects addObject:[self objectFromDataSource:object inContext:context]];
        }
    }
    return objects;
}

+ (RG_PREFIX_NONNULL instancetype) objectFromDataSource:(RG_PREFIX_NULLABLE id<RGDataSource>)source
                                              inContext:(RG_PREFIX_NULLABLE NSManagedObjectContext*)context {
    NSObject<RGDeserializable>* ret;
    if ([self isSubclassOfClass:kRGNSManagedObject]) {
        NSAssert(context, @"A subclass of NSManagedObject must be created within a valid NSManagedObjectContext.");
        NSManagedObjectContext* RG_SUFFIX_NONNULL validContext = (id RG_SUFFIX_NONNULL)context;
        ret = [kRGNSEntityDescClass insertNewObjectForEntityForName:NSStringFromClass(self)
                                             inManagedObjectContext:validContext];
    } else {
        ret = [self new];
    }
    return [ret extendWith:source inContext:context];
}

- (RG_PREFIX_NONNULL instancetype) extendWith:(RG_PREFIX_NULLABLE id<RGDataSource>)source
                                    inContext:(RG_PREFIX_NULLABLE NSManagedObjectContext*)context {
    
    NSDictionary* overrides = nil;
    if ([[self class] respondsToSelector:@selector(overrideKeysForMapping)]) {
        overrides = [[self class] overrideKeysForMapping];
    }
    NSDictionary* properties = [[self class] rg_propertyList];
    NSDictionary* canonicals = [[self class] rg_canonicalPropertyList];
    /* for each piece of data I have; if there's an override: initialize literally; otherwise initialize canonically */
    for (NSString* key in source) {
        id value = [source valueForKeyPath:key];
        NSString* override = overrides[key];
        RGPropertyDeclaration* target = override ? properties[override] : canonicals[rg_canonical_form(key.UTF8String)];
        /* ask if there's a custom implementation, if not proceed to the rules */
        if (target && value &&
            (![self respondsToSelector:@selector(shouldTransformValue:forProperty:inContext:)] ||
            [self shouldTransformValue:value forProperty:target.name inContext:context])) {
            [self rg_initProperty:target withValue:value inContext:context];
        }
    }
    return self;
}

/**
 This method can be considered at a high level to be performing `self.key = value`.  It inserts type coercion where
   appropriate, and optionally allows the object to override the default behavior at the property level.
 
 JSON types when deserialized from NSData are: NSNull, NSNumber (number or boolean), NSString, NSArray, NSDictionary.
 RGXMLNode is odd, but it can be used as nil, NSString, NSDictionary, or NSArray where required.
 */
- (void) rg_initProperty:(RG_PREFIX_NONNULL RGPropertyDeclaration*)property
               withValue:(RG_PREFIX_NONNULL id)value
               inContext:(RG_PREFIX_NULLABLE id)context {
    NSString* key = property.name;
    /* If the array we're given contains objects which we can create, create those too */
    id target = [value isKindOfClass:[NSArray self]] ? rg_unpack_array(value, context) : value;
    
    if (rg_isStringInitObject(property.type)) {
        [self rg_initStringProp:property withValue:target];
    } else if (rg_isCollectionObject(property.type)) {
        [self rg_initArrayProp:property withValue:target];
    } else if ([property.type isSubclassOfClass:[NSDictionary self]]) {
        [self rg_initDictProp:property withValue:target];
    } else if ([property.type isSubclassOfClass:[NSValue self]]) {
        [self rg_initValueProp:property withValue:target];
    } else if (rg_isMetaClassObject(property.type)) {
        [self rg_initClassProp:property withValue:target];
    } else if ([property.type isSubclassOfClass:[NSDate self]]) {
        [self rg_initDateProp:property withValue:target];
    } else if ([target isKindOfClass:property.type]) {  /* If already a subclass theres no reason to coerce it */
        [self setValue:target forKey:key];
    } else if ([target isKindOfClass:[NSDictionary self]] || [target isKindOfClass:[RGXMLNode self]]) {
        /* lhs is some kind of user defined object, since the source has keys, but doesn't match NSDictionary */
        [self setValue:[property.type objectFromDataSource:target inContext:context] forKey:key];
    }
#ifdef DEBUG
    [self valueForKey:key] ? RG_VOID_NOOP : RGLog(@"FAIL: initialization of property %@ on type %@", key, [self class]);
#endif
}

- (void) rg_initStringProp:(RG_PREFIX_NONNULL RGPropertyDeclaration*)property withValue:(RG_PREFIX_NONNULL id)value {
    NSAssert([property.type instancesRespondToSelector:@selector(initWithString:)], @"Wrong initializer");
    NSString* source = rg_to_string(value);
    if (source) {
        [self setValue:[[property.type alloc] initWithString:source] forKey:property.name];
    }
}

- (void) rg_initClassProp:(RG_PREFIX_NONNULL RGPropertyDeclaration*)propery withValue:(RG_PREFIX_NONNULL id)value {
    NSString* source = rg_to_string(value);
    if (source) {
        [self setValue:NSClassFromString(source) forKey:propery.name];
    }
}

- (void) rg_initDateProp:(RG_PREFIX_NONNULL RGPropertyDeclaration*)property withValue:(RG_PREFIX_NONNULL id)value {
    NSString* source = rg_to_string(value);
    if (source) {
        NSString* dateFormat;
        if ([[self class] respondsToSelector:@selector(dateFormatForProperty:)]) {
            dateFormat = [[self class] dateFormatForProperty:property.name];
        }
        NSDateFormatter* dateFormatter = rg_threadsafe_formatter();
        if (dateFormat) {
            dateFormatter.dateFormat = dateFormat;
            [self setValue:[dateFormatter dateFromString:source] forKey:property.name];
            return; /* Let's not second-guess the developer... */
        }
        for (NSString* predefinedFormat in rg_date_formats()) {
            dateFormatter.dateFormat = predefinedFormat;
            NSDate* date = [dateFormatter dateFromString:source];
            if (date) {
                [self setValue:date forKey:property.name];
                return;
            }
        }
    }
}

- (void) rg_initArrayProp:(RG_PREFIX_NONNULL RGPropertyDeclaration*)property withValue:(RG_PREFIX_NONNULL id)value {
    NSAssert([property.type instancesRespondToSelector:@selector(initWithArray:)], @"Wrong initializer");
    NSArray* source = [value isKindOfClass:[NSArray self]] ? value : nil;
    if ([value isKindOfClass:[RGXMLNode self]]) {
        source = [value childNodes];
    }
    if (source) {
        [self setValue:[[property.type alloc] initWithArray:source] forKey:property.name];
    }
}

- (void) rg_initDictProp:(RG_PREFIX_NONNULL RGPropertyDeclaration*)property withValue:(RG_PREFIX_NONNULL id)value {
    NSAssert([property.type instancesRespondToSelector:@selector(initWithDictionary:)], @"Wrong initializer");
    NSDictionary* source = [value isKindOfClass:[NSDictionary self]] ? value : nil;
    if ([value isKindOfClass:[RGXMLNode self]]) {
        source = [(RGXMLNode*)value dictionaryRepresentation];
    }
    if (source) {
        [self setValue:[[property.type alloc] initWithDictionary:source] forKey:property.name];
    }
}

- (void) rg_initValueProp:(RG_PREFIX_NONNULL RGPropertyDeclaration*)property withValue:(RG_PREFIX_NONNULL id)value {
    NSNumber* source = [value isKindOfClass:[NSNumber self]] ? value : nil;
    NSString* stringValue = rg_to_string(value);
    if (stringValue) {
        if (property.isIntegral || property.isFloatingPoint || !property.isPrimitive) {
            source = [rg_number_formatter() numberFromString:stringValue] ?: (property.isPrimitive ? @0 : nil);
        } else {
            RGLog(@"Unsupported Destination for NSString: %@ on %@", property.name, [self class]);
            return;
        }
    }
    if (source) {
        [self setValue:source forKey:property.name];
    }
}

@end
