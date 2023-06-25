//
//  SecurityExtension.m
//  BorderControl
//
//  Created by azimgd on 25.06.2023.
//

#import <Foundation/Foundation.h>
#import "SecurityExtension.h"

NSString *const securityExtensionBundleId = @"B6BB88CAP5.com.azimgd.BorderControl.Security";

@implementation SecurityExtension

static SecurityExtension *sharedInstance = nil;

+ (SecurityExtension *)shared {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[SecurityExtension alloc] init];
  });
  return sharedInstance;
}

- (void)install
{
  OSSystemExtensionRequest *systemRequest = [OSSystemExtensionRequest
    activationRequestForExtension:securityExtensionBundleId
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
}

- (void)requestNeedsUserApproval:(nonnull OSSystemExtensionRequest *)request {
}

@end

