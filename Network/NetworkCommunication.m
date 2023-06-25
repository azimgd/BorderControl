//
//  NetworkCommunication.m
//  BorderControl
//
//  Created by azimgd on 13.06.2023.
//

#import <Foundation/Foundation.h>
#import "NetworkCommunication.h"

@implementation NetworkCommunication

static NetworkCommunication *sharedInstance = nil;

+ (NetworkCommunication *)shared {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      sharedInstance = [[NetworkCommunication alloc] init];
  });
  return sharedInstance;
}

- (NSString *)extensionMachServiceNameFromBundle:(NSBundle *)bundle {
  NSDictionary *networkExtensionKeys = [bundle objectForInfoDictionaryKey:@"NetworkExtension"];
  NSString *machServiceName = networkExtensionKeys[@"NEMachServiceName"];

  if (!machServiceName) {
    @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
      reason:@"Mach service name is missing from the Info.plist"
      userInfo:nil];
  }
  return machServiceName;
}

- (void)startListener {
  NSString *machServiceName = [self extensionMachServiceNameFromBundle:NSBundle.mainBundle];
  NSXPCListener *newListener = [[NSXPCListener alloc] initWithMachServiceName:machServiceName];
  newListener.delegate = self;
  [newListener resume];
  self.listener = newListener;
}

- (void)registerWithExtension:(NSBundle *)bundle
  delegate:(id<AppCommunication>)delegate
  completionHandler:(void (^)(BOOL))completionHandler {
    self.delegate = delegate;

    if (self.currentConnection) {
      NSLog(@"Already registered with the provider");
      completionHandler(YES);
      return;
    }

    NSString *machServiceName = [self extensionMachServiceNameFromBundle:bundle];
    NSXPCConnection *newConnection = [[NSXPCConnection alloc] initWithMachServiceName:machServiceName options:0];

    // The exported object is the delegate.
    NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(AppCommunication)];
    newConnection.exportedInterface = exportedInterface;
    newConnection.exportedObject = delegate;

    // The remote object is the provider's NetworkConnection instance.
    NSXPCInterface *remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ProviderCommunication)];
    newConnection.remoteObjectInterface = remoteObjectInterface;

    self.currentConnection = newConnection;
    [newConnection resume];

    id<ProviderCommunication> providerProxy = (id<ProviderCommunication>)[
      newConnection
      remoteObjectProxyWithErrorHandler:^(NSError *registerError) {
        [self.currentConnection invalidate];
        self.currentConnection = nil;
        completionHandler(NO);
    }];

    if (!providerProxy) {
      @throw [NSException
               exceptionWithName:NSInternalInconsistencyException
               reason:@"Failed to create a remote object proxy for the provider"
               userInfo:nil];
    }
    
    [providerProxy register:^(BOOL success) {
      completionHandler(success);
    }];
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // The exported object is this NetworkConnection instance.
    NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ProviderCommunication)];
    newConnection.exportedInterface = exportedInterface;
    newConnection.exportedObject = self;

    // The remote object is the delegate of the app's NetworkConnection instance.
    NSXPCInterface *remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(AppCommunication)];
    newConnection.remoteObjectInterface = remoteObjectInterface;

    newConnection.invalidationHandler = ^{
      self.currentConnection = nil;
    };

    newConnection.interruptionHandler = ^{
      self.currentConnection = nil;
    };

    self.currentConnection = newConnection;
    [newConnection resume];

    return YES;
}

- (void)register:(void (^)(BOOL))completionHandler {
    NSLog(@"App registered");
    completionHandler(YES);
}

- (NSBundle *)extensionBundle {
  NSURL *extensionsDirectoryURL = [NSURL
                                   fileURLWithPath:@"Contents/Library/SystemExtensions"
                                   relativeToURL:[[NSBundle mainBundle] bundleURL]];
  NSArray<NSURL *> *extensionURLs;
  NSError *error;

  extensionURLs = [[NSFileManager defaultManager]
                    contentsOfDirectoryAtURL:extensionsDirectoryURL
                    includingPropertiesForKeys:nil
                    options:NSDirectoryEnumerationSkipsHiddenFiles
                    error:&error];

  if (error) {
    NSString *errorMessage = [NSString stringWithFormat:@"Failed to get the contents of %@: %@", extensionsDirectoryURL.absoluteString, error.localizedDescription];
    @throw [NSException exceptionWithName:NSGenericException reason:errorMessage userInfo:nil];
  }

  if (extensionURLs.count == 0) {
    @throw [NSException exceptionWithName:NSGenericException reason:@"Failed to find any system extensions" userInfo:nil];
  }

  NSBundle *extensionBundle = [NSBundle bundleWithURL:extensionURLs.firstObject];
  if (!extensionBundle) {
    NSString *errorMessage = [NSString stringWithFormat:@"Failed to create a bundle with URL %@", extensionURLs.firstObject.absoluteString];
    @throw [NSException exceptionWithName:NSGenericException reason:errorMessage userInfo:nil];
  }

  return extensionBundle;
}

- (BOOL)logger:(NSString *)payload responseHandler:(void (^)(BOOL))responseHandler {
  if (!self.currentConnection) {
    NSLog(@"Cannot prompt user because the app isn't registered");
    return NO;
  }
  
  id<AppCommunication> appProxy = (id<AppCommunication>)[self.currentConnection remoteObjectProxyWithErrorHandler:^(NSError *promptError) {
    NSLog(@"Failed to prompt the user: %@", promptError.localizedDescription);
    self.currentConnection = nil;
    responseHandler(YES);
  }];

  if (!appProxy) {
    @throw [NSException
             exceptionWithName:NSInternalInconsistencyException
             reason:@"Failed to create a remote object proxy for the app"
             userInfo:nil];
  }

  responseHandler(YES);
  
  return YES;
}

@end
