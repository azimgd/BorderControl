//
//  SecurityCommunication.h
//  Security
//
//  Created by azimgd on 24.06.2023.
//

#ifndef SecurityCommunication_h
#define SecurityCommunication_h

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>

@interface SecurityCommunication : NSObject <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;

- (void)connect;
- (void)dispatch:(NSDictionary *)payload;
- (void)disconnect;

@end

#endif /* SecurityCommunication_h */
