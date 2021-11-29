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

#import "GoogleDataTransport/GDTCCTTests/Unit/Helpers/GDTCCTTestRequestParser.h"

#import <nanopb/pb.h>
#import <nanopb/pb_decode.h>
#import <nanopb/pb_encode.h>

@interface NSData (GDTCOREventDataObject) <GDTCOREventDataObject>
@end

@implementation NSData (GDTCOREventDataObject)

- (NSData *)transportBytes {
  return [self copy];
}

@end

@implementation GDTCCTTestRequestParser

+ (gdt_cct_BatchedLogRequest)requestWithData:(NSData *)data error:(NSError **)outError {
  gdt_cct_BatchedLogRequest request = gdt_cct_BatchedLogRequest_init_default;
  pb_istream_t istream = pb_istream_from_buffer([data bytes], [data length]);
  if (!pb_decode(&istream, gdt_cct_BatchedLogRequest_fields, &request)) {
    NSString *nanopb_error = [NSString stringWithFormat:@"%s", PB_GET_ERROR(&istream)];
    NSDictionary *userInfo = @{@"nanopb error:" : nanopb_error};
    if (outError != NULL) {
      *outError = [NSError errorWithDomain:NSURLErrorDomain code:-1 userInfo:userInfo];
    }
  }
  return request;
}

+ (NSArray<GDTCOREvent *> *)eventsWithBatchRequest:(gdt_cct_BatchedLogRequest)batchRequest
                                             error:(NSError **)outError {
  NSMutableArray<GDTCOREvent *> *events = [NSMutableArray array];

  for (NSUInteger reqIdx = 0; reqIdx < batchRequest.log_request_count; reqIdx++) {
    gdt_cct_LogRequest request = batchRequest.log_request[reqIdx];

    NSString *mappingID = @(request.log_source).stringValue;

    for (NSUInteger eventIdx = 0; eventIdx < request.log_event_count; eventIdx++) {
      gdt_cct_LogEvent event = request.log_event[eventIdx];

      GDTCOREvent *decodedEvent = [[GDTCOREvent alloc] initWithMappingID:mappingID
                                                                  target:kGDTCORTargetTest];
      decodedEvent.dataObject = [NSData dataWithBytes:event.source_extension->bytes
                                               length:event.source_extension->size];

      [events addObject:decodedEvent];
    }
  }

  return [events copy];
}

+ (gdt_client_metrics_ClientMetrics)clientMetricsWithData:(NSData *)data
                                                    error:(NSError **)outError {
  gdt_client_metrics_ClientMetrics clientMetrics = gdt_client_metrics_ClientMetrics_init_zero;

  pb_istream_t istream = pb_istream_from_buffer([data bytes], [data length]);
  if (!pb_decode(&istream, gdt_client_metrics_ClientMetrics_fields, &clientMetrics)) {
    NSString *nanopb_error = [NSString stringWithFormat:@"%s", PB_GET_ERROR(&istream)];
    NSDictionary *userInfo = @{@"nanopb error:" : nanopb_error};
    if (outError != NULL) {
      *outError = [NSError errorWithDomain:@"GDTCCTTestRequestParser" code:-1 userInfo:userInfo];
    }
  }

  if (clientMetrics.log_source_metrics == NULL && outError != NULL) {
    NSString *errorInfo = @"Failed to parse required fields.";
    *outError = [NSError errorWithDomain:@"GDTCCTTestRequestParser"
                                    code:-1
                                userInfo:@{NSLocalizedFailureReasonErrorKey : errorInfo}];
  }

  return clientMetrics;
}

@end
