//
//  main.m
//  Network
//
//  Created by azimgd on 13.06.2023.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
#import "NetworkCommunication.h"
#import "ExtensionBundle.h"

int main(int argc, char *argv[])
{
  @autoreleasepool {
    [NEProvider startSystemExtensionMode];
    NSString *machService = [[ExtensionBundle shared] extensionBundleMachService:[NSBundle mainBundle]];
    [[NetworkCommunication shared] startListener:machService callback:^(NSError *error) {
      [[NetworkCommunication shared] dispatcher:@"#1" callback:^(NSString *response) {
        NSLog(@"[border-control] dispatched correctly #1");
      }];
    }];
  }

  dispatch_main();
}
