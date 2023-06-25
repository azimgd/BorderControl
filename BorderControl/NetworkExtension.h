//
//  NetworkExtension.h
//  BorderControl
//
//  Created by azimgd on 13.06.2023.
//

#ifndef NetworkExtension_h
#define NetworkExtension_h

#import <NetworkExtension/NetworkExtension.h>
#import <SystemExtensions/SystemExtensions.h>

@interface NetworkExtension : NSObject<OSSystemExtensionRequestDelegate, NSXPCListenerDelegate>
  @property (class, nonatomic, readonly) NetworkExtension *shared;

  - (void)install;
@end

#endif /* NetworkExtension_h */
