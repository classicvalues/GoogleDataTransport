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

#import <XCTest/XCTest.h>

#import "GoogleDataTransport/GDTCCTLibrary/GDTCORClientMetrics+GDTCCTSupport.h"

#import "GoogleDataTransport/GDTCCTTests/Unit/Helpers/GDTCCTTestRequestParser.h"
#import "GoogleDataTransport/GDTCORLibrary/ClientMetrics/GDTCORDroppedEventsCounter.h"

#import "GoogleDataTransport/GDTCCTTests/Unit/Helpers/GDTCORClientMetricsTestHelpers.h"

@interface GDTCORClientMetrics_GDTCCTSupportTests : XCTestCase

@end

@implementation GDTCORClientMetrics_GDTCCTSupportTests

- (void)testTransportBytes {
  GDTCORClientMetrics *clientMetrics = [[GDTCORClientMetrics alloc]
      initWithCurrentStorageSize:1234
              maximumStorageSize:5678
        droppedEventsByMappingID:[GDTCORClientMetricsTestHelpers generateDroppedEventByMappingID]];

  // Try to encode the metrics.
  NSData *encodedMetrics = [clientMetrics transportBytes];
  XCTAssertNotNil(encodedMetrics);
  XCTAssertGreaterThan(encodedMetrics.length, 0);

  // Try to decode.
  NSError *decodingError;
  gdt_client_metrics_ClientMetrics decodedMetrics =
      [GDTCCTTestRequestParser clientMetricsWithData:encodedMetrics error:&decodingError];
  XCTAssertNil(decodingError);

  // Verify decoded metrics.
  [GDTCORClientMetricsTestHelpers assertMetrics:clientMetrics correspondToProto:decodedMetrics];
}

@end
