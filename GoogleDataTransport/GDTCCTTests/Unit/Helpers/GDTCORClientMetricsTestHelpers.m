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

#import "GoogleDataTransport/GDTCCTTests/Unit/Helpers/GDTCORClientMetricsTestHelpers.h"

#import "GoogleDataTransport/GDTCORLibrary/ClientMetrics/GDTCORDroppedEventsCounter.h"
#import "GoogleDataTransport/GDTCCTLibrary/GDTCORClientMetrics+GDTCCTSupport.h"

@implementation GDTCORClientMetricsTestHelpers

+ (void)assertMetrics:(GDTCORClientMetrics *)metrics
    correspondToProto:(gdt_client_metrics_ClientMetrics)metricsProto {

  // Verify storage metrics.
  XCTAssertEqual(metricsProto.global_metrics.storage_metrics.current_cache_size_bytes,
                 metrics.currentStorageSize);
  XCTAssertEqual(metricsProto.global_metrics.storage_metrics.max_cache_size_bytes,
                 metrics.maximumStorageSize);

  // Verify log source metrics.
  XCTAssertEqual(metricsProto.log_source_metrics_count,
                 metrics.droppedEventsByMappingID.count);

  for (int logSourceIndex = 0; logSourceIndex < metricsProto.log_source_metrics_count;
       logSourceIndex++) {
    gdt_client_metrics_LogSourceMetrics decodedLogSourceMetrics =
        metricsProto.log_source_metrics[logSourceIndex];

    // Verify log source (mapping ID).
    NSString *mappingID = [[NSString alloc] initWithBytes:decodedLogSourceMetrics.log_source->bytes
                                                   length:decodedLogSourceMetrics.log_source->size
                                                 encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(mappingID);

    NSArray<GDTCORDroppedEventsCounter *> *originalEvents =
        metrics.droppedEventsByMappingID[mappingID];
    XCTAssertNotNil(originalEvents);

    // Verify dropped event counters.
    XCTAssertEqual(decodedLogSourceMetrics.log_event_dropped_count, originalEvents.count);
    for (int droppedEventsIndex = 1;
         droppedEventsIndex < decodedLogSourceMetrics.log_event_dropped_count;
         droppedEventsIndex++) {
      gdt_client_metrics_LogEventDropped decodedDroppedEvent =
          decodedLogSourceMetrics.log_event_dropped[droppedEventsIndex];

      GDTCORDroppedEventsCounter *originalDroppedEvent = originalEvents[droppedEventsIndex];

      XCTAssertEqual(decodedDroppedEvent.events_dropped_count, originalDroppedEvent.eventCount);
      XCTAssertEqual([self dropReasonForProtoReason:decodedDroppedEvent.reason],
                     originalDroppedEvent.dropReason);
    }
  }
}

+ (GDTCOREventDropReason)dropReasonForProtoReason:
    (gdt_client_metrics_LogEventDropped_Reason)protoReason {
  switch (protoReason) {
    case gdt_client_metrics_LogEventDropped_Reason_REASON_UNKNOWN:
      return GDTCOREventDropReasonUnknown;
    case gdt_client_metrics_LogEventDropped_Reason_MESSAGE_TOO_OLD:
      return GDTCOREventDropReasonMessageTooOld;
    case gdt_client_metrics_LogEventDropped_Reason_CACHE_FULL:
      return GDTCOREventDropReasonStorageFull;
    case gdt_client_metrics_LogEventDropped_Reason_PAYLOAD_TOO_BIG:
      return GDTCOREventDropReasonUnknown;
    case gdt_client_metrics_LogEventDropped_Reason_MAX_RETRIES_REACHED:
      return GDTCOREventDropReasonMaxRetriesReached;
    case gdt_client_metrics_LogEventDropped_Reason_INVALID_PAYLOD:
      return GDTCOREventDropReasonServerError;
    case gdt_client_metrics_LogEventDropped_Reason_SERVER_ERROR:
      return GDTCOREventDropReasonServerError;
  }
}

+ (NSDictionary<NSString *, NSArray<GDTCORDroppedEventsCounter *> *> *)
    generateDroppedEventByMappingID {
  NSInteger numberOfMappingIDs = 10;
  NSMutableDictionary<NSString *, NSArray<GDTCORDroppedEventsCounter *> *>
      *droppedEventsByMappingID = [NSMutableDictionary dictionaryWithCapacity:numberOfMappingIDs];

  for (NSInteger i = 0; i < numberOfMappingIDs; i++) {
    NSString *mappingID = @(i).stringValue;
    __auto_type droppedEvents = [self generateDroppedEventsWithMappingID:mappingID];
    droppedEventsByMappingID[mappingID] = droppedEvents;
  }

  return droppedEventsByMappingID;
}

+ (NSArray<GDTCORDroppedEventsCounter *> *)generateDroppedEventsWithMappingID:
    (NSString *)mappingID {
  NSMutableArray<GDTCORDroppedEventsCounter *> *events = [NSMutableArray array];
  for (GDTCOREventDropReason reason = GDTCOREventDropReasonUnknown;
       reason < GDTCOREventDropReasonServerError; reason++) {
    NSInteger randomEventCount = arc4random_uniform(100000) + 1;
    [events addObject:[[GDTCORDroppedEventsCounter alloc] initWithEventCount:randomEventCount
                                                                  dropReason:reason
                                                                   mappingID:mappingID]];
  }
  return [events copy];
}

@end
