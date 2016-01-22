
#import "RestGoatee-Core.h"
#import <objc/runtime.h>

const size_t kRGMaxAutoSize = 1 << 10;

NSString* RG_SUFFIX_NONNULL const kRGSerializationKey = @"__class";
NSString* RG_SUFFIX_NONNULL const kRGDateFormatterKey = @"kRGDateFormatterKey";
NSString* RG_SUFFIX_NONNULL const kRGXMLDocumentNodeKey = @"kRGDocument";
NSString* RG_SUFFIX_NONNULL const kRGInnerXMLKey = @"__innerXML__";

/* storage for extern'd class references */
Class RG_SUFFIX_NONNULL rg_NSObjectClass;
Class RG_SUFFIX_NONNULL rg_NSObjectMetaClass;
Class RG_SUFFIX_NULLABLE rg_NSManagedObject;
Class RG_SUFFIX_NULLABLE rg_NSEntityDescription;

@interface RGConstants : NSObject 

@end

@implementation RGConstants

+ (void) load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rg_NSObjectClass = objc_getClass("NSObject");
        rg_NSObjectMetaClass = objc_getMetaClass("NSObject");
        rg_NSManagedObject = objc_getClass("NSManagedObject");
        rg_NSEntityDescription = objc_getClass("NSEntityDescription");
    });
}

@end
