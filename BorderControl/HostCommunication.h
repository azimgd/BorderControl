//
//  HostCommunication.h
//  BorderControl
//
//  Created by azimgd on 24.06.2023.
//

#ifndef HostCommunication_h
#define HostCommunication_h

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>

@interface HostCommunication : NSObject <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;

- (void)connect;
- (void)dispatch:(NSDictionary *)payload;
- (void)disconnect;

@end

#endif /* HostCommunication_h */
