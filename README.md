[![Build Status](https://travis-ci.org/rdignard08/RestGoatee-Core.svg?branch=master)](https://travis-ci.org/rdignard08/RestGoatee-Core)
[![Coverage Status](https://codecov.io/github/rdignard08/RestGoatee-Core/coverage.svg?branch=master)](https://codecov.io/github/rdignard08/RestGoatee-Core?branch=master)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Pod Version](https://img.shields.io/cocoapods/v/RestGoatee-Core.svg)](https://cocoapods.org/pods/RestGoatee-Core)
[![Pod Platform](http://img.shields.io/cocoapods/p/RestGoatee-Core.svg?style=flat)](http://cocoadocs.org/docsets/RestGoatee-Core/)
[![Pod License](http://img.shields.io/cocoapods/l/RestGoatee-Core.svg?style=flat)](https://github.com/rdignard08/RestGoatee-Core/blob/master/LICENSE)

RestGoatee-Core
===============

RestGoatee-Core is a framework which takes raw `NSDictionary` and `NSXMLParser` objects and convienently converts them to your own domain models.

Supports: iOS 5.0+, requires ARC

This library's aim is one of simplicity in the common case and extensibility in the general case:<br/>
1) The act of translating a data source to a domain model is not the place for business logic or key translation.<br/>
2) The API layer should be able to handle new objects and object properties seemlessly without requiring new deserialization logic.  For example, this <a href="https://github.com/rdignard08/RestGoatee/commit/50b516c4e5377ef02a384b26ce94984655b424f0">commit</a> added an entirely new response object to the example project without fanfare.<br/>
3) Due to JSON and XML having limited types, the deserializer needs to be able to intelligently map to a larger standard family of types.<br/>
4) CoreData support is usually not done at the outset of a project; this library makes it easier to turn it on with minimal refactoring.  CoreData support is implicit, but inactive in projects without it.<br/>
5) The default mapping behavior should be both generally intuitive (correct 99% of the time) and extensible.<br/>
6) The default should be the least verbose in terms of complexity and lines of code.  You don't specify mappings for objects that are one-to-one, well named, and explicitly typed.

Why Use RestGoatee?
===================
Consider your favorite or most popular model framework:

  * Does it require mappings to build simple objects?  <img src="https://github.com/jloughry/Unicode/raw/master/graphics/red_x.png"/>
  * Does it support `NSManagedObject` subclasses? <img src="https://github.com/jloughry/Unicode/raw/master/graphics/green_check.png"/>
  * Does it understand the keys `foo-bar` `foo_bar` and `fooBar` are likely the same key? <img src="https://github.com/jloughry/Unicode/raw/master/graphics/green_check.png"/>
  * JSON or XML? <img src="https://github.com/jloughry/Unicode/raw/master/graphics/green_check.png"/>

# Installation
Using cocoapods add `pod 'RestGoatee-Core'` to your Podfile and run `pod install`.  People without cocoapods can include the top level folder "RestGoatee-Core" in their repository.  Include `#import <RestGoatee-Core.h>` to include all public headers and start using the library. 

Example
=======
##### Let's explore how to work with the given domain model:
```objc
@interface BaseObject : NSObject
@property (nonatomic, strong) NSString* stringValue;
@property (nonatomic, strong) NSNumber* numberValue;
@property (nonatomic, assign) double doubleValue;
@end

@interface DerivedObject : BaseObject
@property (nonatomic, strong) NSDate* dateValue;
@property (nonatomic, strong) id rawValue;
@end
```


##### Getting started, let's make an instance of DerivedObject with an NSDictionary:
```objc
DerivedObject* derived = [DerivedObject objectFromDataSource:@{
                                                             @"stringValue" : @"aString",
                                                             @"numberValue" : @3,
                                                             @"doubleValue" : @3.14,
                                                             @"dateValue" : @"2016-01-17T16:13:00-0800",
                                                             @"rawValue" : [NSNull null]
                                                             } inContext:nil];

assert([derived.stringValue isEqual:@"aString"]);
assert([derived.numberValue isEqual:@3]);
assert(derived.doubleValue == 3.14);
assert([derived.dateValue timeIntervalSince1970] == 1453075980.0);
assert(derived.rawValue == [NSNull null]);
```

##### What if not all properties are specified?
```objc
DerivedObject* derived = [DerivedObject objectFromDataSource:@{ @"stringValue" : @"aString" } inContext:nil];

assert([derived.stringValue isEqual:@"aString"]);
assert(derived.numberValue == nil);
assert(derived.doubleValue == 0.0);
```
If a value isn't provided it remains the default value.  Likewise if more keys are provided that aren't used they are ignored.

##### What if my API returns NSNull or the value?
```objc
DerivedObject* derived = [DerivedObject objectFromDataSource:@{ @"stringValue" : [NSNull null] } inContext:nil];

assert(derived.stringValue == nil);
```
The rules are pretty simple, and guarantee you will never break the type system (an `NSURL*` property will always have an `NSURL` or `nil`).
- If the value provided is a subclass of the property type it gets set to that value.
- If the value can be converted to the type of the property (`NSNumber` => `NSString` through `.stringValue`) it gets set to the converted value.
- Otherwise the property remains unset and the value is discarded.
- As a consequence, properties of type `id` or `NSObject*` will receive any value.

##### What if my API keys are snake case?
```objc
DerivedObject* derived = [DerivedObject objectFromDataSource:@{ @"string_value" : @"aString" } inContext:nil];

assert([derived.stringValue isEqual:@"aString"]);
```
Not CamelCase? No problem. The implicit mapping will handle all cases where the lowercase ASCII alphabet and numbers of the keys match.

##### What if my API keys are _really_ different?
```objc
@implementation DerivedObject

+ (NSDictionary*) overrideKeysForMapping {
    return @{ @"super_secret_str" : @"stringValue" };
}

@end

DerivedObject* derived = [DerivedObject objectFromDataSource:@{ @"super_secret_str" : @"aString" } inContext:nil];

assert([derived.stringValue isEqual:@"aString"]);
```
Providing `+overrideKeysForMapping` gives you the flexibility to map a key to the name of the property.  Any key not specified goes through the default process so you only need to specify the exceptions.

##### What if the default behavior doesn't do what I want?
```objc
@implementation DerivedObject

- (BOOL) shouldTransformValue:(id)value forProperty:(NSString*)propertyName {
    if ([propertyName isEqual:@"stringValue"]) {
        self.stringValue = [value description].uppercaseString;
        return NO;
    }
    return YES;
}

@end

DerivedObject* derived = [DerivedObject objectFromDataSource:@{ @"stringValue" : @"abcd" } inContext:nil];

assert([derived.stringValue isEqual:@"ABCD"]);
```
You can override `-shouldTransformValue:forProperty:` and return `NO` whenever you want to take control directly.

##### How does serialization work?
```objc
DerivedObject* derived = [DerviedObject new];
derived.stringValue = @"aString";
derived.numberValue = @3;
derived.doubleValue = 3.0;
NSDictionary* dictionaryRepresentation = [derived dictionaryRepresentation];

assert([dictionaryRepresentation[@"stringValue"] isEqual:@"aString"]);
assert([dictionaryRepresentation[@"numberValue"] isEqual:@"3"]);
assert([dictionaryRepresentation[@"doubleValue"] isEqual:@"3"]);
```
`-dictionaryRepresentation` returns a dictionary where the keys are the names of the properties and the values are the result of serializing that value.  A property of type `NSString*`, `NSURL*`, `NSNumber*`, or a primitive will be a value of `NSString*`.  `NSNull*` values stay the same.  `NSArray*`, `NSDictionary*`, and all other `NSObject*` subclasses are output by applying the same rules to their sub objects.

For an example of the use case see https://github.com/rdignard08/RestGoatee

License
=======
BSD Simplified (2-clause)
