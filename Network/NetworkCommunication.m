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

- (void)register:(void (^)(BOOL))completionHandler {
  completionHandler(YES);
}

- (void)startListener {
  NSString *machServiceName = [[ExtensionBundle shared] extensionBundleMachService:[NSBundle mainBundle]];
  NSXPCListener *newListener = [[NSXPCListener alloc] initWithMachServiceName:machServiceName];
  newListener.delegate = self;
  [newListener resume];
  self.listener = newListener;
}

- (void)registerWithExtension:(NSBundle *)bundle
  delegate:(id<HostCommunication>)delegate
  completionHandler:(void (^)(BOOL))completionHandler {
  self.delegate = delegate;

  if (self.connection) {
    completionHandler(YES);
    return;
  }

  NSString *machServiceName = [[ExtensionBundle shared] extensionBundleMachService:bundle];
  NSXPCConnection *newConnection = [[NSXPCConnection alloc] initWithMachServiceName:machServiceName options:0];

  // The exported object is the delegate.
  NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HostCommunication)];
  newConnection.exportedInterface = exportedInterface;
  newConnection.exportedObject = delegate;

  // The remote object is the provider's NetworkConnection instance.
  NSXPCInterface *remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ExtensionCommunication)];
  newConnection.remoteObjectInterface = remoteObjectInterface;

  self.connection = newConnection;
  [newConnection resume];

  id<ExtensionCommunication> extensionCommunication = (id<ExtensionCommunication>)[
    newConnection
    remoteObjectProxyWithErrorHandler:^(NSError *error) {
      [self.connection invalidate];
      self.connection = nil;
      completionHandler(NO);
  }];

  if (!extensionCommunication) {
    @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
      reason:@"Failed to create a remote object proxy for the provider"
      userInfo:nil];
  }
  
  [extensionCommunication register:^(BOOL success) {
    completionHandler(success);
  }];
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
  // The exported object is this NetworkConnection instance.
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

- (BOOL)logger:(NSString *)payload responseHandler:(void (^)(BOOL))responseHandler {
  if (!self.connection) {
    return NO;
  }
  
  id<HostCommunication> hostCommunication = (id<HostCommunication>)[
    self.connection
    remoteObjectProxyWithErrorHandler:^(NSError *error) {
    [self.connection invalidate];
    self.connection = nil;
    responseHandler(NO);
  }];

  if (!hostCommunication) {
    @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
      reason:@"Failed to create a remote object proxy for the app"
      userInfo:nil];
  }

  [hostCommunication register:^(BOOL success) {
    [self.delegate register:^(BOOL success) {
      responseHandler(success);
    }];
  }];
  
  return YES;
}

@end
