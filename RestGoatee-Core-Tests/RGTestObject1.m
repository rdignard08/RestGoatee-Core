
#import "RGTestObject1.h"

@implementation RGTestObject1

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ %@", [super description], [self dictionaryRepresentation]];
}

@end
