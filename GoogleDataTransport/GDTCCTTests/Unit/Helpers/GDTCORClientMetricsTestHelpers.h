/*
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#include "GoogleDataTransport/GDTCCTLibrary/Protogen/nanopb/client_metrics.nanopb.h"

@class GDTCORClientMetrics;
@class GDTCORDroppedEventsCounter;

NS_ASSUME_NONNULL_BEGIN

@interface GDTCORClientMetricsTestHelpers : NSObject

/// Uses `XCTAssert` macros to validate if `metricsProto` contains all information from `metrics`.
+ (void)assertMetrics:(GDTCORClientMetrics *)metrics
    correspondToProto:(gdt_client_metrics_ClientMetrics)metricsProto;

/// Generates a random dropped events counters with enumeration of all possible reasons to populate
/// `GDTCORClientMetrics.droppedEventsByMappingID`.
+ (NSDictionary<NSString *, NSArray<GDTCORDroppedEventsCounter *> *> *)
    generateDroppedEventByMappingID;

/// Generates an array  with `GDTCORDroppedEventsCounter` instances for each possible drop reason
/// with a random count for the specified mapping ID.
+ (NSArray<GDTCORDroppedEventsCounter *> *)generateDroppedEventsWithMappingID:(NSString *)mappingID;

@end

NS_ASSUME_NONNULL_END
