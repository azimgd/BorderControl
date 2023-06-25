//
//  NetworkCommunication.h
//  BorderControl
//
//  Created by azimgd on 13.06.2023.
//

#ifndef NetworkCommunication_h
#define NetworkCommunication_h

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
#import "NetworkCommunication.h"

// From Extension to Host
@protocol HostCommunication <NSObject>
  - (void)remoteDispatcher:(void (^)(NSString *))callback;
@end

// From Host to Extension
@protocol ExtensionCommunication <NSObject>
  - (void)remoteDispatcher:(void (^)(NSString *))callback;
@end

@interface NetworkCommunication : NSObject<NSXPCListenerDelegate>

@property (nonatomic, strong) NSXPCListener *listener;
@property (nonatomic, strong) NSXPCConnection *connection;
@property (class, nonatomic, readonly) NetworkCommunication *shared;
@property (nonatomic, copy) void (^startListenerCallback)(NSError *);

- (void)startListener:(NSString *)machService callback:(void (^)(NSError *))callback;

- (void)startConnection:(NSString *)machService callback:(void (^)(NSError *))callback;

- (void)dispatcher:(NSString *)payload callback:(void (^)(NSString *))callback;

@end


#endif /* NetworkCommunication_h */
