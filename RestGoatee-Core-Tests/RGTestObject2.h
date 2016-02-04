
#import "RGTestObject1.h"

@interface RGTestObject2 : RGTestObject1

@property (nonatomic, strong) NSObject* objectProperty;
@property (nonatomic, strong) NSDate* dateProperty;
@property (nonatomic, weak) NSString* weakProperty;
@property (nonatomic, assign) NSInteger intProperty;
@property (nonatomic, strong, readonly) id readOnlyProperty;
@property (nonatomic, strong) RGTestObject1* subObject;
@property (nonatomic, strong) NSArray* arrayOfSubObj;
@property (nonatomic, assign) float floatProperty;

@end
