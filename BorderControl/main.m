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
    [[NetworkCommunication shared] startConnection:machService callback:^(NSError *error) {
      [[NetworkCommunication shared] dispatcher:@"payload" callback:^(NSString *payload) {
        NSLog(@"#machService: host callback return %@", payload);
      }];
    }];
  }
  return NSApplicationMain(argc, argv);
}
