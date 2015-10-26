/* Copyright (c) 2/5/15, Ryan Dignard
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

#import "NSObject+RG_SharedImpl.h"
#import "RestGoatee-Core.h"
#import "NSString+RGCanonicalValue.h"

FILE_START

/* Property Description Keys */
NSString* SUFFIX_NONNULL const kRGPropertyAtomicType = @"atomicity";
NSString* SUFFIX_NONNULL const kRGPropertyBacking = @"ivar";
NSString* SUFFIX_NONNULL const kRGPropertyGetter = @"getter";
NSString* SUFFIX_NONNULL const kRGPropertySetter = @"setter";
NSString* SUFFIX_NONNULL const kRGPropertyReadwrite = @"readwrite";
NSString* SUFFIX_NONNULL const kRGPropertyReadonly = @"readonly";
NSString* SUFFIX_NONNULL const kRGPropertyAssign = @"assign";
NSString* SUFFIX_NONNULL const kRGPropertyStrong = @"retain";
NSString* SUFFIX_NONNULL const kRGPropertyCopy = @"copy";
NSString* SUFFIX_NONNULL const kRGPropertyWeak = @"weak";
NSString* SUFFIX_NONNULL const kRGPropertyClass = @"type";
NSString* SUFFIX_NONNULL const kRGPropertyRawType = @"raw_type";
NSString* SUFFIX_NONNULL const kRGPropertyDynamic = @"__dynamic__";
NSString* SUFFIX_NONNULL const kRGPropertyAtomic = @"atomic";
NSString* SUFFIX_NONNULL const kRGPropertyNonatomic = @"nonatomic";

/* Ivar Description Keys */
NSString* SUFFIX_NONNULL const kRGIvarOffset = @"ivar_offset";
NSString* SUFFIX_NONNULL const kRGIvarSize = @"ivar_size";
NSString* SUFFIX_NONNULL const kRGIvarPrivate = @"private";
NSString* SUFFIX_NONNULL const kRGIvarProtected = @"protected";
NSString* SUFFIX_NONNULL const kRGIvarPublic = @"public";

/* Keys shared between properties and ivars */
NSString* SUFFIX_NONNULL const kRGPropertyName = @"name";
NSString* SUFFIX_NONNULL const kRGPropertyCanonicalName = @"canonically";
NSString* SUFFIX_NONNULL const kRGPropertyStorage = @"storage";
NSString* SUFFIX_NONNULL const kRGPropertyAccess = @"access";
NSString* SUFFIX_NONNULL const kRGSerializationKey = @"__class";
NSString* SUFFIX_NONNULL const kRGPropertyListProperty = @"rg_propertyList";

/* storage for extern'd class references */
Class SUFFIX_NULLABLE rg_sNSManagedObjectContext;
Class SUFFIX_NULLABLE rg_sNSManagedObject;
Class SUFFIX_NULLABLE rg_sNSManagedObjectModel;
Class SUFFIX_NULLABLE rg_sNSPersistentStoreCoordinator;
Class SUFFIX_NULLABLE rg_sNSEntityDescription;
Class SUFFIX_NULLABLE rg_sNSFetchRequest;

NSArray GENERIC(NSString*) * SUFFIX_NONNULL __attribute__((pure)) rg_dateFormats(void) {
    static dispatch_once_t onceToken;
    static NSArray GENERIC(NSString*) * _sDateFormats;
    dispatch_once(&onceToken, ^{
        _sDateFormats = @[ @"yyyy-MM-dd'T'HH:mm:ssZZZZZ", @"yyyy-MM-dd HH:mm:ss ZZZZZ", @"yyyy-MM-dd'T'HH:mm:ssz", @"yyyy-MM-dd" ];
    });
    return _sDateFormats;
}

BOOL __attribute__((pure)) rg_isClassObject(id SUFFIX_NULLABLE object) {
    return object_getClass(object) != [NSObject class] && object_getClass(/* the meta-class */object_getClass(object)) == object_getClass([NSObject class]);
    /* if the class of the meta-class == NSObject's meta-class; object was itself a Class object */
    /* object_getClass * object_getClass * <plain_nsobject> should not return true */
}

BOOL __attribute__((pure)) rg_isMetaClassObject(id SUFFIX_NULLABLE object) {
    return rg_isClassObject(object) && class_isMetaClass(object);
}

BOOL __attribute__((pure)) rg_isInlineObject(Class SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSDate class]] || [cls isSubclassOfClass:[NSString class]] || [cls isSubclassOfClass:[NSData class]] || [cls isSubclassOfClass:[NSNull class]] || [cls isSubclassOfClass:[NSValue class]] || [cls isSubclassOfClass:[NSURL class]];
}

BOOL __attribute__((pure)) rg_isCollectionObject(Class SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSSet class]] || [cls isSubclassOfClass:[NSArray class]] || [cls isSubclassOfClass:[NSOrderedSet class]];
}

BOOL __attribute__((pure)) rg_isKeyedCollectionObject(Class SUFFIX_NULLABLE cls) {
    return [cls isSubclassOfClass:[NSDictionary class]] || [cls isSubclassOfClass:[RGXMLNode class]];
}

BOOL __attribute__((pure)) rg_isDataSourceClass(Class SUFFIX_NULLABLE cls) {
    return [cls instancesRespondToSelector:@selector(objectForKeyedSubscript:)] && [cls instancesRespondToSelector:@selector(setObject:forKeyedSubscript:)] && [cls instancesRespondToSelector:@selector(valueForKeyPath:)] && [cls instancesRespondToSelector:@selector(countByEnumeratingWithState:objects:count:)];
}

static NSString* SUFFIX_NONNULL __attribute__((pure)) rg_firstQuotedSubstring(NSString* SUFFIX_NULLABLE str) {
    const NSUInteger inputLength = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger i = 0, j = 0;
    char* outBuffer = malloc(inputLength);
    const char* inBuffer = str.UTF8String;
    BOOL foundFirst = NO;
    for (; i != inputLength; i++) {
        char c = inBuffer[i];
        if (foundFirst) {
            if (c == '"') break; else outBuffer[j++] = c;
        } else if (c == '"') {
            foundFirst = YES;
        }
    }
    NSString* ret = [[NSString alloc] initWithBytesNoCopy:outBuffer length:j encoding:NSUTF8StringEncoding freeWhenDone:YES];
    return ret.length ? ret : str; /* there should be 2 '"' on each end, the class is in the middle, if not, give up */
}

static Class SUFFIX_NONNULL __attribute__((pure)) rg_classForTypeString(NSString* SUFFIX_NULLABLE str) {
    if ([str isEqual:@(@encode(Class))]) return object_getClass([NSObject class]);
    if ([str isEqual:@(@encode(id))]) return [NSObject class];
    str = rg_firstQuotedSubstring(str);
    return NSClassFromString(str) ?: [NSNumber class];
}

static void rg_parseIvarStructOntoPropertyDeclaration(Ivar SUFFIX_NULLABLE ivar, NSMutableDictionary* SUFFIX_NULLABLE propertyData) {
    propertyData[kRGIvarOffset] = @(ivar_getOffset(ivar));
}

static NSMutableDictionary* SUFFIX_NONNULL rg_parseIvarStruct(Ivar SUFFIX_NONNULL ivar) {
    NSString* name = [NSString stringWithUTF8String:ivar_getName(ivar)];
    
    /* The default values for ivars are: assign (if primitive) strong (if object), protected */
    NSMutableDictionary* propertyDict = [@{
                                           kRGPropertyName : name,
                                           kRGPropertyCanonicalName : name.rg_canonicalValue,
                                           kRGPropertyStorage : kRGPropertyAssign,
                                           kRGPropertyAccess : kRGIvarProtected,
                                           kRGPropertyBacking : name,
                                           kRGIvarOffset : @(ivar_getOffset(ivar))
                                           } mutableCopy];
    NSString* ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
    propertyDict[kRGPropertyClass] = rg_classForTypeString(ivarType);
    propertyDict[kRGPropertyRawType] = rg_firstQuotedSubstring(ivarType);
    return propertyDict;
}

static NSMutableDictionary* SUFFIX_NONNULL rg_parsePropertyStruct(objc_property_t SUFFIX_NONNULL property) {
    NSString* name = [NSString stringWithUTF8String:property_getName(property)];
    /* The default values for properties are: if object and ARC compiled: strong (we don't have to check for this, ARC will insert the retain attribute) else assign. atomic. readwrite. */
    NSMutableDictionary* propertyDict = [@{
                                           kRGPropertyName : name,
                                           kRGPropertyCanonicalName : name.rg_canonicalValue,
                                           kRGPropertyStorage : kRGPropertyAssign,
                                           kRGPropertyAtomicType : kRGPropertyAtomic,
                                           kRGPropertyAccess : kRGPropertyReadwrite } mutableCopy];
    uint32_t attributeCount = 0;
    objc_property_attribute_t* attributes = property_copyAttributeList(property, &attributeCount);
    for (uint32_t i = 0; i < attributeCount; i++) {
        objc_property_attribute_t attribute = attributes[i];
        const char heading = attribute.name ? attribute.name[0] : '\0';
        NSString* value = [NSString stringWithUTF8String:attribute.value];
        /* The first character is the type encoding; the other field is a value of some kind (if anything)
         See: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html */
        switch (heading) {
            case '&':
                propertyDict[kRGPropertyStorage] = kRGPropertyStrong;
                break;
            case 'C':
                propertyDict[kRGPropertyStorage] = kRGPropertyCopy;
                break;
            case 'W':
                propertyDict[kRGPropertyStorage] = kRGPropertyWeak;
                break;
            case 'V':
                propertyDict[kRGPropertyBacking] = value;
                break;
            case 'D':
                propertyDict[kRGPropertyBacking] = kRGPropertyDynamic;
                break;
            case 'N':
                propertyDict[kRGPropertyAtomicType] = kRGPropertyNonatomic;
                break;
            case 'T':
            case 't': /* TODO: I have no fucking idea what 'old-style' typing looks like */
                propertyDict[kRGPropertyRawType] = rg_firstQuotedSubstring(value);
                propertyDict[kRGPropertyClass] = rg_classForTypeString(value);
                break;
            case 'R':
                propertyDict[kRGPropertyAccess] = kRGPropertyReadonly;
                break;
            case 'G':
                propertyDict[kRGPropertyGetter] = value;
                break;
            case 'S':
                propertyDict[kRGPropertySetter] = value;
        }
    }
    free(attributes);
    return propertyDict;
}

Class SUFFIX_NONNULL rg_topClassDeclaringPropertyNamed(Class SUFFIX_NULLABLE currentClass, NSString* SUFFIX_NULLABLE propertyName) {
    const char* utf8Name = propertyName.UTF8String;
    Class iteratorClass = currentClass, priorClass;
    while (YES) {
        if (!class_getProperty(iteratorClass, utf8Name) && !class_getInstanceVariable(iteratorClass, utf8Name)) return priorClass;
        priorClass = iteratorClass;
        iteratorClass = class_getSuperclass(iteratorClass);
    }
}

@implementation NSObject (RG_SharedImpl)

+ (void) load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rg_sNSManagedObjectContext = objc_getClass("NSManagedObjectContext");
        rg_sNSManagedObject = objc_getClass("NSManagedObject");
        rg_sNSManagedObjectModel = objc_getClass("NSManagedObjectModel");
        rg_sNSPersistentStoreCoordinator = objc_getClass("NSPersistentStoreCoordinator");
        rg_sNSEntityDescription = objc_getClass("NSEntityDescription");
        rg_sNSFetchRequest = objc_getClass("NSFetchRequest");
    });
}

+ (PREFIX_NONNULL NSMutableArray GENERIC(NSMutableDictionary*) *) rg_propertyList {
    @synchronized (self) {
        NSMutableArray* rg_propertyList = objc_getAssociatedObject(self, @selector(rg_propertyList));
        if (!rg_propertyList) {
            NSMutableArray* propertyStructure = [NSMutableArray new];
            [propertyStructure addObjectsFromArray:[[self superclass] rg_propertyList]];
            uint32_t count;
            objc_property_t* properties = class_copyPropertyList(self, &count);
            for (uint32_t i = 0; i < count; i++) {
                [propertyStructure addObject:rg_parsePropertyStruct(properties[i])];
            }
            free(properties);
            Ivar* ivars = class_copyIvarList(self, &count);
            for (uint32_t i = 0; i < count; i++) {
                NSString* ivarName = [NSString stringWithUTF8String:ivar_getName(ivars[i])];
                NSUInteger ivarIndex = [propertyStructure[kRGPropertyBacking] indexOfObject:ivarName];
                if (ivarIndex == NSNotFound) {
                    [propertyStructure addObject:rg_parseIvarStruct(ivars[i])];
                } else {
                    rg_parseIvarStructOntoPropertyDeclaration(ivars[i], propertyStructure[ivarIndex]);
                }
            }
            free(ivars);
            rg_propertyList = propertyStructure;
            objc_setAssociatedObject(self, @selector(rg_propertyList), rg_propertyList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return rg_propertyList;
    }
}

+ (PREFIX_NONNULL NSMutableDictionary GENERIC(RGCanonicalKey*, NSMutableDictionary GENERIC(NSString*, id) *) *) rg_canonicalPropertyList {
    @synchronized (self) {
        NSMutableDictionary* rg_canonicalPropertyList = objc_getAssociatedObject(self, @selector(rg_canonicalPropertyList));
        if (!rg_canonicalPropertyList) {
            rg_canonicalPropertyList = [NSMutableDictionary new];
            [rg_canonicalPropertyList addEntriesFromDictionary:[[self superclass] rg_canonicalPropertyList]];
            uint32_t count;
            objc_property_t* properties = class_copyPropertyList(self, &count);
            for (uint32_t i = 0; i < count; i++) {
                NSMutableDictionary* property = rg_parsePropertyStruct(properties[i]);
                RGCanonicalKey* key = [[RGCanonicalKey alloc] initWithKey:property[kRGPropertyName] withCanonicalName:property[kRGPropertyCanonicalName]];
                rg_canonicalPropertyList[key] = property;
            }
            free(properties);
            Ivar* ivars = class_copyIvarList(self, &count);
            for (uint32_t i = 0; i < count; i++) {
                NSString* ivarName = [NSString stringWithUTF8String:ivar_getName(ivars[i])];
                if ([ivarName isEqual:@"_urlProperty"]) {
                    NSLog(@"%@", ivarName);
                }
                NSMutableDictionary* propertyDecl = rg_canonicalPropertyList[ivarName];
                if (propertyDecl) {
                    rg_parseIvarStructOntoPropertyDeclaration(ivars[i], propertyDecl);
                } else {
                    propertyDecl = rg_parseIvarStruct(ivars[i]);
                    RGCanonicalKey* key = [[RGCanonicalKey alloc] initWithKey:propertyDecl[kRGPropertyName] withCanonicalName:propertyDecl[kRGPropertyCanonicalName]];
                    rg_canonicalPropertyList[key] = propertyDecl;
                }
            }
            free(ivars);
            objc_setAssociatedObject(self, @selector(rg_canonicalPropertyList), rg_canonicalPropertyList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return rg_canonicalPropertyList;
    }
}

+ (PREFIX_NULLABLE NSMutableDictionary*) rg_declarationForProperty:(PREFIX_NONNULL NSString*)propertyName {
    NSUInteger index = [[self rg_propertyList][kRGPropertyName] indexOfObject:propertyName];
    return index == NSNotFound ? nil : [self rg_propertyList][index];
}

- (PREFIX_NONNULL Class) rg_classForProperty:(PREFIX_NONNULL NSString*)propertyName {
    return [[self class] rg_declarationForProperty:propertyName][kRGPropertyClass] ?: [NSNumber class];
}

- (BOOL) rg_isPrimitive:(PREFIX_NONNULL NSString*)propertyName {
    NSString* rawType = [[self class] rg_declarationForProperty:propertyName][kRGPropertyRawType];
    return !NSClassFromString(rawType) && ![rawType isEqual:@(@encode(id))] && ![rawType isEqual:@(@encode(Class))];
}

@end

FILE_END
