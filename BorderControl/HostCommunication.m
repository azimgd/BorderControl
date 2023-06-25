//
//  HostCommunication.m
//  BorderControl
//
//  Created by azimgd on 24.06.2023.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>
#import "HostCommunication.h"

@implementation HostCommunication

- (void)connect {
  self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://localhost:7991"]];
  self.webSocket.delegate = self;
  [self.webSocket open];
}

- (void)dispatch:(NSDictionary *)payload {
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];

  if (error) {
    return NSLog(@"[border-control-host] websocket error converting json object to data: %@", error);
  }
  
  if (self.webSocket.readyState == SR_OPEN) {
    [self.webSocket sendData:data error:&error];
  } else {
    NSLog(@"[border-control-host] websocket connection is not setup");
  }
}

- (void)disconnect {
  [self.webSocket close];
  self.webSocket = nil;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
  NSLog(@"[border-control-host] websocket connection opened");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
  NSLog(@"[border-control-host] websocket received message: %@", message);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
  NSLog(@"[border-control-host] websocket failed with error: %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
  NSLog(@"[border-control-host] websocket closed with code: %ld reason: %@ clean: %d", (long)code, reason, wasClean);
}

@end
