
General
======

- A class prefix is required
  - Minimum of 2 uppercase characters, recommendation is 3
- A tab means 4 spaces
- No new line may be adjacent to another
  - In the case that these guidelines create multiple adjacent new lines, they are combined into a single instance
- `extern` should always appear first
- `const` applied to a pointer should have a space between the `*` and `const`
- limit lines to 120 characters

Preprocessor
======

- General
  - Preprocessor declarations should be tab indented by the number of nestings
    - Number of nestings increase when the line starts with `#if`, `#ifdef`, or `#ifndef`
    - Number of nestings decrease when the line starts with `#endif`
    - Number of nestings is temporarily reduced by 1 when the line starts with `#else`  
  - No space(s) should appear between the `#` and the preprocessor declaration
  
- Headers
  - Files containing Objective-C should use `#import`; all others use `#include`
  - A single space should follow `#import` or `#include`
  - A header file should import other headers that are strictly necessary
    - If it's possible to not include it, do not include it
  - In an implementation file, the first include should always be thee file containing the interface.

- Macros
  - Should be all capitalized with spaces denoted as underscores
  - Should be prefixed, the prefix ought to be the class prefix followed by an underscore
  - Should be `#if`, `#ifdef`, `#ifndef` tested before `#define`
  - Should wrap their replacement in parentheses
  - Should be defined at the top of the file after imported headers
  - Should not be used for string constants
  - Should not be used for code generation

File scope
======

- All symbols with external linkage (`extern` or not specfied) should be prefixed with the lowercase class prefix and a `_`
- If initialized at runtime, should be thread-safe with `dispatch_once`
- Should not be `nil`, `Nil`, `NULL`, `'\0'`, `0`, `0.0` defined.
    - If that value is desired, leave the declaration without definition.

- External
  - In the header file the identifier should be declared `extern`
  - If the value in not provided at runtime
    - If it's a pointer, the pointer should be `const`
    - Otherwise the value should be `const`
  - If the value is provided at runtime omit `const`
  - In the implementation file define the identifier the same as declared in the header file

- Static
  - Should not appear in the header file
  - Should be declared `static`
  
- C Functions
  - Identifiers should be prefixed with the lowercase class prefix and an underscore
  - Identifiers should be all lowercase with underscores used for spaces
  - When taking no arguments, the argument list declared `(void)`
  - A space will appear between the return type and the identifier
  - No space will appear between the identifier and argument list
  - No space will appear before the first argument or after the last argument
  - A space will appear after each `,` in the argument list

- Class Interface
  - Should declare the absolute minimum
    - Protocol conformance should only be declared publicly if another class needs it
    - Absolutely no ivars 
    - Properties should not be declared publicly 
    - Methods should only be as necessary
  - Prefer simple initializers, preferably `init`
    - Expose properties instead of complex initializers

Loops
=====

- For in
  - Do not place `__strong` in the iterator condition
  - Do not modify the temporary iterator variable
- For
  - Should only be used if all statements are need: initial statement, condition, and step statement
