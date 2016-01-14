
#import "RGDefines.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, RGStorageSemantics) {
    kRGPropertyAssign,
    kRGPropertyStrong,
    kRGPropertyCopy,
    kRGPropertyWeak
};

RG_FILE_START

/**
 Returns the property name in as its canonical key.
 */
NSString* const rg_canonical_form(const char* const utf8Input) __attribute__((pure));

/**
 An object that encapsulates a property declaration, and enables object based introspection of a class.  It is a programmer error to invoke `-init`.
 */
@interface RGPropertyDeclaration : NSObject

/**
 The name of the property.
 */
@property RG_NONNULL_PROPERTY(nonatomic, strong, readonly) NSString* name;

/**
 The name of the property as used for key resolution.
 */
@property RG_NONNULL_PROPERTY(nonatomic, strong, readonly) NSString* canonicalName;

/**
 A `Class` object, an instance of which can contain the value of this property.  Primitive properties use `NSNumber` by default.
 */
@property RG_NONNULL_PROPERTY(nonatomic, strong, readonly) Class type;

/**
 The memory management semantics of the property.  The default is `assign` (`kRGPropertyAssign`).
 */
@property (nonatomic, assign, readonly) RGStorageSemantics storageSemantics;

/**
 Whether or not the property is a raw type (int, float, struct, union, etc.).  Default is `NO`.
 */
@property (nonatomic, assign, readonly) BOOL isPrimitive;

/**
 Whether or not the property is modifiable.  The default is `NO`.
 */
@property (nonatomic, assign, readonly) BOOL readOnly;

/**
 The designated initializer; it is a programmer error to invoke `-init`.
 */
- (RG_PREFIX_NONNULL instancetype) initWithProperty:(RG_PREFIX_NULLABLE objc_property_t)property NS_DESIGNATED_INITIALIZER;

@end

RG_FILE_END
