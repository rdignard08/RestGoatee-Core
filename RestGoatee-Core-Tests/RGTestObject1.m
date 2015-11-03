
#import "RGTestObject1.h"
#import "RestGoatee-Core.h"

@implementation RGTestObject1

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ %@", [super description], [self dictionaryRepresentation]];
}

@end
