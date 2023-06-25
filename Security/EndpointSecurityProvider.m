//
//  EndpointSecurityProvider.m
//  Security
//
//  Created by azimgd on 25.06.2023.
//

#import <Foundation/Foundation.h>
#import "EndpointSecurityProvider.h"
#import "SecurityCommunication.h"

NSString* convert(es_string_token_t* stringToken){
  return [[NSString alloc] initWithBytes:stringToken->data length:stringToken->length encoding:NSUTF8StringEncoding];
}

@implementation EndpointSecurityProvider

static SecurityCommunication *securityCommunication;

- (void)handleMessage:(const es_message_t *)message {
  if (message->event_type == ES_EVENT_TYPE_NOTIFY_OPEN) {
    NSDictionary *payload = @{
      @"event": @"open",
      @"destination": [[NSString alloc] initWithFormat:@"%s", message->event.open.file->path.data]
    };
    [securityCommunication dispatch:payload];
  }
  else if (message->event_type == ES_EVENT_TYPE_NOTIFY_CLOSE) {
    NSDictionary *payload = @{
      @"event": @"close",
      @"destination": [[NSString alloc] initWithFormat:@"%s", message->event.close.target->path.data]
    };
    [securityCommunication dispatch:payload];
  }
  else if (message->event_type == ES_EVENT_TYPE_NOTIFY_WRITE) {
    NSDictionary *payload = @{
      @"event": @"write",
      @"destination": [[NSString alloc] initWithFormat:@"%s", message->event.write.target->path.data]
    };
    [securityCommunication dispatch:payload];
  }
  else if (message->event_type == ES_EVENT_TYPE_NOTIFY_CREATE) {
    NSDictionary *payload = @{
      @"event": @"create",
      @"destination": [[NSString alloc] initWithFormat:@"%s", message->event.create.destination.new_path.filename.data]
    };
    [securityCommunication dispatch:payload];
  }
  else {}
}

- (void)start {
  securityCommunication = [SecurityCommunication new];
  [securityCommunication connect];

  es_new_client_result_t newClientResult = es_new_client(&_client, ^(es_client_t *client, const es_message_t *message) {
    [self handleMessage:message];
  });
  
  switch (newClientResult) {
    case ES_NEW_CLIENT_RESULT_SUCCESS:
      break;
    case ES_NEW_CLIENT_RESULT_ERR_NOT_ENTITLED:
      NSLog(@"[border-control-security] endpoint framework extension is missing entitlement");
      break;
    case ES_NEW_CLIENT_RESULT_ERR_NOT_PRIVILEGED:
      NSLog(@"[border-control-security] endpoint framework extension is not running as root");
      break;
    case ES_NEW_CLIENT_RESULT_ERR_NOT_PERMITTED:
      NSLog(@"[border-control-security] endpoint framework perform Transparency, Consent and Control (TCC) approval");
      break;
    case ES_NEW_CLIENT_RESULT_ERR_INVALID_ARGUMENT:
      NSLog(@"[border-control-security] endpoint framework invalid argument to es_new_client(); client or handler was null");
      break;
    case ES_NEW_CLIENT_RESULT_ERR_TOO_MANY_CLIENTS:
      NSLog(@"[border-control-security] endpoint framework exceeded maximum number of simultaneously-connected ES clients");
      break;
    case ES_NEW_CLIENT_RESULT_ERR_INTERNAL:
      NSLog(@"[border-control-security] endpoint framework failed to connect to the Endpoint Security subsystem");
      break;
  }
  
  NSArray<NSString *> *paths = @[
    @"/Applications/",
    @"/bin/",
    @"/cores/",
    @"/dev/",
    @"/Library/",
    @"/opt/",
    @"/private/",
    @"/sbin/",
    @"/System/",
    @"/usr/",
    @"/var/",
  ];
  
  for (NSString *path in paths) {
    es_mute_path(_client, [path UTF8String], ES_MUTE_PATH_TYPE_PREFIX);
  }

  es_mute_path(_client, [NSProcessInfo.processInfo.arguments[0] UTF8String], ES_MUTE_PATH_TYPE_LITERAL);
  es_mute_path(_client, "/dev/ttys001", ES_MUTE_PATH_TYPE_LITERAL);
}

- (void)subscribe {
  es_event_type_t events[] = {
    ES_EVENT_TYPE_NOTIFY_CREATE,
    ES_EVENT_TYPE_NOTIFY_OPEN,
    ES_EVENT_TYPE_NOTIFY_RENAME,
    ES_EVENT_TYPE_NOTIFY_CLOSE,
    ES_EVENT_TYPE_NOTIFY_WRITE,
    ES_EVENT_TYPE_NOTIFY_UNLINK,
    ES_EVENT_TYPE_NOTIFY_EXIT
  };

  es_return_t subscribeResult = es_subscribe(self.client, events, sizeof(events) / sizeof(events[0]));
  
  if (subscribeResult != ES_RETURN_SUCCESS) {
    NSLog(@"[border-control-security] endpoint framework failed to subscribe to event");
  } else {
    NSLog(@"[border-control-security] endpoint framework successfully subscribed to event");
  }
}

@end
