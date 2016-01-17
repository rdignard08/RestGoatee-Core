# RestGoatee CHANGELOG

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
