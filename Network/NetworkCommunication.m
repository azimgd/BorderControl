//
//  NetworkCommunication.m
//  BorderControl
//
//  Created by azimgd on 24.06.2023.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>
#import "NetworkCommunication.h"

@implementation NetworkCommunication

- (void)connect {
  self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://localhost:8080"]];
  self.webSocket.delegate = self;
  [self.webSocket open];
}

- (void)dispatch:(NSDictionary *)payload {
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];

  if (!error) {
    if (self.webSocket.readyState == SR_OPEN) {
      [self.webSocket sendData:data error:&error];
    } else {
      NSLog(@"WebSocket connection is not open");
    }
  } else {
    NSLog(@"Error converting JSON object to data: %@", error);
  }
}

- (void)disconnect {
  [self.webSocket close];
  self.webSocket = nil;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
  NSLog(@"WebSocket connection opened");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
  NSLog(@"Received message: %@", message);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
  NSLog(@"WebSocket failed with error: %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
  NSLog(@"WebSocket closed with code: %ld reason: %@ clean: %d", (long)code, reason, wasClean);
}

@end
