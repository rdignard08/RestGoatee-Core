# RestGoatee CHANGELOG

## 2.1.0
- May no longer create an RGXMLNode without a name
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
- NSException raise:... have been replaced with NSAssert.
- Speed up of about 50% for calls to rg_canonical_form with a small string.
- Fix leak in RGPropertyDeclaration setup code.
- The property name on RGXMLNode is now nonnull (this was true before).
- corrected and expanded some document comments.
- Speed up in calls to RGLog().
- RGLog(nil) will print (null) instead of the empty string.

## 0.1.0

Initial release.
