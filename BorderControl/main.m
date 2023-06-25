//
//  main.m
//  BorderControl
//
//  Created by azimgd on 13.06.2023.
//

#import <Cocoa/Cocoa.h>
#import "NetworkExtension.h"
#import "NetworkCommunication.h"
#import "ExtensionBundle.h"

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    [[NetworkExtension shared] install];
    
    NSBundle *extensionBundle = [[ExtensionBundle shared] extensionBundle:[NSBundle mainBundle]];
    NSString *machService = [[ExtensionBundle shared] extensionBundleMachService:extensionBundle];
    [[NetworkCommunication shared] startConnection:machService];

    [[NetworkCommunication shared] dispatcher:@"str" callback:^(NSString *payload) {
      NSLog(@"#machService: %@", payload);
    }];
  }
  return NSApplicationMain(argc, argv);
}
