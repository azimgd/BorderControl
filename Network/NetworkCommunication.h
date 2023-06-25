//
//  NetworkCommunication.h
//  Network
//
//  Created by azimgd on 24.06.2023.
//

#ifndef NetworkCommunication_h
#define NetworkCommunication_h

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>

@interface NetworkCommunication : NSObject <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;

- (void)connect;
- (void)dispatch:(NSDictionary *)payload;
- (void)disconnect;

@end

#endif /* NetworkCommunication_h */
