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
#import <objc/runtime.h>
#import "RestGoatee-Core.h"
#import "NSString+RGCanonicalValue.h"

FILE_START

/* Property Description Keys */
NSString* suffix_nonnull const kRGPropertyAtomicType = @"atomicity";
NSString* suffix_nonnull const kRGPropertyBacking = @"ivar";
NSString* suffix_nonnull const kRGPropertyGetter = @"getter";
NSString* suffix_nonnull const kRGPropertySetter = @"setter";
NSString* suffix_nonnull const kRGPropertyReadwrite = @"readwrite";
NSString* suffix_nonnull const kRGPropertyReadonly = @"readonly";
NSString* suffix_nonnull const kRGPropertyAssign = @"assign";
NSString* suffix_nonnull const kRGPropertyStrong = @"retain";
NSString* suffix_nonnull const kRGPropertyCopy = @"copy";
NSString* suffix_nonnull const kRGPropertyWeak = @"weak";
NSString* suffix_nonnull const kRGPropertyClass = @"type";
NSString* suffix_nonnull const kRGPropertyRawType = @"raw_type";
NSString* suffix_nonnull const kRGPropertyDynamic = @"__dynamic__";
NSString* suffix_nonnull const kRGPropertyAtomic = @"atomic";
NSString* suffix_nonnull const kRGPropertyNonatomic = @"nonatomic";

/* Ivar Description Keys */
NSString* suffix_nonnull const kRGIvarOffset = @"ivar_offset";
NSString* suffix_nonnull const kRGIvarSize = @"ivar_size";
NSString* suffix_nonnull const kRGIvarPrivate = @"private";
NSString* suffix_nonnull const kRGIvarProtected = @"protected";
NSString* suffix_nonnull const kRGIvarPublic = @"public";

/* Keys shared between properties and ivars */
NSString* suffix_nonnull const kRGPropertyName = @"name";
NSString* suffix_nonnull const kRGPropertyCanonicalName = @"canonically";
NSString* suffix_nonnull const kRGPropertyStorage = @"storage";
NSString* suffix_nonnull const kRGPropertyAccess = @"access";
NSString* suffix_nonnull const kRGSerializationKey = @"__class";
NSString* suffix_nonnull const kRGPropertyListProperty = @"rg_propertyList";

/* storage for extern'd class references */
Class suffix_nullable rg_sNSManagedObjectContext;
Class suffix_nullable rg_sNSManagedObject;
Class suffix_nullable rg_sNSManagedObjectModel;
Class suffix_nullable rg_sNSPersistentStoreCoordinator;
Class suffix_nullable rg_sNSEntityDescription;
Class suffix_nullable rg_sNSFetchRequest;

NSArray* const rg_dateFormats() {
    static dispatch_once_t onceToken;
    static NSArray* _sDateFormats;
    dispatch_once(&onceToken, ^{
        _sDateFormats = @[ @"yyyy-MM-dd'T'HH:mm:ssZZZZZ", @"yyyy-MM-dd HH:mm:ss ZZZZZ", @"yyyy-MM-dd'T'HH:mm:ssz", @"yyyy-MM-dd" ];
    });
    return _sDateFormats;
}

BOOL rg_isClassObject(id object) {
    return object_getClass(object) != [NSObject class] && object_getClass(/* the meta-class */object_getClass(object)) == object_getClass([NSObject class]);
    /* if the class of the meta-class == NSObject's meta-class; object was itself a Class object */
    /* object_getClass * object_getClass * <plain_nsobject> should not return true */
}

BOOL rg_isMetaClassObject(id object) {
    return rg_isClassObject(object) && class_isMetaClass(object);
}

BOOL rg_isInlineObject(Class cls) {
    return [cls isSubclassOfClass:[NSDate class]] || [cls isSubclassOfClass:[NSString class]] || [cls isSubclassOfClass:[NSData class]] || [cls isSubclassOfClass:[NSNull class]] || [cls isSubclassOfClass:[NSValue class]] || [cls isSubclassOfClass:[NSURL class]];
}

BOOL rg_isCollectionObject(Class cls) {
    return [cls isSubclassOfClass:[NSSet class]] || [cls isSubclassOfClass:[NSArray class]] || [cls isSubclassOfClass:[NSOrderedSet class]];
}

BOOL rg_isKeyedCollectionObject(Class cls) {
    return [cls isSubclassOfClass:[NSDictionary class]];
}

BOOL rg_isDataSourceClass(Class cls) {
    return [cls instancesRespondToSelector:@selector(objectForKeyedSubscript:)] && [cls instancesRespondToSelector:@selector(setObject:forKeyedSubscript:)] && [cls instancesRespondToSelector:@selector(valueForKeyPath:)] && [cls instancesRespondToSelector:@selector(countByEnumeratingWithState:objects:count:)];
}

static NSString* rg_firstQuotedSubstring(NSString* str) {
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

static Class rg_classForTypeString(NSString* str) {
    if ([str isEqual:@(@encode(Class))]) return object_getClass([NSObject class]);
    if ([str isEqual:@(@encode(id))]) return [NSObject class];
    str = rg_firstQuotedSubstring(str);
    return NSClassFromString(str) ?: [NSNumber class];
}

static void rg_parseIvarStructOntoPropertyDeclaration(struct objc_ivar* ivar, NSMutableDictionary* propertyData) {
    propertyData[kRGIvarOffset] = @(ivar_getOffset(ivar));
}

static NSMutableDictionary* rg_parseIvarStruct(Ivar ivar) {
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

NSMutableDictionary* rg_parsePropertyStruct(objc_property_t property) {
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

void rg_calculateIvarSize(Class, NSMutableArray*);
void rg_calculateIvarSize(Class object, NSMutableArray/*NSMutableDictionary*/* properties) {
    NSArray* rawOffsets = properties[kRGIvarOffset];
    NSMutableArray* offsets = [NSMutableArray new];
    for (NSUInteger i = 0; i < rawOffsets.count; i++) {
        NSNumber* offset = rawOffsets[i];
        if (![offset isKindOfClass:[NSNull class]]) {
            [offsets addObject:@{ @"o" : offset, @"i" : @(i) }];
        }
    }
    [offsets sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSNumber*)obj1[@"o"] compare:obj2[@"o"]];
    }];
    for (NSUInteger i = 0; i < offsets.count; i++) {
        NSDictionary* obj = offsets[i];
        NSNumber* nextOffset = (i == (offsets.count - 1)) ? @(class_getInstanceSize(object)) : offsets[i+1][@"o"];
        properties[[obj[@"i"] unsignedIntegerValue]][kRGIvarSize] = @([nextOffset unsignedIntegerValue] - [obj[@"o"] unsignedIntegerValue]);
    }
}

Class rg_topClassDeclaringPropertyNamed(Class currentClass, NSString* propertyName) {
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
        rg_sNSManagedObjectContext = NSClassFromString(@"NSManagedObjectContext");
        rg_sNSManagedObject = NSClassFromString(@"NSManagedObject");
        rg_sNSManagedObjectModel = NSClassFromString(@"NSManagedObjectModel");
        rg_sNSPersistentStoreCoordinator = NSClassFromString(@"NSPersistentStoreCoordinator");
        rg_sNSEntityDescription = NSClassFromString(@"NSEntityDescription");
        rg_sNSFetchRequest = NSClassFromString(@"NSFetchRequest");
    });
}

+ (prefix_nonnull NSArray*) rg_propertyList {
    static dispatch_once_t onceToken;
    static NSArray* rg_propertyList;
    dispatch_once(&onceToken, ^{
        NSMutableArray* propertyStructure = [NSMutableArray array];
        NSMutableArray* stack = [NSMutableArray array];
        uint32_t count;
        for (Class superClass = self; superClass; superClass = [superClass superclass]) {
            [stack insertObject:superClass atIndex:0]; /* we want superclass properties to be overwritten by subclass properties so append front */
        }
        for (Class cls in stack) {
            objc_property_t* properties = class_copyPropertyList(cls, &count);
            for (uint32_t i = 0; i < count; i++) {
                [propertyStructure addObject:rg_parsePropertyStruct(properties[i])];
            }
            free(properties);
        }
        for (Class cls in stack) {
            Ivar* ivars = class_copyIvarList(cls, &count);
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
        }
        /* rg_calculateIvarSize(self, propertyStructure); //*/
        for (NSUInteger i = 0; i < propertyStructure.count; i++) {
            propertyStructure[i] = [propertyStructure[i] copy];
        }
        rg_propertyList = [propertyStructure copy];
    });
    return rg_propertyList;
}

+ (prefix_nullable NSDictionary*) rg_declarationForProperty:(prefix_nonnull NSString*)propertyName {
    NSUInteger index = [[self rg_propertyList][kRGPropertyName] indexOfObject:propertyName];
    return index == NSNotFound ? nil : [self rg_propertyList][index];
}

- (prefix_nonnull NSArray*) rg_keys {
    if ([self isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary*)self allKeys];
    }
    if ([self isKindOfClass:[RGXMLNode class]]) {
        NSMutableArray* someKeys = [[[self class] rg_propertyList][kRGPropertyName] mutableCopy];
        [someKeys addObjectsFromArray:[[(RGXMLNode*)self attributes] allKeys]];
        [someKeys addObjectsFromArray:[(RGXMLNode*)self childNodes][@"name"]];
        return [someKeys copy];
    }
    return [[self class] rg_propertyList][kRGPropertyName];
}

- (prefix_nonnull Class) rg_classForProperty:(prefix_nonnull NSString*)propertyName {
    return [[self class] rg_declarationForProperty:propertyName][kRGPropertyClass] ?: [NSNumber class];
}

- (BOOL) rg_isPrimitive:(prefix_nonnull NSString*)propertyName {
    NSString* rawType = [[self class] rg_declarationForProperty:propertyName][kRGPropertyRawType];
    return !NSClassFromString(rawType) && ![rawType isEqual:@(@encode(id))] && ![rawType isEqual:@(@encode(Class))];
}

@end

FILE_END
