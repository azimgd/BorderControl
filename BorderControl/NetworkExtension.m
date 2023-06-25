//
//  NetworkExtension.m
//  BorderControl
//
//  Created by azimgd on 13.06.2023.
//

#import <Foundation/Foundation.h>
#import "NetworkExtension.h"
#import "ExtensionBundle.h"

@implementation NetworkExtension

static NetworkExtension *sharedInstance = nil;

+ (NetworkExtension *)shared {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[NetworkExtension alloc] init];
  });
  return sharedInstance;
}

- (void)install
{
  NSString *extensionBundleId = [[ExtensionBundle shared] extensionBundle:[NSBundle mainBundle]].bundleIdentifier;
  
  OSSystemExtensionRequest *systemRequest = [OSSystemExtensionRequest
    activationRequestForExtension:extensionBundleId
    queue:dispatch_get_main_queue()
  ];
  
  systemRequest.delegate = self;
  [OSSystemExtensionManager.sharedManager submitRequest:systemRequest];
}

#pragma OSSystemExtensionRequestDelegate

- (OSSystemExtensionReplacementAction)request:(nonnull OSSystemExtensionRequest *)request
  actionForReplacingExtension:(nonnull OSSystemExtensionProperties *)existing
  withExtension:(nonnull OSSystemExtensionProperties *)ext
{
  return OSSystemExtensionReplacementActionReplace;
}

- (void)request:(nonnull OSSystemExtensionRequest *)request
  didFailWithError:(nonnull NSError *)error
{
}

- (void)request:(nonnull OSSystemExtensionRequest *)request didFinishWithResult:(OSSystemExtensionRequestResult)result
{
  [NEFilterManager.sharedManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
    NSString *extensionBundleId = [[ExtensionBundle shared] extensionBundle:[NSBundle mainBundle]].bundleIdentifier;

    NEFilterProviderConfiguration* configuration = [[NEFilterProviderConfiguration alloc] init];
    configuration.filterPackets = false;
    configuration.filterDataProviderBundleIdentifier = extensionBundleId;
    configuration.filterSockets = true;
    configuration.filterPacketProviderBundleIdentifier = extensionBundleId;
    
    NEFilterManager.sharedManager.localizedDescription = extensionBundleId;
    NEFilterManager.sharedManager.enabled = true;
    NEFilterManager.sharedManager.providerConfiguration = configuration;

    [NEFilterManager.sharedManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
    }];
  }];
}

- (void)requestNeedsUserApproval:(nonnull OSSystemExtensionRequest *)request {
}

@end
