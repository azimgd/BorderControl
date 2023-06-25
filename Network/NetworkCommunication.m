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

  if (error) {
    return NSLog(@"[border-control-network] websocket error converting json object to data: %@", error);
  }
  
  if (self.webSocket.readyState == SR_OPEN) {
    [self.webSocket sendData:data error:&error];
  } else {
    NSLog(@"[border-control-network] websocket connection is not setup");
  }
}

- (void)disconnect {
  [self.webSocket close];
  self.webSocket = nil;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
  NSLog(@"[border-control-network] websocket connection opened");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
  NSLog(@"[border-control-network] websocket received message: %@", message);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
  NSLog(@"[border-control-network] websocket failed with error: %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
  NSLog(@"[border-control-network] websocket closed with code: %ld reason: %@ clean: %d", (long)code, reason, wasClean);
}

@end
