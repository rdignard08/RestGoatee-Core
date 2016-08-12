/* Copyright (c) 11/19/2015, Ryan Dignard
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

#import "RestGoatee-Core.h"

CLASS_SPEC(RestGoatee_Core)

#pragma mark - rg_log
- (void) testRGLogNormal {
    XCTAssertNoThrow(RGLogs(kRGLogSeverityDebug, @"hello"));
}

- (void) testRGLogNil {
    rg_set_logging_severity(kRGLogSeverityDebug);
    XCTAssertThrows(RGLogs(kRGLogSeverityDebug, (NSString* RG_SUFFIX_NONNULL)nil));
}

#pragma mark - rg_threadsafe_formatter
- (void) testRGThreadSafeFormatterSame {
    NSDateFormatter* formatter = rg_threadsafe_formatter();
    NSDateFormatter* anotherFormatter = rg_threadsafe_formatter();
    XCTAssert(formatter == anotherFormatter);
}

- (void) testRGThreadSafeFormatterDiffered {
    NSDateFormatter* formatter = rg_threadsafe_formatter();
    __block NSDateFormatter* anotherFormatter;
    dispatch_queue_t backgroundQueue = dispatch_queue_create("background", DISPATCH_QUEUE_SERIAL);
    dispatch_async(backgroundQueue, ^{
        anotherFormatter = rg_threadsafe_formatter();
    });
    dispatch_sync(backgroundQueue, ^{}); // apple's so smart dispatch_sync will lie.
    XCTAssert(formatter != anotherFormatter);
}

#pragma mark - rg_number_formatter
- (void) testRGNumberFormatterSame {
    id formatter = rg_number_formatter();
    id anotherFormatter = rg_number_formatter();
    XCTAssert(formatter == anotherFormatter);
}

- (void) testRGNumberFormatterDifferent {
    id formatter = rg_number_formatter();
    __block id anotherFormatter;
    dispatch_queue_t backgroundQueue = dispatch_queue_create("background", DISPATCH_QUEUE_SERIAL);
    dispatch_async(backgroundQueue, ^{
        anotherFormatter = rg_number_formatter();
    });
    dispatch_sync(backgroundQueue, ^{});
    XCTAssert(formatter != anotherFormatter);
}

#pragma mark - rg_unpack_array
- (void) testRGUnpackArrayWithNil {
    NSArray *values = rg_unpack_array(nil, nil);
    XCTAssert(values.count == 0);
}

#pragma mark - rg_log_severity
- (void) testTraceMessageLogs {
    rg_set_logging_severity(kRGLogSeverityTrace);
    RGLogs(kRGLogSeverityTrace, @"Hello Trace");
}

- (void) testDebugMessageLogs {
    rg_set_logging_severity(kRGLogSeverityDebug);
    RGLogs(kRGLogSeverityDebug, @"Hello Debug");
}

- (void) testWarnMessageLogs {
    rg_set_logging_severity(kRGLogSeverityWarning);
    RGLogs(kRGLogSeverityWarning, @"Hello Warn");
}

- (void) testWarnMessageDoesntLog {
    rg_set_logging_severity(kRGLogSeverityError);
    RGLogs(kRGLogSeverityWarning, @"No Warn");
}

- (void) testErrorMessageLogs {
    rg_set_logging_severity(kRGLogSeverityError);
    RGLogs(kRGLogSeverityError, @"Hello Error");
}

- (void) testFatalMessageLogs {
    rg_set_logging_severity(kRGLogSeverityFatal);
    RGLogs(kRGLogSeverityFatal, @"Hello Fatal");
}

- (void) testNoneMessageLogs {
    rg_set_logging_severity(kRGLogSeverityNone);
    RGLogs(kRGLogSeverityNone, @"Hello None");
}

SPEC_END

