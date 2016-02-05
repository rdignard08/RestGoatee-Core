//
//  RGTestObject4.m
//  RestGoatee-Core
//
//  Created by Ryan Dignard on 2/4/16.
//  Copyright © 2016 RestGoatee. All rights reserved.
//

#import "RGTestObject4.h"

@implementation RGTestObject4

+ (RG_PREFIX_NULLABLE NSDictionary*) overrideKeysForMapping {
    return @{ RG_STRING_SEL(stringProperty) : RG_STRING_SEL(numberProperty) };
}

+ (RG_PREFIX_NULLABLE NSString*) dateFormatForProperty:(RG_PREFIX_NONNULL NSString* __unused)propertyName {
    return @"dd/MM/yyyy";
}

- (BOOL) shouldTransformValue:(RG_PREFIX_NULLABLE __unused id)value forProperty:(RG_PREFIX_NONNULL NSString*)propertyName inContext:(RG_PREFIX_NULLABLE __unused NSManagedObjectContext*)context {
    if ([propertyName isEqual:RG_STRING_SEL(idProperty)]) {
        self.idProperty = @"foobaz";
        return NO;
    }
    return YES;
}

@end
