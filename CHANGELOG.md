# Version History

## 2.5.5
- `ONLY_ACTIVE_ARCH` is set to `NO` for all debug framework targets

## 2.5.4
- `RGLog()` needs to use the GNU block extention for compatibility

## 2.5.3
- New method `-[NSObject rg_stringValue]` which is programmatically more predicatable for certain classes
- Replace usage of `-[NSObject description]` with `-[NSObject rg_stringValue]`
- Marked macro `RGLog` as deprecated
- `-[NSObject dictionaryRepresentation]` is now documented to raise an exception for weird receivers

## 2.5.2
- There is now a new log function `rg_log_severity` with the macro `RGLogs` to better enable use
- The macro `RGLog` now uses the new log function, but behavior should remain the same
- Users with release mode builds which use assertions will compile without modification

## 2.5.1
- `RG_STRING_SEL` macro does not add any runtime overhead, needs `DEBUG` defined to check spelling

## 2.5.0
- `rg_swizzle` has been removed from the library's product as it was only used by the test target
- `const` on return value warnings have been fixed
- OCLint scheme and script are fixed and buildable

## 2.4.5
- Duplicated framework Info.plist and umbrella headers have been consolidated to a single set
- Module map is now explicit
- Fixed a warning from RGPropertyDeclaration.h not being marked private
- Removed static lib target
- Release configuration builds will have optimizations enabled
- `GCC_SYMBOLS_PRIVATE_EXTERN` is no longer in effect

## 2.4.4
- Fixed building on projects without implicit Foundation

## 2.4.3
- Added framework targets for OS X, watchOS, and tvOS
- Podspec now correctly shows support for watchOS 1.0

## 2.4.2
- Fixed a warning that appeared when the project is compiled in release configuration
- Test host is upgraded to iOS 9.2

## 2.4.1
- Provide a shared scheme and framework target to support Carthage

## 2.4.0
- Certain functions taking C strings now take a buffer and length instead
- `RGPropertyDeclaration` is based on `property_getAttributes` instead of `property_copyAttributeList`
- `RGPropertyDeclaration` has new properties: `backingIvar`, `isDynamic`, `isAtomic`, `getter`, `setter`, `isGarbageCollectible`

## 2.3.0
- Restored 100% coverage
- `RGDataSource` objects no longer need to conform to `NSFastEnumeration`
- `attributes` on `RGXMLNode` is no longer assignable; modify the object itself
- `objectsFromArraySource:inContext:` now only accepts an `NSArray*` as input

## 2.2.1
- The backing symbol of `RGLog()`, `rg_log`, is gone
- The symbol `rg_date_formats` is a function pointer
- oclint_run.sh now uses xcpretty

## 2.2.0
- The symbols of the form `rg_...` are now of the form `kRG...`
- `parentNode` on `RGXMLNode` is now writable
- `rootNode` on `RGXMLSerializer` is now null resettable
- Legacy runtime support (Properties encoded as 't...' instead of modern 'T...') is removed
- `RGPropertyDeclaration` now has properties `isFloatingPoint` and `isIntegral` to describe primitives
- `readOnly` on `RGPropertyDeclaration` renamed `isReadOnly`
- Initializing an aggregate primitive type will explicitly fail
- New symbol `kRGNumberFormatKey` used on `NSThread`'s dictionary
- The symbol `rg_dateFormats` is now `rg_date_formats`
- `rg_number_formatter()` is available to return a thread safe `NSNumberFormatter`
- `rg_is_integral_encoding()`, `rg_is_floating_encoding()`, `rg_to_string()` are available
- `name` and `innerXML` on `RGXMLNode` are copy to prevent later mutation
- Rule changes:
  - A self-closing XML tag targeting an `NSNumber` will leave it `nil` rather than `@0`
  - A self-closing XML tag targeting an `NSString` will leave it `nil` rather than `@""`
  - A self-closing XML tag targeting an `NSDecimalNumber` will leave it `nil` rather than `+notANumber`
  - An `NSArray` may no long initialize an `NSString` / `NSURL` type
  - `id` and `NSObject` properties now correctly get assigned `NSNull`
  - An `NSNumber` may now technically intialize an `NSDate` (perhaps useful for timestamps?)
  - An `RGXMLNode` targeting an `NSArray` property will also have its children unpacked

## 2.1.5
- `<objc/runtime.h>` will no longer be included with the public headers
- `RGXMLSerializer` will now raise exceptions on malformed XML instead of issuing warnings

## 2.1.4
- `objectsFromArraySource:inContext:` now correctly indicates that the return values are a kind of `NSObject` not `id`
- `RGLog()` is slightly faster (again)

## 2.1.3
- Project is once again has 100% branch coverage
- `childNodes` is now exposed as `NSMutableArray` (it always was)
- Iterating over `RGXMLNode` is slightly faster

## 2.1.2
- `RGLog()` does not accept `nil` as input.
- `RGLog()` is slightly faster.
- `-[RGXMLSerializer initWithParser:]` is now the designated initializer.

## 2.1.1
- Missing license declaration on some files.
- The macros `RG_FILE_START` & `RG_FILE_END` are gone.
- Project no longer has a prefix header.
- All defined constants should be visible outside of the project.

## 2.1.0
- May no longer create an `RGXMLNode` without a name
  - The document node now has a name `kRGXMLDocumentNodeKey`
- Fixed leak in initialization
- No longer converts a compatible array of objects into a single property of that type
- The project is completely tested

## 2.0.5
- Add deployment targets for OS X, TvOS, and WatchOS

## 2.0.4
- Basic swift package manager support.

## 2.0.3
- A new NSDateFormatter is not allocated for each date property.  These are reused across threads.
- rg_threadsafe_formatter is available for use, do not leave the object's properties modified.
- Fix nullability warnings in the project.
- Nothing is assumed nonnull, as the whole library has been audited.
- Fixed a bug preventing dictionaryRepresentation from working.
- NSException raise:... have been replaced with `NSAssert`.
- Speed up of about 50% for calls to `rg_canonical_form` with a small string.
- Fix leak in RGPropertyDeclaration setup code.
- The property name on `RGXMLNode` is now nonnull (this was true before).
- corrected and expanded some document comments.
- Speed up in calls to `RGLog()`.
- `RGLog(nil)` will print "(null)" instead of the empty string.

## 0.1.0

Initial release.
