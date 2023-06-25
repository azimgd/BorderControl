//
//  NetworkCommunication.m
//  BorderControl
//
//  Created by azimgd on 13.06.2023.
//

#import <Foundation/Foundation.h>
#import "NetworkCommunication.h"
#import "ExtensionBundle.h"

@implementation NetworkCommunication

static NetworkCommunication *sharedInstance = nil;

+ (NetworkCommunication *)shared {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[NetworkCommunication alloc] init];
  });
  return sharedInstance;
}

- (void)remoteDispatcher:(void (^)(BOOL))completionHandler {
  completionHandler(YES);
}

- (void)startListener {
  NSString *machServiceName = [[ExtensionBundle shared] extensionBundleMachService:[NSBundle mainBundle]];
  NSXPCListener *newListener = [[NSXPCListener alloc] initWithMachServiceName:machServiceName];
  newListener.delegate = self;
  [newListener resume];
  self.listener = newListener;
}

- (void)startConnection:(NSBundle *)bundle {
  if (self.connection) {
    @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
      reason:@"Remote proxy connection has not been configured"
      userInfo:nil];
  }

  NSString *machServiceName = [[ExtensionBundle shared] extensionBundleMachService:bundle];
  NSXPCConnection *newConnection = [[NSXPCConnection alloc] initWithMachServiceName:machServiceName options:0];

  // The exported object is the delegate.
  NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HostCommunication)];
  newConnection.exportedInterface = exportedInterface;
  newConnection.exportedObject = self;

  // The remote object is the extenion's NetworkCommunication instance.
  NSXPCInterface *remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ExtensionCommunication)];
  newConnection.remoteObjectInterface = remoteObjectInterface;

  self.connection = newConnection;
  [newConnection resume];

  id<ExtensionCommunication> extensionCommunication = (id<ExtensionCommunication>)[
    newConnection
    remoteObjectProxyWithErrorHandler:^(NSError *error) {
      [self.connection invalidate];
      self.connection = nil;
  }];

  if (!extensionCommunication) {
    @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
      reason:@"Failed to create a remote object proxy for the extension"
      userInfo:nil];
  }
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
  // The exported object is this NetworkCommunication instance.
  NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ExtensionCommunication)];
  newConnection.exportedInterface = exportedInterface;
  newConnection.exportedObject = self;

  // The remote object is the delegate of the app's NetworkConnection instance.
  NSXPCInterface *remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HostCommunication)];
  newConnection.remoteObjectInterface = remoteObjectInterface;

  newConnection.invalidationHandler = ^{
    self.connection = nil;
  };

  newConnection.interruptionHandler = ^{
    self.connection = nil;
  };

  self.connection = newConnection;
  [newConnection resume];

  return YES;
}

- (BOOL)dispatcher:(NSString *)payload {
  if (!self.connection) {
    NSLog(@"Cannot dispatch user because the app isn't registered");
    return NO;
  }
  
  id<HostCommunication> hostCommunication = (id<HostCommunication>)[
    self.connection
    remoteObjectProxyWithErrorHandler:^(NSError *error) {

    [self.connection invalidate];
    self.connection = nil;
  }];

  if (!hostCommunication) {
    @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
      reason:@"Failed to create a remote object proxy for the app"
      userInfo:nil];
  }

  [hostCommunication remoteDispatcher:^(BOOL success) {}];

  return YES;
}

@end
