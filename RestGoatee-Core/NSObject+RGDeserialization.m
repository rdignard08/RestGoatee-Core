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

@interface NSObject (RGForwardDeclarations)

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
    if ([self isSubclassOfClass:rg_NSManagedObject]) {
        NSAssert(context, @"A subclass of NSManagedObject must be created within a valid NSManagedObjectContext.");
        NSManagedObjectContext* RG_SUFFIX_NONNULL validContext = (id RG_SUFFIX_NONNULL)context;
        ret = [rg_NSEntityDescClass insertNewObjectForEntityForName:NSStringFromClass(self)
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
    NSDictionary* canonicalProperties = [[self class] rg_canonicalPropertyList];
    /* for each piece of data I have; if there's an override: initialize literally; otherwise initialize canonically */
    for (NSString* key in source) {
        id value = [source valueForKeyPath:key];
        NSAssert(value, @"This should always be true but I'm not 100%% on that");
        NSString* overrideDest = overrides[key];
        if (overrideDest) {
            [self rg_initProperty:properties[overrideDest] withValue:value inContext:context];
        } else {
            [self rg_initProperty:canonicalProperties[rg_canonical_form(key.UTF8String)]
                        withValue:value
                        inContext:context];
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
- (void) rg_initProperty:(RG_PREFIX_NULLABLE RGPropertyDeclaration*)property
               withValue:(RG_PREFIX_NONNULL id)value
               inContext:(RG_PREFIX_NULLABLE id)context {
    
    /* can't initialize a property that doesn't exist */
    if (!property) return;
    NSString* key = property.name;
    Class propertyType = property.type;
    id target = value;
    /* first ask if there's a custom implementation */
    if ([self respondsToSelector:@selector(shouldTransformValue:forProperty:inContext:)] &&
        ![(id<RGDeserializable>)self shouldTransformValue:target forProperty:key inContext:context]) {
        return;
    }
    /* null and non-existent set the property to 0 - possible optimization since init already does this */
    if (!target || [target isKindOfClass:[NSNull self]]) {
        [self setValue:property.isPrimitive ? @0 : nil forKey:key];
        return;
    }
    if ([target isKindOfClass:[NSArray self]]) { /* If the array we're given contains objects which we can create,
                                                    create those too */
        NSMutableArray RG_GENERIC(id) * ret = [NSMutableArray new];
        for (__strong id obj in target) {
            if (rg_isDataSourceClass([obj class])) {
                NSString* serializationKey = obj[kRGSerializationKey];
                if (serializationKey) {
                    Class objectClass = NSClassFromString(serializationKey);
                    if (!rg_isDataSourceClass(objectClass) && objectClass) {
                        obj = [objectClass objectFromDataSource:obj inContext:context];
                    }
                }
            }
            [ret addObject:obj];
        }
        target = ret;
    }
    /* __NSCFString -> NSMutableString -> NSString */
    id mutableVersion = [target respondsToSelector:@selector(mutableCopyWithZone:)] ? [target mutableCopy] : nil;
    if ([mutableVersion isKindOfClass:propertyType]) { /* if the target is a mutable of a immutable type we have */
        [self setValue:mutableVersion forKey:key];
        return;
    } /* This is the one instance where we can quickly cast down the value */
    
    if ([target isKindOfClass:propertyType]) { /* NSValue */
        [self setValue:target forKey:key];
        return;
    } /* If JSONValue is already a subclass of propertyType theres no reason to coerce it */
    
    /* Otherwise... this mess */
    
    if (rg_isMetaClassObject(propertyType)) { /* the property's type is Meta-class so its a reference to Class */
        if ([target isKindOfClass:[RGXMLNode self]]) {
            NSString* innerXML = [target innerXML];
            target = innerXML ?: @"";
        }
        [self setValue:NSClassFromString([target description]) forKey:key];
    } else if ([propertyType isSubclassOfClass:[NSDictionary self]] &&
               ([target isKindOfClass:[NSDictionary self]] || [target isKindOfClass:[RGXMLNode self]])) {
        /* NSDictionary */
        if ([target isKindOfClass:[RGXMLNode self]]) target = [(RGXMLNode*)target dictionaryRepresentation];
        [self setValue:[[propertyType alloc] initWithDictionary:target] forKey:key];
    } else if (rg_isCollectionObject(propertyType) &&
               ([target isKindOfClass:[NSArray self]] || [target isKindOfClass:[RGXMLNode self]])) {
        /* NSArray, NSSet, or NSOrderedSet */
        if ([target isKindOfClass:[RGXMLNode self]]) target = [target childNodes];
        [self setValue:[[propertyType alloc] initWithArray:target] forKey:key];
    } else if ([propertyType isSubclassOfClass:[NSDecimalNumber self]] && ([target isKindOfClass:[NSNumber self]] ||
                                                                           [target isKindOfClass:[NSString self]] ||
                                                                           [target isKindOfClass:[RGXMLNode self]])) {
        /* NSDecimalNumber, subclasses must go first */
        if ([target isKindOfClass:[RGXMLNode self]]) {
            NSString* innerXML = [target innerXML];
            target = innerXML ?: @"";
        }
        if ([target isKindOfClass:[NSNumber self]]) target = [target stringValue];
        [self setValue:[propertyType decimalNumberWithString:target] forKey:key];
    } else if ([propertyType isSubclassOfClass:[NSNumber self]] && ([target isKindOfClass:[NSNumber self]] ||
                                                                    [target isKindOfClass:[NSString self]] ||
                                                                    [target isKindOfClass:[RGXMLNode self]])) {
        /* NSNumber */
        if ([target isKindOfClass:[RGXMLNode self]]) {
            NSString* innerXML = [target innerXML];
            target = innerXML ?: @"";
        }
        if ([target isKindOfClass:[NSString self]]) {
            if (property.isIntegral || property.isFloatingPoint || !property.isPrimitive) {
                target = [rg_number_formatter() numberFromString:target] ?: (property.isPrimitive ? @0 : nil);
            } else {
                RGLog(@"Unsupported Destination for NSString: %@ on %@", property.name, [self class]);
                return;
            }
        }
        [self setValue:target forKey:key]; /* Note: setValue: will unwrap the value if the destination is a primitive */
    } else if ([propertyType isSubclassOfClass:[NSValue self]] && ([target isKindOfClass:[NSNumber self]] ||
                                                                   [target isKindOfClass:[NSString self]] ||
                                                                   [target isKindOfClass:[RGXMLNode self]])) {
        /* NSValue */
        if ([target isKindOfClass:[RGXMLNode self]]) {
            NSString* innerXML = [target innerXML];
            target = innerXML ?: @"";
        }
        if ([target isKindOfClass:[NSString self]]) {
            target = [rg_number_formatter() numberFromString:target] ?: @0;
        }
        [self setValue:target forKey:key]; /* NSNumber is a subclass of NSValue hence it's a valid assignment */
    } else if (([propertyType isSubclassOfClass:[NSString self]] || [propertyType isSubclassOfClass:[NSURL self]]) &&
               ([target isKindOfClass:[NSNumber self]] || [target isKindOfClass:[NSString self]] ||
                [target isKindOfClass:[RGXMLNode self]] || [target isKindOfClass:[NSArray self]])) {
                   /* NSString, NSURL */
        if ([target isKindOfClass:[RGXMLNode self]]) {
            NSString* innerXML = [target innerXML];
            target = innerXML ?: @"";
        }
        if ([target isKindOfClass:[NSArray self]]) target = [target componentsJoinedByString:@","];
        if ([target isKindOfClass:[NSNumber self]]) target = [target stringValue];
        [self setValue:[[propertyType alloc] initWithString:target] forKey:key];
    } else if ([propertyType isSubclassOfClass:[NSDate self]]) { /* NSDate */
        if ([target isKindOfClass:[RGXMLNode self]]) {
            NSString* innerXML = [target innerXML];
            target = innerXML ?: @"";
        }
        NSString* dateFormat = nil;
        if ([[self class] respondsToSelector:@selector(dateFormatForProperty:)]) {
            dateFormat = [[self class] dateFormatForProperty:key];
        }
        NSDateFormatter* dateFormatter = rg_threadsafe_formatter();
        if (dateFormat) {
            dateFormatter.dateFormat = dateFormat;
            [self setValue:[dateFormatter dateFromString:target] forKey:key];
            return; /* Let's not second-guess the developer... */
        }
        for (NSString* predefinedFormat in rg_date_formats()) {
            dateFormatter.dateFormat = predefinedFormat;
            NSDate* date = [dateFormatter dateFromString:target];
            if (date) {
                [self setValue:date forKey:key];
                break;
            }
        }
    /* At this point we've exhausted the supported foundation classes for the LHS... these handle sub-objects */
    } else if (!rg_isInlineObject(propertyType) && !rg_isCollectionObject(propertyType) &&
               ([target isKindOfClass:[NSDictionary self]] || [target isKindOfClass:[RGXMLNode self]])) {
        /* lhs is some kind of user defined object, since the source has keys, but doesn't match NSDictionary */
        [self setValue:[propertyType objectFromDataSource:target inContext:context] forKey:key];
    }
#ifdef DEBUG
    [self valueForKey:key] ? RG_VOID_NOOP : RGLog(@"FAIL: initialization of property %@ on type %@", key, [self class]);
#endif
}

@end
