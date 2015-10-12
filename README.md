[![Build Status](https://travis-ci.org/rdignard08/RestGoatee-Core.svg?branch=master)](https://travis-ci.org/rdignard08/RestGoatee-Core)
RestGoatee-Core
===============

RestGoatee-Core is a framework which takes raw `NSDictionary` and `NSXMLParser` objects and convienently converts them to your own domain models.

Supports: iOS 6.0+

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
For an example of the use case see https://github.com/rdignard08/RestGoatee

License
=======
BSD Simplified (2-clause)
