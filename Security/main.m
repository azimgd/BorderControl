//
//  main.m
//  Security
//
//  Created by azimgd on 25.06.2023.
//

#import <Foundation/Foundation.h>
#import <EndpointSecurity/EndpointSecurity.h>

int main(int argc, const char *argv[])
{
  es_client_t *client = NULL;
  es_new_client_result_t newClientResult =
  es_new_client(&client, ^(es_client_t * client, const es_message_t * message) {
    switch (message->event_type) {
      case ES_EVENT_TYPE_AUTH_EXEC:
        es_respond_auth_result(client, message, ES_AUTH_RESULT_ALLOW, true);
        break;
      default:
        NSLog(@"[border-control-security] endpoint framework unexpected event type: %i", message->event_type);
        break;
    }
  });

  // Handle any errors encountered while creating the client.
  switch (newClientResult) {
    case ES_NEW_CLIENT_RESULT_SUCCESS:
      // Client created successfully; continue.
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

  // Subscribe the client to the ES_EVENT_TYPE_AUTH_EXEC event.
  // When the client receives a message with this event type, it must authorize
  // (allow or deny) the event.
  es_event_type_t eventTypes[1] = { ES_EVENT_TYPE_AUTH_EXEC };
  es_return_t subscribeResult = es_subscribe(client, eventTypes, sizeof(eventTypes));
  
  if (subscribeResult != ES_RETURN_SUCCESS) {
    NSLog(@"[border-control-security] endpoint framework failed to subscribe to event");
  } else {
    NSLog(@"[border-control-security] endpoint framework successfully subscribed to event");
  }

  return 0;
}
