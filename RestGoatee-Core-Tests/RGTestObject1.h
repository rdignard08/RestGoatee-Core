
@class RGTestObject2;

@interface RGTestObject1 : NSObject

@property (nonatomic, strong) NSString* stringProperty;
@property (nonatomic, strong) NSMutableString* mutableProperty;
@property (nonatomic, strong) NSURL* urlProperty;
@property (nonatomic, strong) NSNumber* numberProperty;
@property (nonatomic, strong) NSDecimalNumber* decimalProperty;
@property (nonatomic, strong) NSValue* valueProperty;
@property (nonatomic, strong) id idProperty;
@property (nonatomic, strong) Class classProperty;
@property (nonatomic, strong) NSArray* arrayProperty;
@property (nonatomic, strong) NSDictionary* dictionaryProperty;
@property (nonatomic, assign) unsigned long longProperty;
@property (nonatomic, assign) double doubleProperty;
@property (nonatomic, assign) NSRange rangeProperty;

@end
