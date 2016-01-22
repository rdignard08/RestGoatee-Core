
#import "RGPropertyDeclaration.h"
#import "RestGoatee-Core.h"

RG_FILE_START

static NSString* RG_SUFFIX_NONNULL const rg_malloc_based_canonical(const char* RG_SUFFIX_NONNULL const utfName, size_t length) {
    char* canonicalBuffer = malloc(length);
    size_t outputLength = 0;
    for (size_t i = 0; i != length; i++) {
        char c = utfName[i];
        if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z')) { /* a digit or lowercase character; no change */
            canonicalBuffer[outputLength++] = c;
        } else if (c >= 'A' && c <= 'Z') { /* an uppercase character; to lower */
            canonicalBuffer[outputLength++] = c + (const int)('a' - 'A'); /* 'a' - 'A' == 32 */
        } /* unicodes, symbols, spaces, etc. are completely skipped */
    }
    return [[NSString alloc] initWithBytesNoCopy:canonicalBuffer length:outputLength encoding:NSUTF8StringEncoding freeWhenDone:YES];
}

static NSString* RG_SUFFIX_NONNULL const rg_static_based_canonical(const char* RG_SUFFIX_NONNULL const utfName, size_t length) {
    char canonicalBuffer[length];
    size_t outputLength = 0;
    for (size_t i = 0; i != length; i++) {
        char c = utfName[i];
        if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z')) { /* a digit or lowercase character; no change */
            canonicalBuffer[outputLength++] = c;
        } else if (c >= 'A' && c <= 'Z') { /* an uppercase character; to lower */
            canonicalBuffer[outputLength++] = c + (const int)('a' - 'A'); /* 'a' - 'A' == 32 */
        } /* unicodes, symbols, spaces, etc. are completely skipped */
    }
    return [[NSString alloc] initWithBytes:canonicalBuffer length:outputLength encoding:NSUTF8StringEncoding];
}

NSString* RG_SUFFIX_NONNULL const rg_canonical_form(const char* RG_SUFFIX_NONNULL const utfName) {
    const size_t length = strlen(utfName);
    return length >= kRGMaxAutoSize ? rg_malloc_based_canonical(utfName, length) : rg_static_based_canonical(utfName, length);
}

@implementation RGPropertyDeclaration

- (RG_PREFIX_NULLABLE instancetype) init {
    [NSException raise:NSGenericException format:@"-init is not a valid initializer of %@", [self class]];
    return [super init];
}

- (RG_PREFIX_NONNULL instancetype) initWithProperty:(RG_PREFIX_NONNULL objc_property_t)property {
    self = [super init];
    if (self) {
        [self initializeName:property];
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
                case 't': /* I have no idea what 'old-style' typing looks like; gonna assume it's the same / no one uses it */
                    [self initializeType:attribute.value];
                    break;
                case 'R':
                    self->_readOnly = YES;
            }
        }
        free(attributes);
    }
    return self;
}

- (void) initializeName:(RG_PREFIX_NULLABLE objc_property_t)property {
    const char* utfName = property_getName(property);
    self->_name = @(utfName);
    self->_canonicalName = rg_canonical_form(utfName);
}

- (void) initializeType:(const char*)value {
    BOOL isClass = strcmp(@encode(Class), value) == 0;
    if (isClass || strcmp(@encode(id), value) == 0) {
        self->_type = isClass ? objc_getMetaClass("NSObject") : objc_getClass("NSObject");
        self->_isPrimitive = NO;
        return;
    }
    const size_t typeLength = strlen(value);
    size_t outputLength = 0;
    char* buffer = malloc(typeLength);
    BOOL foundFirst = NO;
    for (size_t j = 0; j != typeLength; j++) {
        char c = value[j];
        if (foundFirst) {
            if (c == '"') {
                break;
            } else {
                buffer[outputLength++] = c;
            }
        } else if (c == '"') {
            foundFirst = YES;
        }
    } /* there should be 2 '"' on each end, the class is in the middle */
    buffer[outputLength] = '\0';
    Class propertyType = objc_getClass(buffer);
    free(buffer);
    self->_type = propertyType ?: [NSNumber self];
    self->_isPrimitive = !propertyType;
}

@end

RG_FILE_END
