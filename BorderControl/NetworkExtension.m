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
  
  NSLog(@"[#bordercontrol] %@", extensionBundleId);
}

#pragma OSSystemExtensionRequestDelegate

- (OSSystemExtensionReplacementAction)request:(nonnull OSSystemExtensionRequest *)request
  actionForReplacingExtension:(nonnull OSSystemExtensionProperties *)existing
  withExtension:(nonnull OSSystemExtensionProperties *)ext
{
  NSLog(@"[#bordercontrol] -> network filter activation requested");

  return OSSystemExtensionReplacementActionReplace;
}

- (void)request:(nonnull OSSystemExtensionRequest *)request
  didFailWithError:(nonnull NSError *)error
{
  NSLog(@"[#bordercontrol] -> network filter activation request failed %@", error);
}

- (void)request:(nonnull OSSystemExtensionRequest *)request didFinishWithResult:(OSSystemExtensionRequestResult)result
{
  NSLog(@"[#bordercontrol] -> network filter activation completed");
  
  [NEFilterManager.sharedManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
    if (nil != error && YES != [NSProcessInfo.processInfo.arguments containsObject:@"-json"])
    {
      NSLog(@"[#bordercontrol] -> network filter extension settings fetch failed");
    } else {
      NSLog(@"[#bordercontrol] -> network filter extension settings fetch succeeded");
    }
    
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
      if (nil != error && YES != [NSProcessInfo.processInfo.arguments containsObject:@"-json"]) {
        NSLog(@"[#bordercontrol] -> network filter extension settings save failed");
      } else {
        NSLog(@"[#bordercontrol] -> network filter extension settings save succeeded");
      }
    }];
  }];
}

- (void)requestNeedsUserApproval:(nonnull OSSystemExtensionRequest *)request {
  NSLog(@"[#bordercontrol] -> network filter extension approval finished");
}

@end
