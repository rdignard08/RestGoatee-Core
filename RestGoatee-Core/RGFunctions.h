
#import "RGConstants.h"
#import "RGXMLNode.h"

/**
 Returns the built-in date formats the library supports. Contains: ISO, `-[NSDate description]`.
 */
NSArray RG_GENERIC(NSString*) * RG_SUFFIX_NULLABLE rg_dateFormats(void) __attribute__((pure));

/**
 `rg_threadsafe_formatter` returns a per thread instance of `NSDateFormatter`.  Never pass the returned object between threads.  Always set the objects properties (`dateFormat`, `locale`, `timezone`, etc.) before use.
 */
NSDateFormatter* RG_SUFFIX_NONNULL rg_threadsafe_formatter(void);

/**
 Returns the property name in as its canonical key.
 */
NSString* RG_SUFFIX_NONNULL const rg_canonical_form(const char* RG_SUFFIX_NONNULL const utf8Input) __attribute__((pure));

/**
 `rg_swizzle` is a basic implementation of swizzling.  It does not clobber the super class if the method is not on the subclass.
 */
void rg_swizzle(Class RG_SUFFIX_NULLABLE cls, SEL RG_SUFFIX_NULLABLE original, SEL RG_SUFFIX_NULLABLE replacement) __attribute__((cold));

/**
 The `rg_log` function is the backing debug function of `RGLog`.  It logs the file name & line number of the call site.
 */
void rg_log(NSString* RG_SUFFIX_NULLABLE format, ...) __attribute__((cold));

/**
 Returns `YES` if the parameter `object` is of type `Class` but _not_ a meta-class.
 */
BOOL __attribute__((pure, always_inline, warn_unused_result)) rg_isClassObject(id RG_SUFFIX_NULLABLE object);

/**
 Returns `YES` if object has the same type as `NSObject`'s meta class.
 */
BOOL __attribute__((pure, always_inline, warn_unused_result)) rg_isMetaClassObject(id RG_SUFFIX_NULLABLE object);

/**
 Returns `YES` if the given type can be adequately represented by an `NSString`.
 */
BOOL __attribute__((pure, always_inline, warn_unused_result)) rg_isInlineObject(Class RG_SUFFIX_NULLABLE cls);

/**
 Returns `YES` if the given type can be adequately represented by an `NSArray`.
 */
BOOL __attribute__((pure, always_inline, warn_unused_result)) rg_isCollectionObject(Class RG_SUFFIX_NULLABLE cls);

/**
 Returns `YES` if the given type is a "key => value" type.  Thus it can be represented by an `NSDictionary`.
 */
BOOL __attribute__((pure, always_inline, warn_unused_result)) rg_isKeyedCollectionObject(Class RG_SUFFIX_NULLABLE cls);

/**
 Returns `YES` if the given class conforms to `RGDataSource`.  Necessary due to some bug (the 2nd clause).
 */
BOOL __attribute__((pure, always_inline, warn_unused_result)) rg_isDataSourceClass(Class RG_SUFFIX_NULLABLE cls);
