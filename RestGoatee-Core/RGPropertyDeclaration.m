
#import "RGPropertyDeclaration.h"

RG_FILE_START

NSString* const rg_canonicalForm(const char* const utfName) {
    const size_t nameLength = strlen(utfName);
    size_t outputLength = 0;
    char* canonicalBuffer = malloc(nameLength);
    for (size_t i = 0; i != nameLength; i++) {
        char c = utfName[i];
        if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z')) { /* a digit or lowercase character; no change */
            canonicalBuffer[outputLength++] = c;
        } else if (c >= 'A' && c <= 'Z') { /* an uppercase character; to lower */
            canonicalBuffer[outputLength++] = c + (const int)('a' - 'A'); /* 'a' - 'A' == 32 */
        } /* unicodes, symbols, spaces, etc. are completely skipped */
    }
    return [[NSString alloc] initWithBytesNoCopy:canonicalBuffer length:outputLength encoding:NSUTF8StringEncoding freeWhenDone:YES];
}

@implementation RGPropertyDeclaration
@synthesize name = _name;
@synthesize canonicalName = _canonicalName;
@synthesize storageSemantics = _storageSemantics;

- (RG_PREFIX_NONNULL instancetype) init {
    NSAssert(NO, @"-init is not a valid initializer of %@", [self class]);
    return [self initWithProperty:NULL];
}

- (RG_PREFIX_NONNULL instancetype) initWithProperty:(RG_PREFIX_NULLABLE objc_property_t)property {
    self = [super init];
    if (self && property) {
        const char* utfName = property_getName(property);
        self->_name = @(utfName);
        self->_canonicalName = rg_canonicalForm(utfName);
        uint32_t attributeCount = 0;
        objc_property_attribute_t* attributes = property_copyAttributeList(property, &attributeCount);
        for (uint32_t i = 0; i < attributeCount; i++) {
            objc_property_attribute_t attribute = attributes[i];
            /* The first character is the type encoding; the other field is a value of some kind (if anything)
             See: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html */
            switch (attribute.name[0]) {
                case '&':
                    self->_storageSemantics = kRGPropertyStrong;
                    break;
                case 'C':
                    self->_storageSemantics = kRGPropertyCopy;
                    break;
                case 'W':
                    self->_storageSemantics = kRGPropertyWeak;
                    break;
                case 'T':
                case 't': { /* I have no idea what 'old-style' typing looks like; gonna assume it's the same / no one uses it */
                    const size_t typeLength = strlen(attribute.value);
                    size_t outputLength = 0;
                    char* buffer = malloc(typeLength + 1);
                    BOOL foundFirst = NO;
                    for (size_t j = 0; j != typeLength; j++) {
                        char c = attribute.value[j];
                        if (foundFirst) {
                            if (c == '"') break; else buffer[outputLength++] = c;
                        } else if (c == '"') {
                            foundFirst = YES;
                        }
                    } /* there should be 2 '"' on each end, the class is in the middle */
                    buffer[outputLength] = '\0';
                    Class propertyType = Nil;
                    if (strcmp(@encode(Class), attribute.value) == 0) {
                        propertyType = objc_getMetaClass("NSObject");
                    } else if (strcmp(@encode(id), attribute.value) == 0) {
                        propertyType = objc_getClass("NSObject");
                    } else {
                        propertyType = objc_getClass(buffer);
                    }
                    self->_type = propertyType ?: [NSNumber class];
                    self->_isPrimitive = !propertyType;
                }
                    break;
                case 'R':
                    self->_readOnly = YES;
            }
        }
        free(attributes);
    }
    return self;
}

- (RG_PREFIX_NONNULL NSString*) description {
    return [NSString stringWithFormat:@"%@\nname: %@\ncanonicalName: %@\ntype: %@\nstorageSemantics: %@\nisPrimitive: %@\n readOnly: %@", super.description, self.name, self.canonicalName, self.type, @(self.storageSemantics), @(self.isPrimitive), @(self.readOnly)];
}

@end

RG_FILE_END
