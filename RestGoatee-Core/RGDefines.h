/* Copyright (c) 6/22/14, Ryan Dignard
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

#define FILE_START \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wgnu\"") \
_Pragma("clang assume_nonnull begin")

#define FILE_END \
_Pragma("clang assume_nonnull end") \
_Pragma("clang diagnostic pop")

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"

#if __has_feature(nullability)
#define nullable_property(...) (nullable, ## __VA_ARGS__)
#define nonnull_property(...) (nonnull, ## __VA_ARGS__)
#define null_resettable_property(...) (null_resettable, ## __VA_ARGS__)
#define prefix_nullable nullable
#define suffix_nullable __nullable
#define prefix_nonnull nonnull
#define suffix_nonnull __nonnull
#else
#define nullable_property(...) (__VA_ARGS__)
#define nonnull_property(...) (__VA_ARGS__)
#define null_resettable_property(...) (__VA_ARGS__)
#define prefix_nullable
#define suffix_nullable
#define prefix_nonnull
#define suffix_nonnull
#endif

#if __has_feature(objc_generics)
#define GENERIC(...) < __VA_ARGS__ >
#else
#define GENERIC(...)
#endif

#pragma clang diagnostic pop

/* `NULL` and `nil` are typed `void*` and I need it to be typed `void` */
#define VOID_NOOP ((void)0)

/* enables a selector declarations to be used in place of an `NSString`, provides spell checking. */
#define STRING_SEL(sel) NSStringFromSelector(@selector(sel))