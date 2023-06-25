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
    
    NSObject *delegate = [NSObject new];
    NetworkCommunication *sharedConnection = [NetworkCommunication shared];
    [sharedConnection
      registerWithExtension:[[ExtensionBundle shared] extensionBundle:[NSBundle mainBundle]]
      delegate:delegate
      completionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSLog(@"#bordercontrol: xpc connection was established");
          
          [[NetworkCommunication shared] logger:@"long-message-string" responseHandler:^(BOOL result) {
            NSLog(@"#bordercontrol: xpc logs were delivered");
          }];
        });
      }];
  }
  return NSApplicationMain(argc, argv);
}
