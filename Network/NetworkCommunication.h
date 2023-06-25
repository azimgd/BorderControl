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

@protocol AppCommunication <NSObject>
  - (void)register:(void (^)(BOOL))completionHandler;
@end

@protocol ProviderCommunication <NSObject>
  - (void)register:(void (^)(BOOL))completionHandler;
@end

@interface NetworkCommunication : NSObject<NSXPCListenerDelegate>

@property (nonatomic, strong) NSXPCListener *listener;
@property (nonatomic, strong) NSXPCConnection *currentConnection;
@property (nonatomic, weak) id<AppCommunication> delegate;
@property (class, nonatomic, readonly) NetworkCommunication *shared;

- (NSString *)extensionMachServiceNameFromBundle:(NSBundle *)bundle;

- (void)startListener;

- (void)registerWithExtension:(NSBundle *)bundle
  delegate:(id<AppCommunication>)delegate
  completionHandler:(void (^)(BOOL))completionHandler;

- (BOOL)logger:(NSString *)payload
  responseHandler:(void (^)(BOOL))responseHandler;

- (NSBundle *)extensionBundle;

@end


#endif /* NetworkCommunication_h */
